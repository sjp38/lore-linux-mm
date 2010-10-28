Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6A2598D0004
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 01:18:10 -0400 (EDT)
Subject: Re: [PATCH] parisc: fix compile failure with kmap_atomic changes
Date: Thu, 28 Oct 2010 01:18:06 -0400 (EDT)
From: "John David Anglin" <dave@hiauly1.hia.nrc.ca>
In-Reply-To: <1288204547.6886.23.camel@mulgrave.site> from "James Bottomley" at Oct 27, 2010 01:35:47 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20101028051807.539484D30@hiauly1.hia.nrc.ca>
Sender: owner-linux-mm@kvack.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-parisc@vger.kernel.org, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

Signed-off-by: John David Anglin  <dave.anglin@nrc-cnrc.gc.ca>

Sent effectively the same change to parisc-linux list months ago...

> This commit:
> 
> commit 3e4d3af501cccdc8a8cca41bdbe57d54ad7e7e73
> Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date:   Tue Oct 26 14:21:51 2010 -0700
> 
>     mm: stack based kmap_atomic()
> 
> overlooked the fact that parisc uses kmap as a coherence mechanism, so
> even though we have no highmem, we do need to supply our own versions of
> kmap (and atomic).  This patch converts the parisc kmap to the form
> which is needed to keep it compiling (it's a simple prototype and name
> change).
> 
> Signed-off-by: James Bottomley <James.Bottomley@suse.de>
> 
> ---
> 
> diff --git a/arch/parisc/include/asm/cacheflush.h b/arch/parisc/include/asm/cacheflush.h
> index dba11ae..f388a85 100644
> --- a/arch/parisc/include/asm/cacheflush.h
> +++ b/arch/parisc/include/asm/cacheflush.h
> @@ -126,20 +126,20 @@ static inline void *kmap(struct page *page)
>  
>  #define kunmap(page)			kunmap_parisc(page_address(page))
>  
> -static inline void *kmap_atomic(struct page *page, enum km_type idx)
> +static inline void *__kmap_atomic(struct page *page)
>  {
>  	pagefault_disable();
>  	return page_address(page);
>  }
>  
> -static inline void kunmap_atomic_notypecheck(void *addr, enum km_type idx)
> +static inline void __kunmap_atomic(void *addr)
>  {
>  	kunmap_parisc(addr);
>  	pagefault_enable();
>  }
>  
> -#define kmap_atomic_prot(page, idx, prot)	kmap_atomic(page, idx)
> -#define kmap_atomic_pfn(pfn, idx)	kmap_atomic(pfn_to_page(pfn), (idx))
> +#define kmap_atomic_prot(page, prot)	kmap_atomic(page)
> +#define kmap_atomic_pfn(pfn)	kmap_atomic(pfn_to_page(pfn))
>  #define kmap_atomic_to_page(ptr)	virt_to_page(ptr)
>  #endif
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-parisc" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
J. David Anglin                                  dave.anglin@nrc-cnrc.gc.ca
National Research Council of Canada              (613) 990-0752 (FAX: 952-6602)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
