Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default
 dma pad mask
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20080521.181945.27326326.davem@davemloft.net>
References: <20080521131811.GA20212@gondor.apana.org.au>
	<20080522100712S.tomof@acm.org>
	<20080521.181945.27326326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20080522103221C.fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 22 May 2008 10:32:21 +0900
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@davemloft.net
Cc: fujita.tomonori@lab.ntt.co.jp, herbert@gondor.apana.org.au, akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 18:19:45 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Date: Thu, 22 May 2008 10:14:12 +0900
> 
> > On Wed, 21 May 2008 21:18:11 +0800
> > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > 
> > > On Wed, May 21, 2008 at 09:46:24PM +0900, FUJITA Tomonori wrote:
> > > >
> > > > No, you misunderstand my question. I meant, software algorithms don't
> > > > need ARCH_KMALLOC_MINALIGN alignment for __crt_ctx and if we are fine
> > > > with using the ALIGN hack for crypto hardware every time (like
> > > > aes_ctx_common), crypto doesn't need ARCH_KMALLOC_MINALIGN alignment
> > > > for __crt_ctx. Is this right?
> > > 
> > > The padlock isn't the only hardware device that will require
> > > such alignment.  Now that we have the async interface there will
> > > be more.
> > 
> > Ok, so it's all about crypto hardware requirement. In other words, if
> > we accept for potential performance drop of crypto hardware, crypto
> > can drop this alignment.
> 
> It sounds to me that Herbert is saying that the VIA crypto hardware
> will malfunction if not given an aligned address, rather than simply
> go more slowly.

I understand that.

VIA crypto driver has the following code to get proper alignment:

static inline struct aes_ctx *aes_ctx_common(void *ctx)
{
	unsigned long addr = (unsigned long)ctx;
	unsigned long align = PADLOCK_ALIGNMENT;

	if (align <= crypto_tfm_ctx_alignment())
		align = 1;
	return (struct aes_ctx *)ALIGN(addr, align);
}

What he insists is:

When crypto hardware alignment is smaller than the minimum alignment
guaranteed by kmalloc, the above function is faster since ALIGN is
nullified. That's why crypto uses the minimum alignment guaranteed by
kmalloc.


What I asking is:

On most architectures, the minimum alignment guaranteed by kmalloc is
too small (8 bytes). This ideal story doesn't happen to most of us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
