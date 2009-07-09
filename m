Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7918C6B0085
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 21:01:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n691E84O025482
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Jul 2009 10:14:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5611D45DE6F
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 10:14:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 29DD045DE6E
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 10:14:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A2811DB8040
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 10:14:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 69FCD1DB8037
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 10:14:04 +0900 (JST)
Date: Thu, 9 Jul 2009 10:12:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-Id: <20090709101219.17d8f8a3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090708173206.GN356@random.random>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com>
	<20090707084750.GX2714@wotan.suse.de>
	<20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090708173206.GN356@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Jul 2009 19:32:06 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

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
Hmm, scan & take diff & merge user pages in the kernel ?
IIUC, it can be only help if zero-page's life time are verrrry long.

> My only dislike is that zero page requires a flood of "if ()" new
> branches in fast paths that benefits nothing but badly written app,
> and that's the only reason I liked its removal.
> 
I'll take Linus's suggestion "use pte_special() in vm_normal_page()".
Then, "if()" will not increase so much as expected, flood.

In usual apps which doen't use any zero-page, following path will be checked.

 - "is this WRITE fault ?" in do_anonymous_page().
 - vm_normal_page() never finds pte_special() then no more "if"s.
 - get_user_pages() etc..will have more 2-3 if()s depends on passed flags.

Anyway, I'll reduce overheads as much as possible. please see v3.
pte_special() checks (which are already used) reduce "if()" to some extent.

> For goodly (and badly) written scientific app there KSM that will do
> more than zeropage while dealing with matrix algorithms and such. If
> they try KSM and they don't gain a lot more free memory than with the
> zero page hack, then I agree in reintroducing it, but I guess when
> they try KSM they will ask you to patch kernel with it, instead of
> patch kernel with zeropage. 

Most of the difference between zeropage and KSM solution is that
zeropage requires no refcnt/rmap handling, never pollutes caches, etc.
This will be big advantage.

> If they don't gain anything more with KSM
> than with zeropage, and the kksmd overhead is too high, then it would
> make sense to use zeropage for them I agree even if it bites in the
> fast path of all apps that can't benefit from it. (not to tell the
> fact that reading zero and writing non zero back for normal apps is
> harmful as there's a double page fault generated instead of a single
> one, kksmd has a cost but zeropage isn't free either in term of page
> faults too)
> 
Sorry, my _all_ customers use RHEL5 and there are no ksm yet.

BTW, I love concepts of KSM but I don't trust KSM so much as that I recommend
it to my customers, yet. It's a bit young for production in my point of view.
AFAIK, no bug reports of ksm has reached this mailing list, yet.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
