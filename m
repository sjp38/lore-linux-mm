Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8675B6B0263
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c78so24122376wme.4
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:32:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e2si14155858wjp.153.2016.10.23.21.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:32:27 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4Susb062981
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:26 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2692caywbg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:25 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 10:02:22 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 63D08E0040
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:11 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4WKhr49020976
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:20 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4WJKA020939
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:20 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 4/8] mm: Accommodate coherent device memory nodes in MPOL_BIND implementation
Date: Mon, 24 Oct 2016 10:01:53 +0530
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477283517-2504-5-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

This change is part of the isolation requiring coherent device memory nodes
implementation.

Currently MPOL_MBIND interface simply fails on a coherent device memory
node after the zonelist changes introduced earlier. Without __GFP_THISNODE
flag, the first node of the nodemask will not be selected in the case where
the local node (where the application is executing) is not part of the user
provided nodemask for MPOL_MBIND. This will be the case for coherent memory
nodes which are always CPU less. This changes the mbind() system call
implementation so that memory can be allocated from coherent memory node
through MPOL_MBIND interface.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/mempolicy.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0b859af..cb1ba01 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1694,6 +1694,26 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
 		if (unlikely(gfp & __GFP_THISNODE) &&
 				unlikely(!node_isset(nd, policy->v.nodes)))
 			nd = first_node(policy->v.nodes);
+
+#ifdef CONFIG_COHERENT_DEVICE
+		/*
+		 * Coherent device memory
+		 *
+		 * In case the local node is not part of the nodemask, test if
+		 * the first node in the nodemask is a coherent device memory
+		 * node in which case select it.
+		 *
+		 * FIXME: The check will be restricted to the first node of the
+		 * nodemask or scan through the nodemask to select any present
+		 * coherent device memory node on it or select the first one if
+		 * all of the nodes in the nodemask are coherent device memory.
+		 * These are various approaches possible.
+		 */
+		if (unlikely(!node_isset(nd, policy->v.nodes))) {
+			if (isolated_cdm_node(first_node(policy->v.nodes)))
+				nd = first_node(policy->v.nodes);
+		}
+#endif
 		break;
 	default:
 		BUG();
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
