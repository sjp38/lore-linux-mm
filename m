Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 230646B0083
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:53:20 -0400 (EDT)
Received: by wief7 with SMTP id f7so89572236wie.0
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:53:18 -0700 (PDT)
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com. [195.75.94.108])
        by mx.google.com with ESMTPS id wb11si370057wic.105.2015.05.11.08.52.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:59 -0700 (PDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:58 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id D3AC61B0806B
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:53:39 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqte733751174
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:55 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqrnf015267
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:54 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 13/15] powerpc: enable_kernel_altivec() requires disabled preemption
Date: Mon, 11 May 2015 17:52:18 +0200
Message-Id: <1431359540-32227-14-git-send-email-dahi@linux.vnet.ibm.com>
In-Reply-To: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

enable_kernel_altivec() has to be called with disabled preemption.
Let's make this explicit, to prepare for pagefault_disable() not
touching preemption anymore.

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: David Hildenbrand <dahi@linux.vnet.ibm.com>
---
 arch/powerpc/lib/vmx-helper.c | 11 ++++++-----
 drivers/crypto/vmx/aes.c      |  8 +++++++-
 drivers/crypto/vmx/aes_cbc.c  |  6 ++++++
 drivers/crypto/vmx/ghash.c    |  8 ++++++++
 4 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/lib/vmx-helper.c b/arch/powerpc/lib/vmx-helper.c
index 3cf529c..ac93a3b 100644
--- a/arch/powerpc/lib/vmx-helper.c
+++ b/arch/powerpc/lib/vmx-helper.c
@@ -27,11 +27,11 @@ int enter_vmx_usercopy(void)
 	if (in_interrupt())
 		return 0;
 
-	/* This acts as preempt_disable() as well and will make
-	 * enable_kernel_altivec(). We need to disable page faults
-	 * as they can call schedule and thus make us lose the VMX
-	 * context. So on page faults, we just fail which will cause
-	 * a fallback to the normal non-vmx copy.
+	preempt_disable();
+	/*
+	 * We need to disable page faults as they can call schedule and
+	 * thus make us lose the VMX context. So on page faults, we just
+	 * fail which will cause a fallback to the normal non-vmx copy.
 	 */
 	pagefault_disable();
 
@@ -47,6 +47,7 @@ int enter_vmx_usercopy(void)
 int exit_vmx_usercopy(void)
 {
 	pagefault_enable();
+	preempt_enable();
 	return 0;
 }
 
diff --git a/drivers/crypto/vmx/aes.c b/drivers/crypto/vmx/aes.c
index ab300ea..a9064e3 100644
--- a/drivers/crypto/vmx/aes.c
+++ b/drivers/crypto/vmx/aes.c
@@ -78,12 +78,14 @@ static int p8_aes_setkey(struct crypto_tfm *tfm, const u8 *key,
     int ret;
     struct p8_aes_ctx *ctx = crypto_tfm_ctx(tfm);
 
+    preempt_disable();
     pagefault_disable();
     enable_kernel_altivec();
     ret = aes_p8_set_encrypt_key(key, keylen * 8, &ctx->enc_key);
     ret += aes_p8_set_decrypt_key(key, keylen * 8, &ctx->dec_key);
     pagefault_enable();
-    
+    preempt_enable();
+
     ret += crypto_cipher_setkey(ctx->fallback, key, keylen);
     return ret;
 }
@@ -95,10 +97,12 @@ static void p8_aes_encrypt(struct crypto_tfm *tfm, u8 *dst, const u8 *src)
     if (in_interrupt()) {
         crypto_cipher_encrypt_one(ctx->fallback, dst, src);
     } else {
+	preempt_disable();
         pagefault_disable();
         enable_kernel_altivec();
         aes_p8_encrypt(src, dst, &ctx->enc_key);
         pagefault_enable();
+	preempt_enable();
     }
 }
 
@@ -109,10 +113,12 @@ static void p8_aes_decrypt(struct crypto_tfm *tfm, u8 *dst, const u8 *src)
     if (in_interrupt()) {
         crypto_cipher_decrypt_one(ctx->fallback, dst, src);
     } else {
+	preempt_disable();
         pagefault_disable();
         enable_kernel_altivec();
         aes_p8_decrypt(src, dst, &ctx->dec_key);
         pagefault_enable();
+	preempt_enable();
     }
 }
 
