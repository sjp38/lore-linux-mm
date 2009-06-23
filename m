Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C5D036B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 07:04:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5NB4CSW032595
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Jun 2009 20:04:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C76E845DD7C
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 20:04:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A236445DE51
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 20:04:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D273E08008
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 20:04:12 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 20EB4E0800E
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 20:04:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: BUG: Bad page state [was: Strange oopses in 2.6.30]
In-Reply-To: <20090622091626.GA3981@csn.ul.ie>
References: <20090622113652.21E7.A69D9226@jp.fujitsu.com> <20090622091626.GA3981@csn.ul.ie>
Message-Id: <20090623200147.2236.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Jun 2009 20:04:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Jiri Slaby <jirislaby@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh@veritas.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Mon, Jun 22, 2009 at 11:39:53AM +0900, KOSAKI Motohiro wrote:
> > (cc to Mel and some reviewer)
> > 
> > > Flags are:
> > > 0000000000400000 -- __PG_MLOCKED
> > > 800000000050000c -- my page flags
> > >         3650000c -- Maxim's page flags
> > > 0000000000693ce1 -- my PAGE_FLAGS_CHECK_AT_FREE
> > 
> > I guess commit da456f14d (page allocator: do not disable interrupts in
> > free_page_mlock()) is a bit wrong.
> > 
> > current code is:
> > -------------------------------------------------------------
> > static void free_hot_cold_page(struct page *page, int cold)
> > {
> > (snip)
> >         int clearMlocked = PageMlocked(page);
> > (snip)
> >         if (free_pages_check(page))
> >                 return;
> > (snip)
> >         local_irq_save(flags);
> >         if (unlikely(clearMlocked))
> >                 free_page_mlock(page);
> > -------------------------------------------------------------
> > 
> > Oh well, we remove PG_Mlocked *after* free_pages_check().
> > Then, it makes false-positive warning.
> > 
> > Sorry, my review was also wrong. I think reverting this patch is better ;)
> > 
> 
> I think a revert is way overkill. The intention of the patch is sound -
> reducing the number of times interrupts are disabled. Having pages
> with the PG_locked bit is now somewhat of an expected situation. I'd
> prefer to go with either
> 
> 1. Unconditionally clearing the bit with TestClearPageLocked as the
>    patch already posted does
> 2. Removing PG_locked from the free_pages_check()
> 3. Unlocking the pages as we go when an mlocked VMA is being torn town
> 
> The patch that addresses 1 seemed ok to me. What do you think?

Yes, I've overlooked Hanns's patch. I think that is good patch.
Thansk folks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
