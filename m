Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id F37A96B6F1C
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 15:25:50 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22-v6so2376481plq.21
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 12:25:50 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e11-v6si21876622plb.373.2018.09.04.12.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 12:25:49 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: Move page struct poisoning from CONFIG_DEBUG_VM
 to CONFIG_DEBUG_VM_PGFLAGS
References: <20180904181550.4416.50701.stgit@localhost.localdomain>
 <20180904183339.4416.44582.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <fe84cdb4-7be7-8ad8-58ca-681f46e2e55c@intel.com>
Date: Tue, 4 Sep 2018 12:25:49 -0700
MIME-Version: 1.0
In-Reply-To: <20180904183339.4416.44582.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: alexander.h.duyck@intel.com, pavel.tatashin@microsoft.com, mhocko@suse.com, akpm@linux-foundation.org, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 09/04/2018 11:33 AM, Alexander Duyck wrote:
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1444,7 +1444,7 @@ void * __init memblock_virt_alloc_try_nid_raw(
>  
>  	ptr = memblock_virt_alloc_internal(size, align,
>  					   min_addr, max_addr, nid);
> -#ifdef CONFIG_DEBUG_VM
> +#ifdef CONFIG_DEBUG_VM_PGFLAGS
>  	if (ptr && size > 0)
>  		memset(ptr, PAGE_POISON_PATTERN, size);
>  #endif
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 10b07eea9a6e..0fd9ad5021b0 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -696,7 +696,7 @@ int __meminit sparse_add_one_section(struct pglist_data *pgdat,
>  		goto out;
>  	}
>  
> -#ifdef CONFIG_DEBUG_VM
> +#ifdef CONFIG_DEBUG_VM_PGFLAGS
>  	/*
>  	 * Poison uninitialized struct pages in order to catch invalid flags
>  	 * combinations.

I think this is the wrong way to do this.  It keeps the setting and
checking still rather tenuously connected.  If you were to leave it this
way, it needs commenting.  It's also rather odd that we're memsetting
the entire 'struct page' for a config option that's supposedly dealing
with page->flags.  That deserves _some_ addressing in a comment or
changelog.

How about:

#ifdef CONFIG_DEBUG_VM_PGFLAGS
#define VM_BUG_ON_PGFLAGS(cond, page) VM_BUG_ON_PAGE(cond, page)
+static inline void poison_struct_pages(struct page *pages, int nr)
+{
+	memset(pages, PAGE_POISON_PATTERN, size * sizeof(...));
+}
#else
#define VM_BUG_ON_PGFLAGS(cond, page) BUILD_BUG_ON_INVALID(cond)
static inline void poison_struct_pages(struct page *pages, int nr) {}
#endif

That puts the setting and checking in one spot, and also removes a
couple of #ifdefs from .c files.
