Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 597946B006C
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 07:56:20 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa1so2528360pad.14
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 04:56:20 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id bi5si5473002pbb.109.2014.03.14.04.56.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 04:56:19 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 14 Mar 2014 17:26:16 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 654DF125805B
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 17:28:28 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2EBtnnA63766688
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 17:25:49 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2EBtu0x012311
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 17:25:57 +0530
Date: Fri, 14 Mar 2014 17:25:56 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH] numa: Use LAST_CPUPID_SHIFT to calculate LAST_CPUPID_MASK
Message-ID: <20140314115556.GA10406@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Ping Fan <qemulist@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

LAST_CPUPID_MASK is calculated using LAST_CPUPID_WIDTH.  However
LAST_CPUPID_WIDTH itself can be 0. (when LAST_CPUPID_NOT_IN_PAGE_FLAGS
is set). In such a case LAST_CPUPID_MASK turns out to be 0.

But with recent commit 1ae71d0319: (mm: numa: bugfix for
LAST_CPUPID_NOT_IN_PAGE_FLAGS) if LAST_CPUPID_MASK is 0,
page_cpupid_xchg_last() and page_cpupid_reset_last() causes
page->_last_cpupid to be set to 0.

This causes performance regression. Its almost as if numa_balancing is
off.

Fix LAST_CPUPID_MASK by using LAST_CPUPID_SHIFT instead of
LAST_CPUPID_WIDTH.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c1b7414..b9765bf 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -684,7 +684,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
-#define LAST_CPUPID_MASK	((1UL << LAST_CPUPID_WIDTH) - 1)
+#define LAST_CPUPID_MASK	((1UL << LAST_CPUPID_SHIFT) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
 static inline enum zone_type page_zonenum(const struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
