Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74B3A8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 20:31:58 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b8so24685811pfe.10
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 17:31:58 -0800 (PST)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v20sor5331060pgo.22.2018.12.28.17.31.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 17:31:57 -0800 (PST)
Date: Fri, 28 Dec 2018 17:31:47 -0800
Message-Id: <20181229013147.211079-1-shakeelb@google.com>
Mime-Version: 1.0
Subject: [PATCH] percpu: plumb gfp flag to pcpu_get_pages
From: Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Dennis Zhou <dennis@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

__alloc_percpu_gfp() can be called from atomic context, so, make
pcpu_get_pages use the gfp provided to the higher layer.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/percpu-vm.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index d8078de912de..4f42c4c5c902 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -21,6 +21,7 @@ static struct page *pcpu_chunk_page(struct pcpu_chunk *chunk,
 
 /**
  * pcpu_get_pages - get temp pages array
+ * @gfp: allocation flags passed to the underlying allocator
  *
  * Returns pointer to array of pointers to struct page which can be indexed
  * with pcpu_page_idx().  Note that there is only one array and accesses
@@ -29,7 +30,7 @@ static struct page *pcpu_chunk_page(struct pcpu_chunk *chunk,
  * RETURNS:
  * Pointer to temp pages array on success.
  */
-static struct page **pcpu_get_pages(void)
+static struct page **pcpu_get_pages(gfp_t gfp)
 {
 	static struct page **pages;
 	size_t pages_size = pcpu_nr_units * pcpu_unit_pages * sizeof(pages[0]);
@@ -37,7 +38,7 @@ static struct page **pcpu_get_pages(void)
 	lockdep_assert_held(&pcpu_alloc_mutex);
 
 	if (!pages)
-		pages = pcpu_mem_zalloc(pages_size, GFP_KERNEL);
+		pages = pcpu_mem_zalloc(pages_size, gfp);
 	return pages;
 }
 
@@ -278,7 +279,7 @@ static int pcpu_populate_chunk(struct pcpu_chunk *chunk,
 {
 	struct page **pages;
 
-	pages = pcpu_get_pages();
+	pages = pcpu_get_pages(gfp);
 	if (!pages)
 		return -ENOMEM;
 
@@ -316,7 +317,7 @@ static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk,
 	 * successful population attempt so the temp pages array must
 	 * be available now.
 	 */
-	pages = pcpu_get_pages();
+	pages = pcpu_get_pages(GFP_KERNEL);
 	BUG_ON(!pages);
 
 	/* unmap and free */
-- 
2.20.1.415.g653613c723-goog
