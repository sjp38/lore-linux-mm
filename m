Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E15276B009A
	for <linux-mm@kvack.org>; Wed, 20 May 2009 15:05:43 -0400 (EDT)
Date: Wed, 20 May 2009 12:05:19 -0700
From: "Larry H." <research@subreption.com>
Subject: [patch 5/5] Apply the PG_sensitive flag to the CryptoAPI subsystem
Message-ID: <20090520190519.GE10756@oblivion.subreption.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, pageexec@freemail.hu, linux-crypto@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch deploys the use of the PG_sensitive page allocator flag
within the CryptoAPI subsystem, in all relevant locations where
algorithm and key contexts are allocated.

Some calls to memset for zeroing the buffers have been removed to
avoid duplication of the sanitizing process, since this is already
taken care of by the allocator during page freeing.

The only noticeable impact on performance might be in the blkcipher
modifications, although this is likely negligible and balanced with
the security benefits of this patch in the long term.

Signed-off-by: Larry H. <research@subreption.com>

---
 crypto/ablkcipher.c |    3 +--
 crypto/aead.c       |    5 ++---
 crypto/ahash.c      |    3 +--
 crypto/algapi.c     |    2 +-
 crypto/api.c        |    7 +++----
 crypto/authenc.c    |    2 +-
 crypto/blkcipher.c  |   11 +++++------
 crypto/cipher.c     |    3 +--
 crypto/cryptd.c     |    2 +-
 crypto/gcm.c        |    6 +++---
 crypto/hash.c       |    3 +--
 crypto/rng.c        |    2 +-
 crypto/seqiv.c      |    5 +++--
 crypto/shash.c      |    3 +--
 14 files changed, 25 insertions(+), 32 deletions(-)

Index: linux-2.6/crypto/ablkcipher.c
===================================================================
--- linux-2.6.orig/crypto/ablkcipher.c
+++ linux-2.6/crypto/ablkcipher.c
@@ -35,14 +35,13 @@ static int setkey_unaligned(struct crypt
 	unsigned long absize;
 
 	absize = keylen + alignmask;
-	buffer = kmalloc(absize, GFP_ATOMIC);
+	buffer = kmalloc(absize, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!buffer)
 		return -ENOMEM;
 
 	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
 	memcpy(alignbuffer, key, keylen);
 	ret = cipher->setkey(tfm, alignbuffer, keylen);
-	memset(alignbuffer, 0, keylen);
 	kfree(buffer);
 	return ret;
 }
Index: linux-2.6/crypto/aead.c
===================================================================
--- linux-2.6.orig/crypto/aead.c
+++ linux-2.6/crypto/aead.c
@@ -33,14 +33,13 @@ static int setkey_unaligned(struct crypt
 	unsigned long absize;
 
 	absize = keylen + alignmask;
-	buffer = kmalloc(absize, GFP_ATOMIC);
+	buffer = kmalloc(absize, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!buffer)
 		return -ENOMEM;
 
 	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
 	memcpy(alignbuffer, key, keylen);
 	ret = aead->setkey(tfm, alignbuffer, keylen);
-	memset(alignbuffer, 0, keylen);
 	kfree(buffer);
 	return ret;
 }
@@ -232,7 +231,7 @@ struct crypto_instance *aead_geniv_alloc
 	if (IS_ERR(name))
 		return ERR_PTR(err);
 
-	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL);
+	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL | GFP_SENSITIVE);
 	if (!inst)
 		return ERR_PTR(-ENOMEM);
 
Index: linux-2.6/crypto/ahash.c
===================================================================
--- linux-2.6.orig/crypto/ahash.c
+++ linux-2.6/crypto/ahash.c
@@ -138,14 +138,13 @@ static int ahash_setkey_unaligned(struct
 	unsigned long absize;
 
 	absize = keylen + alignmask;
-	buffer = kmalloc(absize, GFP_ATOMIC);
+	buffer = kmalloc(absize, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!buffer)
 		return -ENOMEM;
 
 	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
 	memcpy(alignbuffer, key, keylen);
 	ret = ahash->setkey(tfm, alignbuffer, keylen);
-	memset(alignbuffer, 0, keylen);
 	kfree(buffer);
 	return ret;
 }
Index: linux-2.6/crypto/algapi.c
===================================================================
--- linux-2.6.orig/crypto/algapi.c
+++ linux-2.6/crypto/algapi.c
@@ -634,7 +634,7 @@ struct crypto_instance *crypto_alloc_ins
 	struct crypto_spawn *spawn;
 	int err;
 
-	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL);
+	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL | GFP_SENSITIVE);
 	if (!inst)
 		return ERR_PTR(-ENOMEM);
 
