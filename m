Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 6E59C6B006C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 14:39:41 -0500 (EST)
Message-ID: <51100E79.9080101@wwwdotorg.org>
Date: Mon, 04 Feb 2013 12:39:37 -0700
From: Stephen Warren <swarren@wwwdotorg.org>
MIME-Version: 1.0
Subject: Re: next-20130204 - bisected slab problem to "slab: Common constants
 for kmalloc boundaries"
References: <510FE051.7080107@imgtec.com>
In-Reply-To: <510FE051.7080107@imgtec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Hogan <james.hogan@imgtec.com>, linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On 02/04/2013 09:22 AM, James Hogan wrote:
> Hi,
> 
> I've hit boot problems in next-20130204 on Meta:
> 
> META213-Thread0 DSP [LogF] kobject (4fc03980): tried to init an initialized object, something is seriously wrong.
> META213-Thread0 DSP [LogF] 
> META213-Thread0 DSP [LogF] Call trace: 
> META213-Thread0 DSP [LogF] [<4000888c>] _show_stack+0x68/0x7c
> META213-Thread0 DSP [LogF] [<400088b4>] _dump_stack+0x14/0x28
> META213-Thread0 DSP [LogF] [<40103794>] _kobject_init+0x58/0x9c
> META213-Thread0 DSP [LogF] [<40103810>] _kobject_create+0x38/0x64
> META213-Thread0 DSP [LogF] [<40103eac>] _kobject_create_and_add+0x14/0x8c
> META213-Thread0 DSP [LogF] [<40190ac4>] _mnt_init+0xd8/0x220
> META213-Thread0 DSP [LogF] [<40190508>] _vfs_caches_init+0xb0/0x160
...
> I've bisected it to the following commit:
> 
> commit 95a05b428cc675694321c8f762591984f3fd2b1e
> Author: Christoph Lameter <cl@linux.com>
> Date:   Thu Jan 10 19:14:19 2013 +0000
> 
>     slab: Common constants for kmalloc boundaries
>     
>     Standardize the constants that describe the smallest and largest
>     object kept in the kmalloc arrays for SLAB and SLUB.
>     
>     Differentiate between the maximum size for which a slab cache is used
>     (KMALLOC_MAX_CACHE_SIZE) and the maximum allocatable size
>     (KMALLOC_MAX_SIZE, KMALLOC_MAX_ORDER).
>     
>     Signed-off-by: Christoph Lameter <cl@linux.com>
>     Signed-off-by: Pekka Enberg <penberg@kernel.org>

I see the same problem on ARM. I believe it's because of the changes to
the calculation of MALLOC_SHIFT_LOW.

The old code was:

#if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
#define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
#else
#ifdef CONFIG_SLAB
#define KMALLOC_MIN_SIZE 32
#else
#define KMALLOC_MIN_SIZE 8
#endif
#endif

#define KMALLOC_SHIFT_LOW ilog2(KMALLOC_MIN_SIZE)

Here, KMALLOC_SHIFT_LOW and KMALLOC_MIN_SIZE are always consistent/related.

The new code is:

#define KMALLOC_SHIFT_LOW	5
...
#if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
#define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
#else
#define KMALLOC_MIN_SIZE (1 << KMALLOC_SHIFT_LOW)
#endif

Here, if defined(ARCH_DMA_MINALIGN), then KMALLOC_MIN_SIZE isn't
relative-to/derived-from KMALLOC_SHIFT_LOW, so the two may become
inconsistent.

On my ARM system at least, CONFIG_ARM_L1_CACHE_SHIFT_6 is set since I
have an ARMv7 CPU (see arch/arm/mm/Kconfig), which causes
CONFIG_ARM_L1_CACHE_SHIFT=6, then:

> arch/arm/include/asm/cache.h:7:#define L1_CACHE_SHIFT		CONFIG_ARM_L1_CACHE_SHIFT
> arch/arm/include/asm/cache.h:8:#define L1_CACHE_BYTES		(1 << L1_CACHE_SHIFT)
> arch/arm/include/asm/cache.h:17:#define ARCH_DMA_MINALIGN	L1_CACHE_BYTES

... hence that case triggers.

I also see that in most parts of the patch, SLUB_PAGE_SHIFT was replaced
with (KMALLOC_SHIFT_HIGH + 1), or equivalently tests were changed from <
to <=:

> -		size <= SLUB_MAX_SIZE && !(flags & SLUB_DMA)) {
> +		size <= KMALLOC_MAX_CACHE_SIZE && !(flags & SLUB_DMA)) {

However, the following doesn't seem to have that adjustment:

> diff --git a/mm/slub.c b/mm/slub.c
> index ba2ca53..d0f72ee 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2775,7 +2775,7 @@ init_kmem_cache_node(struct kmem_cache_node *n)
>  static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
>  {
>  	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
> -			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache_cpu));
> +			KMALLOC_SHIFT_HIGH * sizeof(struct kmem_cache_cpu));

Should that also be (KMALLOC_SHIFT_HIGH + 1)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
