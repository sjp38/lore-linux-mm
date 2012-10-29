Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 120326B005A
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 10:02:09 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so2646595dad.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 07:02:08 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] percpu: change a method freeing a chunk for consistency.
Date: Mon, 29 Oct 2012 22:59:58 +0900
Message-Id: <1351519198-5075-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux.com>

commit 099a19d9('allow limited allocation before slab is online') changes a method
allocating a chunk from kzalloc to pcpu_mem_alloc.
But, it missed changing matched free operation.
It may not be a problem for now, but fix it for consistency.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux.com>

diff --git a/mm/percpu.c b/mm/percpu.c
index ddc5efb..ec25896 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -631,7 +631,7 @@ static void pcpu_free_chunk(struct pcpu_chunk *chunk)
 	if (!chunk)
 		return;
 	pcpu_mem_free(chunk->map, chunk->map_alloc * sizeof(chunk->map[0]));
-	kfree(chunk);
+	pcpu_mem_free(chunk, pcpu_chunk_struct_size);
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
