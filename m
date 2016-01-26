Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 914906B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:18:06 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l65so95478873wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 01:18:06 -0800 (PST)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id a127si3124159wmf.116.2016.01.26.01.18.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 01:18:05 -0800 (PST)
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 26 Jan 2016 09:18:04 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 69AB417D8066
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:18:09 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0Q9I1Wo524572
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 09:18:01 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0Q9I0fD010404
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:18:01 -0500
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH/RFC 2/3] x86: query dynamic DEBUG_PAGEALLOC setting
Date: Tue, 26 Jan 2016 10:18:24 +0100
Message-Id: <1453799905-10941-3-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
References: <1453799905-10941-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, Christian Borntraeger <borntraeger@de.ibm.com>

We can use debug_pagealloc_enabled() to check if we can map
the identity mapping with 2MB pages. We can also add the state
into the dump_stack output.

The patch does not touch the code for the 1GB pages, which ignored
CONFIG_DEBUG_PAGEALLOC. Do we need to fence this as well?

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 arch/x86/kernel/dumpstack.c |  4 +++-
 arch/x86/mm/init.c          |  7 ++++---
 arch/x86/mm/pageattr.c      | 14 ++++----------
 3 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index 9c30acf..7971638 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -266,7 +266,9 @@ int __die(const char *str, struct pt_regs *regs, long err)
 	printk("SMP ");
 #endif
 #ifdef CONFIG_DEBUG_PAGEALLOC
-	printk("DEBUG_PAGEALLOC ");
+	printk("DEBUG_PAGEALLOC(%s) ",
+		debug_pagealloc_enabled() ? "enabled" : "disabled");
+
 #endif
 #ifdef CONFIG_KASAN
 	printk("KASAN");
diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index 493f541..39823fd 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -150,13 +150,14 @@ static int page_size_mask;
 
 static void __init probe_page_size_mask(void)
 {
-#if !defined(CONFIG_DEBUG_PAGEALLOC) && !defined(CONFIG_KMEMCHECK)
+#if !defined(CONFIG_KMEMCHECK)
 	/*
-	 * For CONFIG_DEBUG_PAGEALLOC, identity mapping will use small pages.
+	 * For CONFIG_KMEMCHECK or pagealloc debugging, identity mapping will
+	 * use small pages.
 	 * This will simplify cpa(), which otherwise needs to support splitting
 	 * large pages into small in interrupt context, etc.
 	 */
-	if (cpu_has_pse)
+	if (cpu_has_pse && !debug_pagealloc_enabled())
 		page_size_mask |= 1 << PG_LEVEL_2M;
 #endif
 
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index a3137a4..a49c8fd 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -103,12 +103,6 @@ static inline unsigned long highmap_end_pfn(void)
 
 #endif
 
-#ifdef CONFIG_DEBUG_PAGEALLOC
-# define debug_pagealloc 1
-#else
-# define debug_pagealloc 0
-#endif
-
 static inline int
 within(unsigned long addr, unsigned long start, unsigned long end)
 {
@@ -703,10 +697,10 @@ static int split_large_page(struct cpa_data *cpa, pte_t *kpte,
 {
 	struct page *base;
 
-	if (!debug_pagealloc)
+	if (!debug_pagealloc_enabled())
 		spin_unlock(&cpa_lock);
 	base = alloc_pages(GFP_KERNEL | __GFP_NOTRACK, 0);
-	if (!debug_pagealloc)
+	if (!debug_pagealloc_enabled())
 		spin_lock(&cpa_lock);
 	if (!base)
 		return -ENOMEM;
@@ -1326,10 +1320,10 @@ static int __change_page_attr_set_clr(struct cpa_data *cpa, int checkalias)
 		if (cpa->flags & (CPA_ARRAY | CPA_PAGES_ARRAY))
 			cpa->numpages = 1;
 
-		if (!debug_pagealloc)
+		if (!debug_pagealloc_enabled())
 			spin_lock(&cpa_lock);
 		ret = __change_page_attr(cpa, checkalias);
-		if (!debug_pagealloc)
+		if (!debug_pagealloc_enabled())
 			spin_unlock(&cpa_lock);
 		if (ret)
 			return ret;
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
