Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id AD29C6B006E
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 08:10:42 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so4193772vbk.14
        for <linux-mm@kvack.org>; Mon, 13 Aug 2012 05:10:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120812093110.GB18057@dhcp22.suse.cz>
References: <20120810094825.GA1440@dhcp22.suse.cz>
	<CAJd=RBDA3pLYDpryxafx6dLoy7Fk8PmY-EFkXCkuJTB2ywfsjA@mail.gmail.com>
	<20120810122730.GA1425@dhcp22.suse.cz>
	<CAJd=RBAvCd-QcyN9N4xWEiLeVqRypzCzbADvD1qTziRVCHjd4Q@mail.gmail.com>
	<20120810125102.GB1425@dhcp22.suse.cz>
	<CAJd=RBB8Yuk1FEQxTUbEEeD96oqnO26VojetuDgRo=JxOfnadw@mail.gmail.com>
	<20120810131643.GC1425@dhcp22.suse.cz>
	<CAJd=RBDtnF6eoTmDu4HOBGfHnWnxNsXEzArR51+-XhzFCwOmOQ@mail.gmail.com>
	<20120810134811.GD1425@dhcp22.suse.cz>
	<CAJd=RBDUJXOHKbes0KE1aQ7tJCYBr04+=-bCbs8xT9wJ-CtrTw@mail.gmail.com>
	<20120812093110.GB18057@dhcp22.suse.cz>
Date: Mon, 13 Aug 2012 20:10:41 +0800
Message-ID: <CAJd=RBAyOZk1qF05seXBS2D-nk9evA5UAWQFpr0wpqk9d+i+Dw@mail.gmail.com>
Subject: Re: [patch] hugetlb: correct page offset index for sharing pmd
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>

On Sun, Aug 12, 2012 at 5:31 PM, Michal Hocko <mhocko@suse.cz> wrote:
> From d07b88a70ee1dbcc96502c48cde878931e7deb38 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Fri, 10 Aug 2012 15:03:07 +0200
> Subject: [PATCH] hugetlb: do not use vma_hugecache_offset for
>  vma_prio_tree_foreach
>
> 0c176d5 (mm: hugetlb: fix pgoff computation when unmapping page
> from vma) fixed pgoff calculation but it has replaced it by
> vma_hugecache_offset which is not approapriate for offsets used for
> vma_prio_tree_foreach because that one expects index in page units
> rather than in huge_page_shift.


What if another case of vma_prio_tree_foreach in try_to_unmap_file
is correct?


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
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
