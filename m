Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1F15F6B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 15:00:54 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id h4-v6so17212675qtp.7
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:00:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o14si2512932qtr.110.2018.10.31.12.00.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 12:00:51 -0700 (PDT)
Date: Wed, 31 Oct 2018 15:00:47 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: __HAVE_ARCH_PTE_DEVMAP - bug or intended behaviour?
Message-ID: <20181031190047.GA5148@redhat.com>
References: <9cf5c075-c83f-0915-99ef-b2aa59eca685@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9cf5c075-c83f-0915-99ef-b2aa59eca685@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, dan.j.williams@intel.com

On Wed, Oct 31, 2018 at 05:08:23PM +0000, Robin Murphy wrote:
> Hi mm folks,
> 
> I'm looking at ZONE_DEVICE support for arm64, and trying to make sense of a
> build failure has led me down the rabbit hole of pfn_t.h, and specifically
> __HAVE_ARCH_PTE_DEVMAP in this first instance.
> 
> The failure itself is a link error in remove_migration_pte() due to a
> missing definition of pte_mkdevmap(), but I'm a little confused at the fact
> that it's explicitly declared without a definition, as if that breakage is
> deliberate.
> 
> So, is the !__HAVE_ARCH_PTE_DEVMAP case actually expected to work? If not,
> then it seems to me that the relevant code could just be gated by
> CONFIG_ZONE_DEVICE directly to remove the confusion. If it is, though, then
> what should the generic definitions of p??_mkdevmap() be? I guess either way
> I still need to figure out the implications of _PAGE_DEVMAP at the arch end
> and whether/how arm64 should implement it, but given this initial hurdle
> it's not clear exactly where to go next.

AFAIR you can get ZONE_DEVICE without PTE_DEVMAP, PTE_DEVMAP is an
optimization for pte_devmap() test ie being able to only have to
look at pte value to determine if it is a pte pointing to a ZONE_DEVICE
page versus needing to lookup the struct page.

As all architecture so far all have PTE_DEVMAP it might very well
be that the !_HAVE_ARCH_PTE_DEVMAP case is broken (either from the
start or because of changes made since it was added). It kind of
looks broken at least when i glance at it now (ie the default
pte_devmap() should lookup struct page and check if it is a ZONE
DEVICE page).

So your life will be easier if you can do __HAVE_ARCH_PTE_DEVMAP
as you will not need to debug the !__HAVE_ARCH_PTE_DEVMAP case.


> Tangentially, is it also right that is_device_{public,private}_page() can
> still get non-stub definitions even with CONFIG_DEVICE_{PUBLIC,PRIVATE}
> disabled? As it happens, the patch below is enough to dodge the build
> failure for my configuration (i.e. CONFIG_FS_DAX && !CONFIG_HMM) by
> optimising the offending call away, however I'm not sure I'd want to rely on
> that; conceptually, though, it does still seem like it might be appropriate.

Yeah seems like a good idea, the combinatorial config options
explosion is painful. Can gcc optimize:

static inline bool is_device_public_page(const struct page *page)
{
	if (IS_ENABLED(CONFIG_DEVICE_PUBLIC))
		return is_zone_device_page(page) &&
			page->pgmap->type == MEMORY_DEVICE_PUBLIC;
	return false;
}

That would be nicer than #if/#else/#endif

Cheers,
Jerome


> Thanks,
> Robin.
> 
> ----->8-----
> From: Robin Murphy <robin.murphy@arm.com>
> Date: Wed, 31 Oct 2018 15:57:17 +0000
> Subject: [PATCH] mm: Clean up is_device_*_page() definitions
> 
> Refactor is_device_{public,private}_page() with is_pci_p2pdma_page()
> to make them all consistent in depending on their respective config
> options even when CONFIG_DEV_PAGEMAP_OPS is enabled for other reasons.
> This allows a little more compile-time optimisation as well as the
> conceptual and cosmetic cleanup.
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> ---
>  include/linux/mm.h | 52 ++++++++++++++++++++++------------------------
>  1 file changed, 25 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 1e52b8fd1685..15a49ed5436c 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -879,32 +879,6 @@ static inline bool put_devmap_managed_page(struct page
> *page)
>  	}
>  	return false;
>  }
> -
> -static inline bool is_device_private_page(const struct page *page)
> -{
> -	return is_zone_device_page(page) &&
> -		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
> -}
> -
> -static inline bool is_device_public_page(const struct page *page)
> -{
> -	return is_zone_device_page(page) &&
> -		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
> -}
> -
> -#ifdef CONFIG_PCI_P2PDMA
> -static inline bool is_pci_p2pdma_page(const struct page *page)
> -{
> -	return is_zone_device_page(page) &&
> -		page->pgmap->type == MEMORY_DEVICE_PCI_P2PDMA;
> -}
> -#else /* CONFIG_PCI_P2PDMA */
> -static inline bool is_pci_p2pdma_page(const struct page *page)
> -{
> -	return false;
> -}
> -#endif /* CONFIG_PCI_P2PDMA */
> -
>  #else /* CONFIG_DEV_PAGEMAP_OPS */
>  static inline void dev_pagemap_get_ops(void)
>  {
> @@ -918,22 +892,46 @@ static inline bool put_devmap_managed_page(struct page
> *page)
>  {
>  	return false;
>  }
> +#endif /* CONFIG_DEV_PAGEMAP_OPS */
> 
> +#if defined(CONFIG_DEV_PAGEMAP_OPS) && defined(CONFIG_DEVICE_PRIVATE)
> +static inline bool is_device_private_page(const struct page *page)
> +{
> +	return is_zone_device_page(page) &&
> +		page->pgmap->type == MEMORY_DEVICE_PRIVATE;
> +}
> +#else
>  static inline bool is_device_private_page(const struct page *page)
>  {
>  	return false;
>  }
> +#endif
> 
> +#if defined(CONFIG_DEV_PAGEMAP_OPS) && defined(CONFIG_DEVICE_PUBLIC)
> +static inline bool is_device_public_page(const struct page *page)
> +{
> +	return is_zone_device_page(page) &&
> +		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
> +}
> +#else
>  static inline bool is_device_public_page(const struct page *page)
>  {
>  	return false;
>  }
> +#endif
> 
> +#if defined(CONFIG_DEV_PAGEMAP_OPS) && defined(CONFIG_PCI_P2PDMA)
> +static inline bool is_pci_p2pdma_page(const struct page *page)
> +{
> +	return is_zone_device_page(page) &&
> +		page->pgmap->type == MEMORY_DEVICE_PCI_P2PDMA;
> +}
> +#else
>  static inline bool is_pci_p2pdma_page(const struct page *page)
>  {
>  	return false;
>  }
> -#endif /* CONFIG_DEV_PAGEMAP_OPS */
> +#endif
> 
>  static inline void get_page(struct page *page)
>  {
> -- 
> 2.19.1.dirty
