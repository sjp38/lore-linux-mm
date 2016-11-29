Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E66C16B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 04:30:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so42890919wmw.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 01:30:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e79si1666358wmc.73.2016.11.29.01.30.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 01:30:37 -0800 (PST)
Date: Tue, 29 Nov 2016 10:30:35 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
Message-ID: <20161129093035.GC7550@quack2.suse.cz>
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
 <20161128100718.GD2590@quack2.suse.cz>
 <20161128155718.GB7806@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161128155718.GB7806@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Wei Fang <fangwei1@huawei.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

On Mon 28-11-16 10:57:18, Tejun Heo wrote:
> Hello, Jan.
> 
> On Mon, Nov 28, 2016 at 11:07:18AM +0100, Jan Kara wrote:
> > As I'm looking into the code, we need a serialization between bdev writeback
> > and blkdev_put(). That should be doable if we use writeback_single_inode()
> > for writing bdev inode instead of simple filemap_fdatawrite() and then use
> > inode_wait_for_writeback() in blkdev_put() but it needs some careful
> > thought.
> 
> It's kinda weird that sync() is ends up accessing bdev's without any
> synchronization.  Can't we just make iterate_bdevs() grab bd_mutex and
> verify bd_disk isn't NULL before calling into the callback?

This reminded me I've already seen something like this and indeed I've
already had a very similar discussion in March -
https://patchwork.kernel.org/patch/8556941/

Holding bd_mutex in iterate_devs() works but still nothing protects from
flusher thread just walking across the block device inode and trying to
write it which would result in the very same oops.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
