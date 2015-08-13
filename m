Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1901F6B0257
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:07:09 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so13952342pdr.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:07:08 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pi9si1333518pdb.48.2015.08.12.20.07.07
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:07:08 -0700 (PDT)
Subject: [PATCH v5 5/5] scatterlist: convert to __pfn_t
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:01:25 -0400
Message-ID: <20150813030125.36703.92536.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org, hch@lst.de

__pfn_t has flags for sg_chain and sg_last, use it to replace the
(struct page *) entry in struct scatterlist.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mm.h          |    9 +++
 include/linux/scatterlist.h |  111 ++++++++++++++++++++++++++++++-------------
 samples/kfifo/dma-example.c |    8 ++-
 3 files changed, 91 insertions(+), 37 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c4683ea2fcab..348f69467f54 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -992,6 +992,15 @@ static inline __pfn_t page_to_pfn_t(struct page *page)
 	return pfn;
 }
 
+static inline __pfn_t nth_pfn(__pfn_t pfn, unsigned int n)
+{
+	__pfn_t ret;
+
+	ret.val = (__pfn_t_to_pfn(pfn) + n) << PAGE_SHIFT
+		| (pfn.val & PFN_MASK);
+	return ret;
+}
+
 /*
  * Some inline functions in vmstat.h depend on page_zone()
  */
