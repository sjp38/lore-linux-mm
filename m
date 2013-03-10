Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 6CEC06B004D
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 04:08:42 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id rr4so2677671pbb.13
        for <linux-mm@kvack.org>; Sun, 10 Mar 2013 00:08:41 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part2 01/10] mm: introduce free_highmem_page() helper to free highmem pages into buddy system
Date: Sun, 10 Mar 2013 16:01:01 +0800
Message-Id: <1362902470-25787-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
References: <1362902470-25787-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Russell King <linux@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, James Hogan <james.hogan@imgtec.com>, Michal Simek <monstr@monstr.eu>, Ralf Baechle <ralf@linux-mips.org>, David Daney <david.daney@cavium.com>, "David S. Miller" <davem@davemloft.net>, Sam Ravnborg <sam@ravnborg.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "H. Peter Anvin" <hpa@zytor.com>

Introduce helper function free_highmem_page(), which will be used by
architectures with HIGHMEM enabled to free highmem pages into the buddy
system.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: Russell King <linux@arm.linux.org.uk>
Cc: David Howells <dhowells@redhat.com>
Cc: James Hogan <james.hogan@imgtec.com>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: David Daney <david.daney@cavium.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
Cc: "H. Peter Anvin" <hpa@zytor.com>
---
 include/linux/mm.h |    7 +++++++
 mm/page_alloc.c    |    9 +++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d75c14b..f2fb750 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1303,6 +1303,13 @@ extern void free_initmem(void);
  */
 extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
 					int poison, char *s);
+#ifdef	CONFIG_HIGHMEM
+/*
+ * Free a highmem page into the buddy system, adjusting totalhigh_pages
+ * and totalram_pages.
+ */
+extern void free_highmem_page(struct page *page);
+#endif
 
 static inline void adjust_managed_page_count(struct page *page, long count)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0fadb09..37bc8ab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5133,6 +5133,15 @@ unsigned long free_reserved_area(unsigned long start, unsigned long end,
 	return pages;
 }
 
+#ifdef	CONFIG_HIGHMEM
+void free_highmem_page(struct page *page)
+{
+	__free_reserved_page(page);
+	totalram_pages++;
+	totalhigh_pages++;
+}
+#endif
+
 /**
  * set_dma_reserve - set the specified number of pages reserved in the first zone
  * @new_dma_reserve: The number of pages to mark reserved
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
