Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4EB900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 22:32:28 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so20245260pdb.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 19:32:28 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id bf3si3601868pbc.29.2015.06.03.19.32.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 19:32:27 -0700 (PDT)
Received: by pdbki1 with SMTP id ki1so20213278pdb.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 19:32:26 -0700 (PDT)
Date: Thu, 4 Jun 2015 11:32:51 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: clear disk io accounting when reset zram device
Message-ID: <20150604023251.GB1951@swordfish>
References: <20150604015305.GA2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604015305.GA2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Weijie Yang <weijie.yang@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, ngupta@vflare.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (06/04/15 10:53), Minchan Kim wrote:
> > hm, sounds interesting, but I think it will end up being tricky.
> > 
> > zram_remove() will be called from device's sysfs node (now we call it from
> > zram_control sysfs class node, makes a huge difference). sysfs locks the node
> > until node's read/write handler returns back, so zram_remove() will be called
> > with lock(s_active#XXX) being locked (we had a lockdep splat with these locks
> > recently), while zram_remove()->sysfs_remove_group() will once again attempt
> > to lock this node (the very same lock(s_active#XXX)). in other words, we cannot
> > fully remove zram device from its sysfs attr. and I don't want to add any bool
> > flags to zram_remove() and zram_add() indicating that this is a "partial" device
> > remove: don't delete device's sysfs group in remove() and don't create it in add().
> > 
> > 
> > doing reset from zram_control is easy, for sure:
> > 	lock idr mutex,
> > 	do zram_remove() and zram_add()
> > 	unlock idr lock.
> > 
> > `echo ID > /sys/.../zram_control/reset`
> > 
> > no need to modify remove()/add() -- idr will pick up just released idx,
> > so device_id will be preserved. but it'll be hard to drop the per-device
> > `reset` attr and to make it a zram_control attr. things would have been
> > much simpler if all of zram users were also zramctl users. zramctl, from
> > this point of view, lets us change zram interfaces easily -- we merely need
> > to teach/modify zramctl, the rest is transparent.
> 
> Thanks for the looking.
> Fair enough.
> 
> So you mean you don't want to add any bool flags. Instead, you want to move
> reset interface into /sys/.../zram_control/reset and it would be transparent
> if everyone doesn't use raw interface.

I just described the ideal case -- moving reset to zram_control. which
is very much unlikely to happen. even if zramX/reset will become a symlink
to zram_control/reset user still will have to supply a device_id. it's too
late to change this, unfortunately.


> Somethings I have in mind.
> 
> We should change old interface(ie, /sys/block/zram0/reset) by just
> *implementation difficulty* which is just adding a bool flag?
> IMO, it's not a good reason to change old interface.
> I prefer adding a bool flag if it can meet our goal entirely.

well, we can add it. but it's hacky and tricky.


having a clear
"zram_add(void)/zram_remove(void)" vs. "zram_add(bool partial)/zram_remove(bool partial)".

apart from that, zram_add() will introduce additional 4 places where we
can fail to re-create the device:
-- zram = kzalloc(sizeof(struct zram), GFP_KERNEL);
-- ret = idr_alloc(&zram_index_idr, zram, 0, 0, GFP_KERNEL);
-- queue = blk_alloc_queue(GFP_KERNEL);
-- zram->disk = alloc_disk(1);


so, we don't destroy and create zram's sysfs_group. which means that we
better not kfree() and kzalloc() zram pointer, otherise we still need to
set up &disk_to_dev(zram->disk)->kobj. so 'bool partial' flag will now
also make zram kfree()/kmalloc() optional. if we have kfree()/kmalloc()
optional, then we probably should keep idr allocation optional as well. iow,
optional idr_alloc/idr_remove().

which sort of turns zram_add()/zram_remove() into a hell.
I need to think about it more.


> Another thing I repeated several times is that we cannot guarantee
> every users in the world will use zramctl forever so we should
> be careful to change interface even though a userland tool becomes
> popular.

no, of course I'm not saying that everyone is using zramctl nor I count
on it, zram is simply ~4 years older than zramctl.

*things would have been much simpler if* ...


	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