diff --git a/include/linux/scatterlist.h b/include/linux/scatterlist.h
index 698e906ca730..c612599bb155 100644
--- a/include/linux/scatterlist.h
+++ b/include/linux/scatterlist.h
@@ -11,7 +11,7 @@ struct scatterlist {
 #ifdef CONFIG_DEBUG_SG
 	unsigned long	sg_magic;
 #endif
-	unsigned long	page_link;
+	__pfn_t		pfn;
 	unsigned int	offset;
 	unsigned int	length;
 	dma_addr_t	dma_address;
@@ -44,14 +44,14 @@ struct sg_table {
 /*
  * Notes on SG table design.
  *
- * We use the unsigned long page_link field in the scatterlist struct to place
+ * We use the __pfn_t pfn field in the scatterlist struct to place
  * the page pointer AND encode information about the sg table as well. The two
  * lower bits are reserved for this information.
  *
- * If bit 0 is set, then the page_link contains a pointer to the next sg
+ * If PFN_SG_CHAIN is set, then the pfn contains a pointer to the next sg
  * table list. Otherwise the next entry is at sg + 1.
  *
- * If bit 1 is set, then this sg entry is the last element in a list.
+ * If PFN_SG_LAST is set, then this sg entry is the last element in a list.
  *
  * See sg_next().
  *
@@ -64,10 +64,31 @@ struct sg_table {
  * a valid sg entry, or whether it points to the start of a new scatterlist.
  * Those low bits are there for everyone! (thanks mason :-)
  */
-#define sg_is_chain(sg)		((sg)->page_link & 0x01)
-#define sg_is_last(sg)		((sg)->page_link & 0x02)
-#define sg_chain_ptr(sg)	\
-	((struct scatterlist *) ((sg)->page_link & ~0x03))
+static inline bool sg_is_chain(struct scatterlist *sg)
+{
+	return (sg->pfn.val & PFN_SG_CHAIN) == PFN_SG_CHAIN;
+}
+
+static inline bool sg_is_last(struct scatterlist *sg)
+{
+	return (sg->pfn.val & PFN_SG_LAST) == PFN_SG_LAST;
+}
+
+static inline struct scatterlist *sg_chain_ptr(struct scatterlist *sg)
+{
+	return (struct scatterlist *) (sg->pfn.val
+		& ~(PFN_SG_CHAIN | PFN_SG_LAST));
+}
+
+static inline void sg_assign_pfn(struct scatterlist *sg, __pfn_t pfn)
+{
+#ifdef CONFIG_DEBUG_SG
+	BUG_ON(sg->sg_magic != SG_MAGIC);
+	BUG_ON(sg_is_chain(sg));
+#endif
+	pfn.val &= ~PFN_SG_LAST;
+	sg->pfn.val = (sg->pfn.val & PFN_SG_LAST) | pfn.val;
+}
 
 /**
  * sg_assign_page - Assign a given page to an SG entry
@@ -81,18 +102,20 @@ struct sg_table {
  **/
 static inline void sg_assign_page(struct scatterlist *sg, struct page *page)
 {
-	unsigned long page_link = sg->page_link & 0x3;
+	__pfn_t pfn = page_to_pfn_t(page);
 
-	/*
-	 * In order for the low bit stealing approach to work, pages
-	 * must be aligned at a 32-bit boundary as a minimum.
-	 */
-	BUG_ON((unsigned long) page & 0x03);
-#ifdef CONFIG_DEBUG_SG
-	BUG_ON(sg->sg_magic != SG_MAGIC);
-	BUG_ON(sg_is_chain(sg));
-#endif
-	sg->page_link = page_link | (unsigned long) page;
+	/* check that a __pfn_t has enough bits to encode a page */
+	BUG_ON(pfn.val & (PFN_SG_LAST | PFN_SG_CHAIN));
+
+	sg_assign_pfn(sg, pfn);
+}
+
+static inline void sg_set_pfn(struct scatterlist *sg, __pfn_t pfn,
+	unsigned int len, unsigned int offset)
+{
+	sg_assign_pfn(sg, pfn);
+	sg->offset = offset;
+	sg->length = len;
 }
 
 /**
@@ -112,18 +135,34 @@ static inline void sg_assign_page(struct scatterlist *sg, struct page *page)
 static inline void sg_set_page(struct scatterlist *sg, struct page *page,
 			       unsigned int len, unsigned int offset)
 {
-	sg_assign_page(sg, page);
-	sg->offset = offset;
-	sg->length = len;
+	sg_set_pfn(sg, page_to_pfn_t(page), len, offset);
+}
+
+static inline bool sg_has_page(struct scatterlist *sg)
+{
+	return __pfn_t_has_page(sg->pfn);
 }
 
 static inline struct page *sg_page(struct scatterlist *sg)
 {
+	__pfn_t pfn = sg->pfn;
+	struct page *page;
+
+	WARN_ONCE(!sg_has_page(sg), "scatterlist references unmapped memory\n");
+
 #ifdef CONFIG_DEBUG_SG
 	BUG_ON(sg->sg_magic != SG_MAGIC);
 	BUG_ON(sg_is_chain(sg));
 #endif
-	return (struct page *)((sg)->page_link & ~0x3);
+
+	page = __pfn_t_to_page(pfn);
+
+	return page;
+}
+
+static inline unsigned long sg_pfn(struct scatterlist *sg)
+{
+	return __pfn_t_to_pfn(sg->pfn);
 }
 
 /**
@@ -171,7 +210,8 @@ static inline void sg_chain(struct scatterlist *prv, unsigned int prv_nents,
 	 * Set lowest bit to indicate a link pointer, and make sure to clear
 	 * the termination bit if it happens to be set.
 	 */
-	prv[prv_nents - 1].page_link = ((unsigned long) sgl | 0x01) & ~0x02;
+	prv[prv_nents - 1].pfn.val = ((unsigned long) sgl | PFN_SG_CHAIN)
+		& ~PFN_SG_LAST;
 }
 
 /**
@@ -191,8 +231,8 @@ static inline void sg_mark_end(struct scatterlist *sg)
 	/*
 	 * Set termination bit, clear potential chain bit
 	 */
-	sg->page_link |= 0x02;
-	sg->page_link &= ~0x01;
+	sg->pfn.val |= PFN_SG_LAST;
+	sg->pfn.val &= ~PFN_SG_CHAIN;
 }
 
 /**
@@ -208,7 +248,7 @@ static inline void sg_unmark_end(struct scatterlist *sg)
 #ifdef CONFIG_DEBUG_SG
 	BUG_ON(sg->sg_magic != SG_MAGIC);
 #endif
-	sg->page_link &= ~0x02;
+	sg->pfn.val &= ~PFN_SG_LAST;
 }
 
 /**
@@ -216,14 +256,13 @@ static inline void sg_unmark_end(struct scatterlist *sg)
  * @sg:	     SG entry
  *
  * Description:
- *   This calls page_to_phys() on the page in this sg entry, and adds the
- *   sg offset. The caller must know that it is legal to call page_to_phys()
- *   on the sg page.
+ *   This calls __pfn_t_to_phys() on the pfn in this sg entry, and adds the
+ *   sg offset.
  *
  **/
 static inline dma_addr_t sg_phys(struct scatterlist *sg)
 {
-	return page_to_phys(sg_page(sg)) + sg->offset;
+	return __pfn_t_to_phys(sg->pfn) + sg->offset;
 }
 
 /**
@@ -281,7 +320,7 @@ size_t sg_pcopy_to_buffer(struct scatterlist *sgl, unsigned int nents,
 #define SG_MAX_SINGLE_ALLOC		(PAGE_SIZE / sizeof(struct scatterlist))
 
 /*
- * sg page iterator
+ * sg page / pfn iterator
  *
  * Iterates over sg entries page-by-page.  On each successful iteration,
  * you can call sg_page_iter_page(@piter) and sg_page_iter_dma_address(@piter)
@@ -304,13 +343,19 @@ bool __sg_page_iter_next(struct sg_page_iter *piter);
 void __sg_page_iter_start(struct sg_page_iter *piter,
 			  struct scatterlist *sglist, unsigned int nents,
 			  unsigned long pgoffset);
+
+static inline __pfn_t sg_page_iter_pfn(struct sg_page_iter *piter)
+{
+	return nth_pfn(piter->sg->pfn, piter->sg_pgoffset);
+}
+
 /**
  * sg_page_iter_page - get the current page held by the page iterator
  * @piter:	page iterator holding the page
  */
 static inline struct page *sg_page_iter_page(struct sg_page_iter *piter)
 {
-	return nth_page(sg_page(piter->sg), piter->sg_pgoffset);
+	return __pfn_t_to_page(sg_page_iter_pfn(piter));
 }
 
 /**
diff --git a/samples/kfifo/dma-example.c b/samples/kfifo/dma-example.c
index aa243db93f01..3eeff9a56e0e 100644
--- a/samples/kfifo/dma-example.c
+++ b/samples/kfifo/dma-example.c
@@ -75,8 +75,8 @@ static int __init example_init(void)
 	for (i = 0; i < nents; i++) {
 		printk(KERN_INFO
 		"sg[%d] -> "
-		"page_link 0x%.8lx offset 0x%.8x length 0x%.8x\n",
-			i, sg[i].page_link, sg[i].offset, sg[i].length);
+		"pfn_data 0x%.8lx offset 0x%.8x length 0x%.8x\n",
+			i, sg[i].pfn.data, sg[i].offset, sg[i].length);
 
 		if (sg_is_last(&sg[i]))
 			break;
@@ -104,8 +104,8 @@ static int __init example_init(void)
 	for (i = 0; i < nents; i++) {
 		printk(KERN_INFO
 		"sg[%d] -> "
-		"page_link 0x%.8lx offset 0x%.8x length 0x%.8x\n",
-			i, sg[i].page_link, sg[i].offset, sg[i].length);
+		"pfn_data 0x%.8lx offset 0x%.8x length 0x%.8x\n",
+			i, sg[i].pfn.data, sg[i].offset, sg[i].length);
 
 		if (sg_is_last(&sg[i]))
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
