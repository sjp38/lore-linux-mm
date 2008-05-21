Date: Wed, 21 May 2008 18:05:29 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default dma pad mask
Message-ID: <20080521100529.GA19077@gondor.apana.org.au>
References: <20080521031646.GA16565@gondor.apana.org.au> <20080521155414D.fujita.tomonori@lab.ntt.co.jp> <20080521084700.GA18644@gondor.apana.org.au> <20080521183429O.tomof@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080521183429O.tomof@acm.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 21, 2008 at 06:34:45PM +0900, FUJITA Tomonori wrote:
>
> Why do crypto need to know exactly the minimum alignment guaranteed by
> kmalloc? Can you tell me an example how the alignment breaks crypto?

It's used to make the context aligned so that for most algorithms
we can get to the context without going through ALIGN_PTR.  Only
algorithms requiring alignments bigger than that offered by kmalloc
would have to use ALIGN_PTR.  This is important because the context
is used on the fast path, i.e., for AES every block has to access
the context.

If we used an alignment value is bigger than that guaranteed by
kmalloc then this would break because the context may end up
unaligned.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
