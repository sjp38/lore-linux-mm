Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id ED2236B00D2
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 01:48:08 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so7700901pdj.9
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 22:48:07 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id pb4si8181306pac.31.2014.04.13.22.48.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 13 Apr 2014 22:48:06 -0700 (PDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so7789459pab.41
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 22:48:05 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] percpu: make pcpu_alloc_chunk() use pcpu_mem_free() instead of kfree()
Date: Mon, 14 Apr 2014 13:47:40 +0800
Message-Id: <1397454460-19694-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, cl@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

pcpu_chunk_struct_size = sizeof(struct pcpu_chunk) +
	BITS_TO_LONGS(pcpu_unit_pages) * sizeof(unsigned long)

It hardly could be ever bigger than PAGE_SIZE even for large-scale machine,
but for consistency with its couterpart pcpu_mem_zalloc(),
use pcpu_mem_free() instead.

Commit b4916cb17c261a6043bcb2a98d0d6512497a7cf8 addressed this
problem, but missed this one.

Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/percpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 63e24fb..2ddf9a9 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -610,7 +610,7 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 	chunk->map = pcpu_mem_zalloc(PCPU_DFL_MAP_ALLOC *
 						sizeof(chunk->map[0]));
 	if (!chunk->map) {
-		kfree(chunk);
+		pcpu_mem_free(chunk, pcpu_chunk_struct_size);
 		return NULL;
 	}
 
-- 
1.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
