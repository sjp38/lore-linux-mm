Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id E67246B025E
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:57:20 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id h184so115614373ybb.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:57:20 -0800 (PST)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id r71si15002252ywg.155.2016.11.28.07.57.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 07:57:20 -0800 (PST)
Received: by mail-yw0-x244.google.com with SMTP id s68so10162930ywg.0
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:57:20 -0800 (PST)
Date: Mon, 28 Nov 2016 10:57:18 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Fix a NULL dereference crash while accessing
 bdev->bd_disk
Message-ID: <20161128155718.GB7806@htj.duckdns.org>
References: <1480125982-8497-1-git-send-email-fangwei1@huawei.com>
 <20161128100718.GD2590@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161128100718.GD2590@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wei Fang <fangwei1@huawei.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hch@infradead.org, linux-mm@kvack.org, stable@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

Hello, Jan.

On Mon, Nov 28, 2016 at 11:07:18AM +0100, Jan Kara wrote:
> As I'm looking into the code, we need a serialization between bdev writeback
> and blkdev_put(). That should be doable if we use writeback_single_inode()
> for writing bdev inode instead of simple filemap_fdatawrite() and then use
> inode_wait_for_writeback() in blkdev_put() but it needs some careful
> thought.

It's kinda weird that sync() is ends up accessing bdev's without any
synchronization.  Can't we just make iterate_bdevs() grab bd_mutex and
verify bd_disk isn't NULL before calling into the callback?

> Frankly that whole idea of tearing block devices down on last close is a
> major headache and keeps biting us. I'm wondering whether it is still worth
> it these days...

Yeah, it'd be great if we can follow a more conventional lifetime
pattern here.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
