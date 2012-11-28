Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id B8B676B00A5
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:46:43 -0500 (EST)
Date: Wed, 28 Nov 2012 17:46:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121128164640.GB22201@dhcp22.suse.cz>
References: <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <50B403CA.501@jp.fujitsu.com>
 <20121127194813.GP24381@cmpxchg.org>
 <20121127205431.GA2433@dhcp22.suse.cz>
 <20121127205944.GB2433@dhcp22.suse.cz>
 <20121128152631.GT24381@cmpxchg.org>
 <20121128160447.GH12309@dhcp22.suse.cz>
 <20121128163736.GV24381@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121128163736.GV24381@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Wed 28-11-12 11:37:36, Johannes Weiner wrote:
> On Wed, Nov 28, 2012 at 05:04:47PM +0100, Michal Hocko wrote:
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index 095d2b4..5abe441 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -57,13 +57,14 @@ extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
> >  				gfp_t gfp_mask);
> >  /* for swap handling */
> >  extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
> > -		struct page *page, gfp_t mask, struct mem_cgroup **memcgp);
> > +		struct page *page, gfp_t mask, struct mem_cgroup **memcgp,
> > +		bool oom);
> 
> Ok, now I feel almost bad for asking, but why the public interface,
> too?

Would it work out if I tell it was to double check that your review
quality is not decreased after that many revisions? :P

Incremental update and the full patch in the reply
---
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 5abe441..8f48d5e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -57,8 +57,7 @@ extern int mem_cgroup_newpage_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
 /* for swap handling */
 extern int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-		struct page *page, gfp_t mask, struct mem_cgroup **memcgp,
-		bool oom);
+		struct page *page, gfp_t mask, struct mem_cgroup **memcgp);
 extern void mem_cgroup_commit_charge_swapin(struct page *page,
 					struct mem_cgroup *memcg);
 extern void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg);
@@ -218,8 +217,7 @@ static inline int mem_cgroup_cache_charge(struct page *page,
 }
 
 static inline int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
-		struct page *page, gfp_t gfp_mask, struct mem_cgroup **memcgp,
-		bool oom)
+		struct page *page, gfp_t gfp_mask, struct mem_cgroup **memcgp)
 {
 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 02a6d70..3c9b1c5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3789,8 +3789,7 @@ charge_cur_mm:
 }
 
 int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
-				 gfp_t gfp_mask, struct mem_cgroup **memcgp,
-				 bool oom)
+				 gfp_t gfp_mask, struct mem_cgroup **memcgp)
 {
 	*memcgp = NULL;
 	if (mem_cgroup_disabled())
@@ -3804,12 +3803,12 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm, struct page *page,
 	if (!PageSwapCache(page)) {
 		int ret;
 
-		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, memcgp, oom);
+		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, memcgp, true);
 		if (ret == -EINTR)
 			ret = 0;
 		return ret;
 	}
-	return __mem_cgroup_try_charge_swapin(mm, page, gfp_mask, memcgp, oom);
+	return __mem_cgroup_try_charge_swapin(mm, page, gfp_mask, memcgp, true);
 }
 
 void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *memcg)
diff --git a/mm/memory.c b/mm/memory.c
index afad903..6891d3b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2991,7 +2991,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 	}
 
-	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr, true)) {
+	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {
 		ret = VM_FAULT_OOM;
 		goto out_page;
 	}
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 8ec511e..2f8e429 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -828,7 +828,7 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	int ret = 1;
 
 	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page,
-					 GFP_KERNEL, &memcg, true)) {
+					 GFP_KERNEL, &memcg)) {
 		ret = -ENOMEM;
 		goto out_nolock;
 	}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
