Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E961831D3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 04:22:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x63so48079385pfx.7
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 01:22:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v5si2685098pgo.315.2017.03.08.01.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 01:22:50 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v289Ds7P144118
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 04:22:49 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 292f2kggux-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Mar 2017 04:22:49 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 8 Mar 2017 19:22:46 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v289MZRe47972390
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 20:22:43 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v289MAH2020282
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 20:22:11 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm: Change mbind(MPOL_BIND) implementation for CDM nodes
Date: Wed,  8 Mar 2017 14:51:46 +0530
In-Reply-To: <1d67f38b-548f-26a2-23f5-240d6747f286@linux.vnet.ibm.com>
References: <1d67f38b-548f-26a2-23f5-240d6747f286@linux.vnet.ibm.com>
Message-Id: <20170308092146.5264-2-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

CDM nodes need a way of explicit memory allocation mechanism from the user
space. After the previous FALLBACK zonelist rebuilding process changes, the
mbind(MPOL_BIND) based allocation request fails on the CDM node. This is
because allocation requesting local node's FALLBACK zonelist is selected
for further nodemask processing targeted at MPOL_BIND implementation. As
the CDM node's zones are not part of any other regular node's FALLBACK
zonelist, the allocation simply fails without getting any valid zone. The
allocation requesting node is always going to be different than the CDM
node which does not have any CPU. Hence MPOL_MBIND implementation must
choose given CDM node's FALLBACK zonelist instead of the requesting local
node's FALLBACK zonelist. This implements that change.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/mempolicy.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 1e7873e..6089c711 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1692,6 +1692,27 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
 		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
 	}
 
+#ifdef CONFIG_COHERENT_DEVICE
+	/*
+	 * Coherent Device Memory (CDM)
+	 *
+	 * In case the local requesting node is not part of the nodemask, test
+	 * if the first node in the nodemask is CDM, in which case select it.
+	 *
+	 * XXX: There are multiple ways of doing this. This node check can be
+	 * restricted to the first node in the node mask as implemented here or
+	 * scan through the entire nodemask to find out any present CDM node on
+	 * it or select the first CDM node only if all other nodes in the node
+	 * mask are CDM. These are variour approaches possible, the first one
+	 * is implemented here.
+	 */
+	if (policy->mode == MPOL_BIND) {
+		if (unlikely(!node_isset(nd, policy->v.nodes))) {
+			if (is_cdm_node(first_node(policy->v.nodes)))
+				nd = first_node(policy->v.nodes);
+		}
+	}
+#endif
 	return node_zonelist(nd, gfp);
 }
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
