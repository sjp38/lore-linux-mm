Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 86C436B025E
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 04:50:29 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so49705589wme.4
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 01:50:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si63026187wjk.144.2016.11.30.01.50.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 01:50:28 -0800 (PST)
Date: Wed, 30 Nov 2016 10:50:25 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
Message-ID: <20161130095025.GA20030@quack2.suse.cz>
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
 <20161128100718.GD2590@quack2.suse.cz>
 <20161128155718.GB7806@htj.duckdns.org>
 <20161129093035.GC7550@quack2.suse.cz>
 <20161129164350.GC19454@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129164350.GC19454@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Wei Fang <fangwei1@huawei.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

On Tue 29-11-16 11:43:50, Tejun Heo wrote:
> Hello, Jan.
> 
> On Tue, Nov 29, 2016 at 10:30:35AM +0100, Jan Kara wrote:
> > > It's kinda weird that sync() is ends up accessing bdev's without any
> > > synchronization.  Can't we just make iterate_bdevs() grab bd_mutex and
> > > verify bd_disk isn't NULL before calling into the callback?
> > 
> > This reminded me I've already seen something like this and indeed I've
> > already had a very similar discussion in March -
> > https://patchwork.kernel.org/patch/8556941/
> 
> lol
> 
> > Holding bd_mutex in iterate_devs() works but still nothing protects from
> > flusher thread just walking across the block device inode and trying to
> > write it which would result in the very same oops.
> 
> Ah, right.  We aren't implementing either sever or refcnted draining
> semantics properly.  I wonder whether we'd be able to retire the inode
> synchronously during blkdev_put.

Yeah, I've realized flusher thread is mostly taken care of by the fact that
__blkdev_put() does bdev_write_inode() which waits for I_SYNC to get
cleared and then the inode is clean so writeback code mostly ignores it. It
is fragile but likely it works. So for now I've decided to just push the
patch mentioned above to get at least obvious breakage fixed as playing
with bdev lifetime rules definitely won't be a stable material anyway.

I was also thinking about completely tearing down bdev inode in
__blkdev_put() and it could be doable although hunting all inodes
referencing bdev inode through i_bdev will be tricky. Probably we'll need
i_devices things for block devices back...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
