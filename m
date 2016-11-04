Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2ACBB280289
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 14:15:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r68so21785558wmd.0
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 11:15:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id tr13si16643777wjb.191.2016.11.04.11.15.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Nov 2016 11:15:04 -0700 (PDT)
Date: Fri, 4 Nov 2016 19:14:59 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 0/21 v4] dax: Clear dirty bits after flushing caches
Message-ID: <20161104181459.GB6650@quack2.suse.cz>
References: <1478039794-20253-1-git-send-email-jack@suse.cz>
 <20161102051733.GA3821@linux.intel.com>
 <20161104044648.GB3569@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161104044648.GB3569@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>

On Fri 04-11-16 05:46:48, Jan Kara wrote:
> On Tue 01-11-16 23:17:33, Ross Zwisler wrote:
> > On Tue, Nov 01, 2016 at 11:36:06PM +0100, Jan Kara wrote:
> > > Hello,
> > > 
> > > this is the fourth revision of my patches to clear dirty bits from radix tree
> > > of DAX inodes when caches for corresponding pfns have been flushed. This patch
> > > set is significantly larger than the previous version because I'm changing how
> > > ->fault, ->page_mkwrite, and ->pfn_mkwrite handlers may choose to handle the
> > > fault so that we don't have to leak details about DAX locking into the generic
> > > code. In principle, these patches enable handlers to easily update PTEs and do
> > > other work necessary to finish the fault without duplicating the functionality
> > > present in the generic code. I'd be really like feedback from mm folks whether
> > > such changes to fault handling code are fine or what they'd do differently.
> > > 
> > > The patches are based on 4.9-rc1 + Ross' DAX PMD page fault series [1] + ext4
> > > conversion of DAX IO patch to the iomap infrastructure [2]. For testing,
> > > I've pushed out a tree including all these patches and further DAX fixes
> > > to:
> > > 
> > > git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs.git dax
> > 
> > In my testing I hit what I believe to be a new lockdep splat.  This was
> > produced with ext4+dax+generic/246, though I've tried several times to
> > reproduce it and haven't been able.  This testing was done with your tree plus
> > one patch to fix the DAX PMD recursive fallback issue that you reported.  This
> > new patch is folded into v9 of my PMD series that I sent out earlier today.
> > 
> > I've posted the tree I was testing with here:
> > 
> > https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=jan_dax
> > 
> > Here is the lockdep splat, passed through kasan_symbolize:
> > 
> > run fstests generic/246 at 2016-11-01 21:51:34
> > 
> > ======================================================
> > [ INFO: possible circular locking dependency detected ]
> > 4.9.0-rc1-00165-g13826b5 #2 Not tainted
> > -------------------------------------------------------
> > t_mmap_writev/13704 is trying to acquire lock:
> >  ([ 3522.320075] &ei->i_mmap_sem
> > ){++++.+}[ 3522.320924] , at:
> > [<ffffffff8133ef06>] ext4_dax_fault+0x36/0xd0 fs/ext4/file.c:267
> 
> Interesting, I didn't see this in my testing.
> 
> > -> #0[ 3522.342547]  (
> > &ei->i_mmap_sem[ 3522.343023] ){++++.+}
> > :
> >        [<     inline     >] check_prev_add kernel/locking/lockdep.c:1829
> >        [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1939
> >        [<     inline     >] validate_chain kernel/locking/lockdep.c:2266
> >        [<ffffffff8110e89f>] __lock_acquire+0x127f/0x14d0 kernel/locking/lockdep.c:3335
> >        [<ffffffff8110efa2>] lock_acquire+0xf2/0x1e0 kernel/locking/lockdep.c:3746
> >        [<ffffffff81b39b7e>] down_read+0x3e/0xa0 kernel/locking/rwsem.c:22
> >        [<ffffffff8133ef06>] ext4_dax_fault+0x36/0xd0 fs/ext4/file.c:267
> >        [<ffffffff8122f9d1>] __do_fault+0x21/0x130 mm/memory.c:2872
> >        [<     inline     >] do_read_fault mm/memory.c:3231
> >        [<     inline     >] do_fault mm/memory.c:3333
> >        [<     inline     >] handle_pte_fault mm/memory.c:3534
> >        [<     inline     >] __handle_mm_fault mm/memory.c:3624
> >        [<ffffffff812348ae>] handle_mm_fault+0x114e/0x1550 mm/memory.c:3661
> >        [<ffffffff8106bc27>] __do_page_fault+0x247/0x4f0 arch/x86/mm/fault.c:1397
> >        [<ffffffff8106bfad>] trace_do_page_fault+0x5d/0x290 arch/x86/mm/fault.c:1490
> >        [<ffffffff81065dba>] do_async_page_fault+0x1a/0xa0 arch/x86/kernel/kvm.c:265
> >        [<ffffffff81b3ea08>] async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1015
> >        [<     inline     >] arch_copy_from_iter_pmem ./arch/x86/include/asm/pmem.h:95
> >        [<     inline     >] copy_from_iter_pmem ./include/linux/pmem.h:118
> >        [<ffffffff812f4a27>] dax_iomap_actor+0x147/0x270 fs/dax.c:1027
> >        [<ffffffff8130c513>] iomap_apply+0xb3/0x130 fs/iomap.c:78
> 
> So the problem is that we were doing write to a DAX file from a buffer
> which is mmapped DAX file and we took a fault when copying data from the
> buffer. That looks like a real problem. I'll have to think what to do with
> it... Thanks for report!

So the problem is in ext4 iomap conversion (i.e., not in this patch series).
The culprit is that we keep transaction handle running between
->iomap_begin() and ->iomap_end() calls. I was thinking about possible
solutions and I've found only two:

1) Add inode to orphan list when we are extending the file in
ext4_iomap_begin() and stop the current handle. Then grab a new handle in
ext4_iomap_end() and remove inode from the orphan list and update inode
size. This is what we were basically using in the original direct IO path.

2) Add a version of dax_iomap_rw() (or a flag for it) to prefault pages
before calling ->iomap_begin(), then use atomic copy for the data. In
->iomap_end() we'd have to truncate the file if we didn't copy data for
the whole extent. This is more like standard write path works.

Doing 1) is easier, doing 2) may perform better unless there is high memory
pressure which would evict buffers from memory before we actually allocate
the extent and copy data to it.

I guess for now I'll go with 1) just to have the conversion to iomap code
done and look into doing 2) later while measuring what performance benefits
do we get from it.

								Honza

> >        [<ffffffff812f46d6>] dax_iomap_rw+0x76/0xa0 fs/dax.c:1067
> >        [<     inline     >] ext4_dax_write_iter fs/ext4/file.c:196
> >        [<ffffffff8133fb13>] ext4_file_write_iter+0x243/0x340 fs/ext4/file.c:217
> >        [<ffffffff812957d1>] do_iter_readv_writev+0xb1/0x130 fs/read_write.c:695
> >        [<ffffffff81296384>] do_readv_writev+0x1a4/0x250 fs/read_write.c:872
> >        [<ffffffff8129668f>] vfs_writev+0x3f/0x50 fs/read_write.c:911
> >        [<ffffffff81296704>] do_writev+0x64/0x100 fs/read_write.c:944
> >        [<     inline     >] SYSC_writev fs/read_write.c:1017
> >        [<ffffffff81297900>] SyS_writev+0x10/0x20 fs/read_write.c:1014
> >        [<ffffffff81b3d501>] entry_SYSCALL_64_fastpath+0x1f/0xc2 arch/x86/entry/entry_64.S:209
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
