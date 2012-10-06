Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 980C16B0062
	for <linux-mm@kvack.org>; Sat,  6 Oct 2012 20:00:05 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so3381617oag.14
        for <linux-mm@kvack.org>; Sat, 06 Oct 2012 17:00:04 -0700 (PDT)
Message-ID: <5070C5F7.8030302@gmail.com>
Date: Sun, 07 Oct 2012 07:59:51 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: memmap_init_zone() performance improvement
References: <1349276174-8398-1-git-send-email-mike.yoknis@hp.com>
In-Reply-To: <1349276174-8398-1-git-send-email-mike.yoknis@hp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Yoknis <mike.yoknis@hp.com>
Cc: mgorman@suse.de, mingo@redhat.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, mmarek@suse.cz, tglx@linutronix.de, hpa@zytor.com, arnd@arndb.de, sam@ravnborg.org, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/03/2012 10:56 PM, Mike Yoknis wrote:
> memmap_init_zone() loops through every Page Frame Number (pfn),
> including pfn values that are within the gaps between existing
> memory sections.  The unneeded looping will become a boot
> performance issue when machines configure larger memory ranges
> that will contain larger and more numerous gaps.
>
> The code will skip across invalid sections to reduce the
> number of loops executed.

looks reasonable to me.

>
> Signed-off-by: Mike Yoknis <mike.yoknis@hp.com>
> ---
>   arch/x86/include/asm/mmzone_32.h     |    2 ++
>   arch/x86/include/asm/page_32.h       |    1 +
>   arch/x86/include/asm/page_64_types.h |    3 ++-
>   include/asm-generic/page.h           |    1 +
>   include/linux/mmzone.h               |    6 ++++++
>   mm/page_alloc.c                      |    5 ++++-
>   6 files changed, 16 insertions(+), 2 deletions(-)
>
> diff --git a/arch/x86/include/asm/mmzone_32.h b/arch/x86/include/asm/mmzone_32.h
> index eb05fb3..73c5c74 100644
> --- a/arch/x86/include/asm/mmzone_32.h
> +++ b/arch/x86/include/asm/mmzone_32.h
> @@ -48,6 +48,8 @@ static inline int pfn_to_nid(unsigned long pfn)
>   #endif
>   }
>   
> +#define next_pfn_try(pfn)	((pfn)+1)
> +
>   static inline int pfn_valid(int pfn)
>   {
>   	int nid = pfn_to_nid(pfn);
> diff --git a/arch/x86/include/asm/page_32.h b/arch/x86/include/asm/page_32.h
> index da4e762..e2c4cfc 100644
> --- a/arch/x86/include/asm/page_32.h
> +++ b/arch/x86/include/asm/page_32.h
> @@ -19,6 +19,7 @@ extern unsigned long __phys_addr(unsigned long);
>   
>   #ifdef CONFIG_FLATMEM
>   #define pfn_valid(pfn)		((pfn) < max_mapnr)
> +#define next_pfn_try(pfn)	((pfn)+1)
>   #endif /* CONFIG_FLATMEM */
>   
>   #ifdef CONFIG_X86_USE_3DNOW
> diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
> index 320f7bb..02d82e5 100644
> --- a/arch/x86/include/asm/page_64_types.h
> +++ b/arch/x86/include/asm/page_64_types.h
> @@ -69,7 +69,8 @@ extern void init_extra_mapping_wb(unsigned long phys, unsigned long size);
>   #endif	/* !__ASSEMBLY__ */
>   
>   #ifdef CONFIG_FLATMEM
> -#define pfn_valid(pfn)          ((pfn) < max_pfn)
> +#define pfn_valid(pfn)		((pfn) < max_pfn)
> +#define next_pfn_try(pfn)	((pfn)+1)
>   #endif
>   
>   #endif /* _ASM_X86_PAGE_64_DEFS_H */
> diff --git a/include/asm-generic/page.h b/include/asm-generic/page.h
> index 37d1fe2..316200d 100644
> --- a/include/asm-generic/page.h
> +++ b/include/asm-generic/page.h
> @@ -91,6 +91,7 @@ extern unsigned long memory_end;
>   #endif
>   
>   #define pfn_valid(pfn)		((pfn) >= ARCH_PFN_OFFSET && ((pfn) - ARCH_PFN_OFFSET) < max_mapnr)
> +#define next_pfn_try(pfn)	((pfn)+1)
>   
>   #define	virt_addr_valid(kaddr)	(((void *)(kaddr) >= (void *)PAGE_OFFSET) && \
>   				((void *)(kaddr) < (void *)memory_end))
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index f7d88ba..04d3c39 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1166,6 +1166,12 @@ static inline int pfn_valid(unsigned long pfn)
>   		return 0;
>   	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
>   }
> +
> +static inline unsigned long next_pfn_try(unsigned long pfn)
> +{
> +	/* Skip entire section, because all of it is invalid. */
> +	return section_nr_to_pfn(pfn_to_section_nr(pfn) + 1);
> +}
>   #endif
>   
>   static inline int pfn_present(unsigned long pfn)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 5b6b6b1..dd2af8b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3798,8 +3798,11 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>   		 * exist on hotplugged memory.
>   		 */
>   		if (context == MEMMAP_EARLY) {
> -			if (!early_pfn_valid(pfn))
> +			if (!early_pfn_valid(pfn)) {
> +				pfn = next_pfn_try(pfn);
> +				pfn--;
>   				continue;
> +			}
>   			if (!early_pfn_in_nid(pfn, nid))
>   				continue;
>   		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
