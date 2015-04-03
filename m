Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7F76B0038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 17:58:33 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so46980195pab.0
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 14:58:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rp11si3333037pab.94.2015.04.03.14.58.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Apr 2015 14:58:30 -0700 (PDT)
Date: Fri, 3 Apr 2015 14:58:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cma: add functions to get region pages counters
Message-Id: <20150403145828.90a597f5dc1c308d7c31a37d@linux-foundation.org>
In-Reply-To: <1428064960-8279-1-git-send-email-stefan.strogin@gmail.com>
References: <1428064960-8279-1-git-send-email-stefan.strogin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <stefan.strogin@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Safonov <d.safonov@partner.samsung.com>, Stefan Strogin <s.strogin@partner.samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Pintu Kumar <pintu.k@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, Weijie Yang <weijie.yang@samsung.com>, Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>, Michal Hocko <mhocko@suse.cz>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>

On Fri, 03 Apr 2015 15:42:40 +0300 Stefan Strogin <stefan.strogin@gmail.com> wrote:

> From: Dmitry Safonov <d.safonov@partner.samsung.com>
> 
> Here are two functions that provide interface to compute/get used size
> and size of biggest free chunk in cma region. Add that information to debugfs.
> 
> ...
>
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -53,6 +53,36 @@ unsigned long cma_get_size(const struct cma *cma)
>  	return cma->count << PAGE_SHIFT;
>  }
>  
> +unsigned long cma_get_used(struct cma *cma)
> +{
> +	unsigned long ret = 0;
> +
> +	mutex_lock(&cma->lock);
> +	/* pages counter is smaller than sizeof(int) */
> +	ret = bitmap_weight(cma->bitmap, (int)cma->count);
> +	mutex_unlock(&cma->lock);
> +
> +	return ret << cma->order_per_bit;
> +}
> +
> +unsigned long cma_get_maxchunk(struct cma *cma)
> +{
> +	unsigned long maxchunk = 0;
> +	unsigned long start, end = 0;
> +
> +	mutex_lock(&cma->lock);
> +	for (;;) {
> +		start = find_next_zero_bit(cma->bitmap, cma->count, end);
> +		if (start >= cma->count)
> +			break;
> +		end = find_next_bit(cma->bitmap, cma->count, start);
> +		maxchunk = max(end - start, maxchunk);
> +	}
> +	mutex_unlock(&cma->lock);
> +
> +	return maxchunk << cma->order_per_bit;
> +}

This will cause unused code to be included in cma.o when
CONFIG_CMA_DEBUGFS=n.  Please review the below patch which moves it all
into cma_debug.c

> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -33,6 +33,28 @@ static int cma_debugfs_get(void *data, u64 *val)
>  
>  DEFINE_SIMPLE_ATTRIBUTE(cma_debugfs_fops, cma_debugfs_get, NULL, "%llu\n");
>  
> +static int cma_used_get(void *data, u64 *val)
> +{
> +	struct cma *cma = data;
> +
> +	*val = cma_get_used(cma);
> +
> +	return 0;
> +}

We have cma_used_get() and cma_get_used().  Confusing!  Can we think of
better names for one or both of them?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-cma-add-functions-to-get-region-pages-counters-fix

move debug code from cma.c into cma_debug.c so it doesn't get included in
CONFIG_CMA_DEBUGFS=n builds

Cc: Dmitry Safonov <d.safonov@partner.samsung.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Stefan Strogin <stefan.strogin@gmail.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pintu Kumar <pintu.k@samsung.com>
Cc: Weijie Yang <weijie.yang@samsung.com>
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
Cc: Vyacheslav Tyrtov <v.tyrtov@samsung.com>
Cc: Aleksei Mateosian <a.mateosian@samsung.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/cma.h |    2 --
 mm/cma.c            |   30 ------------------------------
 mm/cma_debug.c      |   31 +++++++++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 32 deletions(-)

diff -puN include/linux/cma.h~mm-cma-add-functions-to-get-region-pages-counters-fix include/linux/cma.h
--- a/include/linux/cma.h~mm-cma-add-functions-to-get-region-pages-counters-fix
+++ a/include/linux/cma.h
@@ -18,8 +18,6 @@ struct cma;
 extern unsigned long totalcma_pages;
 extern phys_addr_t cma_get_base(const struct cma *cma);
 extern unsigned long cma_get_size(const struct cma *cma);
-extern unsigned long cma_get_used(struct cma *cma);
-extern unsigned long cma_get_maxchunk(struct cma *cma);
 
 extern int __init cma_declare_contiguous(phys_addr_t base,
 			phys_addr_t size, phys_addr_t limit,
diff -puN mm/cma.c~mm-cma-add-functions-to-get-region-pages-counters-fix mm/cma.c
--- a/mm/cma.c~mm-cma-add-functions-to-get-region-pages-counters-fix
+++ a/mm/cma.c
@@ -53,36 +53,6 @@ unsigned long cma_get_size(const struct
 	return cma->count << PAGE_SHIFT;
 }
 
-unsigned long cma_get_used(struct cma *cma)
-{
-	unsigned long ret = 0;
-
-	mutex_lock(&cma->lock);
-	/* pages counter is smaller than sizeof(int) */
-	ret = bitmap_weight(cma->bitmap, (int)cma->count);
-	mutex_unlock(&cma->lock);
-
-	return ret << cma->order_per_bit;
-}
-
-unsigned long cma_get_maxchunk(struct cma *cma)
-{
-	unsigned long maxchunk = 0;
-	unsigned long start, end = 0;
-
-	mutex_lock(&cma->lock);
-	for (;;) {
-		start = find_next_zero_bit(cma->bitmap, cma->count, end);
-		if (start >= cma->count)
-			break;
-		end = find_next_bit(cma->bitmap, cma->count, start);
-		maxchunk = max(end - start, maxchunk);
-	}
-	mutex_unlock(&cma->lock);
-
-	return maxchunk << cma->order_per_bit;
-}
-
 static unsigned long cma_bitmap_aligned_mask(const struct cma *cma,
 					     int align_order)
 {
diff -puN mm/cma_debug.c~mm-cma-add-functions-to-get-region-pages-counters-fix mm/cma_debug.c
--- a/mm/cma_debug.c~mm-cma-add-functions-to-get-region-pages-counters-fix
+++ a/mm/cma_debug.c
@@ -22,6 +22,37 @@ struct cma_mem {
 
 static struct dentry *cma_debugfs_root;
 
+static unsigned long cma_get_used(struct cma *cma)
+{
+	unsigned long ret = 0;
+
+	mutex_lock(&cma->lock);
+	/* pages counter is smaller than sizeof(int) */
+	ret = bitmap_weight(cma->bitmap, (int)cma->count);
+	mutex_unlock(&cma->lock);
+
+	return ret << cma->order_per_bit;
+}
+
+static unsigned long cma_get_maxchunk(struct cma *cma)
+{
+	unsigned long maxchunk = 0;
+	unsigned long start, end = 0;
+
+	mutex_lock(&cma->lock);
+	for (;;) {
+		start = find_next_zero_bit(cma->bitmap, cma->count, end);
+		if (start >= cma->count)
+			break;
+		end = find_next_bit(cma->bitmap, cma->count, start);
+		maxchunk = max(end - start, maxchunk);
+	}
+	mutex_unlock(&cma->lock);
+
+	return maxchunk << cma->order_per_bit;
+}
+
+
 static int cma_debugfs_get(void *data, u64 *val)
 {
 	unsigned long *p = data;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
