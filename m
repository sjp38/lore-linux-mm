Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id EF2596B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 03:31:28 -0400 (EDT)
Received: by mail-oa0-f48.google.com with SMTP id j1so3033154oag.7
        for <linux-mm@kvack.org>; Fri, 15 Mar 2013 00:31:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363283435-7666-25-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-25-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 15 Mar 2013 15:31:27 +0800
Message-ID: <CAJd=RBD_PDGqLyhcnwwj2UsOxu0dE5B1UAhmRM-esL_mwa-dhw@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 24/30] thp: move maybe_pmd_mkwrite() out of mk_huge_pmd()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> It's confusing that mk_huge_pmd() has sematics different from mk_pte()
> or mk_pmd().
>
> Let's move maybe_pmd_mkwrite() out of mk_huge_pmd() and adjust
> prototype to match mk_pte().
>
No urgent if not used subsequently.

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/huge_memory.c |   14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 34e0385..be7b7e1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -691,11 +691,10 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
>         return pmd;
>  }
>
> -static inline pmd_t mk_huge_pmd(struct page *page, struct vm_area_struct *vma)
> +static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
>  {
>         pmd_t entry;
> -       entry = mk_pmd(page, vma->vm_page_prot);
> -       entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +       entry = mk_pmd(page, prot);
>         entry = pmd_mkhuge(entry);
>         return entry;
>  }
> @@ -723,7 +722,8 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>                 pte_free(mm, pgtable);
>         } else {
>                 pmd_t entry;
> -               entry = mk_huge_pmd(page, vma);
> +               entry = mk_huge_pmd(page, vma->vm_page_prot);
> +               entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>                 /*
>                  * The spinlocking to take the lru_lock inside
>                  * page_add_new_anon_rmap() acts as a full memory
> @@ -1212,7 +1212,8 @@ alloc:
>                 goto out_mn;
>         } else {
>                 pmd_t entry;
> -               entry = mk_huge_pmd(new_page, vma);
> +               entry = mk_huge_pmd(new_page, vma->vm_page_prot);
> +               entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>                 pmdp_clear_flush(vma, haddr, pmd);
>                 page_add_new_anon_rmap(new_page, vma, haddr);
>                 set_pmd_at(mm, haddr, pmd, entry);
> @@ -2382,7 +2383,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>         __SetPageUptodate(new_page);
>         pgtable = pmd_pgtable(_pmd);
>
> -       _pmd = mk_huge_pmd(new_page, vma);
> +       _pmd = mk_huge_pmd(new_page, vma->vm_page_prot);
> +       _pmd = maybe_pmd_mkwrite(pmd_mkdirty(_pmd), vma);
>
>         /*
>          * spin_lock() below is not the equivalent of smp_wmb(), so
> --
> 1.7.10.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
