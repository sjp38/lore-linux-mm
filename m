Date: Tue, 9 Sep 2008 14:40:07 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 6/14]  memcg: lockless page cgroup
Message-Id: <20080909144007.48e6633a.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080822203551.598a263c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203551.598a263c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Aug 2008 20:35:51 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> This patch removes lock_page_cgroup(). Now, page_cgroup is guarded by RCU.
> 
> To remove lock_page_cgroup(), we have to confirm there is no race.
> 
> Anon pages:
> * pages are chareged/uncharged only when first-mapped/last-unmapped.
>   page_mapcount() handles that.
>    (And... pte_lock() is always held in any racy case.)
> 
> Swap pages:
>   There will be race because charge is done before lock_page().
>   This patch moves mem_cgroup_charge() under lock_page().
> 
> File pages: (not Shmem)
> * pages are charged/uncharged only when it's added/removed to radix-tree.
>   In this case, PageLock() is always held.
> 
> Install Page:
>   Is it worth to charge this special map page ? which is (maybe) not on LRU.
>   I think no.
>   I removed charge/uncharge from install_page().
> 
> Page Migration:
>   We precharge it and map it back under lock_page(). This should be treated
>   as special case.
> 
> freeing page_cgroup is done under RCU.
> 
> After this patch, page_cgroup can be accesced via struct page->page_cgroup
> under following conditions.
> 
> 1. The page is file cache and on radix-tree.
>    (means lock_page() or mapping->tree_lock is held.)
> 2. The page is anounymous page and mapped.
>    (means pte_lock is held.)
> 3. under RCU and the page_cgroup is not Obsolete.
> 
> Typical style of "3" is following.
> **
> 	rcu_read_lock();
> 	pc = page_get_page_cgroup(page);
> 	if (pc && !PcgObsolete(pc)) {
> 		......
> 	}
> 	rcu_read_unlock();
> **
> 
> This is now under test. Don't apply if you're not brave.
> 
> Changelog: (v1) -> (v2)
>  - Added Documentation.
> 
> Changelog: (preview) -> (v1)
>  - Added comments.
>  - Fixed page migration.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 

(snip)

>  /*
> @@ -766,14 +724,9 @@ static int mem_cgroup_charge_common(stru
>  	} else
>  		__SetPcgActive(pc);
>  
> -	lock_page_cgroup(page);
> -	if (unlikely(page_get_page_cgroup(page))) {
> -		unlock_page_cgroup(page);
> -		res_counter_uncharge(&mem->res, PAGE_SIZE);
> -		css_put(&mem->css);
> -		kmem_cache_free(page_cgroup_cache, pc);
> -		goto done;
> -	}
> +	/* Double counting race condition ? */
> +	VM_BUG_ON(page_get_page_cgroup(page));
> +
>  	page_assign_page_cgroup(page, pc);
>  
>  	mz = page_cgroup_zoneinfo(pc);

I got this VM_BUG_ON at swapoff.

Trying to shmem_unuse_inode a page which has been moved
to swapcache by shmem_writepage causes this BUG, because
the page has not been uncharged(with all the patches applied).

I made a patch which changes shmem_unuse_inode to charge with
GFP_NOWAIT first and shrink usage on failure, as shmem_getpage does.

But I don't stick to my patch if you handle this case :)


Thanks,
Daisuke Nishimura.

====
Change shmem_unuse_inode to charge with GFP_NOWAIT first and
shrink usage on failure, as shmem_getpage does.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

---
diff --git a/mm/shmem.c b/mm/shmem.c
index 72b5f03..d37cd51 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -922,15 +922,10 @@ found:
 	error = 1;
 	if (!inode)
 		goto out;
-	/* Precharge page using GFP_KERNEL while we can wait */
-	error = mem_cgroup_cache_charge(page, current->mm, GFP_KERNEL);
-	if (error)
-		goto out;
+retry:
 	error = radix_tree_preload(GFP_KERNEL);
-	if (error) {
-		mem_cgroup_uncharge_cache_page(page);
+	if (error)
 		goto out;
-	}
 	error = 1;
 
 	spin_lock(&info->lock);
@@ -938,9 +933,17 @@ found:
 	if (ptr && ptr->val == entry.val) {
 		error = add_to_page_cache_locked(page, inode->i_mapping,
 						idx, GFP_NOWAIT);
-		/* does mem_cgroup_uncharge_cache_page on error */
-	} else	/* we must compensate for our precharge above */
-		mem_cgroup_uncharge_cache_page(page);
+		if (error == -ENOMEM) {
+			if (ptr)
+				shmem_swp_unmap(ptr);
+			spin_unlock(&info->lock);
+			radix_tree_preload_end();
+			error = mem_cgroup_shrink_usage(current->mm, GFP_KERNEL);
+			if (error)
+				goto out;
+			goto retry;
+		}
+	}
 
 	if (error == -EEXIST) {
 		struct page *filepage = find_get_page(inode->i_mapping, idx);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
