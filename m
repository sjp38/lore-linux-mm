Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84ECB6B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 15:16:19 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id xm6so74413186pab.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:16:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rx5si6726418pab.151.2016.04.27.12.16.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 12:16:18 -0700 (PDT)
Date: Wed, 27 Apr 2016 12:16:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5] mm: SLAB freelist randomization
Message-Id: <20160427121617.5a3123d75230effd7842e408@linux-foundation.org>
In-Reply-To: <1461777659-81290-1-git-send-email-thgarnie@google.com>
References: <1461777659-81290-1-git-send-email-thgarnie@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Kees Cook <keescook@chromium.org>, gthelen@google.com, labbott@fedoraproject.org, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Apr 2016 10:20:59 -0700 Thomas Garnier <thgarnie@google.com> wrote:

> Provides an optional config (CONFIG_SLAB_FREELIST_RANDOM) to randomize
> the SLAB freelist.

Forgot this bit?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-slab-freelist-randomization-v5-fix

propagate gfp_t into cache_random_seq_create()

Cc: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@fedoraproject.org>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: Thomas Garnier <thgarnie@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

--- a/mm/slab.c~mm-slab-freelist-randomization-v5-fix
+++ a/mm/slab.c
@@ -1262,7 +1262,7 @@ static void freelist_randomize(struct rn
 }
 
 /* Create a random sequence per cache */
-static int cache_random_seq_create(struct kmem_cache *cachep)
+static int cache_random_seq_create(struct kmem_cache *cachep, gfp_t gfp)
 {
 	unsigned int seed, count = cachep->num;
 	struct rnd_state state;
@@ -1271,7 +1271,7 @@ static int cache_random_seq_create(struc
 		return 0;
 
 	/* If it fails, we will just use the global lists */
-	cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), GFP_KERNEL);
+	cachep->random_seq = kcalloc(count, sizeof(freelist_idx_t), gfp);
 	if (!cachep->random_seq)
 		return -ENOMEM;
 
@@ -1290,7 +1290,7 @@ static void cache_random_seq_destroy(str
 	cachep->random_seq = NULL;
 }
 #else
-static inline int cache_random_seq_create(struct kmem_cache *cachep)
+static inline int cache_random_seq_create(struct kmem_cache *cachep, gfp_t gfp)
 {
 	return 0;
 }
@@ -3999,7 +3999,7 @@ static int enable_cpucache(struct kmem_c
 	int shared = 0;
 	int batchcount = 0;
 
-	err = cache_random_seq_create(cachep);
+	err = cache_random_seq_create(cachep, gfp);
 	if (err)
 		goto end;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
