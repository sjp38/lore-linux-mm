Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id DA3356B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 21:54:34 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id q3so1090056pag.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 18:54:34 -0800 (PST)
Received: from smtp754.redcondor.net (smtp754.redcondor.net. [208.80.206.54])
        by mx.google.com with ESMTPS id h84si9187131pfd.171.2016.02.10.18.54.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 10 Feb 2016 18:54:33 -0800 (PST)
Subject: Re: [PATCH] mm: fix pfn_t vs highmem
References: <20160211021807.37532.78501.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Julian Margetson <runaway@candw.ms>
Message-ID: <56BBF7D1.7080304@candw.ms>
Date: Wed, 10 Feb 2016 22:54:09 -0400
MIME-Version: 1.0
In-Reply-To: <20160211021807.37532.78501.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Stuart Foster <smf.linux@ntlworld.com>

On 2/10/2016 10:18 PM, Dan Williams wrote:
> The pfn_t type uses an unsigned long to store a pfn + flags value.  On a
> 64-bit platform the upper 12 bits of an unsigned long are never used for
> storing the value of a pfn.  However, this is not true on highmem
> platforms, all 32-bits of a pfn value are used to address a 44-bit
> physical address space.  A pfn_t needs to store a 64-bit value.
>
> Reported-by: Stuart Foster <smf.linux@ntlworld.com>
> Reported-by: Julian Margetson <runaway@candw.ms>
> Cc: <dri-devel@lists.freedesktop.org>
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=112211
> Fixes: 01c8f1c44b83 ("mm, dax, gpu: convert vm_insert_mixed to pfn_t")
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>   include/linux/pfn.h   |    2 +-
>   include/linux/pfn_t.h |   19 +++++++++----------
>   kernel/memremap.c     |    2 +-
>   3 files changed, 11 insertions(+), 12 deletions(-)
>
> diff --git a/include/linux/pfn.h b/include/linux/pfn.h
> index 2d8e49711b63..1132953235c0 100644
> --- a/include/linux/pfn.h
> +++ b/include/linux/pfn.h
> @@ -10,7 +10,7 @@
>    * backing is indicated by flags in the high bits of the value.
>    */
>   typedef struct {
> -	unsigned long val;
> +	u64 val;
>   } pfn_t;
>   #endif
>   
> diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
> index 37448ab5fb5c..94994810c7c0 100644
> --- a/include/linux/pfn_t.h
> +++ b/include/linux/pfn_t.h
> @@ -9,14 +9,13 @@
>    * PFN_DEV - pfn is not covered by system memmap by default
>    * PFN_MAP - pfn has a dynamic page mapping established by a device driver
>    */
> -#define PFN_FLAGS_MASK (((unsigned long) ~PAGE_MASK) \
> -		<< (BITS_PER_LONG - PAGE_SHIFT))
> -#define PFN_SG_CHAIN (1UL << (BITS_PER_LONG - 1))
> -#define PFN_SG_LAST (1UL << (BITS_PER_LONG - 2))
> -#define PFN_DEV (1UL << (BITS_PER_LONG - 3))
> -#define PFN_MAP (1UL << (BITS_PER_LONG - 4))
> -
> -static inline pfn_t __pfn_to_pfn_t(unsigned long pfn, unsigned long flags)
> +#define PFN_FLAGS_MASK (((u64) ~PAGE_MASK) << (BITS_PER_LONG_LONG - PAGE_SHIFT))
> +#define PFN_SG_CHAIN (1ULL << (BITS_PER_LONG_LONG - 1))
> +#define PFN_SG_LAST (1ULL << (BITS_PER_LONG_LONG - 2))
> +#define PFN_DEV (1ULL << (BITS_PER_LONG_LONG - 3))
> +#define PFN_MAP (1ULL << (BITS_PER_LONG_LONG - 4))
> +
> +static inline pfn_t __pfn_to_pfn_t(unsigned long pfn, u64 flags)
>   {
>   	pfn_t pfn_t = { .val = pfn | (flags & PFN_FLAGS_MASK), };
>   
> @@ -29,7 +28,7 @@ static inline pfn_t pfn_to_pfn_t(unsigned long pfn)
>   	return __pfn_to_pfn_t(pfn, 0);
>   }
>   
> -extern pfn_t phys_to_pfn_t(phys_addr_t addr, unsigned long flags);
> +extern pfn_t phys_to_pfn_t(phys_addr_t addr, u64 flags);
>   
>   static inline bool pfn_t_has_page(pfn_t pfn)
>   {
> @@ -87,7 +86,7 @@ static inline pmd_t pfn_t_pmd(pfn_t pfn, pgprot_t pgprot)
>   #ifdef __HAVE_ARCH_PTE_DEVMAP
>   static inline bool pfn_t_devmap(pfn_t pfn)
>   {
> -	const unsigned long flags = PFN_DEV|PFN_MAP;
> +	const u64 flags = PFN_DEV|PFN_MAP;
>   
>   	return (pfn.val & flags) == flags;
>   }
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 3427cca5a2a6..b04ea2f5fbfe 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -152,7 +152,7 @@ void devm_memunmap(struct device *dev, void *addr)
>   }
>   EXPORT_SYMBOL(devm_memunmap);
>   
> -pfn_t phys_to_pfn_t(phys_addr_t addr, unsigned long flags)
> +pfn_t phys_to_pfn_t(phys_addr_t addr, u64 flags)
>   {
>   	return __pfn_to_pfn_t(addr >> PAGE_SHIFT, flags);
>   }
>
>
>

Thanks.This fixes my issue.
Tested-by:  Julian Margetson <runaway@candw.ms>

Julian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
