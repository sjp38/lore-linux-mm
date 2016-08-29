Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 88C92830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:07:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so302934351pfd.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:07:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i8si39043976paf.280.2016.08.29.06.07.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 06:07:56 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7TD4VMH080283
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:07:56 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2536xsextf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:07:55 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 29 Aug 2016 23:07:53 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id F23002CE8046
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:07:50 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7TD7oYI3867104
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:07:50 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7TD7out013120
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:07:50 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH v3 1/3] mm: Introduce arch_reserved_kernel_pages()
Date: Mon, 29 Aug 2016 18:36:48 +0530
In-Reply-To: <1472476010-4709-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1472476010-4709-1-git-send-email-srikar@linux.vnet.ibm.com>
Message-Id: <1472476010-4709-2-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

Currently arch specific code can reserve memory blocks but
alloc_large_system_hash() may not take it into consideration when sizing
the hashes. This can lead to bigger hash than required and lead to no
available memory for other purposes. This is specifically true for
systems with CONFIG_DEFERRED_STRUCT_PAGE_INIT enabled.

One approach to solve this problem would be to walk through the memblock
regions and calculate the available memory and base the size of hash
system on the available memory.

The other approach would be to depend on the architecture to provide the
number of pages that are reserved. This change provides hooks to allow
the architecture to provide the required info.

Cc: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>
Cc: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Suggested-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/mm.h |  3 +++
 mm/page_alloc.c    | 12 ++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 08ed53e..7e91cd8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1924,6 +1924,9 @@ extern void show_mem(unsigned int flags);
 extern long si_mem_available(void);
 extern void si_meminfo(struct sysinfo * val);
 extern void si_meminfo_node(struct sysinfo *val, int nid);
+#ifdef __HAVE_ARCH_RESERVED_KERNEL_PAGES
+extern unsigned long arch_reserved_kernel_pages(void);
+#endif
 
 extern __printf(3, 4)
 void warn_alloc_failed(gfp_t gfp_mask, unsigned int order,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3fbe73a..9d91706 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6976,6 +6976,17 @@ static int __init set_hashdist(char *str)
 __setup("hashdist=", set_hashdist);
 #endif
 
+#ifndef __HAVE_ARCH_RESERVED_KERNEL_PAGES
+/*
+ * Returns the number of pages that arch has reserved but
+ * is not known to alloc_large_system_hash().
+ */
+static unsigned long __init arch_reserved_kernel_pages(void)
+{
+	return 0;
+}
+#endif
+
 /*
  * allocate a large system hash table from bootmem
  * - it is assumed that the hash table must contain an exact power-of-2
@@ -7000,6 +7011,7 @@ void *__init alloc_large_system_hash(const char *tablename,
 	if (!numentries) {
 		/* round applicable memory size up to nearest megabyte */
 		numentries = nr_kernel_pages;
+		numentries -= arch_reserved_kernel_pages();
 
 		/* It isn't necessary when PAGE_SIZE >= 1MB */
 		if (PAGE_SHIFT < 20)
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
