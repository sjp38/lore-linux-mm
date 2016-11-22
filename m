Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B8EEB6B0269
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:10 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so9986699wmw.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:20:10 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v129si2809423wma.15.2016.11.22.06.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 06:20:09 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAMEIuOJ042144
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:08 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26vku8btuw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:07 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Nov 2016 00:20:05 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id A8B063578056
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:03 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAMEK3lu61669470
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:03 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAMEK2Iq015897
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:02 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 4/4] mm: Ignore cpuset enforcement when allocation flag has __GFP_THISNODE
Date: Tue, 22 Nov 2016 19:49:40 +0530
In-Reply-To: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1479824388-30446-5-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com

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
index 6de9440..1697e21 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3715,7 +3715,7 @@ struct page *
 		.migratetype = gfpflags_to_migratetype(gfp_mask),
 	};
 
-	if (cpusets_enabled()) {
+	if (cpusets_enabled() && !(alloc_mask & __GFP_THISNODE)) {
 		alloc_mask |= __GFP_HARDWALL;
 		alloc_flags |= ALLOC_CPUSET;
 		if (!ac.nodemask)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
