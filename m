Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A62142806E4
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 12:28:33 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id z132so219430wmg.7
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 09:28:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n17si4130181wrb.347.2017.08.22.09.28.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Aug 2017 09:28:32 -0700 (PDT)
Date: Tue, 22 Aug 2017 18:28:26 +0200
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCHv5 01/19] mm/sparsemem: Allocate mem_section at runtime
 for SPARSEMEM_EXTREME
Message-ID: <20170822162826.umma52xs6qotz2l2@pd.tnic>
References: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
 <20170821152916.40124-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170821152916.40124-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 21, 2017 at 06:28:58PM +0300, Kirill A. Shutemov wrote:
> Size of mem_section array depends on size of physical address space.
> 
> In preparation for boot-time switching between paging modes on x86-64
> we need to make allocation of mem_section dynamic.
> 
> The patch allocates the array on the first call to
> sparse_memory_present_with_active_regions().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/mmzone.h |  6 +++++-
>  mm/page_alloc.c        | 10 ++++++++++
>  mm/sparse.c            | 17 +++++++++++------
>  3 files changed, 26 insertions(+), 7 deletions(-)

This patch needs running through checkpatch:

ERROR: code indent should use tabs where possible
#53: FILE: include/linux/mmzone.h:1148:
+        if (!mem_section)$

WARNING: please, no spaces at the start of a line
#53: FILE: include/linux/mmzone.h:1148:
+        if (!mem_section)$

ERROR: code indent should use tabs where possible
#54: FILE: include/linux/mmzone.h:1149:
+                return NULL;$

WARNING: please, no spaces at the start of a line
#54: FILE: include/linux/mmzone.h:1149:
+                return NULL;$

ERROR: "foo* bar" should be "foo *bar"
#99: FILE: mm/sparse.c:106:
+       struct mem_section* root = NULL;

ERROR: do not initialise statics to 0
#118: FILE: mm/sparse.c:335:
+       static unsigned long old_usemap_snr = 0;

ERROR: do not initialise statics to 0
#119: FILE: mm/sparse.c:336:
+       static unsigned long old_pgdat_snr = 0;

You should integrate it into your patch creation workflow.

> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index fc14b8b3f6ce..9799c2c58ce6 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1137,13 +1137,17 @@ struct mem_section {
>  #define SECTION_ROOT_MASK	(SECTIONS_PER_ROOT - 1)
>  
>  #ifdef CONFIG_SPARSEMEM_EXTREME
> -extern struct mem_section *mem_section[NR_SECTION_ROOTS];
> +extern struct mem_section **mem_section;
>  #else
>  extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
>  #endif
>  
>  static inline struct mem_section *__nr_to_section(unsigned long nr)
>  {
> +#ifdef CONFIG_SPARSEMEM_EXTREME
> +        if (!mem_section)
> +                return NULL;
> +#endif
>  	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
>  		return NULL;
>  	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d30e914afb6..639fd2dce0c4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5681,6 +5681,16 @@ void __init sparse_memory_present_with_active_regions(int nid)
>  	unsigned long start_pfn, end_pfn;
>  	int i, this_nid;
>  
> +#ifdef CONFIG_SPARSEMEM_EXTREME
> +	if (!mem_section) {

Any chance this ifdeffery and above can use IS_ENABLED() instead?

> +		unsigned long size, align;
> +
> +		size = sizeof(struct mem_section) * NR_SECTION_ROOTS;
> +		align = 1 << (INTERNODE_CACHE_SHIFT);
> +		mem_section = memblock_virt_alloc(size, align);
> +	}
> +#endif

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
