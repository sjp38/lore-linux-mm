Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id D7B086B004F
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 10:37:43 -0500 (EST)
Date: Mon, 19 Dec 2011 16:37:38 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/4] memcg: clear pc->mem_cgorup if necessary.
Message-ID: <20111219153738.GC1415@cmpxchg.org>
References: <20111214164734.4d7d6d97.kamezawa.hiroyu@jp.fujitsu.com>
 <20111214165124.4d2cf723.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111214165124.4d2cf723.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Wed, Dec 14, 2011 at 04:51:24PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This is a preparation before removing a flag PCG_ACCT_LRU in page_cgroup
> and reducing atomic ops/complexity in memcg LRU handling.
> 
> In some cases, pages are added to lru before charge to memcg and pages
> are not classfied to memory cgroup at lru addtion. Now, the lru where
> the page should be added is determined a bit in page_cgroup->flags and
> pc->mem_cgroup. I'd like to remove the check of flag.
> 
> To handle the case pc->mem_cgroup may contain stale pointers if pages are
> added to LRU before classification. This patch resets pc->mem_cgroup to
> root_mem_cgroup before lru additions.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

The followup compilation fixes aside, I agree.  But the sites where
the owner is actually reset are really not too obvious.  How about the
comment patch below?

Otherwise,

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: memcg: clear pc->mem_cgorup if necessary fix

Add comments to the clearing sites.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/ksm.c b/mm/ksm.c
index 5c2f0bd..f0ee5bf 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1571,6 +1571,15 @@ struct page *ksm_does_need_to_copy(struct page *page,
 
 	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 	if (new_page) {
+		/*
+		 * The memcg-specific accounting when moving
+		 * pages around the LRU lists relies on the
+		 * page's owner (memcg) to be valid.  Usually,
+		 * pages are assigned to a new owner before
+		 * being put on the LRU list, but since this
+		 * is not the case here, the stale owner from
+		 * a previous allocation cycle must be reset.
+		 */
 		mem_cgroup_reset_owner(new_page);
 		copy_user_highpage(new_page, page, address, vma);
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 730c4c7..44ccfd2 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -302,6 +302,15 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			new_page = alloc_page_vma(gfp_mask, vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
+			/*
+			 * The memcg-specific accounting when moving
+			 * pages around the LRU lists relies on the
+			 * page's owner (memcg) to be valid.  Usually,
+			 * pages are assigned to a new owner before
+			 * being put on the LRU list, but since this
+			 * is not the case here, the stale owner from
+			 * a previous allocation cycle must be reset.
+			 */
 			mem_cgroup_reset_owner(new_page);
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
