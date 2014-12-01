Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id E42F46B006E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 07:58:04 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id a1so5851267wgh.33
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 04:58:04 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id cy10si45355114wib.36.2014.12.01.04.58.04
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 04:58:04 -0800 (PST)
Date: Mon, 1 Dec 2014 14:57:54 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/5] mm: refactor do_wp_page, extract the page copy flow
Message-ID: <20141201125754.GD13856@node.dhcp.inet.fi>
References: <1417435485-24629-1-git-send-email-raindel@mellanox.com>
 <1417435485-24629-4-git-send-email-raindel@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417435485-24629-4-git-send-email-raindel@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

On Mon, Dec 01, 2014 at 02:04:43PM +0200, Shachar Raindel wrote:
> In some cases, do_wp_page had to copy the page suffering a write fault
> to a new location. If the function logic decided that to do this, it
> was done by jumping with a "goto" operation to the relevant code
> block. This made the code really hard to understand. It is also
> against the kernel coding style guidelines.
> 
> This patch extracts the page copy and page table update logic to a
> separate function. It also clean up the naming, from "gotten" to
> "wp_page_copy", and adds few comments.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>
> ---
>  mm/memory.c | 238 +++++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 131 insertions(+), 107 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index dd3bb13..436012d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2123,6 +2123,132 @@ static int wp_page_unlock(struct mm_struct *mm, struct vm_area_struct *vma,
>  }
>  
>  /*
> + * Handle the case of a page which we actually need to copy to a new page.
> + *
> + * High level logic flow:
> + *
> + * - Drop the PTL, allocate a page, copy the content.
> + * - Handle book keeping and accounting - cgroups, mmu-notifiers, etc.
> + * - Regain the PTL. If the pte changed, bail out and release the allocated page
> + * - If the pte is still the way we remember it, update the page table and all
> + *   relevant references. This includes dropping the reference the page-table
> + *   held to the old page, as well as updating the rmap.
> + * - In any case, unlock the PTL and drop the reference we took to the old page.
> + */
> +static int wp_page_copy(struct mm_struct *mm, struct vm_area_struct *vma,
> +			unsigned long address, pte_t *page_table, pmd_t *pmd,
> +			spinlock_t *ptl, pte_t orig_pte, struct page *old_page)
> +	__releases(ptl)
> +{
> +	struct page *new_page = NULL;
> +	pte_t entry;
> +	int page_copied = 0;
> +	const unsigned long mmun_start = address & PAGE_MASK;	/* For mmu_notifiers */
> +	const unsigned long mmun_end = mmun_start + PAGE_SIZE;	/* For mmu_notifiers */
> +	struct mem_cgroup *memcg;
> +
> +	pte_unmap_unlock(page_table, ptl);

Move ptl unlock to caller. No need in __releases(ptl) and shorter list of
argument.

Otherwise:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
