Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D85566B0387
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p43so21719834wrb.6
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:49 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z37si14766006wrb.382.2017.07.24.16.02.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:48 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 09/23] percpu: combine percpu address checks
Date: Mon, 24 Jul 2017 19:02:06 -0400
Message-ID: <20170724230220.21774-10-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The percpu address checks for the reserved and dynamic region chunks are
now specific to each region. The address checking logic can be combined
taking advantage of the global references to the dynamic and static
region chunks.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 51 +++++++++++----------------------------------------
 1 file changed, 11 insertions(+), 40 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 7c9f0d3..5b1fcef 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -182,52 +182,23 @@ static void pcpu_schedule_balance_work(void)
 }
 
 /**
- * pcpu_addr_in_first_chunk - address check for first chunk's dynamic region
- * @addr: percpu address of interest
- *
- * The first chunk is considered to be the dynamic region of the first chunk.
- * While the true first chunk is composed of the static, dynamic, and
- * reserved regions, it is the chunk that serves the dynamic region that is
- * circulated in the chunk slots.
- *
- * The reserved chunk has a separate check and the static region addresses
- * should never be passed into the percpu allocator.
- *
- * RETURNS:
- * True if the address is in the dynamic region of the first chunk.
- */
-static bool pcpu_addr_in_first_chunk(void *addr)
-{
-	void *start_addr = pcpu_first_chunk->base_addr +
-			   pcpu_first_chunk->start_offset;
-	void *end_addr = pcpu_first_chunk->base_addr +
-			 pcpu_first_chunk->nr_pages * PAGE_SIZE -
-			 pcpu_first_chunk->end_offset;
-
-	return addr >= start_addr && addr < end_addr;
-}
-
-/**
- * pcpu_addr_in_reserved_chunk - address check for reserved region
- *
- * The reserved region is a part of the first chunk and primarily serves
- * static percpu variables from kernel modules.
+ * pcpu_addr_in_chunk - check if the address is served from this chunk
+ * @chunk: chunk of interest
+ * @addr: percpu address
  *
  * RETURNS:
- * True if the address is in the reserved region.
+ * True if the address is served from this chunk.
  */
-static bool pcpu_addr_in_reserved_chunk(void *addr)
+static bool pcpu_addr_in_chunk(struct pcpu_chunk *chunk, void *addr)
 {
 	void *start_addr, *end_addr;
 
-	if (!pcpu_reserved_chunk)
+	if (!chunk)
 		return false;
 
-	start_addr = pcpu_reserved_chunk->base_addr +
-		     pcpu_reserved_chunk->start_offset;
-	end_addr = pcpu_reserved_chunk->base_addr +
-		   pcpu_reserved_chunk->nr_pages * PAGE_SIZE -
-		   pcpu_reserved_chunk->end_offset;
+	start_addr = chunk->base_addr + chunk->start_offset;
+	end_addr = chunk->base_addr + chunk->nr_pages * PAGE_SIZE -
+		   chunk->end_offset;
 
 	return addr >= start_addr && addr < end_addr;
 }
@@ -929,11 +900,11 @@ static int __init pcpu_verify_alloc_info(const struct pcpu_alloc_info *ai);
 static struct pcpu_chunk *pcpu_chunk_addr_search(void *addr)
 {
 	/* is it in the dynamic region (first chunk)? */
-	if (pcpu_addr_in_first_chunk(addr))
+	if (pcpu_addr_in_chunk(pcpu_first_chunk, addr))
 		return pcpu_first_chunk;
 
 	/* is it in the reserved region? */
-	if (pcpu_addr_in_reserved_chunk(addr))
+	if (pcpu_addr_in_chunk(pcpu_reserved_chunk, addr))
 		return pcpu_reserved_chunk;
 
 	/*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
