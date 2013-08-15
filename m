Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 8B9C26B0034
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 11:14:18 -0400 (EDT)
Date: Thu, 15 Aug 2013 17:14:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Bug] Reproducible data corruption on i5-3340M: Please revert
 53a59fc67!
Message-ID: <20130815151416.GF27864@dhcp22.suse.cz>
References: <520BB225.8030807@gmail.com>
 <20130814174039.GA24033@dhcp22.suse.cz>
 <CA+55aFwAz7GdcB6nC0Th42y8eAM591sKO1=mYh5SWgyuDdHzcA@mail.gmail.com>
 <20130814182756.GD24033@dhcp22.suse.cz>
 <CA+55aFxB6Wyj3G3Ju8E7bjH-706vi3vysuATUZ13h1tdYbCbnQ@mail.gmail.com>
 <520C9E78.2020401@gmail.com>
 <CA+55aFy2D2hTc_ina1DvungsCL4WU2OTM=bnVb8sDyDcGVCBEQ@mail.gmail.com>
 <20130815134031.GC27864@dhcp22.suse.cz>
 <20130815144600.GD27864@dhcp22.suse.cz>
 <20130815145332.GE27864@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130815145332.GE27864@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ben Tebulin <tebulin@googlemail.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Thu 15-08-13 16:53:32, Michal Hocko wrote:
> On Thu 15-08-13 16:46:00, Michal Hocko wrote:
> > On Thu 15-08-13 15:40:31, Michal Hocko wrote:
> > > On Thu 15-08-13 05:02:31, Linus Torvalds wrote:
> > > > On Thu, Aug 15, 2013 at 2:25 AM, Ben Tebulin <tebulin@googlemail.com> wrote:
> > > > >
> > > > > I just cherry-picked e6c495a96ce0 into 3.9.11 and 3.7.10.
> > > > > Unfortunately this does _not resolve_ my issue (too good to be true) :-(
> > > > 
> > > > Ho humm. I've found at least one other bug, but that one only affects
> > > > hugepages. Do you perhaps have transparent hugepages enabled? But even
> > > > then it looks quite unlikely.
> > > 
> > > __unmap_hugepage_range is hugetlb not THP if you had that one in mind.
> > > And yes, it doesn't set the range which sounds buggy.
> > 
> > Or, did you mean tlb_remove_page called from zap_huge_pmd? That one
> > should be safe as tlb_remove_pmd_tlb_entry sets need_flush and that
> > means that the full range is flushed.
> 
> Dohh... But we need need_flush_all and that is not set here. So this
> really looks buggy.

This is a really dumb attempt to fix this but maybe it is worth trying
to confirm we are really seeing this problem. It still flushes too much
potentially but I am not sure how to find out the proper start...
Will think about it more.
---
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a92012a..a16f452 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1381,7 +1381,11 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			VM_BUG_ON(!PageHead(page));
 			tlb->mm->nr_ptes--;
 			spin_unlock(&tlb->mm->page_table_lock);
-			tlb_remove_page(tlb, page);
+			if (!__tlb_remove_page(tlb, page)) {
+				tlb->start = 0;
+				tlb->end = addr + HPAGE_SIZE;
+				tlb_flush_mmu(tlb);
+			}
 		}
 		pte_free(tlb->mm, pgtable);
 		ret = 1;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
