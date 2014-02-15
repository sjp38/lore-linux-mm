Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6566B0039
	for <linux-mm@kvack.org>; Sat, 15 Feb 2014 18:53:52 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id g10so13349967pdj.16
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 15:53:51 -0800 (PST)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id gx4si10225651pbc.291.2014.02.15.15.53.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Feb 2014 15:53:51 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id x10so13339058pdj.25
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 15:53:51 -0800 (PST)
Date: Sat, 15 Feb 2014 15:53:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] swapoff tmpfs radix_tree: remember to rcu_read_unlock
In-Reply-To: <20140213143005.9aea5709d5befd1df84b19a7@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1402151529060.8605@eggly.anvils>
References: <alpine.LSU.2.11.1402121840500.6398@eggly.anvils> <20140213143005.9aea5709d5befd1df84b19a7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 13 Feb 2014, Andrew Morton wrote:
> On Wed, 12 Feb 2014 18:45:07 -0800 (PST) Hugh Dickins <hughd@google.com> wrote:
> 
> > Running fsx on tmpfs with concurrent memhog-swapoff-swapon, lots of
> > 
> > BUG: sleeping function called from invalid context at kernel/fork.c:606
> > in_atomic(): 0, irqs_disabled(): 0, pid: 1394, name: swapoff
> > 1 lock held by swapoff/1394:
> >  #0:  (rcu_read_lock){.+.+.+}, at: [<ffffffff812520a1>] radix_tree_locate_item+0x1f/0x2b6
> > followed by
> > ================================================
> > [ BUG: lock held when returning to user space! ]
> > 3.14.0-rc1 #3 Not tainted
> > ------------------------------------------------
> > swapoff/1394 is leaving the kernel with locks still held!
> > 1 lock held by swapoff/1394:
> >  #0:  (rcu_read_lock){.+.+.+}, at: [<ffffffff812520a1>] radix_tree_locate_item+0x1f/0x2b6
> > after which the system recovered nicely.
> > 
> > Whoops, I long ago forgot the rcu_read_unlock() on one unlikely branch.
> > 
> > Fixes: e504f3fdd63d ("tmpfs radix_tree: locate_item to speed up swapoff")
> 
> huh.  Venerable.  I'm surprised that such an obvious blooper wasn't
> spotted at review.  Why didn't anyone else hit this.

No surprise that it missed review, obvious though it is in the fix.

And not much surprise that noone else hit this: for most people, even
those using tmpfs and pushing out to swap, swapoff is just something
that happens shortly before the screen goes blank when you shutdown
(and, I haven't noticed how distros order it these days, but swapoff
is anyway better done after unmounting tmpfss, to avoid its slowness).

And it does need the swapped tmpfs file to be truncated or unlinked
while swapoff is searching through it racily with RCU lookups.

What puzzled me more was, why hadn't I seen it before?  I don't run
that fsx test particularly often, but have certainly run it dozens
of times between then and now.  I think the answer must be where I
said "after which the system recovered nicely": I probably did hit
it before, but wasn't attending to the screen at the time, the
warnings got scrolled off by timestamps I was printing, and I
failed to check dmesg or /var/log/messages afterwards.

> 
> 
> > Of course, the truth is that I had been hoping to break Johannes's
> > patchset in mmotm, was thrilled to get this on that, then despondent
> > to realize that the only bug I had found was mine.  Surprised I've
> > not seen it before in 2.5 years: tried again on 3.14-rc1, got the
> > same after 25 minutes.  Probably not serious enough for -stable,
> > but please can we slip the fix into 3.14 - sorry, Johannes's
> > mm-keep-page-cache-radix-tree-nodes-in-check.patch will need a refresh.
> 
> I fixed it up.

Thanks!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
