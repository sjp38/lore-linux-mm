Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 50E8F6B0038
	for <linux-mm@kvack.org>; Sat, 25 Feb 2017 16:00:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f21so103637509pgi.4
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 13:00:13 -0800 (PST)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id m1si10969336pld.241.2017.02.25.13.00.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Feb 2017 13:00:12 -0800 (PST)
Received: by mail-pf0-x22c.google.com with SMTP id j5so1448714pfb.2
        for <linux-mm@kvack.org>; Sat, 25 Feb 2017 13:00:12 -0800 (PST)
From: Tahsin Erdogan <tahsin@google.com>
Subject: [PATCH 1/3] percpu: remove unused chunk_alloc parameter from pcpu_get_pages()
Date: Sat, 25 Feb 2017 12:59:26 -0800
Message-Id: <20170225205926.23431-1-tahsin@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Wilson <chris@chris-wilson.co.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Roman Pen <r.peniaev@gmail.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tahsin Erdogan <tahsin@google.com>

pcpu_get_pages() doesn't use chunk_alloc parameter, remove it.

Fixes: fbbb7f4e149f ("percpu: remove the usage of separate populated bitmap in percpu-vm")
Signed-off-by: Tahsin Erdogan <tahsin@google.com>
---
 mm/percpu-vm.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index 538998a137d2..9ac639499bd1 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -21,7 +21,6 @@ static struct page *pcpu_chunk_page(struct pcpu_chunk *chunk,
 
 /**
  * pcpu_get_pages - get temp pages array
- * @chunk: chunk of interest
  *
  * Returns pointer to array of pointers to struct page which can be indexed
  * with pcpu_page_idx().  Note that there is only one array and accesses
@@ -30,7 +29,7 @@ static struct page *pcpu_chunk_page(struct pcpu_chunk *chunk,
  * RETURNS:
  * Pointer to temp pages array on success.
  */
-static struct page **pcpu_get_pages(struct pcpu_chunk *chunk_alloc)
+static struct page **pcpu_get_pages(void)
 {
 	static struct page **pages;
 	size_t pages_size = pcpu_nr_units * pcpu_unit_pages * sizeof(pages[0]);
@@ -275,7 +274,7 @@ static int pcpu_populate_chunk(struct pcpu_chunk *chunk,
 {
 	struct page **pages;
 
-	pages = pcpu_get_pages(chunk);
+	pages = pcpu_get_pages();
 	if (!pages)
 		return -ENOMEM;
 
@@ -313,7 +312,7 @@ static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk,
 	 * successful population attempt so the temp pages array must
 	 * be available now.
 	 */
-	pages = pcpu_get_pages(chunk);
+	pages = pcpu_get_pages();
 	BUG_ON(!pages);
 
 	/* unmap and free */
-- 
2.11.0.483.g087da7b7c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
