Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id A6D026B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 17:43:22 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id x19so9950714ier.8
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:43:22 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id y13si13742857icn.100.2014.09.23.14.43.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 14:43:22 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id tp5so5063461ieb.27
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:43:21 -0700 (PDT)
Date: Tue, 23 Sep 2014 14:43:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, slab: initialize object alignment on cache creation
In-Reply-To: <20140923141940.e2d3840f31d0f8850b925cf6@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1409231439190.22630@chino.kir.corp.google.com>
References: <20140923141940.e2d3840f31d0f8850b925cf6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, a.elovikov@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since 4590685546a3 ("mm/sl[aou]b: Common alignment code"), the "ralign" 
automatic variable in __kmem_cache_create() may be used as uninitialized.

The proper alignment defaults to BYTES_PER_WORD and can be overridden by 
SLAB_RED_ZONE or the alignment specified by the caller.

This fixes https://bugzilla.kernel.org/show_bug.cgi?id=85031

Reported-by: Andrei Elovikov <a.elovikov@gmail.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 a.elovikov: If you respond to this email with your full name, Andrew can 
 give proper credit for reporting this issue.

 mm/slab.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2128,7 +2128,8 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 int
 __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 {
-	size_t left_over, freelist_size, ralign;
+	size_t left_over, freelist_size;
+	size_t ralign = BYTES_PER_WORD;
 	gfp_t gfp;
 	int err;
 	size_t size = cachep->size;
@@ -2161,14 +2162,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		size &= ~(BYTES_PER_WORD - 1);
 	}
 
-	/*
-	 * Redzoning and user store require word alignment or possibly larger.
-	 * Note this will be overridden by architecture or caller mandated
-	 * alignment if either is greater than BYTES_PER_WORD.
-	 */
-	if (flags & SLAB_STORE_USER)
-		ralign = BYTES_PER_WORD;
-
 	if (flags & SLAB_RED_ZONE) {
 		ralign = REDZONE_ALIGN;
 		/* If redzoning, ensure that the second redzone is suitably

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
