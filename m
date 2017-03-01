Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC5256B0389
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:05:48 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y187so17260789wmy.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:05:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t131si7309681wmf.7.2017.03.01.07.05.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 07:05:47 -0800 (PST)
Date: Wed, 1 Mar 2017 16:05:44 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: mm: GPF in bdi_put
Message-ID: <20170301150544.GH20512@quack2.suse.cz>
References: <CACT4Y+bAF0Udejr0v7YAXhs753yDdyNtoQbORQ55yEWZ+4Wu5g@mail.gmail.com>
 <20170227182755.GR29622@ZenIV.linux.org.uk>
 <20170301142909.GG20512@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
Content-Disposition: inline
In-Reply-To: <20170301142909.GG20512@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Dmitry Vyukov <dvyukov@google.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, syzkaller <syzkaller@googlegroups.com>


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed 01-03-17 15:29:09, Jan Kara wrote:
> On Mon 27-02-17 18:27:55, Al Viro wrote:
> > On Mon, Feb 27, 2017 at 06:11:11PM +0100, Dmitry Vyukov wrote:
> > > Hello,
> > > 
> > > The following program triggers GPF in bdi_put:
> > > https://gist.githubusercontent.com/dvyukov/15b3e211f937ff6abc558724369066ce/raw/cc017edf57963e30175a6a6fe2b8d917f6e92899/gistfile1.txt
> > 
> > What happens is
> > 	* attempt of, essentially, mount -t bdev ..., calls mount_pseudo()
> > and then promptly destroys the new instance it has created.
> > 	* the only inode created on that sucker (root directory, that
> > is) gets evicted.
> > 	* most of ->evict_inode() is harmless, until it gets to
> >         if (bdev->bd_bdi != &noop_backing_dev_info)
> >                 bdi_put(bdev->bd_bdi);
> 
> Thanks for the analysis!
> 
> > added there by "block: Make blk_get_backing_dev_info() safe without open bdev".
> > Since ->bd_bdi hadn't been initialized for that sucker (the same patch has
> > placed initialization into bdget()), we step into shit of varying nastiness,
> > depending on phase of moon, etc.
> 
> Yup, I've missed that the root inode of bdev superblock does not go through
> bdget() (in fact I didn't think what happens with root inode for bdev
> superblock at all) and thus bd_bdi is left uninitialized in that case. I'll
> send a fix for that in a while.
>  
> > Could somebody explain WTF do we have those two lines in bdev_evict_inode(),
> > anyway?  We set ->bd_bdi to something other than noop_backing_dev_info only
> > in __blkdev_get() when ->bd_openers goes from zero to positive, so why is
> > the matching bdi_put() not in __blkdev_put()?  Jan?
> 
> The problem is writeback code (from flusher work or through sync(2) -
> generally inode_to_bdi() users) can be looking at bdev inode independently
> from it being open. So if they start looking while the bdev is open but the
> dereference happens after it is closed and device removed, we oops. We have
> seen oopses due to this for quite a while. And all the stuff that is done
> in __blkdev_put() is not enough to prevent writeback code from having a
> look whether there is not something to write.
> 
> So what we do now is that once we establish valid bd_bdi reference, we
> leave it alone until bdev inode gets evicted. And to handle the case when
> underlying device actually changes, we unhash bdev inode when the device
> gets removed from the system so that it cannot be found by bdget() anymore.

Attached patch fixes the problem for me. I'll post it officially tomorrow
once Al has a chance to reply...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--FCuugMFkClbJLl1L
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-block-Initialize-bd_bdi-on-inode-initialization.patch"


--FCuugMFkClbJLl1L--
