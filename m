Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA89E6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 05:33:09 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u9so2162242wme.6
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 02:33:09 -0800 (PST)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id w5si14304622wrb.70.2017.03.03.02.33.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 02:33:08 -0800 (PST)
Received: by mail-wr0-x244.google.com with SMTP id u108so8809737wrb.2
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 02:33:08 -0800 (PST)
Date: Fri, 3 Mar 2017 11:33:04 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [RFC PATCH 11/12] staging: android: ion: Make Ion heaps
 selectable
Message-ID: <20170303103304.nxfn7zlccx24b3xq@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <1488491084-17252-12-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488491084-17252-12-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org

On Thu, Mar 02, 2017 at 01:44:43PM -0800, Laura Abbott wrote:
> 
> Currently, all heaps are compiled in all the time. In switching to
> a better platform model, let's allow these to be compiled out for good
> measure.
> 
> Signed-off-by: Laura Abbott <labbott@redhat.com>

I'm not the biggest fan of making everything Kconfig-selectable. And the
#ifdef stuff doesn't look all that pretty. If we'd also use this
opportunity to split each heap into their own file I think this patch here
would be a lot more useful.

Anyway, no real opinion from me on this, just an idea.
-Daniel

> ---
>  drivers/staging/android/ion/Kconfig    | 32 ++++++++++++++++++++
>  drivers/staging/android/ion/Makefile   |  8 +++--
>  drivers/staging/android/ion/ion_priv.h | 53 ++++++++++++++++++++++++++++++++--
>  3 files changed, 87 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/android/ion/Kconfig b/drivers/staging/android/ion/Kconfig
> index 0c91b2b..2e97990 100644
> --- a/drivers/staging/android/ion/Kconfig
> +++ b/drivers/staging/android/ion/Kconfig
> @@ -17,3 +17,35 @@ config ION_TEST
>  	  Choose this option to create a device that can be used to test the
>  	  kernel and device side ION functions.
>  
> +config ION_SYSTEM_HEAP
> +	bool "Ion system heap"
> +	depends on ION
> +	help
> +	  Choose this option to enable the Ion system heap. The system heap
> +	  is backed by pages from the buddy allocator. If in doubt, say Y.
> +
> +config ION_CARVEOUT_HEAP
> +	bool "Ion carveout heap support"
> +	depends on ION
> +	help
> +	  Choose this option to enable carveout heaps with Ion. Carveout heaps
> +	  are backed by memory reserved from the system. Allocation times are
> +	  typically faster at the cost of memory not being used. Unless you
> +	  know your system has these regions, you should say N here.
> +
> +config ION_CHUNK_HEAP
> +	bool "Ion chunk heap support"
> +	depends on ION
> +	help
> +          Choose this option to enable chunk heaps with Ion. This heap is
> +	  similar in function the carveout heap but memory is broken down
> +	  into smaller chunk sizes, typically corresponding to a TLB size.
> +	  Unless you know your system has these regions, you should say N here.
> +
> +config ION_CMA_HEAP
> +	bool "Ion CMA heap support"
> +	depends on ION && CMA
> +	help
> +	  Choose this option to enable CMA heaps with Ion. This heap is backed
> +	  by the Contiguous Memory Allocator (CMA). If your system has these
> +	  regions, you should say Y here.
> diff --git a/drivers/staging/android/ion/Makefile b/drivers/staging/android/ion/Makefile
> index 9457090..eef022b 100644
> --- a/drivers/staging/android/ion/Makefile
> +++ b/drivers/staging/android/ion/Makefile
> @@ -1,6 +1,8 @@
> -obj-$(CONFIG_ION) +=	ion.o ion-ioctl.o ion_heap.o \
> -			ion_page_pool.o ion_system_heap.o \
> -			ion_carveout_heap.o ion_chunk_heap.o ion_cma_heap.o
> +obj-$(CONFIG_ION) +=	ion.o ion-ioctl.o ion_heap.o
> +obj-$(CONFIG_ION_SYSTEM_HEAP) += ion_system_heap.o ion_page_pool.o
> +obj-$(CONFIG_ION_CARVEOUT_HEAP) += ion_carveout_heap.o
> +obj-$(CONFIG_ION_CHUNK_HEAP) += ion_chunk_heap.o
> +obj-$(CONFIG_ION_CMA_HEAP) += ion_cma_heap.o
>  obj-$(CONFIG_ION_TEST) += ion_test.o
>  ifdef CONFIG_COMPAT
>  obj-$(CONFIG_ION) += compat_ion.o
> diff --git a/drivers/staging/android/ion/ion_priv.h b/drivers/staging/android/ion/ion_priv.h
> index b09bc7c..6eafe0d 100644
> --- a/drivers/staging/android/ion/ion_priv.h
> +++ b/drivers/staging/android/ion/ion_priv.h
> @@ -369,21 +369,68 @@ size_t ion_heap_freelist_size(struct ion_heap *heap);
>   * heaps as appropriate.
>   */
>  
> +
>  struct ion_heap *ion_heap_create(struct ion_platform_heap *heap_data);
>  void ion_heap_destroy(struct ion_heap *heap);
> +
> +#ifdef CONFIG_ION_SYSTEM_HEAP
>  struct ion_heap *ion_system_heap_create(struct ion_platform_heap *unused);
>  void ion_system_heap_destroy(struct ion_heap *heap);
> -
>  struct ion_heap *ion_system_contig_heap_create(struct ion_platform_heap *heap);
>  void ion_system_contig_heap_destroy(struct ion_heap *heap);
> -
> +#else
> +static inline struct ion_heap * ion_system_heap_create(
> +	struct ion_platform_heap *unused)
> +{
> +	return ERR_PTR(-ENODEV);
> +}
> +static inline void ion_system_heap_destroy(struct ion_heap *heap) { }
> +
> +static inline struct ion_heap *ion_system_contig_heap_create(
> +	struct ion_platform_heap *heap)
> +{
> +	return ERR_PTR(-ENODEV);
> +}
> +
> +static inline void ion_system_contig_heap_destroy(struct ion_heap *heap) { }
> +#endif
> +
> +#ifdef CONFIG_ION_CARVEOUT_HEAP
>  struct ion_heap *ion_carveout_heap_create(struct ion_platform_heap *heap_data);
>  void ion_carveout_heap_destroy(struct ion_heap *heap);
> -
> +#else
> +static inline struct ion_heap *ion_carveout_heap_create(
> +	struct ion_platform_heap *heap_data)
> +{
> +	return ERR_PTR(-ENODEV);
> +}
> +static inline void ion_carveout_heap_destroy(struct ion_heap *heap) { }
> +#endif
> +
> +#ifdef CONFIG_ION_CHUNK_HEAP
>  struct ion_heap *ion_chunk_heap_create(struct ion_platform_heap *heap_data);
>  void ion_chunk_heap_destroy(struct ion_heap *heap);
> +#else
> +static inline struct ion_heap *ion_chunk_heap_create(
> +	struct ion_platform_heap *heap_data)
> +{
> +	return ERR_PTR(-ENODEV);
> +}
> +static inline void ion_chunk_heap_destroy(struct ion_heap *heap) { }
> +
> +#endif
> +
> +#ifdef CONFIG_ION_CMA_HEAP
>  struct ion_heap *ion_cma_heap_create(struct ion_platform_heap *data);
>  void ion_cma_heap_destroy(struct ion_heap *heap);
> +#else
> +static inline struct ion_heap *ion_cma_heap_create(
> +	struct ion_platform_heap *data)
> +{
> +	return ERR_PTR(-ENODEV);
> +}
> +static inline void ion_cma_heap_destroy(struct ion_heap *heap) { }
> +#endif
>  
>  /**
>   * functions for creating and destroying a heap pool -- allows you
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
