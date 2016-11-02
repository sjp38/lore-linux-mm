Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 522236B02A1
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 01:17:37 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ro13so2757345pac.7
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 22:17:37 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id q5si745098pgh.39.2016.11.01.22.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Nov 2016 22:17:36 -0700 (PDT)
Date: Tue, 1 Nov 2016 23:17:33 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 0/21 v4] dax: Clear dirty bits after flushing caches
Message-ID: <20161102051733.GA3821@linux.intel.com>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478039794-20253-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Tue, Nov 01, 2016 at 11:36:06PM +0100, Jan Kara wrote:
> Hello,
> 
> this is the fourth revision of my patches to clear dirty bits from radix tree
> of DAX inodes when caches for corresponding pfns have been flushed. This patch
> set is significantly larger than the previous version because I'm changing how
> ->fault, ->page_mkwrite, and ->pfn_mkwrite handlers may choose to handle the
> fault so that we don't have to leak details about DAX locking into the generic
> code. In principle, these patches enable handlers to easily update PTEs and do
> other work necessary to finish the fault without duplicating the functionality
> present in the generic code. I'd be really like feedback from mm folks whether
> such changes to fault handling code are fine or what they'd do differently.
> 
> The patches are based on 4.9-rc1 + Ross' DAX PMD page fault series [1] + ext4
> conversion of DAX IO patch to the iomap infrastructure [2]. For testing,
> I've pushed out a tree including all these patches and further DAX fixes
> to:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs.git dax

In my testing I hit what I believe to be a new lockdep splat.  This was
produced with ext4+dax+generic/246, though I've tried several times to
reproduce it and haven't been able.  This testing was done with your tree plus
one patch to fix the DAX PMD recursive fallback issue that you reported.  This
new patch is folded into v9 of my PMD series that I sent out earlier today.

I've posted the tree I was testing with here:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=jan_dax

Here is the lockdep splat, passed through kasan_symbolize:

run fstests generic/246 at 2016-11-01 21:51:34

======================================================
[ INFO: possible circular locking dependency detected ]
4.9.0-rc1-00165-g13826b5 #2 Not tainted
-------------------------------------------------------
t_mmap_writev/13704 is trying to acquire lock:
 ([ 3522.320075] &ei->i_mmap_sem
){++++.+}[ 3522.320924] , at:
[<ffffffff8133ef06>] ext4_dax_fault+0x36/0xd0 fs/ext4/file.c:267

but task is already holding lock:
 ([ 3522.324135] jbd2_handle
){++++.+}[ 3522.324875] , at:
[<ffffffff813a48b0>] start_this_handle+0x110/0x440 fs/jbd2/transaction.c:361

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1[ 3522.330384]  (
jbd2_handle[ 3522.330889] ){++++.+}
:
       [<ffffffff8110efa2>] lock_acquire+0xf2/0x1e0 kernel/locking/lockdep.c:3746
       [<ffffffff813a4914>] start_this_handle+0x174/0x440 fs/jbd2/transaction.c:389
       [<ffffffff813a4ecb>] jbd2__journal_start+0xdb/0x290 fs/jbd2/transaction.c:457
       [<ffffffff8137c989>] __ext4_journal_start_sb+0x89/0x1d0 fs/ext4/ext4_jbd2.c:76
       [<     inline     >] __ext4_journal_start fs/ext4/ext4_jbd2.h:318
       [<ffffffff8137370f>] ext4_alloc_file_blocks.isra.34+0xef/0x310 fs/ext4/extents.c:4701
       [<     inline     >] ext4_zero_range fs/ext4/extents.c:4850
       [<ffffffff8137bfa4>] ext4_fallocate+0x974/0xae0 fs/ext4/extents.c:4952
       [<ffffffff81292a8a>] vfs_fallocate+0x15a/0x230 fs/open.c:320
       [<     inline     >] SYSC_fallocate fs/open.c:343
       [<ffffffff812938e4>] SyS_fallocate+0x44/0x70 fs/open.c:337
       [<ffffffff81b3d501>] entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:209

