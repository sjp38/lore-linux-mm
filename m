Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 496FD28024F
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 10:55:42 -0400 (EDT)
Received: by qgeu79 with SMTP id u79so17866712qge.1
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 07:55:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g13si24451779qhc.50.2015.07.20.07.55.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jul 2015 07:55:41 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH 2/3] perpuc: check pcpu_first_chunk and pcpu_reserved_chunk to avoid handling them twice
Date: Mon, 20 Jul 2015 22:55:29 +0800
Message-Id: <1437404130-5188-2-git-send-email-bhe@redhat.com>
In-Reply-To: <1437404130-5188-1-git-send-email-bhe@redhat.com>
References: <1437404130-5188-1-git-send-email-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Baoquan He <bhe@redhat.com>

In pcpu_setup_first_chunk() pcpu_reserved_chunk is assigned to point to
static chunk. While pcpu_first_chunk is got from below code:

	pcpu_first_chunk = dchunk ?: schunk;

Then it could point to static chunk too if dynamic chunk doesn't exist. So
in this patch adding a check in percpu_init_late() to see if pcpu_first_chunk
is equal to pcpu_reserved_chunk. Only if they are not equal we add
pcpu_reserved_chunk to the target array.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/percpu.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index a63b4d8..f7e02c0 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2260,11 +2260,18 @@ void __init setup_per_cpu_areas(void)
 void __init percpu_init_late(void)
 {
 	struct pcpu_chunk *target_chunks[] =
-		{ pcpu_first_chunk, pcpu_reserved_chunk, NULL };
+		{ pcpu_first_chunk, NULL, NULL };
 	struct pcpu_chunk *chunk;
 	unsigned long flags;
 	int i;
 
+	/*
+	 * pcpu_first_chunk could be the same as pcpu_reserved_chunk, add it to the
+	 * target array only if pcpu_first_chunk is not equal to pcpu_reserved_chunk.
+	 */
+	if (pcpu_first_chunk != pcpu_reserved_chunk)
+		target_chunks[1] = pcpu_reserved_chunk;
+
 	for (i = 0; (chunk = target_chunks[i]); i++) {
 		int *map;
 		const size_t size = PERCPU_DYNAMIC_EARLY_SLOTS * sizeof(map[0]);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
