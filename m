Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D37F36B0260
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 06:58:49 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id q124so11230018wmg.2
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 03:58:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w72si20529362wrc.19.2017.01.31.03.58.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Jan 2017 03:58:48 -0800 (PST)
Date: Tue, 31 Jan 2017 12:58:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages
 per zone
Message-ID: <20170131115846.GD19082@dhcp22.suse.cz>
References: <201701202227.GCC13598.OHJMSQFVOtFOLF@I-love.SAKURA.ne.jp>
 <201701211642.JBC39590.SFtVJHMFOLFOQO@I-love.SAKURA.ne.jp>
 <20170125101517.GG32377@dhcp22.suse.cz>
 <20170125101957.GA17632@lst.de>
 <20170125104605.GI32377@dhcp22.suse.cz>
 <201701252009.IHG13512.OFOJFSVLtOQMFH@I-love.SAKURA.ne.jp>
 <20170125130014.GO32377@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170125130014.GO32377@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mgorman@suse.de, viro@ZenIV.linux.org.uk, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org

On Wed 25-01-17 14:00:14, Michal Hocko wrote:
> On Wed 25-01-17 20:09:31, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Wed 25-01-17 11:19:57, Christoph Hellwig wrote:
> > > > On Wed, Jan 25, 2017 at 11:15:17AM +0100, Michal Hocko wrote:
> > > > > I think we are missing a check for fatal_signal_pending in
> > > > > iomap_file_buffered_write. This means that an oom victim can consume the
> > > > > full memory reserves. What do you think about the following? I haven't
> > > > > tested this but it mimics generic_perform_write so I guess it should
> > > > > work.
> > > > 
> > > > Hi Michal,
> > > > 
> > > > this looks reasonable to me.  But we have a few more such loops,
> > > > maybe it makes sense to move the check into iomap_apply?
> > > 
> > > I wasn't sure about the expected semantic of iomap_apply but now that
> > > I've actually checked all the callers I believe all of them should be
> > > able to handle EINTR just fine. Well iomap_file_dirty, iomap_zero_range,
> > > iomap_fiemap and iomap_page_mkwriteseem do not follow the standard
> > > pattern to return the number of written pages or an error but it rather
> > > propagates the error out. From my limited understanding of those code
> > > paths that should just be ok. I was not all that sure about iomap_dio_rw
> > > that is just too convoluted for me. If that one is OK as well then
> > > the following patch should be indeed better.
> > 
> > Is "length" in
> > 
> >    written = actor(inode, pos, length, data, &iomap);
> > 
> > call guaranteed to be small enough? If not guaranteed,
> > don't we need to check SIGKILL inside "actor" functions?
> 
> You are right! Checking for signals inside iomap_apply doesn't really
> solve anything because basically all users do iov_iter_count(). Blee. So
> we have loops around iomap_apply which itself loops inside the actor.
> iomap_write_begin seems to be used by most of them which is also where we
> get the pagecache page so I guess this should be the "right" place to
> put the check in. Things like dax_iomap_actor will need an explicit check.
> This is quite unfortunate but I do not see any better solution.
> What do you think Christoph?

What do you think Christoph? I have an additional patch to handle
do_generic_file_read and a similar one to back off in
__vmalloc_area_node. I would like to post them all in one series but I
would like to know that this one is OK before I do that.

Thanks!

> ---
> From 362da5cac527146a341300c2ca441245c16043e8 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 25 Jan 2017 11:06:37 +0100
> Subject: [PATCH] fs: break out of iomap_file_buffered_write on fatal signals
> 
> Tetsuo has noticed that an OOM stress test which performs large write
> requests can cause the full memory reserves depletion. He has tracked
> this down to the following path
> 	__alloc_pages_nodemask+0x436/0x4d0
> 	alloc_pages_current+0x97/0x1b0
> 	__page_cache_alloc+0x15d/0x1a0          mm/filemap.c:728
> 	pagecache_get_page+0x5a/0x2b0           mm/filemap.c:1331
> 	grab_cache_page_write_begin+0x23/0x40   mm/filemap.c:2773
> 	iomap_write_begin+0x50/0xd0             fs/iomap.c:118
> 	iomap_write_actor+0xb5/0x1a0            fs/iomap.c:190
> 	? iomap_write_end+0x80/0x80             fs/iomap.c:150
> 	iomap_apply+0xb3/0x130                  fs/iomap.c:79
> 	iomap_file_buffered_write+0x68/0xa0     fs/iomap.c:243
> 	? iomap_write_end+0x80/0x80
> 	xfs_file_buffered_aio_write+0x132/0x390 [xfs]
> 	? remove_wait_queue+0x59/0x60
> 	xfs_file_write_iter+0x90/0x130 [xfs]
> 	__vfs_write+0xe5/0x140
> 	vfs_write+0xc7/0x1f0
> 	? syscall_trace_enter+0x1d0/0x380
> 	SyS_write+0x58/0xc0
> 	do_syscall_64+0x6c/0x200
> 	entry_SYSCALL64_slow_path+0x25/0x25
> 
> the oom victim has access to all memory reserves to make a forward
> progress to exit easier. But iomap_file_buffered_write and other callers
> of iomap_apply loop to complete the full request. We need to check for
> fatal signals and back off with a short write instead. As the
> iomap_apply delegates all the work down to the actor we have to hook
> into those. All callers that work with the page cache are calling
> iomap_write_begin so we will check for signals there. dax_iomap_actor
> has to handle the situation explicitly because it copies data to the
> userspace directly. Other callers like iomap_page_mkwrite work on a
> single page or iomap_fiemap_actor do not allocate memory based on the
> given len.
> 
> Fixes: 68a9f5e7007c ("xfs: implement iomap based buffered write path")
> Cc: stable # 4.8+
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/dax.c   | 5 +++++
>  fs/iomap.c | 3 +++
>  2 files changed, 8 insertions(+)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 413a91db9351..0e263dacf9cf 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1033,6 +1033,11 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
>  		struct blk_dax_ctl dax = { 0 };
>  		ssize_t map_len;
>  
> +		if (fatal_signal_pending(current)) {
> +			ret = -EINTR;
> +			break;
> +		}
> +
>  		dax.sector = dax_iomap_sector(iomap, pos);
>  		dax.size = (length + offset + PAGE_SIZE - 1) & PAGE_MASK;
>  		map_len = dax_map_atomic(iomap->bdev, &dax);
> diff --git a/fs/iomap.c b/fs/iomap.c
> index e57b90b5ff37..691eada58b06 100644
> --- a/fs/iomap.c
> +++ b/fs/iomap.c
> @@ -114,6 +114,9 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
>  
>  	BUG_ON(pos + len > iomap->offset + iomap->length);
>  
> +	if (fatal_signal_pending(current))
> +		return -EINTR;
> +
>  	page = grab_cache_page_write_begin(inode->i_mapping, index, flags);
>  	if (!page)
>  		return -ENOMEM;
> -- 
> 2.11.0
> 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