-> #0[ 3522.342547]  (
&ei->i_mmap_sem[ 3522.343023] ){++++.+}
:
       [<     inline     >] check_prev_add kernel/locking/lockdep.c:1829
       [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1939
       [<     inline     >] validate_chain kernel/locking/lockdep.c:2266
       [<ffffffff8110e89f>] __lock_acquire+0x127f/0x14d0 kernel/locking/lockdep.c:3335
       [<ffffffff8110efa2>] lock_acquire+0xf2/0x1e0 kernel/locking/lockdep.c:3746
       [<ffffffff81b39b7e>] down_read+0x3e/0xa0 kernel/locking/rwsem.c:22
       [<ffffffff8133ef06>] ext4_dax_fault+0x36/0xd0 fs/ext4/file.c:267
       [<ffffffff8122f9d1>] __do_fault+0x21/0x130 mm/memory.c:2872
       [<     inline     >] do_read_fault mm/memory.c:3231
       [<     inline     >] do_fault mm/memory.c:3333
       [<     inline     >] handle_pte_fault mm/memory.c:3534
       [<     inline     >] __handle_mm_fault mm/memory.c:3624
       [<ffffffff812348ae>] handle_mm_fault+0x114e/0x1550 mm/memory.c:3661
       [<ffffffff8106bc27>] __do_page_fault+0x247/0x4f0 arch/x86/mm/fault.c:1397
       [<ffffffff8106bfad>] trace_do_page_fault+0x5d/0x290 arch/x86/mm/fault.c:1490
       [<ffffffff81065dba>] do_async_page_fault+0x1a/0xa0 arch/x86/kernel/kvm.c:265
       [<ffffffff81b3ea08>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1015
       [<     inline     >] arch_copy_from_iter_pmem ./arch/x86/include/asm/pmem.h:95
       [<     inline     >] copy_from_iter_pmem ./include/linux/pmem.h:118
       [<ffffffff812f4a27>] dax_iomap_actor+0x147/0x270 fs/dax.c:1027
       [<ffffffff8130c513>] iomap_apply+0xb3/0x130 fs/iomap.c:78
       [<ffffffff812f46d6>] dax_iomap_rw+0x76/0xa0 fs/dax.c:1067
       [<     inline     >] ext4_dax_write_iter fs/ext4/file.c:196
       [<ffffffff8133fb13>] ext4_file_write_iter+0x243/0x340 fs/ext4/file.c:217
       [<ffffffff812957d1>] do_iter_readv_writev+0xb1/0x130 fs/read_write.c:695
       [<ffffffff81296384>] do_readv_writev+0x1a4/0x250 fs/read_write.c:872
       [<ffffffff8129668f>] vfs_writev+0x3f/0x50 fs/read_write.c:911
       [<ffffffff81296704>] do_writev+0x64/0x100 fs/read_write.c:944
       [<     inline     >] SYSC_writev fs/read_write.c:1017
       [<ffffffff81297900>] SyS_writev+0x10/0x20 fs/read_write.c:1014
       [<ffffffff81b3d501>] entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:209

other info that might help us debug this:

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock([ 3522.369967] jbd2_handle
);
                               lock([ 3522.371437] &ei->i_mmap_sem
);
                               lock([ 3522.372912] jbd2_handle
);
  lock([ 3522.373903] &ei->i_mmap_sem
);

 *** DEADLOCK ***

4 locks held by t_mmap_writev/13704:
 #0: [ 3522.376722]  (
sb_writers[ 3522.377174] #15
){++++.+}[ 3522.377632] , at:
[<     inline     >] file_start_write ./include/linux/fs.h:2592
[<ffffffff812963ec>] do_readv_writev+0x20c/0x250 fs/read_write.c:868
 #1: [ 3522.379225]  (
&sb->s_type->i_mutex_key[ 3522.379876] #20
){++++++}[ 3522.380327] , at:
[<     inline     >] inode_lock ./include/linux/fs.h:740
[<     inline     >] ext4_dax_write_iter fs/ext4/file.c:181
[<ffffffff8133faa6>] ext4_file_write_iter+0x1d6/0x340 fs/ext4/file.c:217
 #2: [ 3522.382013]  (
