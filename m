Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 453B46B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 07:06:06 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so3282051pab.26
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 04:06:05 -0700 (PDT)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id j4si1273138pad.63.2014.03.27.04.06.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 04:06:05 -0700 (PDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so3330363pbb.33
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 04:06:05 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 1/2] mm/percpu.c: renew the max_contig if we merge the head and previous block.
Date: Thu, 27 Mar 2014 19:05:43 +0800
Message-Id: <1395918343-6775-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, tj@kernel.org, cl@linux-foundation.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

During pcpu_alloc_area(), we might merge the current head with the
previous block. Since we have calculated the max_contig using the
size of previous block before we skip it, and now we update the size
of previous block, so we should renew the max_contig.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/percpu.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 036cfe0..cfda29c 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -506,9 +506,11 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int size, int align)
 		 * uncommon for percpu allocations.
 		 */
 		if (head && (head < sizeof(int) || chunk->map[i - 1] > 0)) {
-			if (chunk->map[i - 1] > 0)
+			if (chunk->map[i - 1] > 0) {
 				chunk->map[i - 1] += head;
-			else {
+				max_contig =
+					max(chunk->map[i - 1], max_contig);
+			} else {
 				chunk->map[i - 1] -= head;
 				chunk->free_size -= head;
 			}
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
