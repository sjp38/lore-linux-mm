Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 958936B2A35
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:08:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r20-v6so2883465pgv.20
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:08:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o1-v6sor1394536pfk.89.2018.08.23.06.08.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 06:08:21 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 3/3] mm/sparse: use __highest_present_section_nr as the boundary for pfn check
Date: Thu, 23 Aug 2018 21:07:32 +0800
Message-Id: <20180823130732.9489-4-richard.weiyang@gmail.com>
In-Reply-To: <20180823130732.9489-1-richard.weiyang@gmail.com>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com, Wei Yang <richard.weiyang@gmail.com>

And it is known, __highest_present_section_nr is a more strict boundary
than NR_MEM_SECTIONS.

This patch uses a __highest_present_section_nr to check a valid pfn.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/mmzone.h | 4 ++--
 mm/sparse.c            | 1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 33086f86d1a7..5138efde11ae 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1237,7 +1237,7 @@ extern int __highest_present_section_nr;
 #ifndef CONFIG_HAVE_ARCH_PFN_VALID
 static inline int pfn_valid(unsigned long pfn)
 {
-	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
+	if (pfn_to_section_nr(pfn) > __highest_present_section_nr)
 		return 0;
 	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
@@ -1245,7 +1245,7 @@ static inline int pfn_valid(unsigned long pfn)
 
 static inline int pfn_present(unsigned long pfn)
 {
-	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
+	if (pfn_to_section_nr(pfn) > __highest_present_section_nr)
 		return 0;
 	return present_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index 90bab7f03757..a9c55c8da11f 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -174,6 +174,7 @@ void __meminit mminit_validate_memmodel_limits(unsigned long *start_pfn,
  * those loops early.
  */
 int __highest_present_section_nr;
+EXPORT_SYMBOL(__highest_present_section_nr);
 static void section_mark_present(struct mem_section *ms)
 {
 	int section_nr = __section_nr(ms);
-- 
2.15.1
