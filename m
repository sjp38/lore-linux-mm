Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5717E900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 21:53:28 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so18626086pab.3
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 18:53:28 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id re12si3484586pdb.36.2015.06.03.18.53.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 18:53:27 -0700 (PDT)
Received: by pdbqa5 with SMTP id qa5so19648238pdb.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 18:53:27 -0700 (PDT)
Date: Thu, 4 Jun 2015 10:53:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: clear disk io accounting when reset zram device
Message-ID: <20150604015305.GA2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, ngupta@vflare.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Sergey,

Separate as another thread.

On Sat, May 30, 2015 at 01:16:38PM +0900, Sergey Senozhatsky wrote:
> On (05/29/15 23:54), Minchan Kim wrote:
> > I think the problem is caused from weired feature "reset" of zram.
> 
> agree.
> 
> > Until a while ago, we didn't have hot_add/del feature so we should
> > use custom reset function but now we have hot/add feature.
> > So reset is logically same feature(ie, reset = hot_remove+hot_add
> > but remains same device id).
> > 
> 
> hm, sounds interesting, but I think it will end up being tricky.
> 
> zram_remove() will be called from device's sysfs node (now we call it from
> zram_control sysfs class node, makes a huge difference). sysfs locks the node
> until node's read/write handler returns back, so zram_remove() will be called
> with lock(s_active#XXX) being locked (we had a lockdep splat with these locks
> recently), while zram_remove()->sysfs_remove_group() will once again attempt
> to lock this node (the very same lock(s_active#XXX)). in other words, we cannot
> fully remove zram device from its sysfs attr. and I don't want to add any bool
> flags to zram_remove() and zram_add() indicating that this is a "partial" device
> remove: don't delete device's sysfs group in remove() and don't create it in add().
> 
> 
> doing reset from zram_control is easy, for sure:
> 	lock idr mutex,
> 	do zram_remove() and zram_add()
> 	unlock idr lock.
> 
> `echo ID > /sys/.../zram_control/reset`
> 
> no need to modify remove()/add() -- idr will pick up just released idx,
> so device_id will be preserved. but it'll be hard to drop the per-device
> `reset` attr and to make it a zram_control attr. things would have been
> much simpler if all of zram users were also zramctl users. zramctl, from
> this point of view, lets us change zram interfaces easily -- we merely need
> to teach/modify zramctl, the rest is transparent.

Thanks for the looking.
Fair enough.

So you mean you don't want to add any bool flags. Instead, you want to move
reset interface into /sys/.../zram_control/reset and it would be transparent
if everyone doesn't use raw interface.

Somethings I have in mind.

We should change old interface(ie, /sys/block/zram0/reset) by just
*implementation difficulty* which is just adding a bool flag?
IMO, it's not a good reason to change old interface.
I prefer adding a bool flag if it can meet our goal entirely.

Another thing I repeated several times is that we cannot guarantee
every users in the world will use zramctl forever so we should
be careful to change interface even though a userland tool becomes
popular.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
