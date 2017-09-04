Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 494F56B04A7
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 07:22:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l19so55387wmi.1
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 04:22:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e6sor818489wra.32.2017.09.04.04.22.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Sep 2017 04:22:16 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, sparse: fix typo in online_mem_sections
Date: Mon,  4 Sep 2017 13:22:10 +0200
Message-Id: <20170904112210.3401-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

online_mem_sections accidentally marks online only the first section in
the given range. This is a typo which hasn't been noticed because I
haven't tested large 2GB blocks previously. All users of
pfn_to_online_page would get confused on the the rest of the pfn range
in the block.

All we need to fix this is to use iterator (pfn) rather than start_pfn.

Fixes: 2d070eab2e82 ("mm: consider zone which is not fully populated to have holes")
Cc: stable
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index a9783acf2bb9..83b3bf6461af 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -626,7 +626,7 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 	unsigned long pfn;
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
-		unsigned long section_nr = pfn_to_section_nr(start_pfn);
+		unsigned long section_nr = pfn_to_section_nr(pfn);
 		struct mem_section *ms;
 
 		/* onlining code should never touch invalid ranges */
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
