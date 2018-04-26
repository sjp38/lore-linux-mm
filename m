Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5D156B0007
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 16:30:11 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d128so19530726qkf.18
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 13:30:11 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p18si1380768qvi.150.2018.04.26.13.30.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 13:30:10 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH] mm: sections are not offlined during memory hotremove
Date: Thu, 26 Apr 2018 16:30:02 -0400
Message-Id: <20180426203002.3151-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, mhocko@suse.com, linux-mm@kvack.org, stable@vger.kernel.org

Memory hotplug, and hotremove operate with per-block granularity. If
machine has large amount of memory (more than 64G), the size of memory
block can span multiple sections. By mistake, during hotremove we set
only the first section to offline state.

The bug was discovered because kernel selftest started to fail:
https://lkml.kernel.org/r/20180423011247.GK5563@yexl-desktop

After commit, "mm/memory_hotplug: optimize probe routine". But, the bug is
older than this commit. In this optimization we also added a check for
sections to be in a proper state during hotplug operation.

Fixes: 2d070eab2e82 ("mm: consider zone which is not fully populated to have holes")

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 62eef264a7bd..73dc2fcc0eab 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -629,7 +629,7 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 	unsigned long pfn;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
-		unsigned long section_nr = pfn_to_section_nr(start_pfn);
+		unsigned long section_nr = pfn_to_section_nr(pfn);
 		struct mem_section *ms;
 
 		/*
-- 
2.17.0
