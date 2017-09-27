Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5E96B025F
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 17:35:14 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m103so19916879iod.6
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 14:35:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v186sor142180itc.145.2017.09.27.14.35.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 14:35:13 -0700 (PDT)
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: [PATCH 2/2] percpu: fix iteration to prevent skipping over block
Date: Wed, 27 Sep 2017 16:35:00 -0500
Message-Id: <1506548100-31247-3-git-send-email-dennisszhou@gmail.com>
In-Reply-To: <1506548100-31247-1-git-send-email-dennisszhou@gmail.com>
References: <1506548100-31247-1-git-send-email-dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Luis Henriques <lhenriques@suse.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dennis Zhou <dennisszhou@gmail.com>

The iterator functions pcpu_next_md_free_region and
pcpu_next_fit_region use the block offset to determine if they have
checked the area in the prior iteration. However, this causes an issue
when the block offset is greater than subsequent block contig hints. If
within the iterator it moves to check subsequent blocks, it may fail in
the second predicate due to the block offset not being cleared. Thus,
this causes the allocator to skip over blocks leading to false failures
when allocating from the reserved chunk. While this happens in the
general case as well, it will only fail if it cannot allocate a new
chunk.

This patch resets the block offset to 0 to pass the second predicate
when checking subseqent blocks within the iterator function.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
Reported-by: Luis Henriques <lhenriques@suse.com>
---
 mm/percpu.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/percpu.c b/mm/percpu.c
index 59d44d6..aa121ce 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -353,6 +353,8 @@ static void pcpu_next_md_free_region(struct pcpu_chunk *chunk, int *bit_off,
 					block->contig_hint_start);
 			return;
 		}
+		/* reset to satisfy the second predicate above */
+		block_off = 0;
 
 		*bits = block->right_free;
 		*bit_off = (i + 1) * PCPU_BITMAP_BLOCK_BITS - block->right_free;
@@ -407,6 +409,8 @@ static void pcpu_next_fit_region(struct pcpu_chunk *chunk, int alloc_bits,
 			*bit_off = pcpu_block_off_to_off(i, block->first_free);
 			return;
 		}
+		/* reset to satisfy the second predicate above */
+		block_off = 0;
 
 		*bit_off = ALIGN(PCPU_BITMAP_BLOCK_BITS - block->right_free,
 				 align);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
