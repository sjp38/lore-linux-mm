Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id BFAE56B0070
	for <linux-mm@kvack.org>; Wed,  6 May 2015 19:30:26 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so22722978pac.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 16:30:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v3si358353pdr.19.2015.05.06.16.30.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 16:30:25 -0700 (PDT)
Date: Wed, 6 May 2015 16:30:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] x86, mirror: x86 enabling - find mirrored memory
 ranges
Message-Id: <20150506163024.ba4a8eddc8031e5d32b061ba@linux-foundation.org>
In-Reply-To: <b28413d7e10a07406d87f8b48c7ea54e53273691.1430772743.git.tony.luck@intel.com>
References: <cover.1430772743.git.tony.luck@intel.com>
	<b28413d7e10a07406d87f8b48c7ea54e53273691.1430772743.git.tony.luck@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 3 Feb 2015 14:40:19 -0800 Tony Luck <tony.luck@intel.com> wrote:

> UEFI GetMemoryMap() uses a new attribute bit to mark mirrored memory
> address ranges. See UEFI 2.5 spec pages 157-158:
> 
>   http://www.uefi.org/sites/default/files/resources/UEFI%202_5.pdf
> 
> On EFI enabled systems scan the memory map and tell memblock about
> any mirrored ranges.
> 
> ...
>
> --- a/arch/x86/platform/efi/efi.c
> +++ b/arch/x86/platform/efi/efi.c
> @@ -117,6 +117,27 @@ void efi_get_time(struct timespec *now)
>  	now->tv_nsec = 0;
>  }
>  
> +void __init efi_find_mirror(void)
> +{
> +	void *p;
> +	unsigned long long mirror_size = 0, total_size = 0;
> +
> +	for (p = memmap.map; p < memmap.map_end; p += memmap.desc_size) {
> +		efi_memory_desc_t *md = p;
> +		unsigned long long start = md->phys_addr;
> +		unsigned long long size = md->num_pages << EFI_PAGE_SHIFT;

efi_memory_desc_t uses u64 for all this stuff.  Was there a reason for
using ull instead?

> +		total_size += size;
> +		if (md->attribute & EFI_MEMORY_MORE_RELIABLE) {
> +			memblock_mark_mirror(start, size);
> +			mirror_size += size;
> +		}
> +	}
> +	if (mirror_size)
> +		pr_info("Memory: %lldM/%lldM mirrored memory\n",
> +			mirror_size>>20, total_size>>20);
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
