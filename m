Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 539CB6B0253
	for <linux-mm@kvack.org>; Wed, 18 May 2016 11:24:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a17so16476445wme.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 08:24:26 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id p184si33955457wmp.18.2016.05.18.08.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 08:24:25 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n129so13814303wmn.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 08:24:24 -0700 (PDT)
Date: Wed, 18 May 2016 17:24:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 06/13] mm, thp: remove __GFP_NORETRY from khugepaged and
 madvised allocations
Message-ID: <20160518152423.GK21654@dhcp22.suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-7-git-send-email-vbabka@suse.cz>
 <20160512162043.GA4261@dhcp22.suse.cz>
 <57358F03.5080707@suse.cz>
 <20160513120558.GL20141@dhcp22.suse.cz>
 <573C5939.1080909@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <573C5939.1080909@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Wed 18-05-16 13:59:53, Vlastimil Babka wrote:
> On 05/13/2016 02:05 PM, Michal Hocko wrote:
> > On Fri 13-05-16 10:23:31, Vlastimil Babka wrote:
> >> On 05/12/2016 06:20 PM, Michal Hocko wrote:
> >>> On Tue 10-05-16 09:35:56, Vlastimil Babka wrote:
> >>> [...]
> >>>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> >>>> index 570383a41853..0cb09714d960 100644
> >>>> --- a/include/linux/gfp.h
> >>>> +++ b/include/linux/gfp.h
> >>>> @@ -256,8 +256,7 @@ struct vm_area_struct;
> >>>>    #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
> >>>>    #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
> >>>>    #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> >>>> -			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
> >>>> -			 ~__GFP_RECLAIM)
> >>>> +			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
> >>>
> >>> I am not sure this is the right thing to do. I think we should keep
> >>> __GFP_NORETRY and clear it where we want a stronger semantic. This is
> >>> just too suble that all callsites are doing the right thing.
> >>
> >> That would complicate alloc_hugepage_direct_gfpmask() a bit, but if you
> >> think it's worth it, I can turn the default around, OK.
> > 
> > Hmm, on the other hand it is true that GFP_TRANSHUGE is clearing both
> > reclaim flags by default and then overwrites that. This is just too
> > ugly. Can we make GFP_TRANSHUGE to only define flags we care about and
> > then tweak those that should go away at the callsites which matter now
> > that we do not rely on is_thp_gfp_mask?
>  
> So the following patch attempts what you suggest, if I understand you
> correctly. GFP_TRANSHUGE includes all possible flag, and then they are
> removed as needed. I don't really think it helps code readability
> though.

yeah it is ugly has _hell_. I do not think this deserves too much time
to discuss as the flag is mostly internal but one last proposal would be
to define different THP allocations context explicitly. Some callers
would still need some additional meddling but maybe it would be slightly
better to read. Dunno. Anyway if you think this is not really an
improvement then I won't insist on any change to your original patch.
---
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 570383a41853..e7926b466107 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -255,9 +255,14 @@ struct vm_area_struct;
 #define GFP_DMA32	__GFP_DMA32
 #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
 #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
-#define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
+
+/* Optimistic or latency sensitive THP allocation - page fault path */
+#define GFP_TRANSHUGE_LIGHT	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
 			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
 			 ~__GFP_RECLAIM)
+/* More serious THP allocation request - kcompactd */
+#define GFP_TRANSHUGE (GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM) & \
+			~__GFP_NORETRY
 
 /* Convert GFP flags to their corresponding migrate type */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1a4d4c807d92..937b89c6c0aa 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -216,7 +216,7 @@ struct page *get_huge_zero_page(void)
 	if (likely(atomic_inc_not_zero(&huge_zero_refcount)))
 		return READ_ONCE(huge_zero_page);
 
-	zero_page = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE,
+	zero_page = alloc_pages((GFP_TRANSHUGE_LIGHT | __GFP_ZERO) & ~__GFP_MOVABLE,
 			HPAGE_PMD_ORDER);
 	if (!zero_page) {
 		count_vm_event(THP_ZERO_PAGE_ALLOC_FAILED);
@@ -888,23 +888,31 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
  */
 static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 {
-	gfp_t reclaim_flags = 0;
+	gfp_t gfp_mask = GFP_TRANSHUGE_LIGHT;
 
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags) &&
 	    (vma->vm_flags & VM_HUGEPAGE))
-		reclaim_flags = __GFP_DIRECT_RECLAIM;
+		gfp_mask = GFP_TRANSHUGE;
 	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
-		reclaim_flags = __GFP_KSWAPD_RECLAIM;
-	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		reclaim_flags = __GFP_DIRECT_RECLAIM;
+		gfp_mask |= __GFP_KSWAPD_RECLAIM;
+	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags)) {
+		if (vm->vm_flags & VM_HUGEPAGE)
+			gfp_mask = GFP_TRANSHUGE;
+		else
+			gfp_mask = GFP_TRANSHUGE | __GFP_NORETRY;
+	}
 
-	return GFP_TRANSHUGE | reclaim_flags;
+	return gfp_mask;
 }
 
 /* Defrag for khugepaged will enter direct reclaim/compaction if necessary */
 static inline gfp_t alloc_hugepage_khugepaged_gfpmask(void)
 {
-	return GFP_TRANSHUGE | (khugepaged_defrag() ? __GFP_DIRECT_RECLAIM : 0);
+	gfp_t gfp_mask = GFP_TRANSHUGE_LIGHT;
+	if (khugepaged_defrag())
+		gfp_mask = GFP_TRANSHUGE;
+
+	return gfp_mask;
 }
 
 /* Caller must hold page table lock. */
diff --git a/mm/migrate.c b/mm/migrate.c
index 53ab6398e7a2..1cd5c8c18343 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1771,7 +1771,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		goto out_dropref;
 
 	new_page = alloc_pages_node(node,
-		(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
+		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE) & ~__GFP_RECLAIM,
 		HPAGE_PMD_ORDER);
 	if (!new_page)
 		goto out_fail;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