jbd2_handle[ 3522.382486] ){++++.+}
, at: [ 3522.382980] [<ffffffff813a48b0>] start_this_handle+0x110/0x440
 #3: [ 3522.384263]  (
&mm->mmap_sem[ 3522.384757] ){++++++}
, at: [ 3522.385251] [<ffffffff8106bb44>] __do_page_fault+0x164/0x4f0

stack backtrace:
CPU: 0 PID: 13704 Comm: t_mmap_writev Not tainted 4.9.0-rc1-00165-g13826b5 #2
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
 ffffc9000a223720 ffffffff815f5773 ffffffff82f78170 ffffffff82f78170
 ffffc9000a223760 ffffffff8110bc03 ffffc9000a2237b0 ffff880310e5da58
 ffff880310e5d100 0000000000000004 ffff880310e5d9e8 0000000000000003
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff815f5773>] dump_stack+0x85/0xc2 lib/dump_stack.c:51
 [<ffffffff8110bc03>] print_circular_bug+0x1e3/0x250 kernel/locking/lockdep.c:1202
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1829
 [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1939
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2266
 [<ffffffff8110e89f>] __lock_acquire+0x127f/0x14d0 kernel/locking/lockdep.c:3335
 [<ffffffff8110efa2>] lock_acquire+0xf2/0x1e0 kernel/locking/lockdep.c:3746
 [<ffffffff81b39b7e>] down_read+0x3e/0xa0 kernel/locking/rwsem.c:22
 [<ffffffff8133ef06>] ext4_dax_fault+0x36/0xd0 fs/ext4/file.c:267
 [<ffffffff8122f9d1>] __do_fault+0x21/0x130 mm/memory.c:2872
 [<     inline     >] do_read_fault mm/memory.c:3231
 [<     inline     >] do_fault mm/memory.c:3333
 [<     inline     >] handle_pte_fault mm/memory.c:3534
 [<     inline     >] __handle_mm_fault mm/memory.c:3624
 [<ffffffff812348ae>] handle_mm_fault+0x114e/0x1550 mm/memory.c:3661
 [<ffffffff8106bc27>] __do_page_fault+0x247/0x4f0 arch/x86/mm/fault.c:1397
 [<ffffffff8106bfad>] trace_do_page_fault+0x5d/0x290 arch/x86/mm/fault.c:1490
 [<ffffffff81065dba>] do_async_page_fault+0x1a/0xa0 arch/x86/kernel/kvm.c:265
 [<ffffffff81b3ea08>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1015
 [<     inline     >] arch_copy_from_iter_pmem ./arch/x86/include/asm/pmem.h:95
 [<     inline     >] copy_from_iter_pmem ./include/linux/pmem.h:118
 [<ffffffff812f4a27>] dax_iomap_actor+0x147/0x270 fs/dax.c:1027
 [<ffffffff8130c513>] iomap_apply+0xb3/0x130 fs/iomap.c:78
 [<ffffffff812f46d6>] dax_iomap_rw+0x76/0xa0 fs/dax.c:1067
 [<     inline     >] ext4_dax_write_iter fs/ext4/file.c:196
 [<ffffffff8133fb13>] ext4_file_write_iter+0x243/0x340 fs/ext4/file.c:217
 [<ffffffff812957d1>] do_iter_readv_writev+0xb1/0x130 fs/read_write.c:695
 [<ffffffff81296384>] do_readv_writev+0x1a4/0x250 fs/read_write.c:872
 [<ffffffff8129668f>] vfs_writev+0x3f/0x50 fs/read_write.c:911
 [<ffffffff81296704>] do_writev+0x64/0x100 fs/read_write.c:944
 [<     inline     >] SYSC_writev fs/read_write.c:1017
 [<ffffffff81297900>] SyS_writev+0x10/0x20 fs/read_write.c:1014
 [<ffffffff81b3d501>] entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:209

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
