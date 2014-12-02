Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9E36B006C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 21:53:42 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id a1so7594397wgh.19
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 18:53:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t19si34070067wiv.66.2014.12.01.18.53.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 18:53:41 -0800 (PST)
Message-ID: <547D29A3.7090108@redhat.com>
Date: Mon, 01 Dec 2014 21:53:23 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/4] mm: refactor do_wp_page, extract the page copy
 flow
References: <1417467491-20071-1-git-send-email-raindel@mellanox.com> <1417467491-20071-4-git-send-email-raindel@mellanox.com>
In-Reply-To: <1417467491-20071-4-git-send-email-raindel@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/01/2014 03:58 PM, Shachar Raindel wrote:
> In some cases, do_wp_page had to copy the page suffering a write
> fault to a new location. If the function logic decided that to do
> this, it was done by jumping with a "goto" operation to the
> relevant code block. This made the code really hard to understand.
> It is also against the kernel coding style guidelines.
> 
> This patch extracts the page copy and page table update logic to a 
> separate function. It also clean up the naming, from "gotten" to 
> "wp_page_copy", and adds few comments.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com> --- 
> mm/memory.c | 265
> +++++++++++++++++++++++++++++++++--------------------------- 1 file
> changed, 147 insertions(+), 118 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c index b42bec0..c7c0df2
> 100644 --- a/mm/memory.c +++ b/mm/memory.c @@ -2088,6 +2088,146 @@
> static int wp_page_reuse(struct mm_struct *mm, struct
> vm_area_struct *vma, }
> 
> /* + * Handle the case of a page which we actually need to copy to
> a new page. + * + * Called with mmap_sem locked and the old page
> referenced, but + * without the ptl held. + * + * High level logic
> flow: + * + * - Allocate a page, copy the content of the old page
> to the new one. + * - Handle book keeping and accounting - cgroups,
> mmu-notifiers, etc. + * - Take the PTL. If the pte changed, bail
> out and release the allocated page + * - If the pte is still the
> way we remember it, update the page table and all + *   relevant
> references. This includes dropping the reference the page-table + *
> held to the old page, as well as updating the rmap. + * - In any
> case, unlock the PTL and drop the reference we took to the old
> page. + */ +static int wp_page_copy(struct mm_struct *mm, struct
> vm_area_struct *vma, +			unsigned long address, pte_t *page_table,
> pmd_t *pmd, +			pte_t orig_pte, struct page *old_page) +{ +	struct
> page *new_page = NULL; +	spinlock_t *ptl = NULL; +	pte_t entry; +
> int page_copied = 0; +	const unsigned long mmun_start = address &
> PAGE_MASK;	/* For mmu_notifiers */ +	const unsigned long mmun_end =
> mmun_start + PAGE_SIZE;	/* For mmu_notifiers */ +	struct mem_cgroup
> *memcg; + +	if (unlikely(anon_vma_prepare(vma))) +		goto oom; + +
> if (is_zero_pfn(pte_pfn(orig_pte))) { +		new_page =
> alloc_zeroed_user_highpage_movable(vma, address); +		if
> (!new_page) +			goto oom; +	} else { +		new_page =
> alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address); +		if
> (!new_page) +			goto oom; +		cow_user_page(new_page, old_page,
> address, vma); +	} +	__SetPageUptodate(new_page); + +	if
> (mem_cgroup_try_charge(new_page, mm, GFP_KERNEL, &memcg)) +		goto
> oom_free_new; + +	mmu_notifier_invalidate_range_start(mm,
> mmun_start, mmun_end);

I believe the mmu_notifier_invalidate_range_start & _end
functions can be moved inside the pte_same(*page_table, orig_pte)
branch. There is no reason to call those functions if we do not
modify the page table entry.

This is not something introduced by your patch, but you might as
well fix it while you're touching the code :)

Other than that:

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUfSmjAAoJEM553pKExN6DhhIIAI72W6J2jKD9EXulDTF2TXXW
AyiKUvJHg8GiCRExvurHkUwZ+y9WdzrEEjy8ZKZvh76uhvZZpyytRTYysiFTc4Hs
du5qsdxbn/FejukO9hygPGoQnwL7aFG6S6B48syaolR5xpwLXHgI54+5GJNurmY9
mqcfitfojqbQK39d18GvwHl4HkJ4T/Cfg/mf5oRSwlsf9Yc8gcrKGlfrdoHjFAWH
oHXFdVQVw98Khlkpw6cmw/ga9TgTWGipZxQyx2SRVAkq52XhPNivPov+agNWH8Fh
79YbqTqetWYkMdiJXlnnk3V/7bi3fGmSxoA8KM/miheKiDY8ECr0E9qhd3VOegI=
=yuS6
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
