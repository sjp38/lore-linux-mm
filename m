Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 2D7E16B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 19:59:07 -0400 (EDT)
Received: by iajr24 with SMTP id r24so6351755iaj.14
        for <linux-mm@kvack.org>; Thu, 15 Mar 2012 16:59:06 -0700 (PDT)
Date: Thu, 15 Mar 2012 16:58:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/7 v2] mm: rework __isolate_lru_page() file/anon
 filter
In-Reply-To: <4F618645.8020507@openvz.org>
Message-ID: <alpine.LSU.2.00.1203151618150.1291@eggly.anvils>
References: <20120229091547.29236.28230.stgit@zurg> <20120303091327.17599.80336.stgit@zurg> <alpine.LSU.2.00.1203061904570.18675@eggly.anvils> <20120308143034.f3521b1e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1203081758490.18195@eggly.anvils>
 <4F59AE3C.5040200@openvz.org> <alpine.LSU.2.00.1203091559260.23317@eggly.anvils> <4F5AFAF0.6060608@openvz.org> <4F5B22DE.4020402@openvz.org> <alpine.LSU.2.00.1203141842490.2232@eggly.anvils> <4F618645.8020507@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 15 Mar 2012, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > On Sat, 10 Mar 2012, Konstantin Khlebnikov wrote:
> > > Konstantin Khlebnikov wrote:
> > > 
> > > Heh, looks like we don't need these checks at all:
> > > without RECLAIM_MODE_LUMPYRECLAIM we isolate only pages from right lru,
> > > with RECLAIM_MODE_LUMPYRECLAIM we isolate pages from all evictable lru.
> > > Thus we should check only PageUnevictable() on lumpy reclaim.
> > 
> > Yes, those were great simplfying insights: I'm puzzling over why you
> > didn't follow through on them in your otherwise nice 4.5/7, which
> > still involves lru bits in the isolate mode?
> 
> Actually filter is required for single case: lumpy isolation for
> shrink_active_list().
> Maybe I'm wrong,

You are right.  I thought you were wrong, but testing proved you right.

> or this is bug, but I don't see any reasons why this can not happen:

It's very close to being a bug: perhaps I'd call it overlooked silliness.

> sc->reclaim_mode manipulations are very tricky.

And you are right on that too.  Particularly those reset_reclaim_mode()s
in shrink_page_list(), when the set_reclaim_mode() is done at the head of
shrink_inactive_list().

With no set_reclaim_mode() or reset_reclaim_mode() in shrink_active_list(),
so its isolate_lru_pages() test for RECLAIM_MODE_LUMPYRECLAIM just picks up
whatever sc->reclaim_mode was left over from earlier shrink_inactive_list().

Or none: the age_active_anon() call to shrink_active_list() never sets
sc->reclaim_mode, and is lucky that the only test for RECLAIM_MODE_SINGLE
is in code that it won't reach.

(Or maybe I've got some of those details wrong again, it's convoluted.)

I contend that what we want is

--- next/mm/vmscan.c	2012-03-13 03:52:15.360030839 -0700
+++ linux/mm/vmscan.c	2012-03-15 14:53:47.035519540 -0700
@@ -1690,6 +1690,8 @@ static void shrink_active_list(unsigned
 
 	lru_add_drain();
 
+	reset_reclaim_mode(sc);
+
 	if (!sc->may_unmap)
 		isolate_mode |= ISOLATE_UNMAPPED;
 	if (!sc->may_writepage)

but admit that's a slight change in behaviour - though I think only
a sensible one.  It's silly to embark upon lumpy reclaim of adjacent
pages, while tying your hands to pull only from file for file or from
anon for anon (though not so silly to restrict in/activity).

Shrinking the active list is about repopulating an inactive list when
it's low: shrinking the active list is not going to free any pages
(except when they're concurrently freed while it holds them isolated),
it's just going to move them to inactive; so aiming for adjacency at
this stage is pointless.  Counter-productive even: if it's going to
make any contribution to the lumpy reclaim, it should be populating
the inactive list with a variety of good candidates to seed the next
lump (whose adjacent pages will be isolated whichever list they're on):
by populating with adjacent pages itself, it lowers the chance of
later success, and increases the perturbation of lru-ness.

And if we do a reset_reclaim_mode(sc) in shrink_active_list(), then you
can remove the leftover lru stuff which spoils the simplicity of 4.5/7.

But you are right not to mix such a change in with your reorganization:
would you like to add the patch above into your series as a separate
patch (Cc Rik and Mel), or would you like me to send it separately
for discusssion, or do you see reason to disagree with it?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
