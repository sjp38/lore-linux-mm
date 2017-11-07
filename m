Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D13DD6B029D
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 04:43:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id j3so16213903pga.5
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 01:43:15 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id t66si737888pgc.106.2017.11.07.01.43.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 01:43:14 -0800 (PST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] mm: page_ext: allocate page extension though first PFN is
 invalid
Date: Tue, 07 Nov 2017 18:44:47 +0900
Message-id: <20171107094447.14763-1-jaewon31.kim@samsung.com>
References: <CGME20171107094311epcas1p4a5dd975d6e9f3618a26a0a5d68c68b55@epcas1p4.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

online_page_ext and page_ext_init allocate page_ext for each section, but
they do not allocate if the first PFN is !pfn_present(pfn) or
!pfn_valid(pfn).

Though the first page is not valid, page_ext could be useful for other
pages in the section. But checking all PFNs in a section may be time
consuming job. Let's check each (section count / 16) PFN, then prepare
page_ext if any PFN is present or valid.

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 mm/page_ext.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 32f18911deda..634f9c5a8b9b 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -312,7 +312,17 @@ static int __meminit online_page_ext(unsigned long start_pfn,
 	}
 
 	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
-		if (!pfn_present(pfn))
+		unsigned long t_pfn = pfn;
+		bool present = false;
+
+		while (t_pfn <	ALIGN(pfn + 1, PAGES_PER_SECTION)) {
+			if (pfn_present(t_pfn)) {
+				present = true;
+				break;
+			}
+			t_pfn = ALIGN(pfn + 1, PAGES_PER_SECTION >> 4);
+		}
+		if (!present)
 			continue;
 		fail = init_section_page_ext(pfn, nid);
 	}
@@ -391,8 +401,17 @@ void __init page_ext_init(void)
 		 */
 		for (pfn = start_pfn; pfn < end_pfn;
 			pfn = ALIGN(pfn + 1, PAGES_PER_SECTION)) {
-
-			if (!pfn_valid(pfn))
+			unsigned long t_pfn = pfn;
+			bool valid = false;
+
+			while (t_pfn <	ALIGN(pfn + 1, PAGES_PER_SECTION)) {
+				if (pfn_valid(t_pfn)) {
+					valid = true;
+					break;
+				}
+				t_pfn = ALIGN(pfn + 1, PAGES_PER_SECTION >> 4);
+			}
+			if (!valid)
 				continue;
 			/*
 			 * Nodes's pfns can be overlapping.
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
