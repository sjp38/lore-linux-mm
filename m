Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2F36B025E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 08:29:52 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id 191so124620964wmq.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 05:29:52 -0700 (PDT)
Received: from mail.free-electrons.com (down.free-electrons.com. [37.187.137.238])
        by mx.google.com with ESMTP id 128si12260948wmg.38.2016.03.31.05.29.49
        for <linux-mm@kvack.org>;
        Thu, 31 Mar 2016 05:29:49 -0700 (PDT)
From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH 2/4] scatterlist: add sg_alloc_table_from_buf() helper
Date: Thu, 31 Mar 2016 14:29:42 +0200
Message-Id: <1459427384-21374-3-git-send-email-boris.brezillon@free-electrons.com>
In-Reply-To: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
References: <1459427384-21374-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, linux-mtd@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Dave Gordon <david.s.gordon@intel.com>
Cc: Mark Brown <broonie@kernel.org>, linux-spi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>, dmaengine@vger.kernel.org, Mauro Carvalho Chehab <m.chehab@samsung.com>, Hans Verkuil <hans.verkuil@cisco.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, linux-media@vger.kernel.org, Boris Brezillon <boris.brezillon@free-electrons.com>, Richard Weinberger <richard@nod.at>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, linux-crypto@vger.kernel.org, Vignesh R <vigneshr@ti.com>, linux-mm@kvack.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org

sg_alloc_table_from_buf() provides an easy solution to create an sg_table
from a virtual address pointer. This function takes care of dealing with
vmallocated buffers, buffer alignment, or DMA engine limitations (maximum
DMA transfer size).

Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
---
 include/linux/scatterlist.h |  24 ++++++
 lib/scatterlist.c           | 183 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 207 insertions(+)

diff --git a/include/linux/scatterlist.h b/include/linux/scatterlist.h
index 556ec1e..18d1091 100644
--- a/include/linux/scatterlist.h
+++ b/include/linux/scatterlist.h
@@ -41,6 +41,27 @@ struct sg_table {
 	unsigned int orig_nents;	/* original size of list */
 };
 
