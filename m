Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id E62AC6B0037
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 09:44:07 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id z2so9445667wiv.11
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 06:44:07 -0700 (PDT)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id ej7si3336608wib.61.2014.09.25.06.44.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Sep 2014 06:44:06 -0700 (PDT)
Received: by mail-wg0-f52.google.com with SMTP id n12so6263250wgh.35
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 06:44:06 -0700 (PDT)
Date: Thu, 25 Sep 2014 15:44:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/3] mm: memcontrol: do not kill uncharge batching in
 free_pages_and_swap_cache
Message-ID: <20140925134403.GA11080@dhcp22.suse.cz>
References: <1411571338-8178-1-git-send-email-hannes@cmpxchg.org>
 <1411571338-8178-2-git-send-email-hannes@cmpxchg.org>
 <20140924124234.3fdb59d6cdf7e9c4d6260adb@linux-foundation.org>
 <20140924210322.GA11017@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140924210322.GA11017@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 24-09-14 17:03:22, Johannes Weiner wrote:
[...]
> In release_pages, break the lock at least every SWAP_CLUSTER_MAX (32)
> pages, then remove the batching from free_pages_and_swap_cache.

Actually I had something like that originally but then decided to
not change the break out logic to prevent from strange and subtle
regressions. I have focused only on the memcg batching POV and led the
rest untouched.

I do agree that lru_lock batching can be improved as well. Your change
looks almost correct but you should count all the pages while the lock
is held otherwise you might happen to hold the lock for too long just
because most pages are off the LRU already for some reason. At least
that is what my original attempt was doing. Something like the following
on top of the current patch:
---
diff --git a/mm/swap.c b/mm/swap.c
index 39affa1932ce..8a12b33936b4 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -911,13 +911,22 @@ void release_pages(struct page **pages, int nr, bool cold)
 		if (unlikely(PageCompound(page))) {
 			if (zone) {
 				spin_unlock_irqrestore(&zone->lru_lock, flags);
-				lock_batch = 0;
 				zone = NULL;
 			}
 			put_compound_page(page);
 			continue;
 		}
 
+		/*
+		 * Make sure the IRQ-safe lock-holding time does not get
+		 * excessive with a continuous string of pages from the
+		 * same zone. The lock is held only if zone != NULL.
+		 */
+		if (zone && ++lock_batch == SWAP_CLUSTER_MAX) {
+			spin_unlock_irqrestore(&zone->lru_lock, flags);
+			zone = NULL;
+		}
+
 		if (!put_page_testzero(page))
 			continue;
 
@@ -937,16 +946,6 @@ void release_pages(struct page **pages, int nr, bool cold)
 			VM_BUG_ON_PAGE(!PageLRU(page), page);
 			__ClearPageLRU(page);
 			del_page_from_lru_list(page, lruvec, page_off_lru(page));
-
-			/*
-			 * Make sure the IRQ-safe lock-holding time
-			 * does not get excessive with a continuous
-			 * string of pages from the same zone.
-			 */
-			if (++lock_batch == SWAP_CLUSTER_MAX) {
-				spin_unlock_irqrestore(&zone->lru_lock, flags);
-				zone = NULL;
-			}
 		}
 
 		/* Clear Active bit in case of parallel mark_page_accessed */
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
