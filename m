Date: Thu, 22 May 2008 10:14:12 +0900
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default
 dma pad mask
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20080521131811.GA20212@gondor.apana.org.au>
References: <20080521122218.GA19849@gondor.apana.org.au>
	<20080521214624Y.fujita.tomonori@lab.ntt.co.jp>
	<20080521131811.GA20212@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20080522100712S.tomof@acm.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: herbert@gondor.apana.org.au
Cc: fujita.tomonori@lab.ntt.co.jp, akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 21:18:11 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, May 21, 2008 at 09:46:24PM +0900, FUJITA Tomonori wrote:
> >
> > No, you misunderstand my question. I meant, software algorithms don't
> > need ARCH_KMALLOC_MINALIGN alignment for __crt_ctx and if we are fine
> > with using the ALIGN hack for crypto hardware every time (like
> > aes_ctx_common), crypto doesn't need ARCH_KMALLOC_MINALIGN alignment
> > for __crt_ctx. Is this right?
> 
> The padlock isn't the only hardware device that will require
> such alignment.  Now that we have the async interface there will
> be more.

Ok, so it's all about crypto hardware requirement. In other words, if
we accept for potential performance drop of crypto hardware, crypto
can drop this alignment.


> > Because there are few architecture that defines
> > ARCH_KMALLOC_MINALIGN. So if crypto hardware needs alignement, it's
> 
> You keep going back to ARCH_KMALLOC_MINALIGN.  But this has *nothing*
> to do with ARCH_KMALLOC_MINALIGN.  The only reason it appears at
> all in the crypto code is because it's one of the parameters used
> to calculate the minimum alignment guaranteed by kmalloc.

No, you misunderstand what I meant. I'm talking about the minimum
alignment guaranteed by kmalloc too.

What I'm trying to asking you, on the majority of architectures, the
minimum alignment guaranteed by kmalloc (8 bytes) is too small for
algorithms requiring alignments (that is, crypto hardware requiring
alignments). As a result, the former in the following your logic
doesn't happens for most of us. Your logic is:

=
It's used to make the context aligned so that for most algorithms we
can get to the context without going through ALIGN_PTR. Only
algorithms requiring alignments bigger than that offered by kmalloc
would have to use ALIGN_PTR.
=

The former preferable path (algorithms requiring alignments are
smaller than the minimum alignment guaranteed by kmalloc) happens only
on some powerpc, arm, and mips architectures. Do I misunderstand
something?

If you put a hack in __crypto_alloc_tfm and crypto_free_tfm to return
aligned tmf to algorithms (and use aligned attribute for __crt_ctx),
then the your logic would makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
