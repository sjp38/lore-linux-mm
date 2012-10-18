Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 491E46B0069
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 06:21:33 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id hq7so1491528wib.8
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 03:21:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350555140-11030-4-git-send-email-lliubbo@gmail.com>
References: <1350555140-11030-1-git-send-email-lliubbo@gmail.com>
	<1350555140-11030-4-git-send-email-lliubbo@gmail.com>
Date: Thu, 18 Oct 2012 18:21:31 +0800
Message-ID: <CAA_GA1dCoGJNFtHtisab=LcZfM+CMwF2di8Tnv0EVHTk_ZaOnw@mail.gmail.com>
Subject: Re: [PATCH 4/4] thp: cleanup: introduce mk_huge_pmd()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, xiaoguangrong@linux.vnet.ibm.com, hughd@google.com, rientjes@google.com, kirill.shutemov@linux.intel.com, Linux-MM <linux-mm@kvack.org>

On Thu, Oct 18, 2012 at 6:12 PM, Bob Liu <lliubbo@gmail.com> wrote:
> Introduce mk_huge_pmd() to simple code
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/huge_memory.c |   21 ++++++++++++---------
>  1 file changed, 12 insertions(+), 9 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 3588fec..9fd1312 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -605,6 +605,15 @@ static inline pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
>         return pmd;
>  }
>
> +static inline pmd_t mk_huge_pmd(struct page *page, struct vm_area_struct *vma)
> +{
> +       pmd_t entry;
> +       entry = mk_pmd(page, vma->vm_page_prot);
> +       entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +       entry = pmd_mkhuge(entry);
> +       return entry;
> +}
> +
>  static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>                                         struct vm_area_struct *vma,
>                                         unsigned long haddr, pmd_t *pmd,
> @@ -628,9 +637,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>                 pte_free(mm, pgtable);
>         } else {
>                 pmd_t entry;
> -               entry = mk_pmd(page, vma->vm_page_prot);
> -               entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> -               entry = pmd_mkhuge(entry);
> +               entry = mk_huge_pmd(page, vma);
>                 /*
>                  * The spinlocking to take the lru_lock inside
>                  * page_add_new_anon_rmap() acts as a full memory
> @@ -950,9 +957,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>         } else {
>                 pmd_t entry;
>                 VM_BUG_ON(!PageHead(page));
> -               entry = mk_pmd(new_page, vma->vm_page_prot);
> -               entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> -               entry = pmd_mkhuge(entry);
> +               entry = mk_huge_pmd(new_page, vma);
>                 pmdp_clear_flush(vma, haddr, pmd);
>                 page_add_new_anon_rmap(new_page, vma, haddr);
>                 set_pmd_at(mm, haddr, pmd, entry);
> @@ -2019,9 +2024,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>         __SetPageUptodate(new_page);
>         pgtable = pmd_pgtable(_pmd);
>
> -       _pmd = mk_pmd(new_page, vma->vm_page_prot);
> -       _pmd = maybe_pmd_mkwrite(pmd_mkdirty(_pmd), vma);
> -       _pmd = pmd_mkhuge(_pmd);
> +       _pmd = mk_huge_pmd(new_page, vma);
>
>         /*
>          * spin_lock() below is not the equivalent of smp_wmb(), so
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
