Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 226186B0260
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:43:52 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id b66so171691769ywh.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:43:52 -0800 (PST)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id l63si8484334ywb.162.2016.11.29.08.43.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 08:43:51 -0800 (PST)
Received: by mail-yw0-x242.google.com with SMTP id r204so12724924ywb.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 08:43:51 -0800 (PST)
Date: Tue, 29 Nov 2016 11:43:50 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
Message-ID: <20161129164350.GC19454@htj.duckdns.org>
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
 <20161128100718.GD2590@quack2.suse.cz>
 <20161128155718.GB7806@htj.duckdns.org>
 <20161129093035.GC7550@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161129093035.GC7550@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wei Fang <fangwei1@huawei.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

Hello, Jan.

On Tue, Nov 29, 2016 at 10:30:35AM +0100, Jan Kara wrote:
> > It's kinda weird that sync() is ends up accessing bdev's without any
> > synchronization.  Can't we just make iterate_bdevs() grab bd_mutex and
> > verify bd_disk isn't NULL before calling into the callback?
> 
> This reminded me I've already seen something like this and indeed I've
> already had a very similar discussion in March -
> https://patchwork.kernel.org/patch/8556941/

lol

> Holding bd_mutex in iterate_devs() works but still nothing protects from
> flusher thread just walking across the block device inode and trying to
> write it which would result in the very same oops.

Ah, right.  We aren't implementing either sever or refcnted draining
semantics properly.  I wonder whether we'd be able to retire the inode
synchronously during blkdev_put.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
