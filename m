Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91ECD6B025E
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 17:35:13 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g18so17060353itg.1
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 14:35:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s5sor118761its.144.2017.09.27.14.35.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 14:35:12 -0700 (PDT)
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: [PATCH 1/2] percpu: fix starting offset for chunk statistics traversal
Date: Wed, 27 Sep 2017 16:34:59 -0500
Message-Id: <1506548100-31247-2-git-send-email-dennisszhou@gmail.com>
In-Reply-To: <1506548100-31247-1-git-send-email-dennisszhou@gmail.com>
References: <1506548100-31247-1-git-send-email-dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Luis Henriques <lhenriques@suse.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dennis Zhou <dennisszhou@gmail.com>

This patch fixes the starting offset used when scanning chunks to
compute the chunk statistics. The value start_offset (and end_offset)
are managed in bytes while the traversal occurs over bits. Thus for the
reserved and dynamic chunk, it may incorrectly skip over the initial
allocations.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu-stats.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
index 6142484..7a58460 100644
--- a/mm/percpu-stats.c
+++ b/mm/percpu-stats.c
@@ -73,7 +73,7 @@ static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
 		     last_alloc + 1 : 0;
 
 	as_len = 0;
-	start = chunk->start_offset;
+	start = chunk->start_offset / PCPU_MIN_ALLOC_SIZE;
 
 	/*
 	 * If a bit is set in the allocation map, the bound_map identifies
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