+/**
+ * struct sg_constraints - SG constraints structure
+ *
+ * @max_segment_size: maximum segment length. Each SG entry has to be smaller
+ *		      than this value. Zero means no constraint.
+ * @required_alignment: minimum alignment. Is used for both size and pointer
+ *			alignment. If this constraint is not met, the function
+ *			should return -EINVAL.
+ * @preferred_alignment: preferred alignment. Mainly used to optimize
+ *			 throughput when the DMA engine performs better when
+ *			 doing aligned accesses.
+ *
+ * This structure is here to help sg_alloc_table_from_buf() create the optimal
+ * SG list based on DMA engine constraints.
+ */
+struct sg_constraints {
+	size_t max_segment_size;
+	size_t required_alignment;
+	size_t preferred_alignment;
+};
+
 /*
  * Notes on SG table design.
  *
@@ -265,6 +286,9 @@ int sg_alloc_table_from_pages(struct sg_table *sgt,
 	struct page **pages, unsigned int n_pages,
 	unsigned long offset, unsigned long size,
 	gfp_t gfp_mask);
+int sg_alloc_table_from_buf(struct sg_table *sgt, const void *buf, size_t len,
+			    const struct sg_constraints *constraints,
+			    gfp_t gfp_mask);
 
 size_t sg_copy_buffer(struct scatterlist *sgl, unsigned int nents, void *buf,
 		      size_t buflen, off_t skip, bool to_buffer);
diff --git a/lib/scatterlist.c b/lib/scatterlist.c
index 004fc70..9c9746e 100644
--- a/lib/scatterlist.c
+++ b/lib/scatterlist.c
@@ -433,6 +433,189 @@ int sg_alloc_table_from_pages(struct sg_table *sgt,
 }
 EXPORT_SYMBOL(sg_alloc_table_from_pages);
 
+static size_t sg_buf_chunk_len(const void *buf, size_t len,
+			       const struct sg_constraints *cons)
+{
+	size_t chunk_len = len;
+
+	if (cons->max_segment_size)
+		chunk_len = min_t(size_t, chunk_len, cons->max_segment_size);
+
+	if (is_vmalloc_addr(buf)) {
+		unsigned long offset_in_page = offset_in_page(buf);
+		size_t contig_len = PAGE_SIZE - offset_in_page;
+		unsigned long phys = vmalloc_to_pfn(buf) - offset_in_page;
+		const void *contig_ptr = buf + contig_len;
+
+		/*
+		 * Vmalloced buffer might be composed of several physically
+		 * contiguous pages. Avoid extra scattergather entries in
+		 * this case.
+		 */
+		while (contig_len < chunk_len) {
+			if (phys + PAGE_SIZE != vmalloc_to_pfn(contig_ptr))
+				break;
+
+			contig_len += PAGE_SIZE;
+			contig_ptr += PAGE_SIZE;
+			phys += PAGE_SIZE;
+		}
+
+		chunk_len = min_t(size_t, chunk_len, contig_len);
+	}
+
+	if (!IS_ALIGNED((unsigned long)buf, cons->preferred_alignment)) {
+		const void *aligned_buf = PTR_ALIGN(buf,
+						    cons->preferred_alignment);
+		size_t unaligned_len = (unsigned long)(aligned_buf - buf);
+
+		chunk_len = min_t(size_t, chunk_len, unaligned_len);
+	} else if (chunk_len > cons->preferred_alignment) {
+		chunk_len &= ~(cons->preferred_alignment - 1);
+	}
+
+	return chunk_len;
+}
+
+#define sg_for_each_chunk_in_buf(buf, len, chunk_len, constraints)	\
+	for (chunk_len = sg_buf_chunk_len(buf, len, constraints);	\
+	     len;							\
+	     len -= chunk_len, buf += chunk_len,			\
+	     chunk_len = sg_buf_chunk_len(buf, len, constraints))
+
+static int sg_check_constraints(struct sg_constraints *cons,
+				const void *buf, size_t len)
+{
+	/*
+	 * We only accept buffers coming from the lowmem, vmalloc and
+	 * highmem regions.
+	 */
+	if (!virt_addr_valid(buf) && !is_vmalloc_addr(buf) &&
+	    !is_highmem_addr(buf))
+		return -EINVAL;
+
+	if (!cons->required_alignment)
+		cons->required_alignment = 1;
+
+	if (!cons->preferred_alignment)
+		cons->preferred_alignment = cons->required_alignment;
+
+	/* Test if buf and len are properly aligned. */
+	if (!IS_ALIGNED((unsigned long)buf, cons->required_alignment) ||
+	    !IS_ALIGNED(len, cons->required_alignment))
+		return -EINVAL;
+
+	/*
+	 * if the buffer has been vmallocated or kmapped and required_alignment
+	 * is more than PAGE_SIZE we cannot guarantee it.
+	 */
+	if (!virt_addr_valid(buf) && cons->required_alignment > PAGE_SIZE)
+		return -EINVAL;
+
+	/*
+	 * max_segment_size has to be aligned to required_alignment to
+	 * guarantee that all buffer chunks are aligned correctly.
+	 */
+	if (!IS_ALIGNED(cons->max_segment_size, cons->required_alignment))
+		return -EINVAL;
+
+	/*
+	 * preferred_alignment has to be aligned to required_alignment
+	 * to avoid misalignment of buffer chunks.
+	 */
+	if (!IS_ALIGNED(cons->preferred_alignment, cons->required_alignment))
+		return -EINVAL;
+
+	return 0;
+}
+
+/**
+ * sg_alloc_table_from_buf - create an SG table from a buffer
+ *
+ * @sgt: SG table
+ * @buf: buffer you want to create this SG table from
+ * @len: length of buf
+ * @constraints: optional constraints to take into account when creating
+ *		 the SG table. Can be NULL if no specific constraints are
+ *		 required.
+ * @gfp_mask: type of allocation to use when creating the table
+ *
+ * This function creates an SG table from a buffer, its length and some
+ * SG constraints.
+ *
+ * Note: This function supports buffers coming from the lowmem, vmalloc or
+ * highmem region.
+ */
+int sg_alloc_table_from_buf(struct sg_table *sgt, const void *buf, size_t len,
+			    const struct sg_constraints *constraints,
+			    gfp_t gfp_mask)
+{
+	struct sg_constraints cons = { };
+	size_t remaining, chunk_len;
+	const void *sg_buf;
+	int i, ret;
+
+	if (constraints)
+		cons = *constraints;
+
+	ret = sg_check_constraints(&cons, buf, len);
+	if (ret)
+		return ret;
+
+	sg_buf = buf;
+	remaining = len;
+	i = 0;
+	sg_for_each_chunk_in_buf(sg_buf, remaining, chunk_len, &cons)
+		i++;
+
+	ret = sg_alloc_table(sgt, i, gfp_mask);
+	if (ret)
+		return ret;
+
+	sg_buf = buf;
+	remaining = len;
+	i = 0;
+	sg_for_each_chunk_in_buf(sg_buf, remaining, chunk_len, &cons) {
+		if (virt_addr_valid(buf)) {
+			/*
+			 * Buffer is in lowmem, we can safely call
+			 * sg_set_buf().
+			 */
+			sg_set_buf(&sgt->sgl[i], sg_buf, chunk_len);
+		} else {
+			struct page *vm_page;
+
+			/*
+			 * Buffer has been obtained with vmalloc() or kmap().
+			 * In this case we have to extract the page information
+			 * and use sg_set_page().
+			 */
+			if (is_vmalloc_addr(sg_buf))
+				vm_page = vmalloc_to_page(sg_buf);
+			else
+				vm_page = kmap_to_page((void *)sg_buf);
+
+			if (!vm_page) {
+				ret = -ENOMEM;
+				goto err_free_table;
+			}
+
+			sg_set_page(&sgt->sgl[i], vm_page, chunk_len,
+				    offset_in_page(sg_buf));
+		}
+
+		i++;
+	}
+
+	return 0;
+
+err_free_table:
+	sg_free_table(sgt);
+
+	return ret;
+}
+EXPORT_SYMBOL(sg_alloc_table_from_buf);
+
 void __sg_page_iter_start(struct sg_page_iter *piter,
 			  struct scatterlist *sglist, unsigned int nents,
 			  unsigned long pgoffset)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
