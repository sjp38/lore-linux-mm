Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6AD96B033C
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:34 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n75so192164852pfh.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 04:20:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l192si23841510pga.13.2017.05.24.04.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 04:20:34 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4OBFPhN056184
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:33 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2an1m13k45-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 May 2017 07:20:33 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 24 May 2017 12:20:30 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC v2 10/10] mm: Introduce CONFIG_MEM_RANGE_LOCK
Date: Wed, 24 May 2017 13:20:01 +0200
In-Reply-To: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1495624801-8063-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1495624801-8063-11-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@techsingularity.net>, Andi Kleen <andi@firstfloor.org>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

A new configuration variable is introduced to activate the use of
range lock instead of semaphore to protect per process memory layout.

This range lock is replacing the use of a semaphore for mmap_sem.

Currently only available for X86_64 and PPC64 architectures.

By default this option is turned off and requires the EXPERT mode
since it is not yet complete.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/Kconfig | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index beb7a455915d..955d9a735a49 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -309,6 +309,18 @@ config NEED_BOUNCE_POOL
 	bool
 	default y if TILE && USB_OHCI_HCD
 
+config MEM_RANGE_LOCK
+	bool "Use range lock for process's memory layout"
+	default n
+	depends on EXPERT
+	depends on MMU
+	depends on X86_64 || PPC64
+	help
+	  Use range lock instead of traditional semaphore to protect per
+	  process memory layout. This is required when dealing with massive
+	  threaded process on very large system (more than 80 cpu threads).
+	  If unsure say n.
+
 config NR_QUICK
 	int
 	depends on QUICKLIST
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
