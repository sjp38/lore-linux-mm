Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCC06B0270
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:08 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so186091052pgj.6
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:38:08 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d10si11335070plj.152.2017.01.29.19.38.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:38:07 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YOkT069980
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:07 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2890j8sagw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:06 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:38:04 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9F0933578053
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:02 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3bsRE34668624
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:02 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3bUYc020479
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:30 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 07/12] mm: Ignore cpuset enforcement when allocation flag has __GFP_THISNODE
Date: Mon, 30 Jan 2017 09:05:48 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-8-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

__GFP_THISNODE specifically asks the memory to be allocated from the given
node. Not all the requests that end up in __alloc_pages_nodemask() are
originated from the process context where cpuset makes more sense. The
current condition enforces cpuset limitation on every allocation whether
originated from process context or not which prevents __GFP_THISNODE
mandated allocations to come from the specified node. In context of the
coherent device memory node which is isolated from all cpuset nodemask
in the system, it prevents the only way of allocation into it which has
been changed with this patch.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5db353a..609cf9c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3778,7 +3778,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		.migratetype = gfpflags_to_migratetype(gfp_mask),
 	};
 
-	if (cpusets_enabled()) {
+	if (cpusets_enabled() && !(alloc_mask & __GFP_THISNODE)) {
 		alloc_mask |= __GFP_HARDWALL;
 		alloc_flags |= ALLOC_CPUSET;
 		if (!ac.nodemask)
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