Index: linux-2.6/crypto/api.c
===================================================================
--- linux-2.6.orig/crypto/api.c
+++ linux-2.6/crypto/api.c
@@ -114,7 +114,7 @@ struct crypto_larval *crypto_larval_allo
 {
 	struct crypto_larval *larval;
 
-	larval = kzalloc(sizeof(*larval), GFP_KERNEL);
+	larval = kzalloc(sizeof(*larval), GFP_KERNEL | GFP_SENSITIVE);
 	if (!larval)
 		return ERR_PTR(-ENOMEM);
 
@@ -380,7 +380,7 @@ struct crypto_tfm *__crypto_alloc_tfm(st
 	int err = -ENOMEM;
 
 	tfm_size = sizeof(*tfm) + crypto_ctxsize(alg, type, mask);
-	tfm = kzalloc(tfm_size, GFP_KERNEL);
+	tfm = kzalloc(tfm_size, GFP_KERNEL | GFP_SENSITIVE);
 	if (tfm == NULL)
 		goto out_err;
 
@@ -476,7 +476,7 @@ struct crypto_tfm *crypto_create_tfm(str
 	tfmsize = frontend->tfmsize;
 	total = tfmsize + sizeof(*tfm) + frontend->extsize(alg, frontend);
 
-	mem = kzalloc(total, GFP_KERNEL);
+	mem = kzalloc(total, GFP_KERNEL | GFP_SENSITIVE);
 	if (mem == NULL)
 		goto out_err;
 
@@ -592,7 +592,6 @@ void crypto_destroy_tfm(void *mem, struc
 		alg->cra_exit(tfm);
 	crypto_exit_ops(tfm);
 	crypto_mod_put(alg);
-	memset(mem, 0, size);
 	kfree(mem);
 }
 EXPORT_SYMBOL_GPL(crypto_destroy_tfm);
Index: linux-2.6/crypto/authenc.c
===================================================================
--- linux-2.6.orig/crypto/authenc.c
+++ linux-2.6/crypto/authenc.c
@@ -397,7 +397,7 @@ static struct crypto_instance *crypto_au
 	if (IS_ERR(enc_name))
 		goto out_put_auth;
 
-	inst = kzalloc(sizeof(*inst) + sizeof(*ctx), GFP_KERNEL);
+	inst = kzalloc(sizeof(*inst) + sizeof(*ctx), GFP_KERNEL | GFP_SENSITIVE);
 	err = -ENOMEM;
 	if (!inst)
 		goto out_put_auth;
Index: linux-2.6/crypto/blkcipher.c
===================================================================
--- linux-2.6.orig/crypto/blkcipher.c
+++ linux-2.6/crypto/blkcipher.c
@@ -161,7 +161,7 @@ static inline int blkcipher_next_slow(st
 
 	n = aligned_bsize * 3 - (alignmask + 1) +
 	    (alignmask & ~(crypto_tfm_ctx_alignment() - 1));
-	walk->buffer = kmalloc(n, GFP_ATOMIC);
+	walk->buffer = kmalloc(n, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!walk->buffer)
 		return blkcipher_walk_done(desc, walk, -ENOMEM);
 
@@ -242,7 +242,7 @@ static int blkcipher_walk_next(struct bl
 	    !scatterwalk_aligned(&walk->out, alignmask)) {
 		walk->flags |= BLKCIPHER_WALK_COPY;
 		if (!walk->page) {
-			walk->page = (void *)__get_free_page(GFP_ATOMIC);
+			walk->page = (void *)__get_free_page(GFP_ATOMIC|GFP_SENSITIVE);
 			if (!walk->page)
 				n = 0;
 		}
@@ -287,7 +287,7 @@ static inline int blkcipher_copy_iv(stru
 	u8 *iv;
 
 	size += alignmask & ~(crypto_tfm_ctx_alignment() - 1);
-	walk->buffer = kmalloc(size, GFP_ATOMIC);
+	walk->buffer = kmalloc(size, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!walk->buffer)
 		return -ENOMEM;
 
@@ -366,14 +366,13 @@ static int setkey_unaligned(struct crypt
 	unsigned long absize;
 
 	absize = keylen + alignmask;
-	buffer = kmalloc(absize, GFP_ATOMIC);
+	buffer = kmalloc(absize, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!buffer)
 		return -ENOMEM;
 
 	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
 	memcpy(alignbuffer, key, keylen);
 	ret = cipher->setkey(tfm, alignbuffer, keylen);
-	memset(alignbuffer, 0, keylen);
 	kfree(buffer);
 	return ret;
 }
@@ -569,7 +568,7 @@ struct crypto_instance *skcipher_geniv_a
 	if (IS_ERR(name))
 		return ERR_PTR(err);
 
-	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL);
+	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL | GFP_SENSITIVE);
 	if (!inst)
 		return ERR_PTR(-ENOMEM);
 
Index: linux-2.6/crypto/cipher.c
===================================================================
--- linux-2.6.orig/crypto/cipher.c
+++ linux-2.6/crypto/cipher.c
@@ -30,14 +30,13 @@ static int setkey_unaligned(struct crypt
 	unsigned long absize;
 
 	absize = keylen + alignmask;
-	buffer = kmalloc(absize, GFP_ATOMIC);
+	buffer = kmalloc(absize, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!buffer)
 		return -ENOMEM;
 
 	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
 	memcpy(alignbuffer, key, keylen);
 	ret = cia->cia_setkey(tfm, alignbuffer, keylen);
-	memset(alignbuffer, 0, keylen);
 	kfree(buffer);
 	return ret;
 
Index: linux-2.6/crypto/cryptd.c
===================================================================
--- linux-2.6.orig/crypto/cryptd.c
+++ linux-2.6/crypto/cryptd.c
@@ -196,7 +196,7 @@ static struct crypto_instance *cryptd_al
 	struct cryptd_instance_ctx *ctx;
 	int err;
 
-	inst = kzalloc(sizeof(*inst) + sizeof(*ctx), GFP_KERNEL);
+	inst = kzalloc(sizeof(*inst) + sizeof(*ctx), GFP_KERNEL | GFP_SENSITIVE);
 	if (!inst) {
 		inst = ERR_PTR(-ENOMEM);
 		goto out;
Index: linux-2.6/crypto/gcm.c
===================================================================
--- linux-2.6.orig/crypto/gcm.c
+++ linux-2.6/crypto/gcm.c
@@ -208,7 +208,7 @@ static int crypto_gcm_setkey(struct cryp
 				       CRYPTO_TFM_RES_MASK);
 
 	data = kzalloc(sizeof(*data) + crypto_ablkcipher_reqsize(ctr),
-		       GFP_KERNEL);
+		       GFP_KERNEL | GFP_SENSITIVE);
 	if (!data)
 		return -ENOMEM;
 
@@ -454,7 +454,7 @@ static struct crypto_instance *crypto_gc
 	if ((algt->type ^ CRYPTO_ALG_TYPE_AEAD) & algt->mask)
 		return ERR_PTR(-EINVAL);
 
-	inst = kzalloc(sizeof(*inst) + sizeof(*ctx), GFP_KERNEL);
+	inst = kzalloc(sizeof(*inst) + sizeof(*ctx), GFP_KERNEL | GFP_SENSITIVE);
 	if (!inst)
 		return ERR_PTR(-ENOMEM);
 
@@ -703,7 +703,7 @@ static struct crypto_instance *crypto_rf
 	if (IS_ERR(ccm_name))
 		return ERR_PTR(err);
 
-	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL);
+	inst = kzalloc(sizeof(*inst) + sizeof(*spawn), GFP_KERNEL | GFP_SENSITIVE);
 	if (!inst)
 		return ERR_PTR(-ENOMEM);
 
Index: linux-2.6/crypto/hash.c
===================================================================
--- linux-2.6.orig/crypto/hash.c
+++ linux-2.6/crypto/hash.c
@@ -35,14 +35,13 @@ static int hash_setkey_unaligned(struct 
 	unsigned long absize;
 
 	absize = keylen + alignmask;
-	buffer = kmalloc(absize, GFP_ATOMIC);
+	buffer = kmalloc(absize, GFP_ATOMIC | GFP_SENSITIVE);
 	if (!buffer)
 		return -ENOMEM;
 
 	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
 	memcpy(alignbuffer, key, keylen);
 	ret = alg->setkey(crt, alignbuffer, keylen);
-	memset(alignbuffer, 0, keylen);
 	kfree(buffer);
 	return ret;
 }
Index: linux-2.6/crypto/rng.c
===================================================================
--- linux-2.6.orig/crypto/rng.c
+++ linux-2.6/crypto/rng.c
@@ -32,7 +32,7 @@ static int rngapi_reset(struct crypto_rn
 	int err;
 
 	if (!seed && slen) {
-		buf = kmalloc(slen, GFP_KERNEL);
+		buf = kmalloc(slen, GFP_KERNEL | GFP_SENSITIVE);
 		if (!buf)
 			return -ENOMEM;
 
Index: linux-2.6/crypto/seqiv.c
===================================================================
--- linux-2.6.orig/crypto/seqiv.c
+++ linux-2.6/crypto/seqiv.c
@@ -115,9 +115,10 @@ static int seqiv_givencrypt(struct skcip
 
 	if (unlikely(!IS_ALIGNED((unsigned long)info,
 				 crypto_ablkcipher_alignmask(geniv) + 1))) {
-		info = kmalloc(ivsize, req->creq.base.flags &
+		info = kmalloc(ivsize, (req->creq.base.flags &
 				       CRYPTO_TFM_REQ_MAY_SLEEP ? GFP_KERNEL:
-								  GFP_ATOMIC);
+								  GFP_ATOMIC)
+					| GFP_SENSITIVE);
 		if (!info)
 			return -ENOMEM;
 
Index: linux-2.6/crypto/shash.c
===================================================================
--- linux-2.6.orig/crypto/shash.c
+++ linux-2.6/crypto/shash.c
@@ -37,14 +37,13 @@ static int shash_setkey_unaligned(struct
 	int err;
 
 	absize = keylen + (alignmask & ~(CRYPTO_MINALIGN - 1));
-	buffer = kmalloc(absize, GFP_KERNEL);
+	buffer = kmalloc(absize, GFP_KERNEL | GFP_SENSITIVE);
 	if (!buffer)
 		return -ENOMEM;
 
 	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
 	memcpy(alignbuffer, key, keylen);
 	err = shash->setkey(tfm, alignbuffer, keylen);
-	memset(alignbuffer, 0, keylen);
 	kfree(buffer);
 	return err;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
