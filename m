Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6EB2F6B038B
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:24:10 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r18so7948821wmd.1
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:24:10 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id b35si3452084wrb.38.2017.02.28.10.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 10:24:09 -0800 (PST)
Date: Tue, 28 Feb 2017 18:23:56 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: mm: GPF in bdi_put
Message-ID: <20170228182356.GS29622@ZenIV.linux.org.uk>
References: <CACT4Y+bAF0Udejr0v7YAXhs753yDdyNtoQbORQ55yEWZ+4Wu5g@mail.gmail.com>
 <20170227182755.GR29622@ZenIV.linux.org.uk>
 <CACT4Y+aOOc3AKsm80y4Rr7rChB=BUmfBvy+Kud2C_8EGnAZ2hg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+aOOc3AKsm80y4Rr7rChB=BUmfBvy+Kud2C_8EGnAZ2hg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Tue, Feb 28, 2017 at 06:55:55PM +0100, Dmitry Vyukov wrote:

> I am also seeing the following crashes on
> linux-next/8d01c069486aca75b8f6018a759215b0ed0c91f0. Do you think it's
> the same underlying issue?

Yes.
	1) Any attempt of mount -t bdev will fail, as it should
	2) bdevfs instance created by that attempt will be immediately
destroyed (again, as it should)
	3) the sole inode ever created for that instance (its root directory)
will be destroyed in process (again, as it should)
	4) that inode has never had ->bd_bdi initialized - the value stored
there would have been whatever garbage kmem_cache_alloc() has left behind
	5) bdev_evict_inode() will be called for that inode and if
aforementioned garbage happens to be not equal to &noop_backing_dev_info,
the pointer will be passed to bdi_put().

If that inode happens to reuse the memory previously occupied by a bdev
inode of a looked up but never opened block device, it will have ->bd_bdi
still equal to &noop_backing_dev_info, so that crap does not trigger
every time.  That's what the junk (recvmsg/ioctl/etc.) in your reproducer
is affecting.  Specific effects of bdi_put() will, of course, depend upon
the actual garbage found there - silent decrement of refcount of an existing
bdi setting the things up for later use-after-free, outright memory
corruption, etc.

_Any_ stack trace of form sys_mount() -> ... -> bdev_evict_inode() ->
bdi_put() -> <barf>  is almost certainly the same bug.

I would still like to hear from Jan regarding the reasons why we do that
bdi_put() from bdev_evict_inode() and not in __blkdev_put().  My preference
would be to do it there (and reset ->bd_bdi to &noop_backing_dev_info) when
->bd_openers hits 0.  And drop that code from bdev_evict_inode()...

Objections?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
