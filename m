Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 755DF6B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 23:36:20 -0400 (EDT)
Received: by mail-oa0-f44.google.com with SMTP id l10so5337133oag.3
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 20:36:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1374183272-10153-5-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1374183272-10153-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Fri, 19 Jul 2013 11:36:19 +0800
Message-ID: <CAJd=RBBv6rhKqb-30SDaZF3DFf2Nc=Odfo8=uRXQ8m40v_1rKg@mail.gmail.com>
Subject: Re: [PATCH 4/8] migrate: add hugepage migration code to move_pages()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jul 19, 2013 at 5:34 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> This patch extends move_pages() to handle vma with VM_HUGETLB set.
> We will be able to migrate hugepage with move_pages(2) after
> applying the enablement patch which comes later in this series.
>
> We avoid getting refcount on tail pages of hugepage, because unlike thp,
> hugepage is not split and we need not care about races with splitting.
>
> And migration of larger (1GB for x86_64) hugepage are not enabled.
>
> ChangeLog v3:
>  - revert introducing migrate_movable_pages
>  - follow_page_mask(FOLL_GET) returns NULL for tail pages
>  - use isolate_huge_page
>
> ChangeLog v2:
>  - updated description and renamed patch title
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory.c  | 12 ++++++++++--
>  mm/migrate.c | 13 +++++++++++--
>  2 files changed, 21 insertions(+), 4 deletions(-)
>
> diff --git v3.11-rc1.orig/mm/memory.c v3.11-rc1/mm/memory.c
> index 1ce2e2a..8c9a2cb 100644
> --- v3.11-rc1.orig/mm/memory.c
> +++ v3.11-rc1/mm/memory.c
> @@ -1496,7 +1496,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>         if (pud_none(*pud))
>                 goto no_page_table;
>         if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
> -               BUG_ON(flags & FOLL_GET);
> +               if (flags & FOLL_GET)
> +                       goto out;
>                 page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
>                 goto out;
>         }
> @@ -1507,8 +1508,15 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
>         if (pmd_none(*pmd))
>                 goto no_page_table;
>         if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
> -               BUG_ON(flags & FOLL_GET);
>                 page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
> +               if (flags & FOLL_GET) {
> +                       if (PageHead(page))
> +                               get_page_foll(page);
> +                       else {
> +                               page = NULL;
> +                               goto out;
> +                       }
> +               }

Can get_page do the work for us, like the following?

		if (flags & FOLL_GET)
			get_page(page);

>                 goto out;
>         }
>         if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
> diff --git v3.11-rc1.orig/mm/migrate.c v3.11-rc1/mm/migrate.c
> index 3ec47d3..d313737 100644
> --- v3.11-rc1.orig/mm/migrate.c
> +++ v3.11-rc1/mm/migrate.c
> @@ -1092,7 +1092,11 @@ static struct page *new_page_node(struct page *p, unsigned long private,
>
>         *result = &pm->status;
>
> -       return alloc_pages_exact_node(pm->node,
> +       if (PageHuge(p))
> +               return alloc_huge_page_node(page_hstate(compound_head(p)),
> +                                       pm->node);
> +       else
> +               return alloc_pages_exact_node(pm->node,
>                                 GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
>  }
>
> @@ -1152,6 +1156,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>                                 !migrate_all)
>                         goto put_and_set;
>
> +               if (PageHuge(page)) {
> +                       isolate_huge_page(page, &pagelist);
> +                       goto put_and_set;
> +               }
> +
>                 err = isolate_lru_page(page);
>                 if (!err) {
>                         list_add_tail(&page->lru, &pagelist);
> @@ -1174,7 +1183,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>                 err = migrate_pages(&pagelist, new_page_node,
>                                 (unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
>                 if (err)
> -                       putback_lru_pages(&pagelist);
> +                       putback_movable_pages(&pagelist);
>         }
>
>         up_read(&mm->mmap_sem);
> --
> 1.8.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
