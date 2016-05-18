Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7025C6B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 07:59:58 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ga2so22542222lbc.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 04:59:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t203si10608095wmg.31.2016.05.18.04.59.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 04:59:56 -0700 (PDT)
Subject: Re: [RFC 06/13] mm, thp: remove __GFP_NORETRY from khugepaged and
 madvised allocations
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
 <1462865763-22084-7-git-send-email-vbabka@suse.cz>
 <20160512162043.GA4261@dhcp22.suse.cz> <57358F03.5080707@suse.cz>
 <20160513120558.GL20141@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573C5939.1080909@suse.cz>
Date: Wed, 18 May 2016 13:59:53 +0200
MIME-Version: 1.0
In-Reply-To: <20160513120558.GL20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/13/2016 02:05 PM, Michal Hocko wrote:
> On Fri 13-05-16 10:23:31, Vlastimil Babka wrote:
>> On 05/12/2016 06:20 PM, Michal Hocko wrote:
>>> On Tue 10-05-16 09:35:56, Vlastimil Babka wrote:
>>> [...]
>>>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>>>> index 570383a41853..0cb09714d960 100644
>>>> --- a/include/linux/gfp.h
>>>> +++ b/include/linux/gfp.h
>>>> @@ -256,8 +256,7 @@ struct vm_area_struct;
>>>>    #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
>>>>    #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
>>>>    #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
>>>> -			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
>>>> -			 ~__GFP_RECLAIM)
>>>> +			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
>>>
>>> I am not sure this is the right thing to do. I think we should keep
>>> __GFP_NORETRY and clear it where we want a stronger semantic. This is
>>> just too suble that all callsites are doing the right thing.
>>
>> That would complicate alloc_hugepage_direct_gfpmask() a bit, but if you
>> think it's worth it, I can turn the default around, OK.
> 
> Hmm, on the other hand it is true that GFP_TRANSHUGE is clearing both
> reclaim flags by default and then overwrites that. This is just too
> ugly. Can we make GFP_TRANSHUGE to only define flags we care about and
> then tweak those that should go away at the callsites which matter now
> that we do not rely on is_thp_gfp_mask?
 
So the following patch attempts what you suggest, if I understand you
correctly. GFP_TRANSHUGE includes all possible flag, and then they are
removed as needed. I don't really think it helps code readability
though. IMHO it's simpler to define GFP_TRANSHUGE as minimal subset and
only add flags on top. You call the resulting #define ugly, but imho it's
better to have ugliness at a single place, and not at multiple usage places
(see the diff below).

Note that this also affects the printk stuff.
With GFP_TRANSHUGE including all possible flags, it's unlikely printk
will ever print "GFP_TRANSHUGE", since most likely one or more flags
will be always missing.

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 570383a41853..e1998eb5c37f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -256,8 +256,7 @@ struct vm_area_struct;
 #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
 #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
 #define GFP_TRANSHUGE	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
-			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN) & \
-			 ~__GFP_RECLAIM)
+			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN)
 
 /* Convert GFP flags to their corresponding migrate type */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87f09dc986ab..370fbd3b24dd 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -216,7 +216,8 @@ struct page *get_huge_zero_page(void)
 	if (likely(atomic_inc_not_zero(&huge_zero_refcount)))
 		return READ_ONCE(huge_zero_page);
 
-	zero_page = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE,
+	zero_page = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO)
+			& ~(__GFP_MOVABLE | __GFP_NORETRY),
 			HPAGE_PMD_ORDER);
 	if (!zero_page) {
 		count_vm_event(THP_ZERO_PAGE_ALLOC_FAILED);
@@ -882,9 +883,10 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 }
 
 /*
- * If THP is set to always then directly reclaim/compact as necessary
- * If set to defer then do no reclaim and defer to khugepaged
+ * If THP defrag is set to always then directly reclaim/compact as necessary
+ * If set to defer then do only background reclaim/compact and defer to khugepaged
  * If set to madvise and the VMA is flagged then directly reclaim/compact
+ * When direct reclaim/compact is allowed, try a bit harder for flagged VMA's
  */
 static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 {
@@ -896,15 +898,21 @@ static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
 	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
 		reclaim_flags = __GFP_KSWAPD_RECLAIM;
 	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		reclaim_flags = __GFP_DIRECT_RECLAIM;
+		reclaim_flags = __GFP_DIRECT_RECLAIM |
+					((vma->vm_flags & VM_HUGEPAGE) ? 0 : __GFP_NORETRY);
 
-	return GFP_TRANSHUGE | reclaim_flags;
+	return (GFP_TRANSHUGE & ~(__GFP_RECLAIM | __GFP_NORETRY)) | reclaim_flags;
 }
 
 /* Defrag for khugepaged will enter direct reclaim/compaction if necessary */
 static inline gfp_t alloc_hugepage_khugepaged_gfpmask(void)
 {
-	return GFP_TRANSHUGE | (khugepaged_defrag() ? __GFP_DIRECT_RECLAIM : 0);
+	/*
+	 * We don't want kswapd reclaim, and if khugepaged/defrag is disabled
+	 * we disable also direct reclaim. If we do direct reclaim, do retry.
+	 */
+	return GFP_TRANSHUGE & ~(khugepaged_defrag() ?
+			(__GFP_KSWAPD_RECLAIM | __GFP_NORETRY) : __GFP_RECLAIM);
 }
 
 /* Caller must hold page table lock. */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0cee863397e4..4a34187827ca 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3619,11 +3619,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 			/*
 			 * Looks like reclaim/compaction is worth trying, but
 			 * sync compaction could be very expensive, so keep
-			 * using async compaction, unless it's khugepaged
-			 * trying to collapse.
+			 * using async compaction.
 			 */
-			if (!(current->flags & PF_KTHREAD))
-				migration_mode = MIGRATE_ASYNC;
+			migration_mode = MIGRATE_ASYNC;
 		}
 	}
 
-- 
2.8.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