diff --git a/drivers/crypto/vmx/aes_cbc.c b/drivers/crypto/vmx/aes_cbc.c
index 1a559b7..477284a 100644
--- a/drivers/crypto/vmx/aes_cbc.c
+++ b/drivers/crypto/vmx/aes_cbc.c
@@ -79,11 +79,13 @@ static int p8_aes_cbc_setkey(struct crypto_tfm *tfm, const u8 *key,
     int ret;
     struct p8_aes_cbc_ctx *ctx = crypto_tfm_ctx(tfm);
 
+    preempt_disable();
     pagefault_disable();
     enable_kernel_altivec();
     ret = aes_p8_set_encrypt_key(key, keylen * 8, &ctx->enc_key);
     ret += aes_p8_set_decrypt_key(key, keylen * 8, &ctx->dec_key);
     pagefault_enable();
+    preempt_enable();
 
     ret += crypto_blkcipher_setkey(ctx->fallback, key, keylen);
     return ret;
@@ -106,6 +108,7 @@ static int p8_aes_cbc_encrypt(struct blkcipher_desc *desc,
     if (in_interrupt()) {
         ret = crypto_blkcipher_encrypt(&fallback_desc, dst, src, nbytes);
     } else {
+	preempt_disable();
         pagefault_disable();
         enable_kernel_altivec();
 
@@ -119,6 +122,7 @@ static int p8_aes_cbc_encrypt(struct blkcipher_desc *desc,
 	}
 
         pagefault_enable();
+	preempt_enable();
     }
 
     return ret;
@@ -141,6 +145,7 @@ static int p8_aes_cbc_decrypt(struct blkcipher_desc *desc,
     if (in_interrupt()) {
         ret = crypto_blkcipher_decrypt(&fallback_desc, dst, src, nbytes);
     } else {
+	preempt_disable();
         pagefault_disable();
         enable_kernel_altivec();
 
@@ -154,6 +159,7 @@ static int p8_aes_cbc_decrypt(struct blkcipher_desc *desc,
 		}
 
         pagefault_enable();
+	preempt_enable();
     }
 
     return ret;
diff --git a/drivers/crypto/vmx/ghash.c b/drivers/crypto/vmx/ghash.c
index d0ffe27..f255ec4 100644
--- a/drivers/crypto/vmx/ghash.c
+++ b/drivers/crypto/vmx/ghash.c
@@ -114,11 +114,13 @@ static int p8_ghash_setkey(struct crypto_shash *tfm, const u8 *key,
     if (keylen != GHASH_KEY_LEN)
         return -EINVAL;
 
+    preempt_disable();
     pagefault_disable();
     enable_kernel_altivec();
     enable_kernel_fp();
     gcm_init_p8(ctx->htable, (const u64 *) key);
     pagefault_enable();
+    preempt_enable();
     return crypto_shash_setkey(ctx->fallback, key, keylen);
 }
 
@@ -140,23 +142,27 @@ static int p8_ghash_update(struct shash_desc *desc,
             }
             memcpy(dctx->buffer + dctx->bytes, src,
                     GHASH_DIGEST_SIZE - dctx->bytes);
+	    preempt_disable();
             pagefault_disable();
             enable_kernel_altivec();
             enable_kernel_fp();
             gcm_ghash_p8(dctx->shash, ctx->htable, dctx->buffer,
                     GHASH_DIGEST_SIZE);
             pagefault_enable();
+	    preempt_enable();
             src += GHASH_DIGEST_SIZE - dctx->bytes;
             srclen -= GHASH_DIGEST_SIZE - dctx->bytes;
             dctx->bytes = 0;
         }
         len = srclen & ~(GHASH_DIGEST_SIZE - 1);
         if (len) {
+	    preempt_disable();
             pagefault_disable();
             enable_kernel_altivec();
             enable_kernel_fp();
             gcm_ghash_p8(dctx->shash, ctx->htable, src, len);
             pagefault_enable();
+	    preempt_enable();
             src += len;
             srclen -= len;
         }
@@ -180,12 +186,14 @@ static int p8_ghash_final(struct shash_desc *desc, u8 *out)
         if (dctx->bytes) {
             for (i = dctx->bytes; i < GHASH_DIGEST_SIZE; i++)
                 dctx->buffer[i] = 0;
+	    preempt_disable();
             pagefault_disable();
             enable_kernel_altivec();
             enable_kernel_fp();
             gcm_ghash_p8(dctx->shash, ctx->htable, dctx->buffer,
                     GHASH_DIGEST_SIZE);
             pagefault_enable();
+	    preempt_enable();
             dctx->bytes = 0;
         }
         memcpy(out, dctx->shash, GHASH_DIGEST_SIZE);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
