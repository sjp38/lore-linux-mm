Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 110806B0350
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:28:05 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o89so18885745wrc.1
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 07:28:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h206si4325698wmf.146.2017.04.25.07.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 07:28:03 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3PEORvp015112
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:28:02 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a1v4rvqsv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 10:28:02 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 15:27:59 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v2 2/2] mm: skip HWPoisoned pages when onlining pages
Date: Tue, 25 Apr 2017 16:27:52 +0200
In-Reply-To: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1493130472-22843-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

The commit b023f46813cd ("memory-hotplug: skip HWPoisoned page when
offlining pages") skip the HWPoisoned pages when offlining pages, but
this should be skipped when onlining the pages too.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6fa7208bcd56..741ddb50e7d2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -942,6 +942,10 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	if (PageReserved(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
+			if (PageHWPoison(page)) {
+				ClearPageReserved(page);
+				continue;
+			}
 			(*online_page_callback)(page);
 			onlined_pages++;
 		}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
