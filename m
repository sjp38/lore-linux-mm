Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 951DD6B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:55:31 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so4984646pbc.20
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 05:55:31 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id m9si3651752pab.3.2014.03.28.05.55.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 05:55:30 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so4967770pbb.12
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 05:55:30 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH 1/2] mm/percpu.c: renew the max_contig if we merge the head and previous block
Date: Fri, 28 Mar 2014 20:55:21 +0800
Message-Id: <1396011321-19759-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, tj@kernel.org, cl@linux-foundation.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

Hi, tj,
I've reworked the patches on top of percpu/for-3.15.

During pcpu_alloc_area(), we might merge the current head with the
previous block. Since we have calculated the max_contig using the
size of previous block before we skip it, and now we update the size
of previous block, so we should renew the max_contig.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/percpu.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 202e104..63e24fb 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -473,9 +473,11 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int size, int align)
 		 * uncommon for percpu allocations.
 		 */
 		if (head && (head < sizeof(int) || !(p[-1] & 1))) {
+			*p = off += head;
 			if (p[-1] & 1)
 				chunk->free_size -= head;
-			*p = off += head;
+			else
+				max_contig = max(*p - p[-1], max_contig);
 			this_size -= head;
 			head = 0;
 		}
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
