Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 811826B007E
	for <linux-mm@kvack.org>; Thu,  5 May 2016 23:35:09 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id xm6so141001483pab.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 20:35:09 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id lx17si15420398pab.66.2016.05.05.20.35.08
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 20:35:08 -0700 (PDT)
Date: Thu, 5 May 2016 21:35:07 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC v3] [PATCH 0/18] DAX page fault locking
Message-ID: <20160506033507.GA26154@linux.intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461015341-20153-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Mon, Apr 18, 2016 at 11:35:23PM +0200, Jan Kara wrote:
> Hello,
> 
> this is my third attempt at DAX page fault locking rewrite. The patch set has
> passed xfstests both with and without DAX mount option on ext4 and xfs for
> me and also additional page fault beating using the new page fault stress
> tests I have added to xfstests. So I'd be grateful if you guys could have a
> closer look at the patches so that they can be merged. Thanks.
> 
> Changes since v2:
> - lot of additional ext4 fixes and cleanups
> - make PMD page faults depend on CONFIG_BROKEN instead of #if 0
> - fixed page reference leak when replacing hole page with a pfn
> - added some reviewed-by tags
> - rebased on top of current Linus' tree
> 
> Changes since v1:
> - handle wakeups of exclusive waiters properly
> - fix cow fault races
> - other minor stuff
> 
> General description
> 
> The basic idea is that we use a bit in an exceptional radix tree entry as
> a lock bit and use it similarly to how page lock is used for normal faults.
> That way we fix races between hole instantiation and read faults of the
> same index. For now I have disabled PMD faults since there the issues with
> page fault locking are even worse. Now that Matthew's multi-order radix tree
> has landed, I can have a look into using that for proper locking of PMD faults
> but first I want normal pages sorted out.
> 
> In the end I have decided to implement the bit locking directly in the DAX
> code. Originally I was thinking we could provide something generic directly
> in the radix tree code but the functions DAX needs are rather specific.
> Maybe someone else will have a good idea how to distill some generally useful
> functions out of what I've implemented for DAX but for now I didn't bother
> with that.
> 
> 								Honza

Hey Jan,

I've been testing with this a bit today, and I hit the following issue with
generic/231.  I was able to reproduce it 100% of the time with both ext4 and
XFS.

Here's the test:

# ./check generic/231
FSTYP         -- ext4
PLATFORM      -- Linux/x86_64 lorwyn 4.6.0-rc5+
MKFS_OPTIONS  -- /dev/pmem0p2
MOUNT_OPTIONS -- -o dax -o context=system_u:object_r:nfs_t:s0 /dev/pmem0p2 /mnt/xfstests_scratch

