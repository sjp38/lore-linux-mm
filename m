Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 678626B005A
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 19:14:54 -0500 (EST)
Date: Wed, 28 Nov 2012 16:14:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: kswapd craziness in 3.7
Message-Id: <20121128161452.c1ddc9a3.akpm@linux-foundation.org>
In-Reply-To: <20121128235412.GW8218@suse.de>
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org>
	<CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com>
	<50B52DC4.5000109@redhat.com>
	<20121127214928.GA20253@cmpxchg.org>
	<50B5387C.1030005@redhat.com>
	<20121127222637.GG2301@cmpxchg.org>
	<CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com>
	<20121128101359.GT8218@suse.de>
	<20121128145215.d23aeb1b.akpm@linux-foundation.org>
	<20121128235412.GW8218@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 28 Nov 2012 23:54:12 +0000
Mel Gorman <mgorman@suse.de> wrote:

> On Wed, Nov 28, 2012 at 02:52:15PM -0800, Andrew Morton wrote:
> > On Wed, 28 Nov 2012 10:13:59 +0000
> > Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > Based on the reports I've seen I expect the following to work for 3.7
> > > 
> > > Keep
> > >   96710098 mm: revert "mm: vmscan: scale number of pages reclaimed by reclaim/compaction based on failures"
> > >   ef6c5be6 fix incorrect NR_FREE_PAGES accounting (appears like memory leak)
> > > 
> > > Revert
> > >   82b212f4 Revert "mm: remove __GFP_NO_KSWAPD"
> > > 
> > > Merge
> > >   mm: vmscan: fix kswapd endless loop on higher order allocation
> > >   mm: Avoid waking kswapd for THP allocations when compaction is deferred or contended
> > 
> > "mm: Avoid waking kswapd for THP ..." is marked "I have not tested it
> > myself" and when Zdenek tested it he hit an unexplained oom.
> > 
> 
> I thought Zdenek was testing with __GFP_NO_KSWAPD when he hit that OOM.
> Further, when he hit that OOM, it looked like a genuine OOM. He had no
> swap configured and inactive/active file pages were very low. Finally,
> the free pages for Normal looked off and could also have been affected by
> the accounting bug. I'm looking at https://lkml.org/lkml/2012/11/18/132
> here. Are you thinking of something else?

who, me, think?  I was trying to work out why I hadn't merged or queued
a patch which you felt was important.  Turned out it was because it
didn't look very tested and final.

> I have not tested with the patch admittedly but Thorsten has and seemed
> to be ok with it https://lkml.org/lkml/2012/11/23/276.

OK, I'll queue revert-revert-mm-remove-__gfp_no_kswapd.patch and the
patch from https://patchwork.kernel.org/patch/1728081/.

So what I'm currently sitting on for 3.7 is

mm-compaction-fix-return-value-of-capture_free_page.patch
mm-vmemmap-fix-wrong-use-of-virt_to_page.patch
mm-vmscan-fix-endless-loop-in-kswapd-balancing.patch
revert-revert-mm-remove-__gfp_no_kswapd.patch
mm-avoid-waking-kswapd-for-thp-allocations-when-compaction-is-deferred-or-contended.patch
mm-soft-offline-split-thp-at-the-beginning-of-soft_offline_page.patch

> > Please identify "Johannes' patch"?
> 
> mm: vmscan: fix kswapd endless loop on higher order allocation

OK, we have that.  I'll start a round of testing, do another -next drop
and send the above Linuswards tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
