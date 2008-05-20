Date: Tue, 20 May 2008 02:31:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] block: use ARCH_KMALLOC_MINALIGN as the default dma
 pad mask
Message-Id: <20080520023129.2f921f24.akpm@linux-foundation.org>
In-Reply-To: <1211259514-9131-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1211259514-9131-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	<1211259514-9131-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, tsbogend@alpha.franken.de, bzolnier@gmail.com, James.Bottomley@HansenPartnership.com, jeff@garzik.org, davem@davemloft.net, linux-mm@kvack.org, Herbert Xu <herbert@gondor.apana.org.au>
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008 13:58:31 +0900 FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> This sets the default dma pad mask to ARCH_KMALLOC_MINALIGN in
> blk_queue_make_request(). It affects only non-coherent platforms.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Cc: Jens Axboe <jens.axboe@oracle.com>
> ---
>  block/blk-settings.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/block/blk-settings.c b/block/blk-settings.c
> index 8dd8641..781d1bf 100644
> --- a/block/blk-settings.c
> +++ b/block/blk-settings.c
> @@ -84,6 +84,11 @@ EXPORT_SYMBOL(blk_queue_softirq_done);
>   **/
>  void blk_queue_make_request(struct request_queue *q, make_request_fn *mfn)
>  {
> +#ifndef ARCH_KMALLOC_MINALIGN
> +#define ARCH_KMALLOC_MINALIGN 1
> +#endif
> +	unsigned int min_align = ARCH_KMALLOC_MINALIGN;
> +
>  	/*
>  	 * set defaults
>  	 */
> @@ -98,6 +103,7 @@ void blk_queue_make_request(struct request_queue *q, make_request_fn *mfn)
>  	blk_queue_max_sectors(q, SAFE_MAX_SECTORS);
>  	blk_queue_hardsect_size(q, 512);
>  	blk_queue_dma_alignment(q, 511);
> +	blk_queue_dma_pad(q, min_align - 1);
>  	blk_queue_congestion_threshold(q);
>  	q->nr_batching = BLK_BATCH_REQ;

urgh.  This ARCH_KMALLOC_MINALIGN thing has the smell of an expedient
hack which is now growing.

Look at what crypto did (which seems to be a lot worse):

/*
 * The macro CRYPTO_MINALIGN_ATTR (along with the void * type in the actual
 * declaration) is used to ensure that the crypto_tfm context structure is
 * aligned correctly for the given architecture so that there are no alignment
 * faults for C data types.  In particular, this is required on platforms such
 * as arm where pointers are 32-bit aligned but there are data types such as
 * u64 which require 64-bit alignment.
 */
#if defined(ARCH_KMALLOC_MINALIGN)
#define CRYPTO_MINALIGN ARCH_KMALLOC_MINALIGN
#elif defined(ARCH_SLAB_MINALIGN)
#define CRYPTO_MINALIGN ARCH_SLAB_MINALIGN
#else
#define CRYPTO_MINALIGN __alignof__(unsigned long long)
#endif

So here you're using it for "dma aligment" whereas crypto is using it
(or ARCH_SLAB_MINALIGN!) for "cpu 64-bit alignment".


Why does ARCH_KMALLOC_MINALIGN even exist?  What is its mandate?  Sigh.


It's not really related to your patch (although your patch compounds
the problem a little).  But we should sit down and work out what we
actually want to do here.  Something like:

In each architecture's arch/foo/Kconfig, define

	CONFIG_ARCH_DMA_ALIGN

and

	CONFIG_ARCH_64BIT_POINTER_ALIGN

and then use them.  Note that these have nothing to do with each other,
as far as I can tell.

Which leaves the question: "what should slab use"?  Maybe
CONFIG_ARCH_DMA_ALIGN?  But that depends what ARCH_KMALLOC_MINALIGN is
supposed to exist for.

ick.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
