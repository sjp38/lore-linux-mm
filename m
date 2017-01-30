Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF4146B026A
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:48 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so58661121wjy.6
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:37:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m75si11673802wmi.142.2017.01.29.19.37.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:37:47 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3aqQc191247
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:46 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0b-001b2d01.pphosted.com with ESMTP id 289954dhwk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:37:46 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:37:43 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B6E642CE8056
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:41 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3bXx228311620
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:41 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3b9tH020142
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:09 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 04/12] mm: Change mbind(MPOL_BIND) implementation for CDM nodes
Date: Mon, 30 Jan 2017 09:05:45 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-5-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

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
