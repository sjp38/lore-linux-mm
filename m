Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5DE36B0276
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:37 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id q124so1961227wmg.2
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:38:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r123si11671670wmd.141.2017.01.29.19.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:38:36 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YKtw040002
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:35 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 289pf0tujy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:34 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:38:32 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 40EC43578053
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:29 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3cLAH34209876
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:29 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3bucC020986
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:57 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 10/12] mm: Ignore madvise(MADV_MERGEABLE) request for VM_CDM marked VMAs
Date: Mon, 30 Jan 2017 09:05:51 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-11-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

VMA containing CDM memory should be excluded from KSM merging. This change
makes madvise(MADV_MERGEABLE) request on target VMA to be ignored.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/ksm.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/ksm.c b/mm/ksm.c
index 9ae6011..2fb8939 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -37,6 +37,7 @@
 #include <linux/freezer.h>
 #include <linux/oom.h>
 #include <linux/numa.h>
+#include <linux/mempolicy.h>
 
 #include <asm/tlbflush.h>
 #include "internal.h"
@@ -1751,6 +1752,9 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 				 VM_HUGETLB | VM_MIXEDMAP))
 			return 0;		/* just ignore the advice */
 
+		if (is_cdm_vma(vma))
+			return 0;
+
 #ifdef VM_SAO
 		if (*vm_flags & VM_SAO)
 			return 0;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
