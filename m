Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id EEA0B6B0006
	for <linux-mm@kvack.org>; Sun, 10 Mar 2013 01:29:49 -0500 (EST)
Received: by mail-da0-f52.google.com with SMTP id f10so475729dak.25
        for <linux-mm@kvack.org>; Sat, 09 Mar 2013 22:29:49 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v2, part1 01/29] mm: introduce common help functions to deal with reserved/managed pages
Date: Sun, 10 Mar 2013 14:26:44 +0800
Message-Id: <1362896833-21104-2-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, Anatolij Gustschin <agust@denx.de>, Aurelien Jacquiot <a-jacquiot@ti.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Chen Liqin <liqin.chen@sunplusct.com>, Chris Metcalf <cmetcalf@tilera.com>, Chris Zankel <chris@zankel.net>, David Howells <dhowells@redhat.com>, "David S. Miller" <davem@davemloft.net>, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, James Hogan <james.hogan@imgtec.com>, Hirokazu Takata <takata@linux-m32r.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jonas Bonn <jonas@southpole.se>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Lennox Wu <lennox.wu@gmail.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Simek <monstr@monstr.eu>, Michel Lespinasse <walken@google.com>, Mikael Starvik <starvik@axis.com>, Mike Frysinger <vapier@gentoo.org>, Paul Mackerras <paulus@samba.org>, Paul Mundt <lethal@linux-sh.org>, Ralf Baechle <ralf@linux-mips.org>, Richard Henderson <rth@twiddle.net>, Rik van Riel <riel@redhat.com>, Russell King <linux@arm.linux.org.uk>, Rusty Russell <rusty@rustcorp.com.au>, Sam Ravnborg <sam@ravnborg.org>, Tang Chen <tangchen@cn.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Yinghai Lu <yinghai@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, x86@kernel.org, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Vineet Gupta <vgupta@synopsys.com>, linux-snps-arc@vger.kernel.org, virtualization@lists.linux-foundation.org

Code to deal with reserved/managed pages are duplicated by many
architectures, so introduce common help functions to reduce duplicated
code. These common help functions will also be used to concentrate code
to modify totalram_pages and zone->managed_pages, which makes the code
much more clear.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 include/linux/mm.h |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c    |   20 ++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7acc9dc..d75c14b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1295,6 +1295,54 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
 
+/*
+ * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
+ * into the buddy system. The freed pages will be poisoned with pattern
+ * "poison" if it's non-zero.
+ * Return pages freed into the buddy system.
+ */
+extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
+					int poison, char *s);
+
+static inline void adjust_managed_page_count(struct page *page, long count)
+{
+	totalram_pages += count;
+}
+
+/* Free the reserved page into the buddy system, so it gets managed. */
+static inline void __free_reserved_page(struct page *page)
+{
+	ClearPageReserved(page);
+	init_page_count(page);
+	__free_page(page);
+}
+
+static inline void free_reserved_page(struct page *page)
+{
+	__free_reserved_page(page);
+	adjust_managed_page_count(page, 1);
+}
+
+static inline void mark_page_reserved(struct page *page)
+{
+	SetPageReserved(page);
+	adjust_managed_page_count(page, -1);
+}
+
+/*
+ * Default method to free all the __init memory into the buddy system.
+ * The freed pages will be poisoned with pattern "poison" if it is
+ * non-zero. Return pages freed into the buddy system.
+ */
+static inline unsigned long free_initmem_default(int poison)
+{
+	extern char __init_begin[], __init_end[];
+
+	return free_reserved_area(PAGE_ALIGN((unsigned long)&__init_begin) ,
+				  ((unsigned long)&__init_end) & PAGE_MASK,
+				  poison, "unused kernel");
+}
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 /*
  * With CONFIG_HAVE_MEMBLOCK_NODE_MAP set, an architecture may initialise its
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fcced7..0fadb09 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5113,6 +5113,26 @@ early_param("movablecore", cmdline_parse_movablecore);
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
+unsigned long free_reserved_area(unsigned long start, unsigned long end,
+				 int poison, char *s)
+{
+	unsigned long pages, pos;
+
+	pos = start = PAGE_ALIGN(start);
+	end &= PAGE_MASK;
+	for (pages = 0; pos < end; pos += PAGE_SIZE, pages++) {
+		if (poison)
+			memset((void *)pos, poison, PAGE_SIZE);
+		free_reserved_page(virt_to_page(pos));
+	}
+
+	if (pages && s)
+		pr_info("Freeing %s memory: %ldK (%lx - %lx)\n",
+			s, pages << (PAGE_SHIFT - 10), start, end);
+
+	return pages;
+}
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
