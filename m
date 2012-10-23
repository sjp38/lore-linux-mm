Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id F05EF6B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:54:59 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so3400448iak.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 23:54:59 -0700 (PDT)
Message-ID: <50863F3D.4070708@gmail.com>
Date: Tue, 23 Oct 2012 14:54:53 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] thp: clean up __collapse_huge_page_isolate
References: <1350975002-5927-1-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1350975002-5927-1-git-send-email-lliubbo@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, hughd@google.com, rientjes@google.com, xiaoguangrong@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org

On 10/23/2012 02:50 PM, Bob Liu wrote:
> There are duplicated place using release_pte_pages().
> And release_all_pte_pages() can also be removed.
>
> v2: mv label out of condition.

it seems that the first version has already merged in linux-mm

>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>   mm/huge_memory.c |   38 +++++++++++---------------------------
>   1 file changed, 11 insertions(+), 27 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a863af2..96a2ccc 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1700,64 +1700,49 @@ static void release_pte_pages(pte_t *pte, pte_t *_pte)
>   	}
>   }
>   
> -static void release_all_pte_pages(pte_t *pte)
> -{
> -	release_pte_pages(pte, pte + HPAGE_PMD_NR);
> -}
> -
>   static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   					unsigned long address,
>   					pte_t *pte)
>   {
>   	struct page *page;
>   	pte_t *_pte;
> -	int referenced = 0, isolated = 0, none = 0;
> +	int referenced = 0, none = 0;
>   	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
>   	     _pte++, address += PAGE_SIZE) {
>   		pte_t pteval = *_pte;
>   		if (pte_none(pteval)) {
>   			if (++none <= khugepaged_max_ptes_none)
>   				continue;
> -			else {
> -				release_pte_pages(pte, _pte);
> +			else
>   				goto out;
> -			}
>   		}
> -		if (!pte_present(pteval) || !pte_write(pteval)) {
> -			release_pte_pages(pte, _pte);
> +		if (!pte_present(pteval) || !pte_write(pteval))
>   			goto out;
> -		}
>   		page = vm_normal_page(vma, address, pteval);
> -		if (unlikely(!page)) {
> -			release_pte_pages(pte, _pte);
> +		if (unlikely(!page))
>   			goto out;
> -		}
> +
>   		VM_BUG_ON(PageCompound(page));
>   		BUG_ON(!PageAnon(page));
>   		VM_BUG_ON(!PageSwapBacked(page));
>   
>   		/* cannot use mapcount: can't collapse if there's a gup pin */
> -		if (page_count(page) != 1) {
> -			release_pte_pages(pte, _pte);
> +		if (page_count(page) != 1)
>   			goto out;
> -		}
>   		/*
>   		 * We can do it before isolate_lru_page because the
>   		 * page can't be freed from under us. NOTE: PG_lock
>   		 * is needed to serialize against split_huge_page
>   		 * when invoked from the VM.
>   		 */
> -		if (!trylock_page(page)) {
> -			release_pte_pages(pte, _pte);
> +		if (!trylock_page(page))
>   			goto out;
> -		}
>   		/*
>   		 * Isolate the page to avoid collapsing an hugepage
>   		 * currently in use by the VM.
>   		 */
>   		if (isolate_lru_page(page)) {
>   			unlock_page(page);
> -			release_pte_pages(pte, _pte);
>   			goto out;
>   		}
>   		/* 0 stands for page_is_file_cache(page) == false */
> @@ -1770,12 +1755,11 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
>   		    mmu_notifier_test_young(vma->vm_mm, address))
>   			referenced = 1;
>   	}
> -	if (unlikely(!referenced))
> -		release_all_pte_pages(pte);
> -	else
> -		isolated = 1;
> +	if (likely(referenced))
> +		return 1;
>   out:
> -	return isolated;
> +	release_pte_pages(pte, _pte);
> +	return 0;
>   }
>   
>   static void __collapse_huge_page_copy(pte_t *pte, struct page *page,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
