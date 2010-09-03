Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 150226B004D
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 20:33:58 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o83LlAbW022859
	for <linux-mm@kvack.org>; Fri, 3 Sep 2010 14:47:11 -0700
Received: from qwk4 (qwk4.prod.google.com [10.241.195.132])
	by kpbe14.cbf.corp.google.com with ESMTP id o83Ll9fZ002578
	for <linux-mm@kvack.org>; Fri, 3 Sep 2010 14:47:09 -0700
Received: by qwk4 with SMTP id 4so2087562qwk.9
        for <linux-mm@kvack.org>; Fri, 03 Sep 2010 14:47:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100903140649.09dee316.akpm@linux-foundation.org>
References: <1283096628-4450-1-git-send-email-minchan.kim@gmail.com>
	<20100903140649.09dee316.akpm@linux-foundation.org>
Date: Fri, 3 Sep 2010 14:47:03 -0700
Message-ID: <AANLkTimTpj+CSvGx=HC4qnArBV9jxORkKoDA9eap3_cN@mail.gmail.com>
Subject: Re: [PATCH] vmscan: prevent background aging of anon page in no swap system
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 3, 2010 at 2:06 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon, 30 Aug 2010 00:43:48 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
> > Ying Han reported that backing aging of anon pages in no swap system
> > causes unnecessary TLB flush.
> >
> > When I sent a patch(69c8548175), I wanted this patch but Rik pointed out
> > and allowed aging of anon pages to give a chance to promote from inactive
> > to active LRU.
> >
> > It has a two problem.
> >
> > 1) non-swap system
> >
> > Never make sense to age anon pages.
> >
> > 2) swap configured but still doesn't swapon
> >
> > It doesn't make sense to age anon pages until swap-on time.
> > But it's arguable. If we have aged anon pages by swapon, VM have moved
> > anon pages from active to inactive. And in the time swapon by admin,
> > the VM can't reclaim hot pages so we can protect hot pages swapout.
> >
> > But let's think about it. When does swap-on happen? It depends on admin.
> > we can't expect it. Nonetheless, we have done aging of anon pages to
> > protect hot pages swapout. It means we lost run time overhead when
> > below high watermark but gain hot page swap-[in/out] overhead when VM
> > decide swapout. Is it true? Let's think more detail.
> > We don't promote anon pages in case of non-swap system. So even though
> > VM does aging of anon pages, the pages would be in inactive LRU for a long
> > time. It means many of pages in there would mark access bit again. So access
> > bit hot/code separation would be pointless.
> >
> > This patch prevents unnecessary anon pages demotion in not-swapon and
> > non-configured swap system. Of course, it could make side effect that
> > hot anon pages could swap out when admin does swap on.
> > But I think sooner or later it would be steady state.
> > So it's not a big problem.
> > We could lose someting but gain more thing(TLB flush and unnecessary
> > function call to demote anon pages).
> >
> > I used total_swap_pages because we want to age anon pages
> > even though swap full happens.
>
> We don't have any quantitative data on the effect of these excess tlb
> flushes, which makes it difficult to decide which kernel versions
> should receive this patch.
>
> Help?

Andrew:

We observed the degradation on 2.6.34 compared to 2.6.26 kernel. The
workload we are running is doing 4k-random-write which runs about 3-4
minutes. We captured the TLB shootsdowns before/after:

Before the change:
TLB: 29435 22208 37146 25332 47952 43698 43545 40297 49043 44843 46127
50959 47592 46233 43698 44690 TLB shootdowns [HSUM =  662798 ]

After the change:
TLB: 2340 3113 1547 1472 2944 4194 2181 1212 2607 4373 1690 1446 2310
3784 1744 1134 TLB shootdowns [HSUM =  38091 ]

Also worthy to mention, we are running in fake numa system where each
fake node is 128M size. That makes differences on the check
inactive_anon_is_low() since the active/inactive ratio falls to 1.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