generic/231 28s ..../check: line 542:  1545 Segmentation fault      ./$seq > $tmp.rawout 2>&1
 [failed, exit status 139] - output mismatch (see /root/xfstests/results//generic/231.out.bad)
    --- tests/generic/231.out	2016-01-12 09:24:26.420085531 -0700
    +++ /root/xfstests/results//generic/231.out.bad	2016-05-05 21:25:18.629675139 -0600
    @@ -1,16 +1,3 @@
     Qe output created by 231
     === FSX Standard Mode, Memory Mapping, 1 Tasks ===
     All 20000 operations completed A-OK!
    -Comparing user usage
    -Comparing group usage
    -=== FSX Standard Mode, Memory Mapping, 4 Tasks ===
    -All 20000 operations completed A-OK!
    ...
    (Run 'diff -u tests/generic/231.out /root/xfstests/results//generic/231.out.bad'  to see the entire diff)

And the log, passed through kasan_symbolize.py:

t mm/workingset.c:423!
invalid opcode: 0000 [#1] SMP
Modules linked in: nd_pmem nd_btt nd_e820 libnvdimm
CPU: 1 PID: 1545 Comm: 231 Not tainted 4.6.0-rc5+ #1
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
task: ffff880505853180 ti: ffff880504f08000 task.ti: ffff880504f08000
RIP: 0010:[<ffffffff81207b93>]  [<ffffffff81207b93>] shadow_lru_isolate+0x183/0x1a0
RSP: 0018:ffff880504f0bbe8  EFLAGS: 00010006
RAX: ffff880094f304b8 RBX: ffff880094f304a8 RCX: ffff880094f306b8
RDX: 0000000000000077 RSI: 0000000000000000 RDI: ffff8800b8483000
RBP: ffff880504f0bc10 R08: 0000000000000004 R09: 0000000000000000
R10: ffff88009ba51ec8 R11: 0000000000000080 R12: ffff8800b8483000
R13: ffff88009ba51eb0 R14: ffff88009ba51e98 R15: ffff8800b8483048
FS:  00007f3332e14700(0000) GS:ffff88051a200000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f3332e2c000 CR3: 000000051425c000 CR4: 00000000000006e0
Stack:
 ffff8800b8483000 ffff8800b8483048 ffff880504f0bd18 ffff880094f11b78
 ffff880094f304a8 ffff880504f0bc60 ffffffff81206c7f 0000000000000000
 0000000000000000 ffffffff81207a10 ffff880504f0bd10 0000000000000000
Call Trace:
 [<ffffffff81206c7f>] __list_lru_walk_one.isra.3+0x9f/0x150 mm/list_lru.c:223
 [<ffffffff81206d53>] list_lru_walk_one+0x23/0x30 mm/list_lru.c:263
 [<     inline     >] list_lru_shrink_walk include/linux/list_lru.h:170
 [<ffffffff81207bea>] scan_shadow_nodes+0x3a/0x50 mm/workingset.c:457
 [<     inline     >] do_shrink_slab mm/vmscan.c:344
 [<ffffffff811ea37e>] shrink_slab.part.40+0x1fe/0x420 mm/vmscan.c:442
 [<ffffffff811ea5c9>] shrink_slab+0x29/0x30 mm/vmscan.c:406
 [<ffffffff811ec831>] drop_slab_node+0x31/0x60 mm/vmscan.c:460
 [<ffffffff811ec89f>] drop_slab+0x3f/0x70 mm/vmscan.c:471
 [<ffffffff812d8c39>] drop_caches_sysctl_handler+0x69/0xb0 fs/drop_caches.c:58
 [<ffffffff812f2937>] proc_sys_call_handler+0xe7/0x100 fs/proc/proc_sysctl.c:543
 [<ffffffff812f2964>] proc_sys_write+0x14/0x20 fs/proc/proc_sysctl.c:561
 [<ffffffff81269aa7>] __vfs_write+0x37/0x120 fs/read_write.c:529
 [<ffffffff8126a3fc>] vfs_write+0xac/0x1a0 fs/read_write.c:578
 [<     inline     >] SYSC_write fs/read_write.c:625
 [<ffffffff8126b8d8>] SyS_write+0x58/0xd0 fs/read_write.c:617
 [<ffffffff81a92a3c>] entry_SYSCALL_64_fastpath+0x1f/0xbd arch/x86/entry/entry_64.S:207
Code: 66 90 66 66 90 e8 4e 53 88 00 fa 66 66 90 66 66 90 e8 52 5c ef ff 4c 89 e7 e8 ba a1 88 00 89 d8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 <0f> 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 0f 0b 66 66 66 66 66 66 2e
RIP  [<ffffffff81207b93>] shadow_lru_isolate+0x183/0x1a0 mm/workingset.c:448
 RSP <ffff880504f0bbe8>
---[ end trace 8e4a52e5c9e07c83 ]---

This passes 100% of the time with my baseline, which was just v4.6-rc5.

For convenience I've pushed a working tree of what I was testing here:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=jan_testing

My setup is just a pair of PMEM ramdisks for my test device and scratch device.
Let me know if you have any trouble reproducing this result.

Thanks,
- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
