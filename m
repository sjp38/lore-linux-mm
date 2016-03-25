Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 76E796B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 15:22:39 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id 4so88586910pfd.0
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 12:22:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ok17si8745102pab.100.2016.03.25.12.22.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 12:22:38 -0700 (PDT)
Date: Fri, 25 Mar 2016 12:22:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix invalid node in alloc_migrate_target()
Message-Id: <20160325122237.4ca4e0dbca215ccbf4f49922@linux-foundation.org>
In-Reply-To: <56F4E104.9090505@huawei.com>
References: <56F4E104.9090505@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Laura Abbott <lauraa@codeaurora.org>, zhuhui@xiaomi.com, wangxq10@lzu.edu.cn, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 25 Mar 2016 14:56:04 +0800 Xishi Qiu <qiuxishi@huawei.com> wrote:

> It is incorrect to use next_node to find a target node, it will
> return MAX_NUMNODES or invalid node. This will lead to crash in
> buddy system allocation.
> 
> ...
>
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -289,11 +289,11 @@ struct page *alloc_migrate_target(struct page *page, unsigned long private,
>  	 * now as a simple work-around, we use the next node for destination.
>  	 */
>  	if (PageHuge(page)) {
> -		nodemask_t src = nodemask_of_node(page_to_nid(page));
> -		nodemask_t dst;
> -		nodes_complement(dst, src);
> +		int node = next_online_node(page_to_nid(page));
> +		if (node == MAX_NUMNODES)
> +			node = first_online_node;
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
> -					    next_node(page_to_nid(page), dst));
> +					    node);
>  	}
>  
>  	if (PageHighMem(page))

Indeed.  Can you tell us more about this circumstances under which the
kernel will crash?  I need to decide which kernel version(s) need the
patch, but the changelog doesn't contain the info needed to make this
decision (it should).



next_node() isn't a very useful interface, really.  Just about every
caller does this:


	node = next_node(node, XXX);
	if (node == MAX_NUMNODES)
		node = first_node(XXX);

so how about we write a function which does that, and stop open-coding
the same thing everywhere?

And I think your fix could then use such a function:

	int node = that_new_function(page_to_nid(page), node_online_map);



Also, mm/mempolicy.c:offset_il_node() worries me:

	do {
		nid = next_node(nid, pol->v.nodes);
		c++;
	} while (c <= target);

Can't `nid' hit MAX_NUMNODES?


And can someone please explain mem_cgroup_select_victim_node() to me? 
How can we hit the "node = numa_node_id()" path?  Only if
memcg->scan_nodes is empty?  is that even valid?  The comment seems to
have not much to do with the code?

mpol_rebind_nodemask() is similar.



Something like this?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: include/linux/nodemask.h: create next_node_in() helper

Lots of code does

	node = next_node(node, XXX);
	if (node == MAX_NUMNODES)
		node = first_node(XXX);

so create next_node_in() to do this and use it in various places.

Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Laura Abbott" <lauraa@codeaurora.org>
Cc: Hui Zhu <zhuhui@xiaomi.com>
Cc: Wang Xiaoqiang <wangxq10@lzu.edu.cn>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/nodemask.h |   18 +++++++++++++++++-
 kernel/cpuset.c          |    8 +-------
 mm/hugetlb.c             |    4 +---
 mm/memcontrol.c          |    4 +---
 mm/mempolicy.c           |    8 ++------
 mm/page_isolation.c      |    9 +++------
 mm/slab.c                |   13 +++----------
 7 files changed, 28 insertions(+), 36 deletions(-)

diff -puN include/linux/nodemask.h~include-linux-nodemaskh-create-next_node_in-helper include/linux/nodemask.h
--- a/include/linux/nodemask.h~include-linux-nodemaskh-create-next_node_in-helper
+++ a/include/linux/nodemask.h
@@ -43,8 +43,10 @@
  *
  * int first_node(mask)			Number lowest set bit, or MAX_NUMNODES
  * int next_node(node, mask)		Next node past 'node', or MAX_NUMNODES
+ * int next_node_in(node, mask)		Next node past 'node', or wrap to first,
+ *					or MAX_NUMNODES
  * int first_unset_node(mask)		First node not set in mask, or 
- *					MAX_NUMNODES.
+ *					MAX_NUMNODES
  *
  * nodemask_t nodemask_of_node(node)	Return nodemask with bit 'node' set
  * NODE_MASK_ALL			Initializer - all bits set
@@ -259,6 +261,20 @@ static inline int __next_node(int n, con
 	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
 }
 
