Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 69CA16B0035
	for <linux-mm@kvack.org>; Fri, 23 May 2014 15:37:42 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id cc10so1387873wib.17
        for <linux-mm@kvack.org>; Fri, 23 May 2014 12:37:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gq7si2323995wib.55.2014.05.23.12.37.40
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 12:37:41 -0700 (PDT)
Date: Fri, 23 May 2014 16:37:07 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: [PATCH] page_alloc: skip cpuset enforcement for lower zone
 allocations
Message-ID: <20140523193706.GA22854@amt.cnet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>


Zone specific allocations, such as GFP_DMA32, should not be restricted
to cpusets allowed node list: the zones which such allocations demand
might be contained in particular nodes outside the cpuset node list.

The alternative would be to not perform such allocations from
applications which are cpuset restricted, which is unrealistic.

Fixes KVM's alloc_page(gfp_mask=GFP_DMA32) with cpuset as explained.

Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..f228039 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2698,6 +2698,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	unsigned int cpuset_mems_cookie;
 	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
 	struct mem_cgroup *memcg = NULL;
+	nodemask_t *cpuset_mems_allowed = &cpuset_current_mems_allowed;
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2726,9 +2727,14 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
+#ifdef CONFIG_NUMA
+	if (gfp_zone(gfp_mask) < policy_zone)
+		cpuset_mems_allowed = NULL;
+#endif
+
 	/* The preferred zone is used for statistics later */
 	first_zones_zonelist(zonelist, high_zoneidx,
-				nodemask ? : &cpuset_current_mems_allowed,
+				nodemask ? : cpuset_mems_allowed,
 				&preferred_zone);
 	if (!preferred_zone)
 		goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
