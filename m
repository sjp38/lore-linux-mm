Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 720E06B0034
	for <linux-mm@kvack.org>; Sat,  7 Sep 2013 11:32:40 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so4489621pde.10
        for <linux-mm@kvack.org>; Sat, 07 Sep 2013 08:32:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378093542-31971-2-git-send-email-bob.liu@oracle.com>
References: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
	<1378093542-31971-2-git-send-email-bob.liu@oracle.com>
Date: Sat, 7 Sep 2013 11:32:39 -0400
Message-ID: <CAJLXCZR10krfoT7CCW7BTgZRqjTRYTPMS5AMksm2dVso5nswCg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: thp: khugepaged: add policy for finding target node
From: Andrew Davidoff <davidoff@qedmf.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, konrad.wilk@oracle.com, Bob Liu <bob.liu@oracle.com>

On Sun, Sep 1, 2013 at 11:45 PM, Bob Liu <lliubbo@gmail.com> wrote:
>
> Reported-by: Andrew Davidoff <davidoff@qedmf.net>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>

Tested-by: Andrew Davidoff <davidoff@qedmf.net>

> ---
>  mm/huge_memory.c |   50 +++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 41 insertions(+), 9 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7448cf9..86c7f0d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2144,7 +2144,33 @@ static void khugepaged_alloc_sleep(void)
>                         msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
>  }
>
> +static int khugepaged_node_load[MAX_NUMNODES];
>  #ifdef CONFIG_NUMA
> +static int last_khugepaged_target_node = NUMA_NO_NODE;
> +static int khugepaged_find_target_node(void)
> +{
> +       int i, target_node = 0, max_value = 1;
> +
> +       /* find first node with most normal pages hit */
> +       for (i = 0; i < MAX_NUMNODES; i++)
> +               if (khugepaged_node_load[i] > max_value) {
> +                       max_value = khugepaged_node_load[i];
> +                       target_node = i;
> +               }
> +
> +       /* do some balance if several nodes have the same hit number */
> +       if (target_node <= last_khugepaged_target_node) {
> +               for (i = last_khugepaged_target_node + 1; i < MAX_NUMNODES; i++)
> +                       if (max_value == khugepaged_node_load[i]) {
> +                               target_node = i;
> +                               break;
> +                       }
> +       }
> +
> +       last_khugepaged_target_node = target_node;
> +       return target_node;
> +}
> +
>  static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
>  {
>         if (IS_ERR(*hpage)) {
> @@ -2178,9 +2204,8 @@ static struct page
>          * mmap_sem in read mode is good idea also to allow greater
>          * scalability.
>          */
> -       *hpage  = alloc_hugepage_vma(khugepaged_defrag(), vma, address,
> -                                     node, __GFP_OTHER_NODE);
> -
> +       *hpage = alloc_pages_exact_node(node, alloc_hugepage_gfpmask(
> +                       khugepaged_defrag(), __GFP_OTHER_NODE), HPAGE_PMD_ORDER);
>         /*
>          * After allocating the hugepage, release the mmap_sem read lock in
>          * preparation for taking it in write mode.
> @@ -2196,6 +2221,11 @@ static struct page
>         return *hpage;
>  }
>  #else
> +static int khugepaged_find_target_node(void)
> +{
> +       return 0;
> +}
> +
>  static inline struct page *alloc_hugepage(int defrag)
>  {
>         return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
> @@ -2405,6 +2435,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>         if (pmd_trans_huge(*pmd))
>                 goto out;
>
> +       memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
>         pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>         for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
>              _pte++, _address += PAGE_SIZE) {
> @@ -2421,12 +2452,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>                 if (unlikely(!page))
>                         goto out_unmap;
>                 /*
> -                * Chose the node of the first page. This could
> -                * be more sophisticated and look at more pages,
> -                * but isn't for now.
> +                * Chose the node of most normal pages hit, record this
> +                * informaction to khugepaged_node_load[]
>                  */
> -               if (node == NUMA_NO_NODE)
> -                       node = page_to_nid(page);
> +               node = page_to_nid(page);
> +               khugepaged_node_load[node]++;
>                 VM_BUG_ON(PageCompound(page));
>                 if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
>                         goto out_unmap;
> @@ -2441,9 +2471,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>                 ret = 1;
>  out_unmap:
>         pte_unmap_unlock(pte, ptl);
> -       if (ret)
> +       if (ret) {
> +               node = khugepaged_find_target_node();
>                 /* collapse_huge_page will return with the mmap_sem released */
>                 collapse_huge_page(mm, address, hpage, vma, node);
> +       }
>  out:
>         return ret;
>  }
> --
> 1.7.10.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
