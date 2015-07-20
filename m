Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id B0B9E28024F
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:55:44 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so17867323qge.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:55:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f79si15411590qki.10.2015.07.20.07.55.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 07:55:44 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH 3/3] percpu: add macro PCPU_CHUNK_AREA_IN_USE
Date: Mon, 20 Jul 2015 22:55:30 +0800
Message-Id: <1437404130-5188-3-git-send-email-bhe@redhat.com>
In-Reply-To: <1437404130-5188-1-git-send-email-bhe@redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Baoquan He <bhe@redhat.com>

chunk->map[] contains <offset|in-use flag> of each area. Now add a
new macro PCPU_CHUNK_AREA_IN_USE and use it as the in-use flag to
replace all magic number '1'.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/percpu.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index f7e02c0..2f99073 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -80,6 +80,7 @@
 #define PCPU_ATOMIC_MAP_MARGIN_HIGH	64
 #define PCPU_EMPTY_POP_PAGES_LOW	2
 #define PCPU_EMPTY_POP_PAGES_HIGH	4
+#define PCPU_CHUNK_AREA_IN_USE		1
 
 #ifdef CONFIG_SMP
 /* default addr <-> pcpu_ptr mapping, override in asm/percpu.h if necessary */
@@ -328,8 +329,8 @@ static void pcpu_mem_free(void *ptr, size_t size)
  */
 static int pcpu_count_occupied_pages(struct pcpu_chunk *chunk, int i)
 {
-	int off = chunk->map[i] & ~1;
-	int end = chunk->map[i + 1] & ~1;
+	int off = chunk->map[i] & ~PCPU_CHUNK_AREA_IN_USE;
+	int end = chunk->map[i + 1] & ~PCPU_CHUNK_AREA_IN_USE;
 
 	if (!PAGE_ALIGNED(off) && i > 0) {
 		int prev = chunk->map[i - 1];
@@ -340,7 +341,7 @@ static int pcpu_count_occupied_pages(struct pcpu_chunk *chunk, int i)
 
 	if (!PAGE_ALIGNED(end) && i + 1 < chunk->map_used) {
 		int next = chunk->map[i + 1];
-		int nend = chunk->map[i + 2] & ~1;
+		int nend = chunk->map[i + 2] & ~PCPU_CHUNK_AREA_IN_USE;
 
 		if (!(next & 1) && nend >= round_up(end, PAGE_SIZE))
 			end = round_up(end, PAGE_SIZE);
@@ -738,7 +739,7 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 
 	chunk->map_alloc = PCPU_DFL_MAP_ALLOC;
 	chunk->map[0] = 0;
-	chunk->map[1] = pcpu_unit_size | 1;
+	chunk->map[1] = pcpu_unit_size | PCPU_CHUNK_AREA_IN_USE;
 	chunk->map_used = 1;
 
 	INIT_LIST_HEAD(&chunk->list);
@@ -1664,12 +1665,12 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	}
 	schunk->contig_hint = schunk->free_size;
 
-	schunk->map[0] = 1;
+	schunk->map[0] = PCPU_CHUNK_AREA_IN_USE;
 	schunk->map[1] = ai->static_size;
 	schunk->map_used = 1;
 	if (schunk->free_size)
 		schunk->map[++schunk->map_used] = ai->static_size + schunk->free_size;
-	schunk->map[schunk->map_used] |= 1;
+	schunk->map[schunk->map_used] |= PCPU_CHUNK_AREA_IN_USE;
 
 	/* init dynamic chunk if necessary */
 	if (dyn_size) {
@@ -1684,9 +1685,10 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		dchunk->nr_populated = pcpu_unit_pages;
 
 		dchunk->contig_hint = dchunk->free_size = dyn_size;
-		dchunk->map[0] = 1;
+		dchunk->map[0] = PCPU_CHUNK_AREA_IN_USE;
 		dchunk->map[1] = pcpu_reserved_chunk_limit;
-		dchunk->map[2] = (pcpu_reserved_chunk_limit + dchunk->free_size) | 1;
+		dchunk->map[2] = (pcpu_reserved_chunk_limit + dchunk->free_size)
+					| PCPU_CHUNK_AREA_IN_USE;
 		dchunk->map_used = 2;
 	}
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
