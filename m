Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC3678E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 02:55:33 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id m5so1036082iok.22
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 23:55:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11sor2893101jab.8.2018.12.12.23.55.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 23:55:32 -0800 (PST)
MIME-Version: 1.0
References: <20181213051510.20306-1-peterx@redhat.com>
In-Reply-To: <20181213051510.20306-1-peterx@redhat.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Thu, 13 Dec 2018 10:55:21 +0300
Message-ID: <CALYGNiM-L6Hf7S0yyi0XZyt9u=fxLNBHoVV51XQWp4ggS1XH9Q@mail.gmail.com>
Subject: Re: [PATCH v3] mm: thp: fix flags for pmd migration when split
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterx@redhat.com
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, dave.jiang@intel.com, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, =?UTF-8?B?0JrQvtC90YHRgtCw0L3RgtC40L0g0KXQu9C10LHQvdC40LrQvtCy?= <khlebnikov@yandex-team.ru>, zi.yan@cs.rutgers.edu, linux-mm@kvack.org

On Thu, Dec 13, 2018 at 8:15 AM Peter Xu <peterx@redhat.com> wrote:
>
> When splitting a huge migrating PMD, we'll transfer all the existing
> PMD bits and apply them again onto the small PTEs.  However we are
> fetching the bits unconditionally via pmd_soft_dirty(), pmd_write()
> or pmd_yound() while actually they don't make sense at all when it's
> a migration entry.  Fix them up.  Since at it, drop the ifdef together
> as not needed.
>
> Note that if my understanding is correct about the problem then if
> without the patch there is chance to lose some of the dirty bits in
> the migrating pmd pages (on x86_64 we're fetching bit 11 which is part
> of swap offset instead of bit 2) and it could potentially corrupt the
> memory of an userspace program which depends on the dirty bit.
>

Looks good to me

Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

> CC: Andrea Arcangeli <aarcange@redhat.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> CC: Matthew Wilcox <willy@infradead.org>
> CC: Michal Hocko <mhocko@suse.com>
> CC: Dave Jiang <dave.jiang@intel.com>
> CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> CC: Souptick Joarder <jrdr.linux@gmail.com>
> CC: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> CC: Zi Yan <zi.yan@cs.rutgers.edu>
> CC: linux-mm@kvack.org
> CC: linux-kernel@vger.kernel.org
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
> v2:
> - fix it up for young/write/dirty bits too [Konstantin]
> v3:
> - fetch write correctly for migration entry; drop macro [Konstantin]
> ---
>  mm/huge_memory.c | 20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f2d19e4fe854..aebade83cec9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2145,23 +2145,25 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>          */
>         old_pmd = pmdp_invalidate(vma, haddr, pmd);
>
> -#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>         pmd_migration = is_pmd_migration_entry(old_pmd);
> -       if (pmd_migration) {
> +       if (unlikely(pmd_migration)) {
>                 swp_entry_t entry;
>
>                 entry = pmd_to_swp_entry(old_pmd);
>                 page = pfn_to_page(swp_offset(entry));
> -       } else
> -#endif
> +               write = is_write_migration_entry(entry);
> +               young = false;
> +               soft_dirty = pmd_swp_soft_dirty(old_pmd);
> +       } else {
>                 page = pmd_page(old_pmd);
> +               if (pmd_dirty(old_pmd))
> +                       SetPageDirty(page);
> +               write = pmd_write(old_pmd);
> +               young = pmd_young(old_pmd);
> +               soft_dirty = pmd_soft_dirty(old_pmd);
> +       }
>         VM_BUG_ON_PAGE(!page_count(page), page);
>         page_ref_add(page, HPAGE_PMD_NR - 1);
> -       if (pmd_dirty(old_pmd))
> -               SetPageDirty(page);
> -       write = pmd_write(old_pmd);
> -       young = pmd_young(old_pmd);
> -       soft_dirty = pmd_soft_dirty(old_pmd);
>
>         /*
>          * Withdraw the table only after we mark the pmd entry invalid.
> --
> 2.17.1
>
