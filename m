Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E02A6B7390
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:19:21 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id m13so14525131pls.15
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:19:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o81sor27810184pfk.52.2018.12.05.01.19.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 01:19:20 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/2] mm, pageblock: make sure pageblock won't exceed mem_sectioin
Date: Wed,  5 Dec 2018 17:19:04 +0800
Message-Id: <20181205091905.27727-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@techsingularity.net, akpm@linux-foundation.org, Wei Yang <richard.weiyang@gmail.com>

When SPARSEMEM is used, there is an indication that pageblock is not
allowed to exceed one mem_section. Current code doesn't have this
constrain explicitly.

This patch adds this to make sure it won't.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/mmzone.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index be126113b499..8f3ce3a0c7d6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1084,6 +1084,10 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #error Allocator MAX_ORDER exceeds SECTION_SIZE
 #endif
 
+#if (pageblock_order + PAGE_SHIFT) > SECTION_SIZE_BITS
+#error Allocator pageblock_order exceeds SECTION_SIZE
+#endif
+
 static inline unsigned long pfn_to_section_nr(unsigned long pfn)
 {
 	return pfn >> PFN_SECTION_SHIFT;
-- 
2.15.1
