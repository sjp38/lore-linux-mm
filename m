Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 01C766B0034
	for <linux-mm@kvack.org>; Wed, 22 May 2013 03:26:40 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id wp18so1835442obc.21
        for <linux-mm@kvack.org>; Wed, 22 May 2013 00:26:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1368321816-17719-29-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1368321816-17719-29-git-send-email-kirill.shutemov@linux.intel.com>
Date: Wed, 22 May 2013 15:26:40 +0800
Message-ID: <CAJd=RBDvY965A2eD_V5Zg=o0mnG+4s_X55tBFVbAda=2yWt27g@mail.gmail.com>
Subject: Re: [PATCHv4 28/39] thp: prepare zap_huge_pmd() to uncharge file pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, May 12, 2013 at 9:23 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> Uncharge pages from correct counter.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/huge_memory.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7ad458d..a88f9b2 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1385,10 +1385,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>                         spin_unlock(&tlb->mm->page_table_lock);
>                         put_huge_zero_page();
>                 } else {
> +                       int member;
>                         page = pmd_page(orig_pmd);

Better _if_ member is determined before we touch rmap, conceptually?

>                         page_remove_rmap(page);
>                         VM_BUG_ON(page_mapcount(page) < 0);
> -                       add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> +                       member = PageAnon(page) ? MM_ANONPAGES : MM_FILEPAGES;
> +                       add_mm_counter(tlb->mm, member, -HPAGE_PMD_NR);
>                         VM_BUG_ON(!PageHead(page));
>                         tlb->mm->nr_ptes--;
>                         spin_unlock(&tlb->mm->page_table_lock);
> --
> 1.7.10.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
