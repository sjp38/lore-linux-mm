Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id E89826B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 08:45:16 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so2906888vcb.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 05:45:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344866141-27906-1-git-send-email-mhocko@suse.cz>
References: <1344866141-27906-1-git-send-email-mhocko@suse.cz>
Date: Thu, 16 Aug 2012 20:45:15 +0800
Message-ID: <CAJd=RBAwg0k0=8zmRh6jwAYe7Msmxw=HE8qs3YjwXrtsezr78Q@mail.gmail.com>
Subject: Re: [PATCH] hugetlb: do not use vma_hugecache_offset for vma_prio_tree_foreach
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On Mon, Aug 13, 2012 at 9:55 PM, Michal Hocko <mhocko@suse.cz> wrote:
> 0c176d5 (mm: hugetlb: fix pgoff computation when unmapping page
> from vma) fixed pgoff calculation but it has replaced it by
> vma_hugecache_offset which is not approapriate for offsets used for
> vma_prio_tree_foreach because that one expects index in page units
> rather than in huge_page_shift.
> Using vma_hugecache_offset is not incorrect because the pgoff will fit
> into the same vmas but it is confusing so the standard PAGE_SHIFT based
> index calculation is used instead.
>
> Cc: Hillf Danton <dhillf@gmail.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---

Thanks

Acked-by: Hillf Danton <dhillf@gmail.com>


>  mm/hugetlb.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c39e4be..a74ea31 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2462,7 +2462,8 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>          * from page cache lookup which is in HPAGE_SIZE units.
>          */
>         address = address & huge_page_mask(h);
> -       pgoff = vma_hugecache_offset(h, vma, address);
> +       pgoff = ((address - vma->vm_start) >> PAGE_SHIFT) +
> +                       vma->vm_pgoff;
>         mapping = vma->vm_file->f_dentry->d_inode->i_mapping;
>
>         /*
> --
> 1.7.10.4
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
