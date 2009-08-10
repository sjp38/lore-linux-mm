Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 797586B004D
	for <linux-mm@kvack.org>; Sun,  9 Aug 2009 20:16:46 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7A0GmoX021116
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 10 Aug 2009 09:16:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A761A45DE50
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 09:16:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 78A4745DE4C
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 09:16:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CE0A1DB8040
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 09:16:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D2DE11DB8041
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 09:16:47 +0900 (JST)
Date: Mon, 10 Aug 2009 09:14:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] ZERO_PAGE again v5.
Message-Id: <20090810091458.1e889cdc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0908091753250.30153@sister.anvils>
References: <20090805191643.2b11ae78.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0908091753250.30153@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 9 Aug 2009 18:28:48 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Wed, 5 Aug 2009, KAMEZAWA Hiroyuki wrote:
> > Updated from v4 as
> >   - avoid to add new arguments to vm_normal_page().
> >     vm_normal_page() always returns NULL if ZERO_PAGE is found.
> >   - follow_page() directly handles pte_special and ANON_ZERO_PAGE.
> > 
> > Then, amount of changes are reduced. Thanks for advices.
> > 
> > Concerns pointed out:
> >   - Does use_zero_page() cover all cases ?
> >     I think yes..
> >   - All get_user_pages() callers, which may find ZERO_PAGE is safe ?
> >     need tests.
> >   - All follow_pages() callers, which may find ZERO_PAGE is safe ?
> >     I think yes.
> 
> Sorry, KAMEZAWA-san, I'm afraid this is still some way off being right.
> 
> Certainly the extent of the v5 patch is much more to my taste than v4
> was, thank you.
> 
At first, thank you for review.

> Something that's missing, which we can get away with but probably
> need to reinstate, is the shortcut when COWing: not to copy the
> ZERO_PAGE, but just do a memset.
> 
> But just try mlock'ing a private readonly anon area into which you've
> faulted a zero page, and the "BUG: Bad page map" message tells us
> it's quite wrong to be trying use_zero_page() there.
> 
> Actually, I don't understand ignore_zero at all: it's used solely by
> the mlock case, yet its effect seems to be precisely not to fault in
> pages if they're missing - I wonder if you've got in a muddle between
> the two very different awkward cases, mlocking and coredumps of
> sparsely populated areas.
> 
Ah, then, you say mlock() should allocate 'real' page if zero page
is mapped. Right ?

"How to handle mlock" is a concern for me, too. But I selected this
to allow the same behavior to old kernels.

> And I don't at all like the way you flush_dcache_page(page) on a
> page which may now be NULL: okay, you're only encouraging x86 to
> say Yes to the Kconfig option, but that's a landmine for the first
> arch with a real flush_dcache_page(page) which says Yes to it.
> 
do_wp_page()
	-> cow_user_page()
		-> (src is NULL)
Ah....ok, it's bug. I added ....Sorry, I didn't see this in older version
and missed this.

> Actually, the Kconfig stuff seems silly to me (who's going to know
> how to choose on or off?): the only architecture which wanted more
> than one ZERO_PAGE was MIPS, and it doesn't __HAVE_ARCH_PTE_SPECIAL
> yet, so I think I'm going to drop all the Kconfig end of it.
> 
ok, I have no strong demands on it.

> Because I hate reviewing things and trying to direct other people
> by remote control: what usually happens is I send them off in some
> direction which, once I try to do it myself, turns out to have been
> the wrong direction.  I do need to try to do this myself, instead of
> standing on the sidelines criticizing.
> 
> In fairness, I think Linus himself was a little confused when he
> separated off use_zero_page(): I think we've all got confused around
> there (as we noticed a month or so ago when discussing its hugetlb
> equivalent), and I need to think it through again at last.
> 
> I'll get on to it now.
> 

Thank you for comments. I'll go to a trip until Aug/17, programming-camp,
I'll be able to consider this patch and the whole things aroung paging in calm
enviroment. I'll try to restart from scratch.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
