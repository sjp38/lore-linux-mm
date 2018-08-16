Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 882C86B000D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 06:06:47 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id j9-v6so3248691qtn.22
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 03:06:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y131-v6si1655301qka.286.2018.08.16.03.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 03:06:46 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 3/5] mm/memory_hotplug: check if sections are already online/offline
Date: Thu, 16 Aug 2018 12:06:26 +0200
Message-Id: <20180816100628.26428-4-david@redhat.com>
In-Reply-To: <20180816100628.26428-1-david@redhat.com>
References: <20180816100628.26428-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Kemi Wang <kemi.wang@intel.com>, David Rientjes <rientjes@google.com>, Jia He <jia.he@hxt-semitech.com>, Oscar Salvador <osalvador@suse.de>, Petr Tesarik <ptesarik@suse.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dan Williams <dan.j.williams@intel.com>, David Hildenbrand <david@redhat.com>, Mathieu Malaterre <malat@debian.org>, Baoquan He <bhe@redhat.com>, Wei Yang <richard.weiyang@gmail.com>, Ross Zwisler <zwisler@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

Let's add some more sanity checking now that onlining/offlining code
works completely on section basis. This will make sure that we will
never try to online/offline sections that are already (or partially) in
the desired state.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/mmzone.h |  2 ++
 mm/memory_hotplug.c    |  5 +++++
 mm/sparse.c            | 28 ++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0859130e4db8..addfa41c047a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1228,6 +1228,8 @@ static inline int online_section_nr(unsigned long nr)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+bool mem_sections_online(unsigned long pfn, unsigned long end_pfn);
+bool mem_sections_offline(unsigned long pfn, unsigned long end_pfn);
 void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn);
 #ifdef CONFIG_MEMORY_HOTREMOVE
 void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 30d2fa42b0bb..3dc6d2a309c2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -901,6 +901,8 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		return -EINVAL;
 	if (!IS_ALIGNED(nr_pages, PAGES_PER_SECTION))
 		return -EINVAL;
+	if (!mem_sections_offline(pfn, pfn + nr_pages))
+		return -EINVAL;
 
 	/*
 	 * We can't use pfn_to_nid() because nid might be stored in struct page
@@ -1609,6 +1611,9 @@ int offline_pages(unsigned long start_pfn, unsigned long nr_pages)
 		return -EINVAL;
 	if (!IS_ALIGNED(nr_pages, PAGES_PER_SECTION))
 		return -EINVAL;
+	if (!mem_sections_online(start_pfn, end_pfn))
+		return -EINVAL;
+
 	/* This makes hotplug much easier...and readable.
 	   we assume this for now. .*/
 	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start, &valid_end))
diff --git a/mm/sparse.c b/mm/sparse.c
index 10b07eea9a6e..44693cf38ca9 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -520,6 +520,34 @@ void __init sparse_init(void)
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 
+/* check if all mem sections are online */
+bool mem_sections_online(unsigned long pfn, unsigned long end_pfn)
+{
+	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		unsigned long section_nr = pfn_to_section_nr(pfn);
+
+		if (WARN_ON(!valid_section_nr(section_nr)))
+			continue;
+		if (!online_section_nr(section_nr))
+			return false;
+	}
+	return true;
+}
+
+/* check if all mem sections are offline */
+bool mem_sections_offline(unsigned long pfn, unsigned long end_pfn)
+{
+	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		unsigned long section_nr = pfn_to_section_nr(pfn);
+
+		if (WARN_ON(!valid_section_nr(section_nr)))
+			continue;
+		if (online_section_nr(section_nr))
+			return false;
+	}
+	return true;
+}
+
 /* Mark all memory sections within the pfn range as online */
 void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 {
-- 
2.17.1
