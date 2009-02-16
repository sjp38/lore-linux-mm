Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 76A596B0098
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:04:51 -0500 (EST)
Message-Id: <20090216144725.659631692@cmpxchg.org>
Date: Mon, 16 Feb 2009 15:29:28 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/8] crypto: use kzfree()
References: <20090216142926.440561506@cmpxchg.org>
Content-Disposition: inline; filename=crypto-use-kzfree.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
List-ID: <linux-mm.kvack.org>

Use kzfree() instead of memset() + kfree().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 crypto/api.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- a/crypto/api.c
+++ b/crypto/api.c
@@ -569,20 +569,17 @@ EXPORT_SYMBOL_GPL(crypto_alloc_tfm);
 void crypto_destroy_tfm(void *mem, struct crypto_tfm *tfm)
 {
 	struct crypto_alg *alg;
-	int size;
 
 	if (unlikely(!mem))
 		return;
 
 	alg = tfm->__crt_alg;
-	size = ksize(mem);
 
 	if (!tfm->exit && alg->cra_exit)
 		alg->cra_exit(tfm);
 	crypto_exit_ops(tfm);
 	crypto_mod_put(alg);
-	memset(mem, 0, size);
-	kfree(mem);
+	kzfree(mem);
 }
 EXPORT_SYMBOL_GPL(crypto_destroy_tfm);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