+/*
+ * Find the next present node in src, starting after node n, wrapping around to
+ * the first node in src if needed.  Returns MAX_NUMNODES if src is empty.
+ */
+#define next_node_in(n, src) __next_node_in((n), &(src))
+static inline int __next_node_in(int node, const nodemask_t *srcp)
+{
+	int ret = __next_node(node, srcp);
+
+	if (ret == MAX_NUMNODES)
+		ret = __first_node(srcp);
+	return ret;
+}
+
 static inline void init_nodemask_of_node(nodemask_t *mask, int node)
 {
 	nodes_clear(*mask);
diff -puN kernel/cpuset.c~include-linux-nodemaskh-create-next_node_in-helper kernel/cpuset.c
--- a/kernel/cpuset.c~include-linux-nodemaskh-create-next_node_in-helper
+++ a/kernel/cpuset.c
@@ -2591,13 +2591,7 @@ int __cpuset_node_allowed(int node, gfp_
 
 static int cpuset_spread_node(int *rotor)
 {
-	int node;
-
-	node = next_node(*rotor, current->mems_allowed);
-	if (node == MAX_NUMNODES)
-		node = first_node(current->mems_allowed);
-	*rotor = node;
-	return node;
+	return *rotor = next_node_in(*rotor, current->mems_allowed);
 }
 
 int cpuset_mem_spread_node(void)
diff -puN mm/hugetlb.c~include-linux-nodemaskh-create-next_node_in-helper mm/hugetlb.c
--- a/mm/hugetlb.c~include-linux-nodemaskh-create-next_node_in-helper
+++ a/mm/hugetlb.c
@@ -937,9 +937,7 @@ err:
  */
 static int next_node_allowed(int nid, nodemask_t *nodes_allowed)
 {
-	nid = next_node(nid, *nodes_allowed);
-	if (nid == MAX_NUMNODES)
-		nid = first_node(*nodes_allowed);
+	nid = next_node_in(nid, *nodes_allowed);
 	VM_BUG_ON(nid >= MAX_NUMNODES);
 
 	return nid;
diff -puN mm/memcontrol.c~include-linux-nodemaskh-create-next_node_in-helper mm/memcontrol.c
--- a/mm/memcontrol.c~include-linux-nodemaskh-create-next_node_in-helper
+++ a/mm/memcontrol.c
@@ -1388,9 +1388,7 @@ int mem_cgroup_select_victim_node(struct
 	mem_cgroup_may_update_nodemask(memcg);
 	node = memcg->last_scanned_node;
 
-	node = next_node(node, memcg->scan_nodes);
-	if (node == MAX_NUMNODES)
-		node = first_node(memcg->scan_nodes);
+	node = next_node_in(node, memcg->scan_nodes);
 	/*
 	 * We call this when we hit limit, not when pages are added to LRU.
 	 * No LRU may hold pages because all pages are UNEVICTABLE or
diff -puN mm/mempolicy.c~include-linux-nodemaskh-create-next_node_in-helper mm/mempolicy.c
--- a/mm/mempolicy.c~include-linux-nodemaskh-create-next_node_in-helper
+++ a/mm/mempolicy.c
@@ -347,9 +347,7 @@ static void mpol_rebind_nodemask(struct
 		BUG();
 
 	if (!node_isset(current->il_next, tmp)) {
-		current->il_next = next_node(current->il_next, tmp);
-		if (current->il_next >= MAX_NUMNODES)
-			current->il_next = first_node(tmp);
+		current->il_next = next_node_in(current->il_next, tmp);
 		if (current->il_next >= MAX_NUMNODES)
 			current->il_next = numa_node_id();
 	}
@@ -1709,9 +1707,7 @@ static unsigned interleave_nodes(struct
 	struct task_struct *me = current;
 
 	nid = me->il_next;
-	next = next_node(nid, policy->v.nodes);
-	if (next >= MAX_NUMNODES)
-		next = first_node(policy->v.nodes);
+	next = next_node_in(nid, policy->v.nodes);
 	if (next < MAX_NUMNODES)
 		me->il_next = next;
 	return nid;
diff -puN mm/page_isolation.c~include-linux-nodemaskh-create-next_node_in-helper mm/page_isolation.c
--- a/mm/page_isolation.c~include-linux-nodemaskh-create-next_node_in-helper
+++ a/mm/page_isolation.c
@@ -288,13 +288,10 @@ struct page *alloc_migrate_target(struct
 	 * accordance with memory policy of the user process if possible. For
 	 * now as a simple work-around, we use the next node for destination.
 	 */
-	if (PageHuge(page)) {
-		int node = next_online_node(page_to_nid(page));
-		if (node == MAX_NUMNODES)
-			node = first_online_node;
+	if (PageHuge(page))
 		return alloc_huge_page_node(page_hstate(compound_head(page)),
-					    node);
-	}
+					    next_node_in(page_to_nid(page),
+							 node_online_map));
 
 	if (PageHighMem(page))
 		gfp_mask |= __GFP_HIGHMEM;
diff -puN mm/slab.c~include-linux-nodemaskh-create-next_node_in-helper mm/slab.c
--- a/mm/slab.c~include-linux-nodemaskh-create-next_node_in-helper
+++ a/mm/slab.c
@@ -519,22 +519,15 @@ static DEFINE_PER_CPU(unsigned long, sla
 
 static void init_reap_node(int cpu)
 {
-	int node;
-
-	node = next_node(cpu_to_mem(cpu), node_online_map);
-	if (node == MAX_NUMNODES)
-		node = first_node(node_online_map);
-
-	per_cpu(slab_reap_node, cpu) = node;
+	per_cpu(slab_reap_node, cpu) = next_node_in(cpu_to_mem(cpu),
+						    node_online_map);
 }
 
 static void next_reap_node(void)
 {
 	int node = __this_cpu_read(slab_reap_node);
 
-	node = next_node(node, node_online_map);
-	if (unlikely(node >= MAX_NUMNODES))
-		node = first_node(node_online_map);
+	node = next_node_in(node, node_online_map);
 	__this_cpu_write(slab_reap_node, node);
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
