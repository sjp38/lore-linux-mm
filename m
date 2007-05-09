Date: Wed, 09 May 2007 12:12:12 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC] memory hotremove patch take 2 [08/10] (memap init alignment)
In-Reply-To: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
Message-Id: <20070509120814.B916.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

If there is small hole at end of a section, there are not initialized pages.
To find it, messy check is necessary at many place of memory remove code.
But, reserved bit by initialization is enough for most case of them.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 mm/page_alloc.c |    5 +++++
 1 files changed, 5 insertions(+)

Index: current_test/mm/page_alloc.c
===================================================================
--- current_test.orig/mm/page_alloc.c	2007-05-08 15:08:05.000000000 +0900
+++ current_test/mm/page_alloc.c	2007-05-08 15:08:08.000000000 +0900
@@ -2434,6 +2434,11 @@ void __meminit memmap_init_zone(unsigned
 	unsigned long end_pfn = start_pfn + size;
 	unsigned long pfn;
 
+
+#ifdef CONFIG_SPARSEMEM
+	end_pfn = roundup(end_pfn, PAGES_PER_SECTION);
+#endif
+
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		/*
 		 * There can be holes in boot-time mem_map[]s

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
