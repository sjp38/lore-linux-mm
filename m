Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 2F5706B0074
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 08:37:48 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so6747356vcb.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 05:37:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1341412376-6272-1-git-send-email-will.deacon@arm.com>
References: <1341412376-6272-1-git-send-email-will.deacon@arm.com>
Date: Thu, 5 Jul 2012 20:37:46 +0800
Message-ID: <CAJd=RBAmF3dtb8wtEbS-A7BNT=RLsb5emQQWVU8ioeQOO8D7NA@mail.gmail.com>
Subject: Re: [PATCH] mm: hugetlb: flush dcache before returning zeroed huge
 page to userspace
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org

On Wed, Jul 4, 2012 at 10:32 PM, Will Deacon <will.deacon@arm.com> wrote:
> When allocating and returning clear huge pages to userspace as a
> response to a fault, we may zero and return a mapping to a previously
> dirtied physical region (for example, it may have been written by
> a private mapping which was freed as a result of an ftruncate on the
> backing file). On architectures with Harvard caches, this can lead to
> I/D inconsistency since the zeroed view may not be visible to the
> instruction stream.
>
> This patch solves the problem by flushing the region after allocating
> and clearing a new huge page. Note that PowerPC avoids this issue by
> performing the flushing in their clear_user_page implementation to keep
> the loader happy, however this is closely tied to the semantics of the
> PG_arch_1 page flag which is architecture-specific.
>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---

Thanks:)

Acked-by: Hillf Danton <dhillf@gmail.com>

>  mm/hugetlb.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index e198831..b83d026 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2646,6 +2646,7 @@ retry:
>                         goto out;
>                 }
>                 clear_huge_page(page, address, pages_per_huge_page(h));
> +               flush_dcache_page(page);
>                 __SetPageUptodate(page);
>
>                 if (vma->vm_flags & VM_MAYSHARE) {
> --
> 1.7.4.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
