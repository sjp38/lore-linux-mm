Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E95836B005A
	for <linux-mm@kvack.org>; Sun, 31 May 2009 02:02:15 -0400 (EDT)
Date: Sat, 30 May 2009 23:02:13 -0700 (PDT)
Message-Id: <20090530.230213.73434433.davem@davemloft.net>
Subject: Re: [PATCH] Use kzfree in crypto API context initialization and
 key/iv handling
From: David Miller <davem@davemloft.net>
In-Reply-To: <20090531025720.GC9033@oblivion.subreption.com>
References: <20090531025720.GC9033@oblivion.subreption.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: research@subreption.com
Cc: linux-kernel@vger.kernel.org, pageexec@freemail.hu, linux-mm@kvack.org, torvalds@osdl.org, riel@redhat.com, alan@lxorguk.ukuu.org.uk, linux-crypto@vger.kernel.org, herbert@gondor.apana.org.au
List-ID: <linux-mm.kvack.org>

From: "Larry H." <research@subreption.com>
Date: Sat, 30 May 2009 19:57:20 -0700

> [PATCH] Use kzfree in crypto API context initialization and key/iv handling

Thanks for not CC:ing the crypto list, and also not CC:'ing the
crypto maintainer.

Your submissions leave a lot to be desired, on every level.

