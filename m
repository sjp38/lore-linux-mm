Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A31F4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 02:08:59 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n128so34938897pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 23:08:59 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id tj1si14711449pab.206.2016.02.03.23.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 23:08:58 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 65so2610112pfd.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 23:08:58 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 3/3] tools/vm/page-types.c: support swap entry
Date: Thu,  4 Feb 2016 16:08:03 +0900
Message-Id: <1454569683-17918-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1454569683-17918-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1454569683-17918-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

/proc/pid/pagemap (pte_to_pagemap_entry() internally) already reports about
swap entry, so let's make the in-kernel utility aware of it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 tools/vm/page-types.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git v4.5-rc2-mmotm-2016-02-02-17-08/tools/vm/page-types.c v4.5-rc2-mmotm-2016-02-02-17-08_patched/tools/vm/page-types.c
index 5a60162..ec62ab4 100644
--- v4.5-rc2-mmotm-2016-02-02-17-08/tools/vm/page-types.c
+++ v4.5-rc2-mmotm-2016-02-02-17-08_patched/tools/vm/page-types.c
@@ -61,6 +61,8 @@
 #define PM_PFRAME_BITS		55
 #define PM_PFRAME_MASK		((1LL << PM_PFRAME_BITS) - 1)
 #define PM_PFRAME(x)		((x) & PM_PFRAME_MASK)
+#define MAX_SWAPFILES_SHIFT	5
+#define PM_SWAP_OFFSET(x)	(((x) & PM_PFRAME_MASK) >> MAX_SWAPFILES_SHIFT)
 #define PM_SOFT_DIRTY		(1ULL << 55)
 #define PM_MMAP_EXCLUSIVE	(1ULL << 56)
 #define PM_FILE			(1ULL << 61)
@@ -92,7 +94,8 @@
 #define KPF_SLOB_FREE		49
 #define KPF_SLUB_FROZEN		50
 #define KPF_SLUB_DEBUG		51
-#define KPF_FILE		62
+#define KPF_FILE		61
+#define KPF_SWAP		62
 #define KPF_MMAP_EXCLUSIVE	63
 
 #define KPF_ALL_BITS		((uint64_t)~0ULL)
@@ -146,6 +149,7 @@ static const char * const page_flag_names[] = {
 	[KPF_SLUB_DEBUG]	= "E:slub_debug",
 
 	[KPF_FILE]		= "F:file",
+	[KPF_SWAP]		= "w:swap",
 	[KPF_MMAP_EXCLUSIVE]	= "1:mmap_exclusive",
 };
 
@@ -297,6 +301,10 @@ static unsigned long pagemap_pfn(uint64_t val)
 	return pfn;
 }
 
+static unsigned long pagemap_swap_offset(uint64_t val)
+{
+	return val & PM_SWAP ? PM_SWAP_OFFSET(val) : 0;
+}
 
 /*
  * page flag names
@@ -452,6 +460,8 @@ static uint64_t expand_overloaded_flags(uint64_t flags, uint64_t pme)
 		flags |= BIT(SOFTDIRTY);
 	if (pme & PM_FILE)
 		flags |= BIT(FILE);
+	if (pme & PM_SWAP)
+		flags |= BIT(SWAP);
 	if (pme & PM_MMAP_EXCLUSIVE)
 		flags |= BIT(MMAP_EXCLUSIVE);
 
@@ -613,6 +623,22 @@ static void walk_pfn(unsigned long voffset,
 	}
 }
 
+static void walk_swap(unsigned long voffset, uint64_t pme)
+{
+	uint64_t flags = kpageflags_flags(0, pme);
+
+	if (!bit_mask_ok(flags))
+		return;
+
+	if (opt_list == 1)
+		show_page_range(voffset, pagemap_swap_offset(pme), 1, flags);
+	else if (opt_list == 2)
+		show_page(voffset, pagemap_swap_offset(pme), flags);
+
+	nr_pages[hash_slot(flags)]++;
+	total_pages++;
+}
+
 #define PAGEMAP_BATCH	(64 << 10)
 static void walk_vma(unsigned long index, unsigned long count)
 {
@@ -632,6 +658,8 @@ static void walk_vma(unsigned long index, unsigned long count)
 			pfn = pagemap_pfn(buf[i]);
 			if (pfn)
 				walk_pfn(index + i, pfn, 1, buf[i]);
+			if (buf[i] & PM_SWAP)
+				walk_swap(index + i, buf[i]);
 		}
 
 		index += pages;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
