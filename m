Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id C60C06B0038
	for <linux-mm@kvack.org>; Sat, 15 Aug 2015 05:04:29 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so35731622wic.1
        for <linux-mm@kvack.org>; Sat, 15 Aug 2015 02:04:29 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t2si8983736wiy.89.2015.08.15.02.04.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Aug 2015 02:04:28 -0700 (PDT)
Date: Sat, 15 Aug 2015 11:04:26 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC PATCH 4/7] mm: register_dev_memmap()
Message-ID: <20150815090426.GE21033@lst.de>
References: <20150813031253.36913.29580.stgit@otcpl-skl-sds-2.jf.intel.com> <20150813035023.36913.56455.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150813035023.36913.56455.stgit@otcpl-skl-sds-2.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-kernel@vger.kernel.org, boaz@plexistor.com, riel@redhat.com, linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@linux.intel.com>, david@fromorbit.com, mingo@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, mgorman@suse.de, "H. Peter Anvin" <hpa@zytor.com>, ross.zwisler@linux.intel.com, torvalds@linux-foundation.org, hch@lst.de

>  #endif /* _LINUX_KMAP_PFN_H */
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8a4f24d7fdb0..07152a54b841 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -939,6 +939,7 @@ typedef struct {
>   * PFN_SG_CHAIN - pfn is a pointer to the next scatterlist entry
>   * PFN_SG_LAST - pfn references a page and is the last scatterlist entry
>   * PFN_DEV - pfn is not covered by system memmap
> + * PFN_MAP - pfn is covered by a device specific memmap
>   */
>  enum {
>  	PFN_MASK = (1UL << PAGE_SHIFT) - 1,
> @@ -949,6 +950,7 @@ enum {
>  #else
>  	PFN_DEV = 0,
>  #endif
> +	PFN_MAP = (1UL << 3),
>  };
>  
>  static inline __pfn_t pfn_to_pfn_t(unsigned long pfn, unsigned long flags)
> @@ -965,7 +967,7 @@ static inline __pfn_t phys_to_pfn_t(dma_addr_t addr, unsigned long flags)
>  
>  static inline bool __pfn_t_has_page(__pfn_t pfn)
>  {
> -	return (pfn.val & PFN_DEV) == 0;
> +	return (pfn.val & PFN_DEV) == 0 || (pfn.val & PFN_MAP) == PFN_MAP;

Shouldn't we simply not set the PFN_DEV flag instead of needing another
one to cancel it out?

I also wonder if it might be better to not require the __pfn_t and
SG rework patches before this series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
