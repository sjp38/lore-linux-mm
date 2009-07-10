Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9F7F36B009B
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 06:54:41 -0400 (EDT)
Date: Fri, 10 Jul 2009 12:18:07 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
In-Reply-To: <20090708173206.GN356@random.random>
Message-ID: <Pine.LNX.4.64.0907101201280.2456@sister.anvils>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
 <20090707084750.GX2714@wotan.suse.de> <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com>
 <20090708173206.GN356@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, avi@redhat.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 2009, Andrea Arcangeli wrote:
> On Tue, Jul 07, 2009 at 06:06:29PM +0900, KAMEZAWA Hiroyuki wrote:
> > Then,  most of users will not notice that ZERO_PAGE is not available until
> > he(she) find OOM-Killer message. This is very terrible situation for me.
> > (and most of system admins.)
> 
> Can you try to teach them to use KSM and see if they gain a while lot
> more from it (surely they also do some memset(dst, 0) sometime not
> only memcpy(zerosrc, dst)). Not to tell when they init to non zero
> values their arrays/matrix which is a bit harder to optimize for with
> zero page...
> 
> My only dislike is that zero page requires a flood of "if ()" new
> branches in fast paths that benefits nothing but badly written app,
> and that's the only reason I liked its removal.
> 
> For goodly (and badly) written scientific app there KSM that will do
> more than zeropage while dealing with matrix algorithms and such. If
> they try KSM and they don't gain a lot more free memory than with the
> zero page hack, then I agree in reintroducing it, but I guess when
> they try KSM they will ask you to patch kernel with it, instead of
> patch kernel with zeropage. If they don't gain anything more with KSM
> than with zeropage, and the kksmd overhead is too high, then it would
> make sense to use zeropage for them I agree even if it bites in the
> fast path of all apps that can't benefit from it. (not to tell the
> fact that reading zero and writing non zero back for normal apps is
> harmful as there's a double page fault generated instead of a single
> one, kksmd has a cost but zeropage isn't free either in term of page
> faults too)

Much as I like KSM, I have to agree with Avi, that if people are
wanting the ZERO_PAGE back in compute-intensive loads, then relying
on ksmd to put Humpty Dumpty together again is much too expensive a
way to go about it: ZERO_PAGE saves him from falling off the wall
in the first place, and that's much the better way to deal with it.

It might turn out in the end to be convenient to treat the ZERO_PAGE
as an "automatic" KSM page, I don't know; or we'll need to teach KSM
not to waste its time remerging instances of the ZERO_PAGE to a
zeroed KSM page.  We'll worry about that once both sets in mmotm.
 
I didn't care for Kamezawa-san's original patchsets, seemed messy
and branchy, but it looks to be heading the right way now using
vm_normal_page (pity about arches without pte_special, oh well).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
