Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default
 dma pad mask
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20080521122218.GA19849@gondor.apana.org.au>
References: <20080521112554.GA19558@gondor.apana.org.au>
	<20080521210956C.tomof@acm.org>
	<20080521122218.GA19849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20080521214624Y.fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 21 May 2008 21:46:24 +0900
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: herbert@gondor.apana.org.au
Cc: fujita.tomonori@lab.ntt.co.jp, akpm@linux-foundation.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 May 2008 20:22:18 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, May 21, 2008 at 09:09:58PM +0900, FUJITA Tomonori wrote:
> >
> > OK, thanks. So it's about hardware requrement. Let me make sure if I
> > understand crypto alignment issue.
> > 
> > __crt_ctx needs ARCH_KMALLOC_MINALIGN alignment only because of crypto
> > hardware. If I misunderstand it, can you answer my question in the
> > previous mail (it's the part that you cut)? That is, why does
> > __crt_ctx need ARCH_KMALLOC_MINALIGN alignment with software
> > algorithms.
> 
> Because the same structure is used for all algorithms!

No, you misunderstand my question. I meant, software algorithms don't
need ARCH_KMALLOC_MINALIGN alignment for __crt_ctx and if we are fine
with using the ALIGN hack for crypto hardware every time (like
aes_ctx_common), crypto doesn't need ARCH_KMALLOC_MINALIGN alignment
for __crt_ctx. Is this right?


> 
> Why is this so hard to understand?

Because there are few architecture that defines
ARCH_KMALLOC_MINALIGN. So if crypto hardware needs alignement, it's
likely the hardware alignement is larger than __crt_ctx alignment. As
a result, you have to use ALIGN_PTR. So It's hard to understand using
ARCH_KMALLOC_MINALIGN here. I don't know about crypto hardware, but I
wonder if we can use a static alignment like 64 bytes here, which may
work for most of crypto hardware. Or if there are not many users of
crypto hardware, it may be fine to use ALIGN_PTR for the hardware.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