> This patch replaces the kfree() calls within the crypto API (algorithms,
> key setup and handling, etc) with kzfree(), to enforce sanitization of
> the allocated memory.
> 
> This prevents such information from persisting on memory and eventually
> leak to other kernel users or during coldboot attacks.
> 
> This patch replaces kfree() for context (algorithm meta-data) structures
> too. Those are initialized or released once, and remain in use during the
> lifetime of the cipher/algorithm instance, therefore no performance impact
> exists for those specific changes.
> 
> This patch doesn't affect fastpaths.
> 
> Signed-off-by: Larry Highsmith <research@subreption.com>
> 
> ---
>  crypto/ablkcipher.c |    3 +--
>  crypto/aead.c       |    7 +++----
>  crypto/ahash.c      |    3 +--
>  crypto/algapi.c     |    4 ++--
>  crypto/algboss.c    |    8 ++++----
>  crypto/api.c        |   13 +++++--------
>  crypto/authenc.c    |    4 ++--
>  crypto/blkcipher.c  |   13 +++++++------
>  crypto/cbc.c        |    2 +-
>  crypto/ccm.c        |    8 ++++----
>  crypto/cipher.c     |    3 +--
>  crypto/cryptd.c     |    4 ++--
>  crypto/ctr.c        |    2 +-
>  crypto/cts.c        |    2 +-
>  crypto/deflate.c    |    4 ++--
>  crypto/ecb.c        |    2 +-
>  crypto/gcm.c        |   10 +++++-----
>  crypto/gf128mul.c   |    4 ++--
>  crypto/hash.c       |    3 +--
>  crypto/hmac.c       |    2 +-
>  crypto/lrw.c        |    2 +-
>  crypto/pcbc.c       |    2 +-
>  crypto/rng.c        |    2 +-
>  crypto/seqiv.c      |    4 ++--
>  crypto/shash.c      |    3 +--
>  crypto/xcbc.c       |    2 +-
>  crypto/xts.c        |    2 +-
>  27 files changed, 55 insertions(+), 63 deletions(-)
> 
> Index: linux-2.6/crypto/ablkcipher.c
> ===================================================================
> --- linux-2.6.orig/crypto/ablkcipher.c
> +++ linux-2.6/crypto/ablkcipher.c
> @@ -42,8 +42,7 @@ static int setkey_unaligned(struct crypt
>  	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
>  	memcpy(alignbuffer, key, keylen);
>  	ret = cipher->setkey(tfm, alignbuffer, keylen);
> -	memset(alignbuffer, 0, keylen);
> -	kfree(buffer);
> +	kzfree(buffer);
>  	return ret;
>  }
>  
> Index: linux-2.6/crypto/aead.c
> ===================================================================
> --- linux-2.6.orig/crypto/aead.c
> +++ linux-2.6/crypto/aead.c
> @@ -40,8 +40,7 @@ static int setkey_unaligned(struct crypt
>  	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
>  	memcpy(alignbuffer, key, keylen);
>  	ret = aead->setkey(tfm, alignbuffer, keylen);
> -	memset(alignbuffer, 0, keylen);
> -	kfree(buffer);
> +	kzfree(buffer);
>  	return ret;
>  }
>  
> @@ -298,7 +297,7 @@ out:
>  err_drop_alg:
>  	crypto_drop_aead(spawn);
>  err_free_inst:
> -	kfree(inst);
> +	kzfree(inst);
>  	inst = ERR_PTR(err);
>  	goto out;
>  }
> @@ -307,7 +306,7 @@ EXPORT_SYMBOL_GPL(aead_geniv_alloc);
>  void aead_geniv_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_aead(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  EXPORT_SYMBOL_GPL(aead_geniv_free);
>  
> Index: linux-2.6/crypto/ahash.c
> ===================================================================
> --- linux-2.6.orig/crypto/ahash.c
> +++ linux-2.6/crypto/ahash.c
> @@ -145,8 +145,7 @@ static int ahash_setkey_unaligned(struct
>  	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
>  	memcpy(alignbuffer, key, keylen);
>  	ret = ahash->setkey(tfm, alignbuffer, keylen);
> -	memset(alignbuffer, 0, keylen);
> -	kfree(buffer);
> +	kzfree(buffer);
>  	return ret;
>  }
>  
> Index: linux-2.6/crypto/algapi.c
> ===================================================================
> --- linux-2.6.orig/crypto/algapi.c
> +++ linux-2.6/crypto/algapi.c
> @@ -185,7 +185,7 @@ out:	
>  	return larval;
>  
>  free_larval:
> -	kfree(larval);
> +	kzfree(larval);
>  err:
>  	larval = ERR_PTR(ret);
>  	goto out;
> @@ -657,7 +657,7 @@ struct crypto_instance *crypto_alloc_ins
>  	return inst;
>  
>  err_free_inst:
> -	kfree(inst);
> +	kzfree(inst);
>  	return ERR_PTR(err);
>  }
>  EXPORT_SYMBOL_GPL(crypto_alloc_instance);
> Index: linux-2.6/crypto/algboss.c
> ===================================================================
> --- linux-2.6.orig/crypto/algboss.c
> +++ linux-2.6/crypto/algboss.c
> @@ -81,7 +81,7 @@ static int cryptomgr_probe(void *data)
>  		goto err;
>  
>  out:
> -	kfree(param);
> +	kzfree(param);
>  	module_put_and_exit(0);
>  
>  err:
> @@ -193,7 +193,7 @@ static int cryptomgr_schedule_probe(stru
>  	return NOTIFY_STOP;
>  
>  err_free_param:
> -	kfree(param);
> +	kzfree(param);
>  err_put_module:
>  	module_put(THIS_MODULE);
>  err:
> @@ -215,7 +215,7 @@ static int cryptomgr_test(void *data)
>  skiptest:
>  	crypto_alg_tested(param->driver, err);
>  
> -	kfree(param);
> +	kzfree(param);
>  	module_put_and_exit(0);
>  }
>  
> @@ -242,7 +242,7 @@ static int cryptomgr_schedule_test(struc
>  	return NOTIFY_STOP;
>  
>  err_free_param:
> -	kfree(param);
> +	kzfree(param);
>  err_put_module:
>  	module_put(THIS_MODULE);
>  err:
> Index: linux-2.6/crypto/api.c
> ===================================================================
> --- linux-2.6.orig/crypto/api.c
> +++ linux-2.6/crypto/api.c
> @@ -107,7 +107,7 @@ static void crypto_larval_destroy(struct
>  	BUG_ON(!crypto_is_larval(alg));
>  	if (larval->adult)
>  		crypto_mod_put(larval->adult);
> -	kfree(larval);
> +	kzfree(larval);
>  }
>  
>  struct crypto_larval *crypto_larval_alloc(const char *name, u32 type, u32 mask)
> @@ -151,7 +151,7 @@ static struct crypto_alg *crypto_larval_
>  	up_write(&crypto_alg_sem);
>  
>  	if (alg != &larval->alg)
> -		kfree(larval);
> +		kzfree(larval);
>  
>  	return alg;
>  }
> @@ -400,7 +400,7 @@ cra_init_failed:
>  out_free_tfm:
>  	if (err == -EAGAIN)
>  		crypto_shoot_alg(alg);
> -	kfree(tfm);
> +	kzfree(tfm);
>  out_err:
>  	tfm = ERR_PTR(err);
>  out:
> @@ -497,7 +497,7 @@ cra_init_failed:
>  out_free_tfm:
>  	if (err == -EAGAIN)
>  		crypto_shoot_alg(alg);
> -	kfree(mem);
> +	kzfree(mem);
>  out_err:
>  	tfm = ERR_PTR(err);
>  out:
> @@ -580,20 +580,17 @@ EXPORT_SYMBOL_GPL(crypto_alloc_tfm);
>  void crypto_destroy_tfm(void *mem, struct crypto_tfm *tfm)
>  {
>  	struct crypto_alg *alg;
> -	int size;
>  
>  	if (unlikely(!mem))
>  		return;
>  
>  	alg = tfm->__crt_alg;
> -	size = ksize(mem);
>  
>  	if (!tfm->exit && alg->cra_exit)
>  		alg->cra_exit(tfm);
>  	crypto_exit_ops(tfm);
>  	crypto_mod_put(alg);
> -	memset(mem, 0, size);
> -	kfree(mem);
> +	kzfree(mem);
>  }
>  EXPORT_SYMBOL_GPL(crypto_destroy_tfm);
>  
> Index: linux-2.6/crypto/authenc.c
> ===================================================================
> --- linux-2.6.orig/crypto/authenc.c
> +++ linux-2.6/crypto/authenc.c
> @@ -461,7 +461,7 @@ err_drop_enc:
>  err_drop_auth:
>  	crypto_drop_spawn(&ctx->auth);
>  err_free_inst:
> -	kfree(inst);
> +	kzfree(inst);
>  out_put_auth:
>  	inst = ERR_PTR(err);
>  	goto out;
> @@ -473,7 +473,7 @@ static void crypto_authenc_free(struct c
>  
>  	crypto_drop_skcipher(&ctx->enc);
>  	crypto_drop_spawn(&ctx->auth);
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_authenc_tmpl = {
> Index: linux-2.6/crypto/blkcipher.c
> ===================================================================
> --- linux-2.6.orig/crypto/blkcipher.c
> +++ linux-2.6/crypto/blkcipher.c
> @@ -136,9 +136,11 @@ err:
>  	if (walk->iv != desc->info)
>  		memcpy(desc->info, walk->iv, crypto_blkcipher_ivsize(tfm));
>  	if (walk->buffer != walk->page)
> -		kfree(walk->buffer);
> -	if (walk->page)
> +		kzfree(walk->buffer);
> +	if (walk->page) {
> +		memset(walk->page, 0, PAGE_SIZE);
>  		free_page((unsigned long)walk->page);
> +	}
>  
>  	return err;
>  }
> @@ -373,8 +375,7 @@ static int setkey_unaligned(struct crypt
>  	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
>  	memcpy(alignbuffer, key, keylen);
>  	ret = cipher->setkey(tfm, alignbuffer, keylen);
> -	memset(alignbuffer, 0, keylen);
> -	kfree(buffer);
> +	kzfree(buffer);
>  	return ret;
>  }
>  
> @@ -661,7 +662,7 @@ out:
>  err_drop_alg:
>  	crypto_drop_skcipher(spawn);
>  err_free_inst:
> -	kfree(inst);
> +	kzfree(inst);
>  	inst = ERR_PTR(err);
>  	goto out;
>  }
> @@ -670,7 +671,7 @@ EXPORT_SYMBOL_GPL(skcipher_geniv_alloc);
>  void skcipher_geniv_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_skcipher(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  EXPORT_SYMBOL_GPL(skcipher_geniv_free);
>  
> Index: linux-2.6/crypto/cbc.c
> ===================================================================
> --- linux-2.6.orig/crypto/cbc.c
> +++ linux-2.6/crypto/cbc.c
> @@ -264,7 +264,7 @@ out_put_alg:
>  static void crypto_cbc_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_cbc_tmpl = {
> Index: linux-2.6/crypto/ccm.c
> ===================================================================
> --- linux-2.6.orig/crypto/ccm.c
> +++ linux-2.6/crypto/ccm.c
> @@ -565,7 +565,7 @@ err_drop_ctr:
>  err_drop_cipher:
>  	crypto_drop_spawn(&ictx->cipher);
>  err_free_inst:
> -	kfree(inst);
> +	kzfree(inst);
>  out_put_cipher:
>  	inst = ERR_PTR(err);
>  	goto out;
> @@ -600,7 +600,7 @@ static void crypto_ccm_free(struct crypt
>  
>  	crypto_drop_spawn(&ctx->cipher);
>  	crypto_drop_skcipher(&ctx->ctr);
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_ccm_tmpl = {
> @@ -831,7 +831,7 @@ out:
>  out_drop_alg:
>  	crypto_drop_aead(spawn);
>  out_free_inst:
> -	kfree(inst);
> +	kzfree(inst);
>  	inst = ERR_PTR(err);
>  	goto out;
>  }
> @@ -839,7 +839,7 @@ out_free_inst:
>  static void crypto_rfc4309_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_rfc4309_tmpl = {
> Index: linux-2.6/crypto/cipher.c
> ===================================================================
> --- linux-2.6.orig/crypto/cipher.c
> +++ linux-2.6/crypto/cipher.c
> @@ -37,8 +37,7 @@ static int setkey_unaligned(struct crypt
>  	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
>  	memcpy(alignbuffer, key, keylen);
>  	ret = cia->cia_setkey(tfm, alignbuffer, keylen);
> -	memset(alignbuffer, 0, keylen);
> -	kfree(buffer);
> +	kzfree(buffer);
>  	return ret;
>  
>  }
> Index: linux-2.6/crypto/cryptd.c
> ===================================================================
> --- linux-2.6.orig/crypto/cryptd.c
> +++ linux-2.6/crypto/cryptd.c
> @@ -225,7 +225,7 @@ out:
>  	return inst;
>  
>  out_free_inst:
> -	kfree(inst);
> +	kzfree(inst);
>  	inst = ERR_PTR(err);
>  	goto out;
>  }
> @@ -527,7 +527,7 @@ static void cryptd_free(struct crypto_in
>  	struct cryptd_instance_ctx *ctx = crypto_instance_ctx(inst);
>  
>  	crypto_drop_spawn(&ctx->spawn);
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template cryptd_tmpl = {
> Index: linux-2.6/crypto/ctr.c
> ===================================================================
> --- linux-2.6.orig/crypto/ctr.c
> +++ linux-2.6/crypto/ctr.c
> @@ -231,7 +231,7 @@ out_put_alg:
>  static void crypto_ctr_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_ctr_tmpl = {
> Index: linux-2.6/crypto/cts.c
> ===================================================================
> --- linux-2.6.orig/crypto/cts.c
> +++ linux-2.6/crypto/cts.c
> @@ -326,7 +326,7 @@ out_put_alg:
>  static void crypto_cts_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_cts_tmpl = {
> Index: linux-2.6/crypto/deflate.c
> ===================================================================
> --- linux-2.6.orig/crypto/deflate.c
> +++ linux-2.6/crypto/deflate.c
> @@ -86,7 +86,7 @@ static int deflate_decomp_init(struct de
>  out:
>  	return ret;
>  out_free:
> -	kfree(stream->workspace);
> +	kzfree(stream->workspace);
>  	goto out;
>  }
>  
> @@ -99,7 +99,7 @@ static void deflate_comp_exit(struct def
>  static void deflate_decomp_exit(struct deflate_ctx *ctx)
>  {
>  	zlib_inflateEnd(&ctx->decomp_stream);
> -	kfree(ctx->decomp_stream.workspace);
> +	kzfree(ctx->decomp_stream.workspace);
>  }
>  
>  static int deflate_init(struct crypto_tfm *tfm)
> Index: linux-2.6/crypto/ecb.c
> ===================================================================
> --- linux-2.6.orig/crypto/ecb.c
> +++ linux-2.6/crypto/ecb.c
> @@ -160,7 +160,7 @@ out_put_alg:
>  static void crypto_ecb_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_ecb_tmpl = {
> Index: linux-2.6/crypto/gcm.c
> ===================================================================
> --- linux-2.6.orig/crypto/gcm.c
> +++ linux-2.6/crypto/gcm.c
> @@ -242,7 +242,7 @@ static int crypto_gcm_setkey(struct cryp
>  		err = -ENOMEM;
>  
>  out:
> -	kfree(data);
> +	kzfree(data);
>  	return err;
>  }
>  
> @@ -507,7 +507,7 @@ out:
>  out_put_ctr:
>  	crypto_drop_skcipher(&ctx->ctr);
>  err_free_inst:
> -	kfree(inst);
> +	kzfree(inst);
>  	inst = ERR_PTR(err);
>  	goto out;
>  }
> @@ -540,7 +540,7 @@ static void crypto_gcm_free(struct crypt
>  	struct gcm_instance_ctx *ctx = crypto_instance_ctx(inst);
>  
>  	crypto_drop_skcipher(&ctx->ctr);
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_gcm_tmpl = {
> @@ -762,7 +762,7 @@ out:
>  out_drop_alg:
>  	crypto_drop_aead(spawn);
>  out_free_inst:
> -	kfree(inst);
> +	kzfree(inst);
>  	inst = ERR_PTR(err);
>  	goto out;
>  }
> @@ -770,7 +770,7 @@ out_free_inst:
>  static void crypto_rfc4106_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_rfc4106_tmpl = {
> Index: linux-2.6/crypto/gf128mul.c
> ===================================================================
> --- linux-2.6.orig/crypto/gf128mul.c
> +++ linux-2.6/crypto/gf128mul.c
> @@ -352,8 +352,8 @@ void gf128mul_free_64k(struct gf128mul_6
>  	int i;
>  
>  	for (i = 0; i < 16; i++)
> -		kfree(t->t[i]);
> -	kfree(t);
> +		kzfree(t->t[i]);
> +	kzfree(t);
>  }
>  EXPORT_SYMBOL(gf128mul_free_64k);
>  
> Index: linux-2.6/crypto/hash.c
> ===================================================================
> --- linux-2.6.orig/crypto/hash.c
> +++ linux-2.6/crypto/hash.c
> @@ -42,8 +42,7 @@ static int hash_setkey_unaligned(struct 
>  	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
>  	memcpy(alignbuffer, key, keylen);
>  	ret = alg->setkey(crt, alignbuffer, keylen);
> -	memset(alignbuffer, 0, keylen);
> -	kfree(buffer);
> +	kzfree(buffer);
>  	return ret;
>  }
>  
> Index: linux-2.6/crypto/hmac.c
> ===================================================================
> --- linux-2.6.orig/crypto/hmac.c
> +++ linux-2.6/crypto/hmac.c
> @@ -218,7 +218,7 @@ static void hmac_exit_tfm(struct crypto_
>  static void hmac_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_instance *hmac_alloc(struct rtattr **tb)
> Index: linux-2.6/crypto/lrw.c
> ===================================================================
> --- linux-2.6.orig/crypto/lrw.c
> +++ linux-2.6/crypto/lrw.c
> @@ -287,7 +287,7 @@ out_put_alg:
>  static void free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_tmpl = {
> Index: linux-2.6/crypto/pcbc.c
> ===================================================================
> --- linux-2.6.orig/crypto/pcbc.c
> +++ linux-2.6/crypto/pcbc.c
> @@ -270,7 +270,7 @@ out_put_alg:
>  static void crypto_pcbc_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_pcbc_tmpl = {
> Index: linux-2.6/crypto/rng.c
> ===================================================================
> --- linux-2.6.orig/crypto/rng.c
> +++ linux-2.6/crypto/rng.c
> @@ -42,7 +42,7 @@ static int rngapi_reset(struct crypto_rn
>  
>  	err = crypto_rng_alg(tfm)->rng_reset(tfm, seed, slen);
>  
> -	kfree(buf);
> +	kzfree(buf);
>  	return err;
>  }
>  
> Index: linux-2.6/crypto/seqiv.c
> ===================================================================
> --- linux-2.6.orig/crypto/seqiv.c
> +++ linux-2.6/crypto/seqiv.c
> @@ -43,7 +43,7 @@ static void seqiv_complete2(struct skcip
>  	memcpy(req->creq.info, subreq->info, crypto_ablkcipher_ivsize(geniv));
>  
>  out:
> -	kfree(subreq->info);
> +	kzfree(subreq->info);
>  }
>  
>  static void seqiv_complete(struct crypto_async_request *base, int err)
> @@ -69,7 +69,7 @@ static void seqiv_aead_complete2(struct 
>  	memcpy(req->areq.iv, subreq->iv, crypto_aead_ivsize(geniv));
>  
>  out:
> -	kfree(subreq->iv);
> +	kzfree(subreq->iv);
>  }
>  
>  static void seqiv_aead_complete(struct crypto_async_request *base, int err)
> Index: linux-2.6/crypto/shash.c
> ===================================================================
> --- linux-2.6.orig/crypto/shash.c
> +++ linux-2.6/crypto/shash.c
> @@ -44,8 +44,7 @@ static int shash_setkey_unaligned(struct
>  	alignbuffer = (u8 *)ALIGN((unsigned long)buffer, alignmask + 1);
>  	memcpy(alignbuffer, key, keylen);
>  	err = shash->setkey(tfm, alignbuffer, keylen);
> -	memset(alignbuffer, 0, keylen);
> -	kfree(buffer);
> +	kzfree(buffer);
>  	return err;
>  }
>  
> Index: linux-2.6/crypto/xcbc.c
> ===================================================================
> --- linux-2.6.orig/crypto/xcbc.c
> +++ linux-2.6/crypto/xcbc.c
> @@ -346,7 +346,7 @@ out_put_alg:
>  static void xcbc_free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_xcbc_tmpl = {
> Index: linux-2.6/crypto/xts.c
> ===================================================================
> --- linux-2.6.orig/crypto/xts.c
> +++ linux-2.6/crypto/xts.c
> @@ -264,7 +264,7 @@ out_put_alg:
>  static void free(struct crypto_instance *inst)
>  {
>  	crypto_drop_spawn(crypto_instance_ctx(inst));
> -	kfree(inst);
> +	kzfree(inst);
>  }
>  
>  static struct crypto_template crypto_tmpl = {
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
