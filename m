Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAFC6B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 07:20:54 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u48so28174845wrc.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 04:20:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35si10490899wre.175.2017.03.02.04.20.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 04:20:53 -0800 (PST)
Date: Thu, 2 Mar 2017 13:20:49 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: mm: GPF in bdi_put
Message-ID: <20170302122049.GA23354@quack2.suse.cz>
References: <CACT4Y+bAF0Udejr0v7YAXhs753yDdyNtoQbORQ55yEWZ+4Wu5g@mail.gmail.com>
 <20170227182755.GR29622@ZenIV.linux.org.uk>
 <20170301142909.GG20512@quack2.suse.cz>
 <20170302114453.GX29622@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170302114453.GX29622@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Thu 02-03-17 11:44:53, Al Viro wrote:
> On Wed, Mar 01, 2017 at 03:29:09PM +0100, Jan Kara wrote:
> 
> > The problem is writeback code (from flusher work or through sync(2) -
> > generally inode_to_bdi() users) can be looking at bdev inode independently
> > from it being open. So if they start looking while the bdev is open but the
> > dereference happens after it is closed and device removed, we oops. We have
> > seen oopses due to this for quite a while. And all the stuff that is done
> > in __blkdev_put() is not enough to prevent writeback code from having a
> > look whether there is not something to write.
> 
> Um.  What's to prevent the queue/device/module itself from disappearing
> from under you?  IOW, what are you doing that is safe to do in face of
> driver going rmmoded?

So BDI does not have direct relation to the device itself. It is an
abstraction for some of the device properties / functionality and thus it
can live even after the device itself went away and the module got removed.
The only thing users of bdi want is to tell them whether the device is
congested or various statistics and dirty inode tracking for writeback
purposes and that is all independent of the particular device or whether it
still exists.

Technically there may be pointers bdi->dev, bdi->owner to the device which
are properly refcounted (so the device structure or module cannot be
removed under us). These references get dropped & cleared in
bdi_unregister() generally called from blk_cleanup_queue() (will be moved
to del_gendisk() soon) when the device is going away. This can happen while
e.g. bdev still references the bdi so users of bdi->dev or bdi->owner have
to be careful to sychronize against device removal and bdi_unregister() but
there are only very few such users.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
