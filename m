Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA096B0260
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so114755497pfg.3
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:42:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d76si13584065pga.220.2016.10.23.21.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:42:44 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4cXYH130732
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:44 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 268yyuneaq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:42:44 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 14:42:42 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 971662CE8046
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:39 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4gdLr590180
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:39 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4gdDo030464
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:39 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 03/10] powerpc/mm: Allow memory hotplug into a memory less node
Date: Mon, 24 Oct 2016 10:12:22 +0530
In-Reply-To: <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477284149-2976-4-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

From: Reza Arbab <arbab@linux.vnet.ibm.com>

Remove the check which prevents us from hotplugging into an empty node.

Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/numa.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 42fcc8e..5010181 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -1091,7 +1091,7 @@ static int hot_add_node_scn_to_nid(unsigned long scn_addr)
 int hot_add_scn_to_nid(unsigned long scn_addr)
 {
 	struct device_node *memory = NULL;
-	int nid, found = 0;
+	int nid;
 
 	if (!numa_enabled || (min_common_depth < 0))
 		return first_online_node;
@@ -1107,17 +1107,6 @@ int hot_add_scn_to_nid(unsigned long scn_addr)
 	if (nid < 0 || !node_online(nid))
 		nid = first_online_node;
 
-	if (NODE_DATA(nid)->node_spanned_pages)
-		return nid;
-
-	for_each_online_node(nid) {
-		if (NODE_DATA(nid)->node_spanned_pages) {
-			found = 1;
-			break;
-		}
-	}
-
-	BUG_ON(!found);
 	return nid;
 }
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
