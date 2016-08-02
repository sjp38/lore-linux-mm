Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id C84796B0260
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 09:19:48 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ca5so300029817pac.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 06:19:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id lk5si3079046pab.204.2016.08.02.06.19.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 06:19:48 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u72DEui7059464
	for <linux-mm@kvack.org>; Tue, 2 Aug 2016 09:19:47 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24gpjg346k-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Aug 2016 09:19:47 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 2 Aug 2016 23:19:42 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 3A0113578052
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 23:19:28 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u72DJSNc27263058
	for <linux-mm@kvack.org>; Tue, 2 Aug 2016 23:19:28 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u72DJRNc023270
	for <linux-mm@kvack.org>; Tue, 2 Aug 2016 23:19:28 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH 2/2] fadump: Disable deferred page struct initialisation
Date: Tue,  2 Aug 2016 18:49:07 +0530
In-Reply-To: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
Message-Id: <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux--foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Fadump kernel reserves significant number of memory blocks. On a multi-node
machine, with CONFIG_DEFFERRED_STRUCT_PAGE support, fadump kernel fails to
boot. Fix this by disabling deferred page struct initialisation.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/powerpc/kernel/fadump.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/kernel/fadump.c b/arch/powerpc/kernel/fadump.c
index 3cb3b02a..117faf2 100644
--- a/arch/powerpc/kernel/fadump.c
+++ b/arch/powerpc/kernel/fadump.c
@@ -318,6 +318,7 @@ int __init fadump_reserve_mem(void)
 				be64_to_cpu(fdm_active->rmr_region.source_len);
 		pr_debug("fadumphdr_addr = %p\n",
 				(void *) fw_dump.fadumphdr_addr);
+		disable_deferred_meminit();
 	} else {
 		/* Reserve the memory at the top of memory. */
 		size = get_fadump_area_size();
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
