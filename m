Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C30B66B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 17:20:35 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1532337Ab1EBVUM (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 2 May 2011 23:20:12 +0200
Date: Mon, 2 May 2011 23:20:12 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 2/4] mm: Enable set_page_section() only if CONFIG_SPARSEMEM and !CONFIG_SPARSEMEM_VMEMMAP
Message-ID: <20110502212012.GC4623@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

set_page_section() is valid only in CONFIG_SPARSEMEM and
!CONFIG_SPARSEMEM_VMEMMAP context. Move it to proper place
and amend accordingly functions which are using it.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 include/linux/mm.h |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 692dbae..23465e1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -680,6 +680,12 @@ static inline struct zone *page_zone(struct page *page)
 }
 
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
+static inline void set_page_section(struct page *page, unsigned long section)
+{
+	page->flags &= ~(SECTIONS_MASK << SECTIONS_PGSHIFT);
+	page->flags |= (section & SECTIONS_MASK) << SECTIONS_PGSHIFT;
+}
+
 static inline unsigned long page_to_section(struct page *page)
 {
 	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
@@ -698,18 +704,14 @@ static inline void set_page_node(struct page *page, unsigned long node)
 	page->flags |= (node & NODES_MASK) << NODES_PGSHIFT;
 }
 
-static inline void set_page_section(struct page *page, unsigned long section)
-{
-	page->flags &= ~(SECTIONS_MASK << SECTIONS_PGSHIFT);
-	page->flags |= (section & SECTIONS_MASK) << SECTIONS_PGSHIFT;
-}
-
 static inline void set_page_links(struct page *page, enum zone_type zone,
 	unsigned long node, unsigned long pfn)
 {
 	set_page_zone(page, zone);
 	set_page_node(page, node);
+#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 	set_page_section(page, pfn_to_section_nr(pfn));
+#endif
 }
 
 /*
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
