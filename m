Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDAFE6B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 13:28:10 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id t18so40802106wmt.7
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 10:28:10 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id m131si14422996wmd.60.2017.02.27.10.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 10:28:09 -0800 (PST)
Date: Mon, 27 Feb 2017 18:27:55 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: mm: GPF in bdi_put
Message-ID: <20170227182755.GR29622@ZenIV.linux.org.uk>
References: <CACT4Y+bAF0Udejr0v7YAXhs753yDdyNtoQbORQ55yEWZ+4Wu5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bAF0Udejr0v7YAXhs753yDdyNtoQbORQ55yEWZ+4Wu5g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Mon, Feb 27, 2017 at 06:11:11PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> The following program triggers GPF in bdi_put:
> https://gist.githubusercontent.com/dvyukov/15b3e211f937ff6abc558724369066ce/raw/cc017edf57963e30175a6a6fe2b8d917f6e92899/gistfile1.txt

What happens is
	* attempt of, essentially, mount -t bdev ..., calls mount_pseudo()
and then promptly destroys the new instance it has created.
	* the only inode created on that sucker (root directory, that
is) gets evicted.
	* most of ->evict_inode() is harmless, until it gets to
        if (bdev->bd_bdi != &noop_backing_dev_info)
                bdi_put(bdev->bd_bdi);

added there by "block: Make blk_get_backing_dev_info() safe without open bdev".
Since ->bd_bdi hadn't been initialized for that sucker (the same patch has
placed initialization into bdget()), we step into shit of varying nastiness,
depending on phase of moon, etc.

Could somebody explain WTF do we have those two lines in bdev_evict_inode(),
anyway?  We set ->bd_bdi to something other than noop_backing_dev_info only
in __blkdev_get() when ->bd_openers goes from zero to positive, so why is
the matching bdi_put() not in __blkdev_put()?  Jan?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
