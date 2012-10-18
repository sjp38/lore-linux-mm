Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id DE9686B0062
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 06:20:44 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so6178224wgb.26
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 03:20:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350555140-11030-2-git-send-email-lliubbo@gmail.com>
References: <1350555140-11030-1-git-send-email-lliubbo@gmail.com>
	<1350555140-11030-2-git-send-email-lliubbo@gmail.com>
Date: Thu, 18 Oct 2012 18:20:42 +0800
Message-ID: <CAA_GA1epiwyNHWRW1tbO9bnhYZXsTJ2Fd-806UU6s7X=A4HuVw@mail.gmail.com>
Subject: Re: [PATCH 2/4] thp: introduce hugepage_get_pmd()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, xiaoguangrong@linux.vnet.ibm.com, hughd@google.com, rientjes@google.com, kirill.shutemov@linux.intel.com, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org

On Thu, Oct 18, 2012 at 6:12 PM, Bob Liu <lliubbo@gmail.com> wrote:
> Introduce hugepage_get_pmd() to simple code.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/huge_memory.c |   68 ++++++++++++++++++++++--------------------------------
>  1 file changed, 27 insertions(+), 41 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 462d6ea..e575b29 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1115,6 +1115,25 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>         return ret;
>  }
>
> +static pmd_t *hugepage_get_pmd(struct mm_struct *mm, unsigned long address)
> +{
> +       pgd_t *pgd;
> +       pud_t *pud;
> +       pmd_t *pmd = NULL;
> +
> +       pgd = pgd_offset(mm, address);
> +       if (!pgd_present(*pgd))
> +               goto out;
> +
> +       pud = pud_offset(pgd, address);
> +       if (!pud_present(*pud))
> +               goto out;
> +
> +       pmd = pmd_offset(pud, address);
> +out:
> +       return pmd;
> +}
> +
>  /*
>   * Returns 1 if a given pmd maps a stable (not under splitting) thp.
>   * Returns -1 if it maps a thp under splitting. Returns 0 otherwise.
> @@ -1145,22 +1164,14 @@ pmd_t *page_check_address_pmd(struct page *page,
>                               unsigned long address,
>                               enum page_check_address_pmd_flag flag)
>  {
> -       pgd_t *pgd;
> -       pud_t *pud;
>         pmd_t *pmd, *ret = NULL;
>
>         if (address & ~HPAGE_PMD_MASK)
>                 goto out;
>
> -       pgd = pgd_offset(mm, address);
> -       if (!pgd_present(*pgd))
> -               goto out;
> -
> -       pud = pud_offset(pgd, address);
> -       if (!pud_present(*pud))
> +       pmd = hugepage_get_pmd(mm, address);
> +       if (!pmd)
>                 goto out;
> -
> -       pmd = pmd_offset(pud, address);
>         if (pmd_none(*pmd))
>                 goto out;
>         if (pmd_page(*pmd) != page)
> @@ -1908,8 +1919,6 @@ static void collapse_huge_page(struct mm_struct *mm,
>                                    struct vm_area_struct *vma,
>                                    int node)
>  {
> -       pgd_t *pgd;
> -       pud_t *pud;
>         pmd_t *pmd, _pmd;
>         pte_t *pte;
>         pgtable_t pgtable;
> @@ -1955,16 +1964,9 @@ static void collapse_huge_page(struct mm_struct *mm,
>                 goto out;
>         VM_BUG_ON(vma->vm_flags & VM_NO_THP);
>
> -       pgd = pgd_offset(mm, address);
> -       if (!pgd_present(*pgd))
> +       pmd = hugepage_get_pmd(mm, address);
> +       if (!pmd)
>                 goto out;
> -
> -       pud = pud_offset(pgd, address);
> -       if (!pud_present(*pud))
> -               goto out;
> -
> -       pmd = pmd_offset(pud, address);
> -       /* pmd can't go away or become huge under us */
>         if (!pmd_present(*pmd) || pmd_trans_huge(*pmd))
>                 goto out;
>
> @@ -2048,8 +2050,6 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>                                unsigned long address,
>                                struct page **hpage)
>  {
> -       pgd_t *pgd;
> -       pud_t *pud;
>         pmd_t *pmd;
>         pte_t *pte, *_pte;
>         int ret = 0, referenced = 0, none = 0;
> @@ -2060,15 +2060,9 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>
>         VM_BUG_ON(address & ~HPAGE_PMD_MASK);
>
> -       pgd = pgd_offset(mm, address);
> -       if (!pgd_present(*pgd))
> -               goto out;
> -
> -       pud = pud_offset(pgd, address);
> -       if (!pud_present(*pud))
> +       pmd = hugepage_get_pmd(mm, address);
> +       if (!pmd)
>                 goto out;
> -
> -       pmd = pmd_offset(pud, address);
>         if (!pmd_present(*pmd) || pmd_trans_huge(*pmd))
>                 goto out;
>
> @@ -2363,21 +2357,13 @@ void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
>  static void split_huge_page_address(struct mm_struct *mm,
>                                     unsigned long address)
>  {
> -       pgd_t *pgd;
> -       pud_t *pud;
>         pmd_t *pmd;
>
>         VM_BUG_ON(!(address & ~HPAGE_PMD_MASK));
>
> -       pgd = pgd_offset(mm, address);
> -       if (!pgd_present(*pgd))
> -               return;
> -
> -       pud = pud_offset(pgd, address);
> -       if (!pud_present(*pud))
> +       pmd = hugepage_get_pmd(mm, address);
> +       if (!pmd)
>                 return;
> -
> -       pmd = pmd_offset(pud, address);
>         if (!pmd_present(*pmd))
>                 return;
>         /*
> --
> 1.7.9.5
>
>



-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
