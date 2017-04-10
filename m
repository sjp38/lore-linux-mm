Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 629C56B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:12:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b10so127982162pgn.8
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:12:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id r7si14280995ple.25.2017.04.10.11.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 11:12:03 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3AI4DgS139502
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:12:03 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29re422mcx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:12:02 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 10 Apr 2017 12:12:01 -0600
Date: Mon, 10 Apr 2017 13:11:56 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RFC HMM CDM 3/3] mm/migrate: memory migration using a device
 DMA engine
References: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
 <1491596933-21669-4-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1491596933-21669-4-git-send-email-jglisse@redhat.com>
Message-Id: <20170410181156.hxwfsqhodbhachpu@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Balbir Singh <balbir@au1.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>

(Had sent this to you directly. Reposting for the whole cc list.)

On Fri, Apr 07, 2017 at 04:28:53PM -0400, Jerome Glisse wrote:
>--- a/include/linux/migrate.h
>+++ b/include/linux/migrate.h 
>@@ -212,28 +215,25 @@ static inline unsigned long migrate_pfn(unsigned long pfn)
>  * THE finalize_and_map() CALLBACK MUST NOT CHANGE ANY OF THE SRC OR DST ARRAY
>  * ENTRIES OR BAD THINGS WILL HAPPEN !
>  */
>-struct migrate_vma_ops {
>-	void (*alloc_and_copy)(struct vm_area_struct *vma,
>-			       const unsigned long *src,
>-			       unsigned long *dst,
>-			       unsigned long start,
>-			       unsigned long end,
>-			       void *private);
>-	void (*finalize_and_map)(struct vm_area_struct *vma,
>-				 const unsigned long *src,
>-				 const unsigned long *dst,
>-				 unsigned long start,
>-				 unsigned long end,
>-				 void *private);
>+struct migrate_dma_ops {
>+	void (*alloc_and_copy)(struct migrate_dma_ctx *ctx);
>+	void (*finalize_and_map)(struct migrate_dma_ctx *ctx);
>+};
>+
>+struct migrate_dma_ctx {
>+	const struct migrate_dma_ops	*ops;
>+	unsigned long			*dst;
>+	unsigned long			*src;
>+	unsigned long			cpages;
>+	unsigned long			npages;

Could you add this so we can still pass arguments to the callbacks?

	void				*private;

> };
>
>-int migrate_vma(const struct migrate_vma_ops *ops,
>+int migrate_vma(struct migrate_dma_ctx *ctx,
> 		struct vm_area_struct *vma,
> 		unsigned long start,
>-		unsigned long end,
>-		unsigned long *src,
>-		unsigned long *dst,
>-		void *private);
>+		unsigned long end);
>+int migrate_dma(struct migrate_dma_ctx *migrate_ctx);
>+
>
> #endif /* CONFIG_MIGRATION */
>

...%<...

>--- a/mm/migrate.c
>+++ b/mm/migrate.c
>@@ -2803,16 +2761,76 @@ int migrate_vma(const struct migrate_vma_ops *ops,
> 	 * Note that migration can fail in migrate_vma_struct_page() for each
> 	 * individual page.
> 	 */
>-	ops->alloc_and_copy(vma, src, dst, start, end, private);
>+	migrate_ctx->ops->alloc_and_copy(migrate_ctx);
>
> 	/* This does the real migration of struct page */
>-	migrate_vma_pages(&migrate);
>+	migrate_dma_pages(migrate_ctx, vma, start, end);
>
>-	ops->finalize_and_map(vma, src, dst, start, end, private);
>+	migrate_ctx->ops->finalize_and_map(migrate_ctx);
>
> 	/* Unlock and remap pages */
>-	migrate_vma_finalize(&migrate);
>+	migrate_dma_finalize(migrate_ctx);
>
> 	return 0;
> }
> EXPORT_SYMBOL(migrate_vma);
>+
>+/*
>+ * migrate_dma() - migrate an array of pages using a device DMA engine
>+ *
>+ * @migrate_ctx: migrate context structure
>+ *
>+ * The context structure must have its src fields pointing to an array of
>+ * migrate pfn entry each corresponding to a valid page and each page being
>+ * lock. The dst entry must by an array as big as src, it will be use during
>+ * migration to store the destination pfn.
>+ *
>+ */
>+int migrate_dma(struct migrate_dma_ctx *migrate_ctx)
>+{
>+	unsigned long i;
>+
>+	/* Sanity check the arguments */
>+	if (!migrate_ctx->ops || !migrate_ctx->src || !migrate_ctx->dst)
>+		return -EINVAL;
>+
>+	/* Below code should be hidden behind some DEBUG config */
>+	for (i = 0; i < migrate_ctx->npages; ++i) {
>+		const unsigned long mask = MIGRATE_PFN_VALID |
>+					   MIGRATE_PFN_LOCKED;

This line is before the pages are locked. I think it should be

					   MIGRATE_PFN_MIGRATE;

>+
>+		if (!(migrate_ctx->src[i] & mask))
>+			return -EINVAL;
>+	}
>+
>+	/* Lock and isolate page */
>+	migrate_dma_prepare(migrate_ctx);
>+	if (!migrate_ctx->cpages)
>+		return 0;
>+
>+	/* Unmap pages */
>+	migrate_dma_unmap(migrate_ctx);
>+	if (!migrate_ctx->cpages)
>+		return 0;
>+
>+	/*
>+	 * At this point pages are locked and unmapped, and thus they have
>+	 * stable content and can safely be copied to destination memory that
>+	 * is allocated by the callback.
>+	 *
>+	 * Note that migration can fail in migrate_vma_struct_page() for each
>+	 * individual page.
>+	 */
>+	migrate_ctx->ops->alloc_and_copy(migrate_ctx);
>+
>+	/* This does the real migration of struct page */
>+	migrate_dma_pages(migrate_ctx, NULL, 0, 0);
>+
>+	migrate_ctx->ops->finalize_and_map(migrate_ctx);
>+
>+	/* Unlock and remap pages */
>+	migrate_dma_finalize(migrate_ctx);
>+
>+	return 0;
>+}
>+EXPORT_SYMBOL(migrate_dma);

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
