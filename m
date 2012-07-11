Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E803A6B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 21:18:17 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1366989pbb.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 18:18:17 -0700 (PDT)
Date: Tue, 10 Jul 2012 18:18:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/slob: avoid type warning about alignment value
In-Reply-To: <201207102055.35278.arnd@arndb.de>
Message-ID: <alpine.DEB.2.00.1207101815580.684@chino.kir.corp.google.com>
References: <201207102055.35278.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Tue, 10 Jul 2012, Arnd Bergmann wrote:

> diff --git a/mm/slob.c b/mm/slob.c
> index 95d1c7d..51d6a27 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -426,7 +426,7 @@ out:
>  void *__kmalloc_node(size_t size, gfp_t gfp, int node)
>  {
>  	unsigned int *m;
> -	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
> +	int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
>  	void *ret;
>  
>  	gfp &= gfp_allowed_mask;
> @@ -479,7 +479,7 @@ void kfree(const void *block)
>  
>  	sp = virt_to_page(block);
>  	if (PageSlab(sp)) {
> -		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
> +		int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
>  		unsigned int *m = (unsigned int *)(block - align);
>  		slob_free(m, *m + align);
>  	} else
> @@ -498,7 +498,7 @@ size_t ksize(const void *block)
>  
>  	sp = virt_to_page(block);
>  	if (PageSlab(sp)) {
> -		int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
> +		int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
>  		unsigned int *m = (unsigned int *)(block - align);
>  		return SLOB_UNITS(*m) * SLOB_UNIT;
>  	} else

Wouldn't it be better to avoid this problem more generally by casting the 
__alignof__ for ARCH_{KMALLOC,SLAB}_MINALIGN to int in slab.h?  All 
architectures that define these themselves will be using plain integers, 
the problem is __alignof__ returning size_t when undefined.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
