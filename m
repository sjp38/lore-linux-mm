Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 938946B026B
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 03:55:50 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so60002448wjc.4
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 00:55:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i67si12568705wmh.2.2017.01.30.00.55.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 00:55:49 -0800 (PST)
Date: Mon, 30 Jan 2017 09:55:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170130085546.GF8443@dhcp22.suse.cz>
References: <20170125101957.GA17632@lst.de>
 <20170125104605.GI32377@dhcp22.suse.cz>
 <201701252009.IHG13512.OFOJFSVLtOQMFH@I-love.SAKURA.ne.jp>
 <20170125130014.GO32377@dhcp22.suse.cz>
 <20170127144906.GB4148@dhcp22.suse.cz>
 <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201701290027.AFB30799.FVtFLOOOJMSHQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hch@lst.de, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Sun 29-01-17 00:27:27, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > Tetsuo,
> > before we settle on the proper fix for this issue, could you give the
> > patch a try and try to reproduce the too_many_isolated() issue or
> > just see whether patch [1] has any negative effect on your oom stress
> > testing?
> > 
> > [1] http://lkml.kernel.org/r/20170119112336.GN30786@dhcp22.suse.cz
> 
> I tested with both [1] and below patch applied on linux-next-20170125 and
> the result is at http://I-love.SAKURA.ne.jp/tmp/serial-20170128.txt.xz .
> 
> Regarding below patch, it helped avoiding complete memory depletion with
> large write() request. I don't know whether below patch helps avoiding
> complete memory depletion when reading large amount (in other words, I
> don't know whether this check is done for large read() request).

It's not AFAICS. do_generic_file_read doesn't do the
fatal_signal_pending check.

> But
> I believe that __GFP_KILLABLE (despite the limitation that there are
> unkillable waits in the reclaim path) is better solution compared to
> scattering around fatal_signal_pending() in the callers. The reason
> we check SIGKILL here is to avoid allocating memory more than needed.
> If we check SIGKILL in the entry point of __alloc_pages_nodemask() and
> retry: label in __alloc_pages_slowpath(), we waste 0 page. Regardless
> of whether the OOM killer is invoked, whether memory can be allocated
> without direct reclaim operation, not allocating memory unless needed
> (in other words, allow page allocator fail immediately if the caller
> can give up on SIGKILL and SIGKILL is pending) makes sense. It will
> reduce possibility of OOM livelock on CONFIG_MMU=n kernels where the
> OOM reaper is not available.

I am not really convinced this is a good idea. Put aside the fuzzy
semantic of __GFP_KILLABLE, we would have to use this flag in all
potentially allocating places from read/write paths and then it is just
easier to do the explicit checks in the the loops around those
allocations.
 
> > On Wed 25-01-17 14:00:14, Michal Hocko wrote:
> > [...]
> > > From 362da5cac527146a341300c2ca441245c16043e8 Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Wed, 25 Jan 2017 11:06:37 +0100
> > > Subject: [PATCH] fs: break out of iomap_file_buffered_write on fatal signals
> > > 
> > > Tetsuo has noticed that an OOM stress test which performs large write
> > > requests can cause the full memory reserves depletion. He has tracked
> > > this down to the following path
> > > 	__alloc_pages_nodemask+0x436/0x4d0
> > > 	alloc_pages_current+0x97/0x1b0
> > > 	__page_cache_alloc+0x15d/0x1a0          mm/filemap.c:728
> > > 	pagecache_get_page+0x5a/0x2b0           mm/filemap.c:1331
> > > 	grab_cache_page_write_begin+0x23/0x40   mm/filemap.c:2773
> > > 	iomap_write_begin+0x50/0xd0             fs/iomap.c:118
> > > 	iomap_write_actor+0xb5/0x1a0            fs/iomap.c:190
> > > 	? iomap_write_end+0x80/0x80             fs/iomap.c:150
> > > 	iomap_apply+0xb3/0x130                  fs/iomap.c:79
> > > 	iomap_file_buffered_write+0x68/0xa0     fs/iomap.c:243
> > > 	? iomap_write_end+0x80/0x80
> > > 	xfs_file_buffered_aio_write+0x132/0x390 [xfs]
> > > 	? remove_wait_queue+0x59/0x60
> > > 	xfs_file_write_iter+0x90/0x130 [xfs]
> > > 	__vfs_write+0xe5/0x140
> > > 	vfs_write+0xc7/0x1f0
> > > 	? syscall_trace_enter+0x1d0/0x380
> > > 	SyS_write+0x58/0xc0
> > > 	do_syscall_64+0x6c/0x200
> > > 	entry_SYSCALL64_slow_path+0x25/0x25
> > > 
> > > the oom victim has access to all memory reserves to make a forward
> > > progress to exit easier. But iomap_file_buffered_write and other callers
> > > of iomap_apply loop to complete the full request. We need to check for
> > > fatal signals and back off with a short write instead. As the
> > > iomap_apply delegates all the work down to the actor we have to hook
> > > into those. All callers that work with the page cache are calling
> > > iomap_write_begin so we will check for signals there. dax_iomap_actor
> > > has to handle the situation explicitly because it copies data to the
> > > userspace directly. Other callers like iomap_page_mkwrite work on a
> > > single page or iomap_fiemap_actor do not allocate memory based on the
> > > given len.
> > > 
> > > Fixes: 68a9f5e7007c ("xfs: implement iomap based buffered write path")
> > > Cc: stable # 4.8+
> > > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > >  fs/dax.c   | 5 +++++
> > >  fs/iomap.c | 3 +++
> > >  2 files changed, 8 insertions(+)
> > > 
> > > diff --git a/fs/dax.c b/fs/dax.c
> > > index 413a91db9351..0e263dacf9cf 100644
> > > --- a/fs/dax.c
> > > +++ b/fs/dax.c
> > > @@ -1033,6 +1033,11 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
> > >  		struct blk_dax_ctl dax = { 0 };
> > >  		ssize_t map_len;
> > >  
> > > +		if (fatal_signal_pending(current)) {
> > > +			ret = -EINTR;
> > > +			break;
> > > +		}
> > > +
> > >  		dax.sector = dax_iomap_sector(iomap, pos);
> > >  		dax.size = (length + offset + PAGE_SIZE - 1) & PAGE_MASK;
> > >  		map_len = dax_map_atomic(iomap->bdev, &dax);
> > > diff --git a/fs/iomap.c b/fs/iomap.c
> > > index e57b90b5ff37..691eada58b06 100644
> > > --- a/fs/iomap.c
> > > +++ b/fs/iomap.c
> > > @@ -114,6 +114,9 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
> > >  
> > >  	BUG_ON(pos + len > iomap->offset + iomap->length);
> > >  
> > > +	if (fatal_signal_pending(current))
> > > +		return -EINTR;
> > > +
> > >  	page = grab_cache_page_write_begin(inode->i_mapping, index, flags);
> > >  	if (!page)
> > >  		return -ENOMEM;
> > > -- 
> > > 2.11.0
> 
> Regarding [1], it helped avoiding the too_many_isolated() issue. I can't
> tell whether it has any negative effect, but I got on the first trial that
> all allocating threads are blocked on wait_for_completion() from flush_work()
> in drain_all_pages() introduced by "mm, page_alloc: drain per-cpu pages from
> workqueue context". There was no warn_alloc() stall warning message afterwords.

That patch is buggy and there is a follow up [1] which is not sitting in the
mmotm (and thus linux-next) yet. I didn't get to review it properly and
I cannot say I would be too happy about using WQ from the page
allocator. I believe even the follow up needs to have WQ_RECLAIM WQ.

[1] http://lkml.kernel.org/r/20170125083038.rzb5f43nptmk7aed@techsingularity.net

Thanks for your testing!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
