Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB3066B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:56:10 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so1983205113pgc.1
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:56:10 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c25si6322709pge.95.2017.01.11.08.56.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 08:56:09 -0800 (PST)
Subject: Re: [PATCH v4 2/4] mm: Add function to support extra actions on swap
 in/out
References: <cover.1483999591.git.khalid.aziz@oracle.com>
 <c24c7a844c61d6f8d57dd3791ad7ab5f05305c6b.1483999591.git.khalid.aziz@oracle.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <b31a3aef-26d9-6d3a-109b-c8453a3a2aef@linux.intel.com>
Date: Wed, 11 Jan 2017 08:56:06 -0800
MIME-Version: 1.0
In-Reply-To: <c24c7a844c61d6f8d57dd3791ad7ab5f05305c6b.1483999591.git.khalid.aziz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, akpm@linux-foundation.org, davem@davemloft.net, arnd@arndb.de
Cc: kirill.shutemov@linux.intel.com, mhocko@suse.com, jmarchan@redhat.com, vbabka@suse.cz, dan.j.williams@intel.com, lstoakes@gmail.com, hannes@cmpxchg.org, mgorman@suse.de, hughd@google.com, vdavydov.dev@gmail.com, minchan@kernel.org, namit@vmware.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 01/11/2017 08:12 AM, Khalid Aziz wrote:
> +#ifndef set_swp_pte_at
> +#define set_swp_pte_at(mm, addr, ptep, pte, oldpte)	\
> +		set_pte_at(mm, addr, ptep, pte)
> +#endif

BTW, thanks for the *much* improved description of the series.  This is
way easier to understand.

I really don't think this is the interface we want, though.
set_swp_pte_at() is really doing *two* things:
1. Detecting _PAGE_MCD_4V and squirreling the MCD data away at swap-out
2. Reading back in the MCD data at swap-on

You're effectively using (!pte_none(pte) && !pte_present(pte)) to
determine whether you're at swap in or swap out time.  That's goofy, IMNHO.

It isn't obvious from the context, but this hunk is creating a migration
PTE.  Why is ADI tag manipulation needed?  We're just changing the
physical address of the underlying memory, but neither the
application-visible contents nor the tags are changing.

> @@ -1539,7 +1539,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		swp_pte = swp_entry_to_pte(entry);
>  		if (pte_soft_dirty(pteval))
>  			swp_pte = pte_swp_mksoft_dirty(swp_pte);
> -		set_pte_at(mm, address, pte, swp_pte);
> +		set_swp_pte_at(mm, address, pte, swp_pte, pteval);
>  	} else if (PageAnon(page)) {
>  		swp_entry_t entry = { .val = page_private(page) };
>  		pte_t swp_pte;

Which means you're down to a single call that does swap-out, and a
single call that does swap-in.  There's no reason to hide all your code
behind set_pte_at().

Just add a new arch-specific call that takes the VMA and the swap PTE
and stores the ADI bit in there, here:

> @@ -1572,7 +1572,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		swp_pte = swp_entry_to_pte(entry);
>  		if (pte_soft_dirty(pteval))
>  			swp_pte = pte_swp_mksoft_dirty(swp_pte);
> -		set_pte_at(mm, address, pte, swp_pte);
> +		set_swp_pte_at(mm, address, pte, swp_pte, pteval);
>  	} else

and in do_swap_page(), do the opposite with a second, new call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
