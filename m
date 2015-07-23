Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9B89003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 21:50:24 -0400 (EDT)
Received: by qged69 with SMTP id d69so82334511qge.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 18:50:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q78si3915456qha.77.2015.07.22.18.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 18:50:23 -0700 (PDT)
Date: Thu, 23 Jul 2015 09:50:16 +0800
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v2 3/3] percpu: add macro PCPU_MAP_BUSY
Message-ID: <20150723015016.GA1844@dhcp-17-102.nay.redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
 <1437404130-5188-3-git-send-email-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437404130-5188-3-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

chunk->map[] contains <offset|in-use flag> of each area. Now add a
new macro PCPU_MAP_BUSY and use it as the in-use flag to replace all
magic number '1'.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/percpu.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index a63b4d8..8cf18dc 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -81,6 +81,15 @@
 #define PCPU_EMPTY_POP_PAGES_LOW	2
 #define PCPU_EMPTY_POP_PAGES_HIGH	4
 
+/* we use int array chunk->map[] to describe each area of chunk. Each array
+ * element is represented by one int - contains offset|1 for <offset, in use>
+ * or offset for <ofset, free> (offset need be guaranteed to be even). In the
+ * end there's a sentry entry - <total size, in-use>. So the size of the N-th
+ * area would be the offset of (N+1)-th - the offset of N-th, namely
+ * SIZEn = chunk->map[N+1]&~1 - chunk->map[N]&~1
+ * For more read-able code define PCPU_MAP_BUSY to represent in-use flag.*/
+#define PCPU_MAP_BUSY			1
+
 #ifdef CONFIG_SMP
 /* default addr <-> pcpu_ptr mapping, override in asm/percpu.h if necessary */
 #ifndef __addr_to_pcpu_ptr
@@ -328,8 +337,8 @@ static void pcpu_mem_free(void *ptr, size_t size)
  */
 static int pcpu_count_occupied_pages(struct pcpu_chunk *chunk, int i)
 {
-	int off = chunk->map[i] & ~1;
-	int end = chunk->map[i + 1] & ~1;
+	int off = chunk->map[i] & ~PCPU_MAP_BUSY;
+	int end = chunk->map[i + 1] & ~PCPU_MAP_BUSY;
 
 	if (!PAGE_ALIGNED(off) && i > 0) {
 		int prev = chunk->map[i - 1];
@@ -340,7 +349,7 @@ static int pcpu_count_occupied_pages(struct pcpu_chunk *chunk, int i)
 
 	if (!PAGE_ALIGNED(end) && i + 1 < chunk->map_used) {
 		int next = chunk->map[i + 1];
-		int nend = chunk->map[i + 2] & ~1;
+		int nend = chunk->map[i + 2] & ~PCPU_MAP_BUSY;
 
 		if (!(next & 1) && nend >= round_up(end, PAGE_SIZE))
 			end = round_up(end, PAGE_SIZE);
@@ -738,7 +747,7 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 
 	chunk->map_alloc = PCPU_DFL_MAP_ALLOC;
 	chunk->map[0] = 0;
-	chunk->map[1] = pcpu_unit_size | 1;
+	chunk->map[1] = pcpu_unit_size | PCPU_MAP_BUSY;
 	chunk->map_used = 1;
 
 	INIT_LIST_HEAD(&chunk->list);
@@ -1664,12 +1673,12 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	}
 	schunk->contig_hint = schunk->free_size;
 
-	schunk->map[0] = 1;
+	schunk->map[0] = PCPU_MAP_BUSY;
 	schunk->map[1] = ai->static_size;
 	schunk->map_used = 1;
 	if (schunk->free_size)
 		schunk->map[++schunk->map_used] = ai->static_size + schunk->free_size;
-	schunk->map[schunk->map_used] |= 1;
+	schunk->map[schunk->map_used] |= PCPU_MAP_BUSY;
 
 	/* init dynamic chunk if necessary */
 	if (dyn_size) {
@@ -1684,9 +1693,10 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		dchunk->nr_populated = pcpu_unit_pages;
 
 		dchunk->contig_hint = dchunk->free_size = dyn_size;
-		dchunk->map[0] = 1;
+		dchunk->map[0] = PCPU_MAP_BUSY;
 		dchunk->map[1] = pcpu_reserved_chunk_limit;
-		dchunk->map[2] = (pcpu_reserved_chunk_limit + dchunk->free_size) | 1;
+		dchunk->map[2] = (pcpu_reserved_chunk_limit + dchunk->free_size)
+					| PCPU_MAP_BUSY;
 		dchunk->map_used = 2;
 	}
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
