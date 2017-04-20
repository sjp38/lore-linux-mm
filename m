Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF592806D2
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 05:26:14 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id b82so65972606iod.10
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 02:26:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j8si5800467pli.231.2017.04.20.02.26.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 02:26:13 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3K9NxMZ022487
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 05:26:13 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29xpmbhg25-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 05:26:13 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 20 Apr 2017 10:26:10 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC 2/2] mm: skip HWPoisoned pages when onlining pages
Date: Thu, 20 Apr 2017 11:26:02 +0200
In-Reply-To: <1492680362-24941-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1492680362-24941-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1492680362-24941-3-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

The commit b023f46813cd ("memory-hotplug: skip HWPoisoned page when
offlining pages") skip the HWPoisoned pages when offlining pages, but
this should be skipped when onlining the pages too.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6fa7208bcd56..20e1fadc2369 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -942,6 +942,8 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	if (PageReserved(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
+			if (PageHWPoison(page))
+				continue;
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
