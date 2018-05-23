Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6F46B02AA
	for <linux-mm@kvack.org>; Wed, 23 May 2018 11:12:12 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id p126-v6so22801837qkd.1
        for <linux-mm@kvack.org>; Wed, 23 May 2018 08:12:12 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n23-v6si289552qtn.181.2018.05.23.08.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 08:12:11 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 02/10] mm/page_ext.c: support online/offline of memory < section size
Date: Wed, 23 May 2018 17:11:43 +0200
Message-Id: <20180523151151.6730-3-david@redhat.com>
In-Reply-To: <20180523151151.6730-1-david@redhat.com>
References: <20180523151151.6730-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@techadventures.net>, Kate Stewart <kstewart@linuxfoundation.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Right now, we would free the extended page data if parts of a section
are offlined or if onlining is aborted, although still some pages are
online.

We can simply check if the section is online to see if we are allowed to
free. init_section_page_ext() already takes care of the allocation part
for sub sections.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@techadventures.net>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: Jaewon Kim <jaewon31.kim@samsung.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/page_ext.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 5295ef331165..71a025128dac 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -320,7 +320,9 @@ static int __meminit online_page_ext(unsigned long start_pfn,
 
 	/* rollback */
 	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)
-		__free_page_ext(pfn);
+		/* still online? nothing to do then */
+		if (!online_section_nr(pfn_to_section_nr(pfn)))
+			__free_page_ext(pfn);
 
 	return -ENOMEM;
 }
@@ -334,7 +336,10 @@ static int __meminit offline_page_ext(unsigned long start_pfn,
 	end = SECTION_ALIGN_UP(start_pfn + nr_pages);
 
 	for (pfn = start; pfn < end; pfn += PAGES_PER_SECTION)
-		__free_page_ext(pfn);
+		/* still online? nothing to do then */
+		if (!online_section_nr(pfn_to_section_nr(pfn)))
+			__free_page_ext(pfn);
+
 	return 0;
 
 }
-- 
2.17.0
