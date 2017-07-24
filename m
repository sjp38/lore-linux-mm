Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3ECDF6B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:02:41 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z48so24247925wrc.4
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:02:41 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k30si8475261wrd.103.2017.07.24.16.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:02:40 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 01/23] percpu: setup_first_chunk enforce dynamic region must exist
Date: Mon, 24 Jul 2017 19:01:58 -0400
Message-ID: <20170724230220.21774-2-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The first chunk is handled as a special case as it is composed of the
static, reserved, and dynamic regions. The code handles each case
individually. The next several patches will merge these code paths and
lay the foundation for the bitmap allocator.

This patch modifies logic to enforce that a dynamic region exists and
changes the area map to account for that. This brings the logic closer
to the dynamic chunk's init logic.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 29244fb..3602d41 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1598,6 +1598,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(offset_in_page(ai->unit_size));
 	PCPU_SETUP_BUG_ON(ai->unit_size < PCPU_MIN_UNIT_SIZE);
 	PCPU_SETUP_BUG_ON(ai->dyn_size < PERCPU_DYNAMIC_EARLY_SIZE);
+	PCPU_SETUP_BUG_ON(!ai->dyn_size);
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
 	/* process group information and build config tables accordingly */
@@ -1700,14 +1701,12 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		schunk->free_size = dyn_size;
 		dyn_size = 0;			/* dynamic area covered */
 	}
-	schunk->contig_hint = schunk->free_size;
 
+	schunk->contig_hint = schunk->free_size;
 	schunk->map[0] = 1;
 	schunk->map[1] = ai->static_size;
-	schunk->map_used = 1;
-	if (schunk->free_size)
-		schunk->map[++schunk->map_used] = ai->static_size + schunk->free_size;
-	schunk->map[schunk->map_used] |= 1;
+	schunk->map[2] = (ai->static_size + schunk->free_size) | 1;
+	schunk->map_used = 2;
 	schunk->has_reserved = true;
 
 	/* init dynamic chunk if necessary */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
