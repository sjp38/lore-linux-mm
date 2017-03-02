Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 31ABE6B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 06:45:05 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id y187so26136282wmy.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 03:45:05 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id q188si10726022wme.152.2017.03.02.03.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 03:45:03 -0800 (PST)
Date: Thu, 2 Mar 2017 11:44:53 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: mm: GPF in bdi_put
Message-ID: <20170302114453.GX29622@ZenIV.linux.org.uk>
References: <CACT4Y+bAF0Udejr0v7YAXhs753yDdyNtoQbORQ55yEWZ+4Wu5g@mail.gmail.com>
 <20170227182755.GR29622@ZenIV.linux.org.uk>
 <20170301142909.GG20512@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170301142909.GG20512@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dmitry Vyukov <dvyukov@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>

On Wed, Mar 01, 2017 at 03:29:09PM +0100, Jan Kara wrote:

> The problem is writeback code (from flusher work or through sync(2) -
> generally inode_to_bdi() users) can be looking at bdev inode independently
> from it being open. So if they start looking while the bdev is open but the
> dereference happens after it is closed and device removed, we oops. We have
> seen oopses due to this for quite a while. And all the stuff that is done
> in __blkdev_put() is not enough to prevent writeback code from having a
> look whether there is not something to write.

Um.  What's to prevent the queue/device/module itself from disappearing
from under you?  IOW, what are you doing that is safe to do in face of
driver going rmmoded?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
