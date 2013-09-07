Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 576686B0031
	for <linux-mm@kvack.org>; Sat,  7 Sep 2013 11:31:56 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so4559580pad.9
        for <linux-mm@kvack.org>; Sat, 07 Sep 2013 08:31:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
References: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
Date: Sat, 7 Sep 2013 11:31:55 -0400
Message-ID: <CAJLXCZS4ywM_khTCH4RrU5QiZRosJA8CJBCR2pC7MMDMuF00Fw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: thp: cleanup: mv alloc_hugepage to better place
From: Andrew Davidoff <davidoff@qedmf.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, konrad.wilk@oracle.com, Bob Liu <bob.liu@oracle.com>

On Sun, Sep 1, 2013 at 11:45 PM, Bob Liu <lliubbo@gmail.com> wrote:
> Move alloc_hugepage to better place, no need for a seperate #ifndef CONFIG_NUMA
>
> Signed-off-by: Bob Liu <bob.liu@oracle.com>

Tested-by: Andrew Davidoff <davidoff@qedmf.net>

> ---
>  mm/huge_memory.c |   14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a92012a..7448cf9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -753,14 +753,6 @@ static inline struct page *alloc_hugepage_vma(int defrag,
>                                HPAGE_PMD_ORDER, vma, haddr, nd);
>  }
>
> -#ifndef CONFIG_NUMA
> -static inline struct page *alloc_hugepage(int defrag)
> -{
> -       return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
> -                          HPAGE_PMD_ORDER);
> -}
> -#endif
> -
>  static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
>                 struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
>                 struct page *zero_page)
> @@ -2204,6 +2196,12 @@ static struct page
>         return *hpage;
>  }
>  #else
> +static inline struct page *alloc_hugepage(int defrag)
> +{
> +       return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
> +                          HPAGE_PMD_ORDER);
> +}
> +
>  static struct page *khugepaged_alloc_hugepage(bool *wait)
>  {
>         struct page *hpage;
> --
> 1.7.10.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
