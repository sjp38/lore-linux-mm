Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1CC696B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 14:52:10 -0400 (EDT)
Received: by mail-la0-f50.google.com with SMTP id b8so430684lan.9
        for <linux-mm@kvack.org>; Thu, 29 May 2014 11:52:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id lc9si4583385lbc.22.2014.05.29.11.52.07
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 11:52:08 -0700 (PDT)
Date: Thu, 29 May 2014 15:43:03 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations (v4)
Message-ID: <20140529184303.GA20571@amt.cnet>
References: <20140523193706.GA22854@amt.cnet>
 <20140526185344.GA19976@amt.cnet>
 <53858A06.8080507@huawei.com>
 <20140528224324.GA1132@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140528224324.GA1132@amt.cnet>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>


Zone specific allocations, such as GFP_DMA32, should not be restricted
to cpusets allowed node list: the zones which such allocations demand
might be contained in particular nodes outside the cpuset node list.

Necessary for the following usecase:
- driver which requires zone specific memory (such as KVM, which
requires root pagetable at paddr < 4GB).
- user wants to limit allocations of application to nodeX, and nodeX has
no memory < 4GB.

Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3d54c41..3bbc23f 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2374,6 +2374,7 @@ static struct cpuset *nearest_hardwall_ancestor(struct cpuset *cs)
  * variable 'wait' is not set, and the bit ALLOC_CPUSET is not set
  * in alloc_flags.  That logic and the checks below have the combined
  * affect that:
+ *	gfp_zone(mask) < policy_zone - any node ok
  *	in_interrupt - any node ok (current task context irrelevant)
  *	GFP_ATOMIC   - any node ok
  *	TIF_MEMDIE   - any node ok
@@ -2392,6 +2393,10 @@ int __cpuset_node_allowed_softwall(int node, gfp_t gfp_mask)
 
 	if (in_interrupt() || (gfp_mask & __GFP_THISNODE))
 		return 1;
+#ifdef CONFIG_NUMA
+	if (gfp_zone(gfp_mask) < policy_zone)
+		return 1;
+#endif
 	might_sleep_if(!(gfp_mask & __GFP_HARDWALL));
 	if (node_isset(node, current->mems_allowed))
 		return 1;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..a0ce1ba 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2726,6 +2726,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
+#ifdef CONFIG_NUMA
+	if (gfp_zone(gfp_mask) < policy_zone)
+		nodemask = &node_states[N_ONLINE];
+#endif
+
 	/* The preferred zone is used for statistics later */
 	first_zones_zonelist(zonelist, high_zoneidx,
 				nodemask ? : &cpuset_current_mems_allowed,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
