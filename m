Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17D196B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 00:59:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b124so37601272pfb.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 21:59:56 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z67si55780276pfj.116.2016.06.01.21.59.54
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 21:59:55 -0700 (PDT)
Date: Thu, 2 Jun 2016 14:00:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
Message-ID: <20160602050039.GA3304@bbox>
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
 <20160524025811.GA29094@bbox>
 <20160526003719.GB9661@bbox>
 <8ae0197c-47b7-e5d2-20c3-eb9d01e6b65c@linaro.org>
 <20160527051432.GF2322@bbox>
 <20160527060839.GC13661@js1304-P5Q-DELUXE>
 <20160527081108.GG2322@bbox>
 <aa33f1e4-5a91-aaaf-70f1-557148b29b38@linaro.org>
 <20160530061117.GB28624@bbox>
 <b8858801-af06-9b80-1b29-f9ece515d1bf@linaro.org>
MIME-Version: 1.0
In-Reply-To: <b8858801-af06-9b80-1b29-f9ece515d1bf@linaro.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Jun 01, 2016 at 01:40:48PM -0700, Shi, Yang wrote:
> On 5/29/2016 11:11 PM, Minchan Kim wrote:
> >On Fri, May 27, 2016 at 11:16:41AM -0700, Shi, Yang wrote:
> >
> ><snip>
> >
> >>>
> >>>If we goes this way, how to guarantee this race?
> >>
> >>Thanks for pointing out this. It sounds reasonable. However, this
> >>should be only possible to happen on 32 bit since just 32 bit
> >>version page_is_idle() calls lookup_page_ext(), it doesn't do it on
> >>64 bit.
> >>
> >>And, such race condition should exist regardless of whether DEBUG_VM
> >>is enabled or not, right?
> >>
> >>rcu might be good enough to protect it.
> >>
> >>A quick fix may look like:
> >>
> >>diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
> >>index 8f5d4ad..bf0cd6a 100644
> >>--- a/include/linux/page_idle.h
> >>+++ b/include/linux/page_idle.h
> >>@@ -77,8 +77,12 @@ static inline bool
> >>test_and_clear_page_young(struct page *page)
> >> static inline bool page_is_idle(struct page *page)
> >> {
> >>        struct page_ext *page_ext;
> >>+
> >>+       rcu_read_lock();
> >>        page_ext = lookup_page_ext(page);
> >>+       rcu_read_unlock();
> >>+
> >>	if (unlikely(!page_ext))
> >>                return false;
> >>
> >>diff --git a/mm/page_ext.c b/mm/page_ext.c
> >>index 56b160f..94927c9 100644
> >>--- a/mm/page_ext.c
> >>+++ b/mm/page_ext.c
> >>@@ -183,7 +183,6 @@ struct page_ext *lookup_page_ext(struct page *page)
> >> {
> >>        unsigned long pfn = page_to_pfn(page);
> >>        struct mem_section *section = __pfn_to_section(pfn);
> >>-#if defined(CONFIG_DEBUG_VM) || defined(CONFIG_PAGE_POISONING)
> >>        /*
> >>         * The sanity checks the page allocator does upon freeing a
> >>         * page can reach here before the page_ext arrays are
> >>@@ -195,7 +194,7 @@ struct page_ext *lookup_page_ext(struct page *page)
> >>         */
> >>        if (!section->page_ext)
> >>                return NULL;
> >>-#endif
> >>+
> >>        return section->page_ext + pfn;
> >> }
> >>
> >>@@ -279,7 +278,8 @@ static void __free_page_ext(unsigned long pfn)
> >>                return;
> >>        base = ms->page_ext + pfn;
> >>        free_page_ext(base);
> >>-       ms->page_ext = NULL;
> >>+       rcu_assign_pointer(ms->page_ext, NULL);
> >>+       synchronize_rcu();
> >
> >How does it fix the problem?
> >I cannot understand your point.
> 
> Assigning NULL pointer to page_Ext will be blocked until
> rcu_read_lock critical section is done, so the lookup and writing
> operations will be serialized. And, rcu_read_lock disables preempt
> too.

I meant your rcu_read_lock in page_idle should cover test_bit op.
One more thing, you should use rcu_dereference.

As well, please cover memory onlining case I mentioned in another
thread as well as memory offlining.

Anyway, to me, every caller of page_ext should prepare lookup_page_ext
can return NULL anytime and they should use rcu_read_[un]lock, which
is not good. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
