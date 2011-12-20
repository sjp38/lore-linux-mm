Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id BA0C46B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 05:00:49 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 3/3] page_cgroup: drop multi CONFIG_MEMORY_HOTPLUG
Date: Tue, 20 Dec 2011 18:03:41 +0800
Message-ID: <1324375421-31358-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, Bob Liu <lliubbo@gmail.com>

No need two CONFIG_MEMORY_HOTPLUG place.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/page_cgroup.c |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index b99d19e..de1616a 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -124,22 +124,6 @@ static void *__meminit alloc_page_cgroup(size_t size, int nid)
 	return addr;
 }
 
-#ifdef CONFIG_MEMORY_HOTPLUG
-static void free_page_cgroup(void *addr)
-{
-	if (is_vmalloc_addr(addr)) {
-		vfree(addr);
-	} else {
-		struct page *page = virt_to_page(addr);
-		size_t table_size =
-			sizeof(struct page_cgroup) * PAGES_PER_SECTION;
-
-		BUG_ON(PageReserved(page));
-		free_pages_exact(addr, table_size);
-	}
-}
-#endif
-
 static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
 {
 	struct mem_section *section;
@@ -176,6 +160,20 @@ static int __meminit init_section_page_cgroup(unsigned long pfn, int nid)
 	return 0;
 }
 #ifdef CONFIG_MEMORY_HOTPLUG
+static void free_page_cgroup(void *addr)
+{
+	if (is_vmalloc_addr(addr)) {
+		vfree(addr);
+	} else {
+		struct page *page = virt_to_page(addr);
+		size_t table_size =
+			sizeof(struct page_cgroup) * PAGES_PER_SECTION;
+
+		BUG_ON(PageReserved(page));
+		free_pages_exact(addr, table_size);
+	}
+}
+
 void __free_page_cgroup(unsigned long pfn)
 {
 	struct mem_section *ms;
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
