Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AF5746B004D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 22:42:49 -0400 (EDT)
Date: Fri, 19 Jun 2009 09:58:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 09/22] HWPOISON: Handle hardware poisoned pages in
	try_to_unmap
Message-ID: <20090619015838.GA6192@localhost>
References: <20090615152612.GA11700@localhost> <20090616090308.bac3b1f7.minchan.kim@barrios-desktop> <20090616134944.GB7524@localhost> <20090617092826.56730a10.minchan.kim@barrios-desktop> <20090617072319.GA5841@localhost> <28c262360906170644w65c08a8y2d2805fb08045804@mail.gmail.com> <20090617135543.GA8079@localhost> <28c262360906170703h3363b68dp74471358f647921e@mail.gmail.com> <20090618121430.GA6746@localhost> <28c262360906180631i25ea6a18mbdc5be31c2346c04@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360906180631i25ea6a18mbdc5be31c2346c04@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 18, 2009 at 09:31:52PM +0800, Minchan Kim wrote:
> On Thu, Jun 18, 2009 at 9:14 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> > On Wed, Jun 17, 2009 at 10:03:37PM +0800, Minchan Kim wrote:
> >> On Wed, Jun 17, 2009 at 10:55 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> >> > On Wed, Jun 17, 2009 at 09:44:39PM +0800, Minchan Kim wrote:
> >> >> It is private mail for my question.
> >> >> I don't want to make noise in LKML.
> >> >> And I don't want to disturb your progress to merge HWPoison.
> >> >>
> >> >> > Because this race window is small enough:
> >> >> >
> >> >> > A  A  A  A TestSetPageHWPoison(p);
> >> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  lock_page(page);
> >> >> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  try_to_unmap(page, TTU_MIGRATION|...);
> >> >> > A  A  A  A lock_page_nosync(p);
> >> >> >
> >> >> > such small race windows can be found all over the kernel, it's just
> >> >> > insane to try to fix any of them.
> >> >>
> >> >> I don't know there are intentional small race windows in kernel until you said.
> >> >> I thought kernel code is perfect so it wouldn't allow race window
> >> >> although it is very small. But you pointed out. Until now, My thought
> >> >> is wrong.
> >> >>
> >> >> Do you know else small race windows by intention ?
> >> >> If you know it, tell me, please. It can expand my sight. :)
> >> >
> >> > The memory failure code does not aim to rescue 100% page corruptions.
> >> > That's unreasonable goal - the kernel pages, slab pages (including the
> >> > big dcache/icache) are almost impossible to isolate.
> >> >
> >> > Comparing to the big slab pools, the migration and other race windows are
> >> > really too small to care about :)
> >>
> >> Also, If you will mention this contents as annotation, I will add my
> >> review sign.
> >
> > Good suggestion. Here is a patch for comment updates.
> >
> >> Thanks for kind reply for my boring discussion.
> >
> > Boring? Not at all :)
> >
> > Thanks,
> > Fengguang
> >
> > ---
> > A mm/memory-failure.c | A  76 +++++++++++++++++++++++++-----------------
> > A 1 file changed, 47 insertions(+), 29 deletions(-)
> >
> > --- sound-2.6.orig/mm/memory-failure.c
> > +++ sound-2.6/mm/memory-failure.c
> > @@ -1,4 +1,8 @@
> > A /*
> > + * linux/mm/memory-failure.c
> > + *
> > + * High level machine check handler.
> > + *
> > A * Copyright (C) 2008, 2009 Intel Corporation
> > A * Authors: Andi Kleen, Fengguang Wu
> > A *
> > @@ -6,29 +10,36 @@
> > A * the GNU General Public License ("GPL") version 2 only as published by the
> > A * Free Software Foundation.
> > A *
> > - * High level machine check handler. Handles pages reported by the
> > - * hardware as being corrupted usually due to a 2bit ECC memory or cache
> > - * failure.
> > - *
> > - * This focuses on pages detected as corrupted in the background.
> > - * When the current CPU tries to consume corruption the currently
> > - * running process can just be killed directly instead. This implies
> > - * that if the error cannot be handled for some reason it's safe to
> > - * just ignore it because no corruption has been consumed yet. Instead
> > - * when that happens another machine check will happen.
> > - *
> > - * Handles page cache pages in various states. The tricky part
> > - * here is that we can access any page asynchronous to other VM
> > - * users, because memory failures could happen anytime and anywhere,
> > - * possibly violating some of their assumptions. This is why this code
> > - * has to be extremely careful. Generally it tries to use normal locking
> > - * rules, as in get the standard locks, even if that means the
> > - * error handling takes potentially a long time.
> > - *
> > - * The operation to map back from RMAP chains to processes has to walk
> > - * the complete process list and has non linear complexity with the number
> > - * mappings. In short it can be quite slow. But since memory corruptions
> > - * are rare we hope to get away with this.
> > + * Pages are reported by the hardware as being corrupted usually due to a
> > + * 2bit ECC memory or cache failure. Machine check can either be raised when
> > + * corruption is found in background memory scrubbing, or when someone tries to
> > + * consume the corruption. This code focuses on the former case. A If it cannot
> > + * handle the error for some reason it's safe to just ignore it because no
> > + * corruption has been consumed yet. Instead when that happens another (deadly)
> > + * machine check will happen.
> > + *
> > + * The tricky part here is that we can access any page asynchronous to other VM
> > + * users, because memory failures could happen anytime and anywhere, possibly
> > + * violating some of their assumptions. This is why this code has to be
> > + * extremely careful. Generally it tries to use normal locking rules, as in get
> > + * the standard locks, even if that means the error handling takes potentially
> > + * a long time.
> > + *
> > + * We don't aim to rescue 100% corruptions. That's unreasonable goal - the
> > + * kernel text and slab pages (including the big dcache/icache) are almost
> > + * impossible to isolate. We also try to keep the code clean by ignoring the
> > + * other thousands of small corruption windows.
> 
> other thousands of small corruption windows(ex, migration, ...)
> As far as you know , please write down them.

Like this:

        new_page = alloc_page();
        <small corruption window>
        write to new_page
        <small corruption window>
        read from new_page

> Anyway, I already added my sign.
> Thanks for your effort never get exhausted. :)

You are welcome :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
