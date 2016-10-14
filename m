Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCF616B025E
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 07:30:48 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id n3so69004343lfn.5
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 04:30:48 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id q22si7551171lfg.161.2016.10.14.04.30.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 04:30:47 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id l131so14834535lfl.0
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 04:30:47 -0700 (PDT)
Date: Fri, 14 Oct 2016 13:30:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161014113044.GB6063@dhcp22.suse.cz>
References: <1476340749-13281-1-git-send-email-ming.ling@spreadtrum.com>
 <20161013080936.GG21678@dhcp22.suse.cz>
 <20161014083219.GA20260@spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20161014083219.GA20260@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Ling <ming.ling@spreadtrum.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, minchan@kernel.org, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

On Fri 14-10-16 16:32:19, Ming Ling wrote:
> On a??, 10ae?? 13, 2016 at 10:09:37a,?a?? +0200, Michal Hocko wrote:
> Hello,
> > On Thu 13-10-16 14:39:09, ming.ling wrote:
> > > From: Ming Ling <ming.ling@spreadtrum.com>
> > > 
> > > Non-lru pages don't belong to any lru, so counting them to
> > > NR_ISOLATED_ANON or NR_ISOLATED_FILE doesn't make any sense.
> > > It may misguide functions such as pgdat_reclaimable_pages and
> > > too_many_isolated.
> > 
> > That doesn't make much sense to me. I guess you wanted to say something
> > like
> > "
> > Accounting non-lru pages isolated for migration during pfn walk to
> > NR_ISOLATED_{ANON,FILE} doesn't make any sense and it can misguide
> > heuristics based on those counters such as pgdat_reclaimable_pages resp.
> > too_many_isolated. Note that __alloc_contig_migrate_range can isolate
> > a lot of pages at once.
> > "
> Yesi 1/4 ?your understanding is right, and your description is clearer than
> mine. Do your mind if i borrow it as a comment of this patch in next
> version?

sure, go ahead

> > > On mobile devices such as 512M ram android Phone, it may use
> > > a big zram swap. In some cases zram(zsmalloc) uses too many
> > > non-lru pages, such as:
> > > 	MemTotal: 468148 kB
> > > 	Normal free:5620kB
> > > 	Free swap:4736kB
> > > 	Total swap:409596kB
> > > 	ZRAM: 164616kB(zsmalloc non-lru pages)
> > > 	active_anon:60700kB
> > > 	inactive_anon:60744kB
> > > 	active_file:34420kB
> > > 	inactive_file:37532kB
> > 
> > I assume those zsmalloc pages are migrateable and that is the problem?
> > Please state that explicitly so that even people not familiar with
> > zsmalloc understand the motivation.
> 
> Yes, since Minchan Kim had committed a??mm: migrate: support non-lru
> movable page migrationa??, those zsmalloc pages are migrateable now.
> And i will state that explicitly in next version.

OK

> > > More non-lru pages which used by zram for swap, it influences
> > > pgdat_reclaimable_pages and too_many_isolated more.
> > 
> > It would be good to mention what would be a visible effect of this.
> > "If the NR_ISOLATED_* is too large then the direct reclaim might get
> > throttled prematurely inducing longer allocation latencies without any
> > strong reason."
> > 
> I will detail the effect of counting so many non-lru pages into
> NR_ISOLATED_{ANON,FILE} such as:
>
> 'In function shrink_inactive_list, if there are too many isolated
> pages,it will wait for a moment. So If we miscounting large number
> non-lru pages into NR_ISOLATED_{ANON,FILE}, direct reclaim might
> getthrottled prematurely inducing longer allocation latencies
> without any strong reason. Actually there is no need to take non-lru
> pages into account in shrink_inactive_list which just deals with
> lru pages.

Note that this is true also for the direct compaction.

> In function pgdat_reclaimable_pages, you had considered isolated
> pages in zone_reclaimable_pages. So miscounting non-lru pages into
> NR_ISOLATED_{ANON,FILE} also larger zone_reclaimable_pages and will
> lead to a more optimistic zone_reclaimable judgement.

Which shouldn't be such a big deal.

> '
> > > This patch excludes isolated non-lru pages from NR_ISOLATED_ANON
> > > or NR_ISOLATED_FILE to ensure their counts are right.
> > 
> > But this patch doesn't do that. It just relies on __PageMovable. It is
> > true that all LRU pages should be movable (well except for
> > NR_UNEVICTABLE in certain configurations) but is it true that all
> > movable pages are on the LRU list?
> >
>
> I don't think so. In commit bda807d4 'mm: migrate: support non-lru
> movable page migration', Minchan Kim point out :
> 'For testing of non-lru movable page, VM supports __PageMovable function.
> However, it doesn't guarantee to identify non-lru movable page because
> page->mapping field is unified with other variables in struct page.  As
> well, if driver releases the page after isolation by VM, page->mapping
> doesn't have stable value although it has PAGE_MAPPING_MOVABLE (Look at
> __ClearPageMovable).  But __PageMovable is cheap to catch whether page
> is LRU or non-lru movable once the page has been isolated.  Because LRU
> pages never can have PAGE_MAPPING_MOVABLE in page->mapping.  It is also
> good for just peeking to test non-lru movable pages before more
> expensive checking with lock_page in pfn scanning to select victim.'.
> 
> And he uses __PageMovable to judge whether a isolated page is a lru page
> such as:
> void putback_movable_pages(struct list_head *l)
> {
> 	......
> 	/*
> 	 * We isolated non-lru movable page so here we can use
>  	 * __PageMovable because LRU page's mapping cannot have
> 	 * PAGE_MAPPING_MOVABLE.
> 	 */
> 	if (unlikely(__PageMovable(page))) {
> 		VM_BUG_ON_PAGE(!PageIsolated(page), page);
> 		lock_page(page);
> 		if (PageMovable(page))
> 			putback_movable_page(page);
> 		else
> 			__ClearPageIsolated(page);
> 		unlock_page(page);
> 		put_page(page);
> 	} else {
> 		putback_lru_page(page);
> 	}
> }

I am not familiar with this code enough to comment but to me it all
sounds quite subtle.

> > Why don't you simply mimic what shrink_inactive_list does? Aka count the
> > number of isolated pages and then account them when appropriate?
> >
> I think i am correcting clearly wrong part. So, there is no need to
> describe it too detailed. It's a misunderstanding, and i will add
> more comments as you suggest.

OK, so could you explain why you prefer to relyon __PageMovable rather
than do a trivial counting during the isolation?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
