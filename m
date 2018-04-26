Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7246B0009
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 11:58:44 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id s7-v6so16444593ybo.4
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 08:58:44 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c186-v6si2983783ywb.520.2018.04.26.08.58.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 08:58:43 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH] mm: sections are not offlined during memory hotremove
Date: Thu, 26 Apr 2018 11:58:34 -0400
Message-Id: <20180426155834.16845-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, mhocko@suse.com, linux-mm@kvack.org

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
1.8.3.1
