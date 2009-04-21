Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4B28F6B0047
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:12:50 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3LAD0WX023991
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 19:13:00 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C3AC45DD72
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:13:00 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC6AF45DD74
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:12:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D1974E08001
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:12:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E470F1DB8013
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:12:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 10/25] Calculate the alloc_flags for allocation only once
In-Reply-To: <20090421100530.GN12713@csn.ul.ie>
References: <20090421165022.F13F.A69D9226@jp.fujitsu.com> <20090421100530.GN12713@csn.ul.ie>
Message-Id: <20090421190921.F15F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 19:12:57 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > > +	/* Avoid recursion of direct reclaim */
> > > +	if (p->flags & PF_MEMALLOC)
> > > +		goto nopage;
> > > +
> > 
> > Again. old code doesn't only check PF_MEMALLOC, but also check TIF_MEMDIE.
> > 
> 
> But a direct reclaim will have PF_MEMALLOC set and doesn't care about
> the value of TIF_MEMDIE with respect to recursion.
> 
> There is still a check made for TIF_MEMDIE for setting ALLOC_NO_WATERMARKS
> in gfp_to_alloc_flags() so that flag is still being taken care of.

Do you mean this is intentional change?
I only said there is changelog-less behavior change.

old code is here.
PF_MEMALLOC and TIF_MEMDIE makes goto nopage. it avoid reclaim.
-------------------------------------------------------------------------
rebalance:
        if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
                        && !in_interrupt()) {
                if (!(gfp_mask & __GFP_NOMEMALLOC)) {
nofail_alloc:
                        /* go through the zonelist yet again, ignoring mins */
                        page = get_page_from_freelist(gfp_mask, nodemask, order,
                                zonelist, high_zoneidx, ALLOC_NO_WATERMARKS);
                        if (page)
                                goto got_pg;
                        if (gfp_mask & __GFP_NOFAIL) {
                                congestion_wait(WRITE, HZ/50);
                                goto nofail_alloc;
                        }
                }
                goto nopage;
        }
-------------------------------------------------------------------------


but I don't oppose this change if it is your intentional.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
