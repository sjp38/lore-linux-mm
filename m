Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2CDE76B004A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 16:01:41 -0400 (EDT)
Date: Thu, 30 Jun 2011 13:01:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-Id: <20110630130134.63a1dd37.akpm@linux-foundation.org>
In-Reply-To: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Wed, 29 Jun 2011 19:03:25 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Each memory cgroup has 'swappiness' value and it can be accessed by
> get_swappiness(memcg). The major user is try_to_free_mem_cgroup_pages()
> and swappiness is passed by argument. It's propagated by scan_control.
> 
> get_swappiness is static function but some planned updates will need to
> get swappiness from files other than memcontrol.c
> This patch exports get_swappiness() as mem_cgroup_swappiness().
> By this, we can remove the argument of swapiness from try_to_free...
> and drop swappiness from scan_control. only memcg uses it.

x86_64 allnoconfig (aka Documentation/SubmitChecklist, section 2b):

mm/vmscan.c: In function 'vmscan_swappiness':
mm/vmscan.c:1734: error: implicit declaration of function 'mem_cgroup_swappiness'

This is pretty broken.  I think we do want to implement this for
CONFIG_CGROUP_MEM_RES_CTLR=y, CONFIG_SWAP=n:

--- a/include/linux/swap.h~memcg-export-memory-cgroups-swappiness-fix
+++ a/include/linux/swap.h
@@ -365,17 +365,12 @@ static inline void put_swap_token(struct
 extern void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
 extern int mem_cgroup_count_swap_user(swp_entry_t ent, struct page **pagep);
-extern unsigned int mem_cgroup_swappiness(struct mem_cgroup *mem);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
 {
 }
 
-static inline unsigned int mem_cgroup_swappiness(struct mem_cgroup *mem)
-{
-	return vm_swappiness;
-}
 #endif
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern void mem_cgroup_uncharge_swap(swp_entry_t ent);
@@ -510,5 +505,15 @@ mem_cgroup_count_swap_user(swp_entry_t e
 #endif
 
 #endif /* CONFIG_SWAP */
+
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+extern unsigned int mem_cgroup_swappiness(struct mem_cgroup *mem);
+#else
+static inline unsigned int mem_cgroup_swappiness(struct mem_cgroup *mem)
+{
+	return vm_swappiness;
+}
+#endif
+
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */

But what is the role of CONFIG_CGROUP_MEM_RES_CTLR_SWAP?

And in the above circumstances, vmscan_swappiness() devolves into

static int vmscan_swappiness(struct scan_control *sc)
{
       if (scanning_global_lru(sc))
               return vm_swappiness;
       return vm_swappiness;
}

which I guess makes sense but seems a bit odd.

Anyway, my confidence level is low so I think I'll drop this patch. 
Please have a think about the interplay between
CONFIG_CGROUP_MEM_RES_CTLR, CONFIG_CGROUP_MEM_RES_CTLR_SWAP and
CONFIG_SWAP.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
