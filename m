Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BDEA06B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 13:22:06 -0400 (EDT)
Date: Wed, 8 Jul 2009 19:32:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-ID: <20090708173206.GN356@random.random>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
 <20090707084750.GX2714@wotan.suse.de>
 <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 06:06:29PM +0900, KAMEZAWA Hiroyuki wrote:
> Then,  most of users will not notice that ZERO_PAGE is not available until
> he(she) find OOM-Killer message. This is very terrible situation for me.
> (and most of system admins.)

Can you try to teach them to use KSM and see if they gain a while lot
more from it (surely they also do some memset(dst, 0) sometime not
only memcpy(zerosrc, dst)). Not to tell when they init to non zero
values their arrays/matrix which is a bit harder to optimize for with
zero page...

My only dislike is that zero page requires a flood of "if ()" new
branches in fast paths that benefits nothing but badly written app,
and that's the only reason I liked its removal.

For goodly (and badly) written scientific app there KSM that will do
more than zeropage while dealing with matrix algorithms and such. If
they try KSM and they don't gain a lot more free memory than with the
zero page hack, then I agree in reintroducing it, but I guess when
they try KSM they will ask you to patch kernel with it, instead of
patch kernel with zeropage. If they don't gain anything more with KSM
than with zeropage, and the kksmd overhead is too high, then it would
make sense to use zeropage for them I agree even if it bites in the
fast path of all apps that can't benefit from it. (not to tell the
fact that reading zero and writing non zero back for normal apps is
harmful as there's a double page fault generated instead of a single
one, kksmd has a cost but zeropage isn't free either in term of page
faults too)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
