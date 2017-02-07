Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1BFEE6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 09:07:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so25373130wmv.5
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 06:07:36 -0800 (PST)
Received: from mail-wr0-x22d.google.com (mail-wr0-x22d.google.com. [2a00:1450:400c:c0c::22d])
        by mx.google.com with ESMTPS id 196si12292336wmw.120.2017.02.07.06.07.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 06:07:35 -0800 (PST)
Received: by mail-wr0-x22d.google.com with SMTP id i10so39958251wrb.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 06:07:34 -0800 (PST)
From: Sean Rees <sean@erifax.org>
Subject: [PATCH] mm/slub: Fix random_seq offset destruction
Date: Tue,  7 Feb 2017 14:07:07 +0000
Message-Id: <20170207140707.20824-1-sean@erifax.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, thgarnie@google.com, Sean Rees <sean@erifax.org>

Bailout early from init_cache_random_seq if s->random_seq is already
initialised. This prevents destroying the previously computed random_seq
offsets later in the function.

If the offsets are destroyed, then shuffle_freelist will truncate
page->freelist to just the first object (orphaning the rest).

This fixes https://bugzilla.kernel.org/show_bug.cgi?id=177551.

Signed-off-by: Sean Rees <sean@erifax.org>
---
 mm/slub.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 7aa6f43..7ec0a96 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1422,6 +1422,10 @@ static int init_cache_random_seq(struct kmem_cache *s)
 	int err;
 	unsigned long i, count = oo_objects(s->oo);
 
+	/* Bailout if already initialised */
+	if (s->random_seq)
+		return 0;
+
 	err = cache_random_seq_create(s, count, GFP_KERNEL);
 	if (err) {
 		pr_err("SLUB: Unable to initialize free list for %s\n",
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
