Date: Wed, 21 May 2008 20:01:12 +0900
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default
 dma pad mask
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20080521100529.GA19077@gondor.apana.org.au>
References: <20080521084700.GA18644@gondor.apana.org.au>
	<20080521183429O.tomof@acm.org>
	<20080521100529.GA19077@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20080521200104C.tomof@acm.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: herbert@gondor.apana.org.au
Cc: fujita.tomonori@lab.ntt.co.jp, akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 18:05:29 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, May 21, 2008 at 06:34:45PM +0900, FUJITA Tomonori wrote:
> >
> > Why do crypto need to know exactly the minimum alignment guaranteed by
> > kmalloc? Can you tell me an example how the alignment breaks crypto?
> 
> It's used to make the context aligned so that for most algorithms
> we can get to the context without going through ALIGN_PTR.  Only

How many bytes does the context need to be aligned?

I'm still not sure what you mean. You referred to aes, so let me use
aes as an example.

I think 'we can get to the context' means that accessing to
crypto_aes_ctx from struct crypto_tfm like this:

struct crypto_aes_ctx *ctx = crypto_tfm_ctx(tfm);


struct crypto_tfm and crypto_tfm_ctx are defined as:

struct crypto_tfm {

	u32 crt_flags;

	union {
		struct ablkcipher_tfm ablkcipher;
		struct aead_tfm aead;
		struct blkcipher_tfm blkcipher;
		struct cipher_tfm cipher;
		struct hash_tfm hash;
		struct compress_tfm compress;
	} crt_u;

	struct crypto_alg *__crt_alg;

	void *__crt_ctx[] CRYPTO_MINALIGN_ATTR;
};

static inline void *crypto_tfm_ctx(struct crypto_tfm *tfm)
{
	return tfm->__crt_ctx;
}

struct crypto_aes_ctx is placed right after struct crypto_tfm.

My question is why __crt_ctx needs ARCH_KMALLOC_MINALIGN alignment,
e.g., could be 128 bytes.


> algorithms requiring alignments bigger than that offered by kmalloc
> would have to use ALIGN_PTR.  This is important because the context
> is used on the fast path, i.e., for AES every block has to access
> the context.

Why do algorithms require alignments bigger than ARCH_KMALLOC_MINALIGN?


> If we used an alignment value is bigger than that guaranteed by
> kmalloc then this would break because the context may end up
> unaligned.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
