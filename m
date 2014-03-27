Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f177.google.com (mail-ve0-f177.google.com [209.85.128.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1816B0036
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 16:22:13 -0400 (EDT)
Received: by mail-ve0-f177.google.com with SMTP id sa20so4648501veb.22
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 13:22:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140327200851.GL17679@kvack.org>
References: <20140327134653.GA22407@kvack.org>
	<CA+55aFzFgY4-26SO-MsFagzaj9JevkeeT1OJ3pjj-tcjuNCEeQ@mail.gmail.com>
	<CA+55aFx7vg2rvOu6Bu_e8+BB=ymoUMp0AM9JmAuUuSgo0LVEwg@mail.gmail.com>
	<20140327200851.GL17679@kvack.org>
Date: Thu, 27 Mar 2014 13:22:11 -0700
Message-ID: <CA+55aFy_sRnFu7KguAUAN5kbHk3Qa_0ZuATPU5i8LOyMMWZ_5g@mail.gmail.com>
Subject: Re: git pull -- [PATCH] aio: v2 ensure access to ctx->ring_pages is
 correctly serialised
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Thu, Mar 27, 2014 at 1:08 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
>
> The patch below is lightly tested -- my migration test case is able to
> successfully move the aio ring around multiple times.  It still needs to
> be run through some more thorough tests (like Trinity).  See below for
> the differences relative to your patch.

Ok, from a quick glance-through this fixes my big complaints (not
unrurprisingly, similarly to my patch), and seems to fix  few of the
smaller ones that I didn't bother with.

However, I think you missed the mutex_unlock() in the error paths of
ioctx_alloc().

> What I did instead is to just hold mapping->private_lock over the entire
> operation of aio_migratepage.  That gets rid of the probably broken attempt
> to take a reference count on the kioctx within aio_migratepage(), and makes
> it completely clear that migration won't touch a kioctx after
> put_aio_ring_file() returns.  It also cleans up much of the error handling
> in aio_migratepage() since things cannot change unexpectedly.

Yes, that looks simpler. I don't know what the latency implications
are, but the expensive part (the actual page migration) was and
continues to be under the completion lock with interrupts disabled, so
I guess it's not worse.

It would be good to try to get rid of the completion lock irq thing,
but that looks complex. It would likely require a two-phase migration
model, where phase one is "unmap page from user space and copy it to
new page", and phase two would be "insert new page into mapping". Then
we could have just a "update the tail pointer and the kernel mapping
under the completion lock" thing with interrupts disabled in between.

But that's a much bigger change and requires help from the migration
people. Maybe we don't care about latency here.

> I also added a few comments to help explain the locking.
>
> How does this version look?

Looks ok, except for the error handling wrt mutex_unlock. Did I miss it?

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
