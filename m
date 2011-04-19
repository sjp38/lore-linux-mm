Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 887E28D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 17:58:27 -0400 (EDT)
Date: Tue, 19 Apr 2011 16:58:22 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <1303249716.11237.26.camel@mulgrave.site>
Message-ID: <alpine.DEB.2.00.1104191657030.26867@router.home>
References: <20110415135144.GE8828@tiehlicka.suse.cz>  <alpine.LSU.2.00.1104171952040.22679@sister.anvils>  <20110418100131.GD8925@tiehlicka.suse.cz>  <20110418135637.5baac204.akpm@linux-foundation.org>  <20110419111004.GE21689@tiehlicka.suse.cz>
 <1303228009.3171.18.camel@mulgrave.site>  <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com>  <1303233088.3171.26.camel@mulgrave.site>  <alpine.DEB.2.00.1104191213120.17888@router.home>  <1303235306.3171.33.camel@mulgrave.site>
 <alpine.DEB.2.00.1104191254300.19358@router.home>  <1303237217.3171.39.camel@mulgrave.site>  <alpine.DEB.2.00.1104191325470.19358@router.home>  <1303242580.11237.10.camel@mulgrave.site>  <alpine.DEB.2.00.1104191530040.23077@router.home>
 <1303248103.11237.16.camel@mulgrave.site>  <alpine.DEB.2.00.1104191627040.23077@router.home> <1303249716.11237.26.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

On Tue, 19 Apr 2011, James Bottomley wrote:

> > Which part of me telling you that you will break lots of other things in
> > the core kernel dont you get?
>
> I get that you tell me this ... however, the systems that, according to
> you, should be failing to get to boot prompt do, in fact, manage it.

If you dont use certain subsystems then it may work. Also do you run with
debuggin on.

The following patch is I think what would be needed to fix it.



Subject: [PATCH] Fix discontig support for !NUMA

Under NUMA discontig nodes map directly to the kernel NUMA nodes.

However, when DISCONTIG is used without NUMA then the kernel has only
one NUMA mode (==0) but within the node there may be multiple discontig pages
on various "nodes" for page struct vector management purposes.

Define a function __page_to_nid() that always extracts the node from
the page struct. This can be used in places where we need the discontig
node. Define page_to_nid() under !NUMA to always return 0. This ensures
that the various subsystems relying on page_to_nid(page) == 0 on !NUMA
function properly.

<Untested since I do not have a PARISC system. There could be
additional occurrences that need __page_to_nid>

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/asm-generic/memory_model.h |    2 +-
 include/linux/mm.h                 |   10 ++++++++--
 mm/sparse.c                        |    2 +-
 3 files changed, 10 insertions(+), 4 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2011-04-19 16:43:53.822507013 -0500
+++ linux-2.6/include/linux/mm.h	2011-04-19 16:44:52.082506944 -0500
@@ -666,14 +666,20 @@ static inline int zone_to_nid(struct zon
 }

 #ifdef NODE_NOT_IN_PAGE_FLAGS
-extern int page_to_nid(struct page *page);
+extern int __page_to_nid(struct page *page);
 #else
-static inline int page_to_nid(struct page *page)
+static inline int __page_to_nid(struct page *page)
 {
 	return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
 }
 #endif

+#ifdef CONFIG_NUMA
+#define page_to_nid __page_to_nid
+#else
+#define page_to_nid(x) 0
+#endif
+
 static inline struct zone *page_zone(struct page *page)
 {
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
Index: linux-2.6/include/asm-generic/memory_model.h
===================================================================
--- linux-2.6.orig/include/asm-generic/memory_model.h	2011-04-19 16:45:26.772506904 -0500
+++ linux-2.6/include/asm-generic/memory_model.h	2011-04-19 16:46:02.602506861 -0500
@@ -40,7 +40,7 @@

 #define __page_to_pfn(pg)						\
 ({	struct page *__pg = (pg);					\
-	struct pglist_data *__pgdat = NODE_DATA(page_to_nid(__pg));	\
+	struct pglist_data *__pgdat = NODE_DATA(__page_to_nid(__pg));	\
 	(unsigned long)(__pg - __pgdat->node_mem_map) +			\
 	 __pgdat->node_start_pfn;					\
 })
Index: linux-2.6/mm/sparse.c
===================================================================
--- linux-2.6.orig/mm/sparse.c	2011-04-19 16:44:58.432506937 -0500
+++ linux-2.6/mm/sparse.c	2011-04-19 16:45:07.332506926 -0500
@@ -40,7 +40,7 @@ static u8 section_to_node_table[NR_MEM_S
 static u16 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
 #endif

-int page_to_nid(struct page *page)
+int __page_to_nid(struct page *page)
 {
 	return section_to_node_table[page_to_section(page)];
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
