Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 113AA6B0038
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 15:13:28 -0500 (EST)
Received: by igbhl2 with SMTP id hl2so12048763igb.5
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 12:13:27 -0800 (PST)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id z12si5132271igu.0.2015.03.07.12.13.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Mar 2015 12:13:27 -0800 (PST)
Received: by iecat20 with SMTP id at20so40480933iec.6
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 12:13:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425741651-29152-2-git-send-email-mgorman@suse.de>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
	<1425741651-29152-2-git-send-email-mgorman@suse.de>
Date: Sat, 7 Mar 2015 12:13:27 -0800
Message-ID: <CA+55aFwGLOfmBMHsFzuqKbJqR43+SVydv5zxh-KWMPD=fQG1UQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: thp: Return the correct value for change_huge_pmd
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

Looks obviously correct. The old code was just very wrong.

Acked-by: Linus Torvalds <torvalds@linux-foundation.org>

                     Linus


On Sat, Mar 7, 2015 at 7:20 AM, Mel Gorman <mgorman@suse.de> wrote:
> The wrong value is being returned by change_huge_pmd since commit
> 10c1045f28e8 ("mm: numa: avoid unnecessary TLB flushes when setting
> NUMA hinting entries") which allows a fallthrough that tries to adjust
> non-existent PTEs. This patch corrects it.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/huge_memory.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index fc00c8cb5a82..194c0f019774 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1482,6 +1482,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>
>         if (__pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
>                 pmd_t entry;
> +               ret = 1;
>
>                 /*
>                  * Avoid trapping faults against the zero page. The read-only
> @@ -1490,11 +1491,10 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>                  */
>                 if (prot_numa && is_huge_zero_pmd(*pmd)) {
>                         spin_unlock(ptl);
> -                       return 0;
> +                       return ret;
>                 }
>
>                 if (!prot_numa || !pmd_protnone(*pmd)) {
> -                       ret = 1;
>                         entry = pmdp_get_and_clear_notify(mm, addr, pmd);
>                         entry = pmd_modify(entry, newprot);
>                         ret = HPAGE_PMD_NR;
> --
> 2.1.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
