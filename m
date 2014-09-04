Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0BEF86B0035
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 21:08:23 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id hz1so18722093pad.6
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 18:08:23 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id mi6si421286pab.17.2014.09.03.18.08.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 03 Sep 2014 18:08:23 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id y13so12386290pdi.37
        for <linux-mm@kvack.org>; Wed, 03 Sep 2014 18:08:22 -0700 (PDT)
Date: Wed, 3 Sep 2014 18:06:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 4/6] mm/hugetlb: add migration entry check in
 hugetlb_change_protection
In-Reply-To: <1409276340-7054-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1409031752510.11238@eggly.anvils>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1409276340-7054-5-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, 28 Aug 2014, Naoya Horiguchi wrote:

> There is a race condition between hugepage migration and change_protection(),
> where hugetlb_change_protection() doesn't care about migration entries and
> wrongly overwrites them. That causes unexpected results like kernel crash.
> 
> This patch adds is_hugetlb_entry_(migration|hwpoisoned) check in this
> function to do proper actions.
> 
> ChangeLog v3:
> - handle migration entry correctly (instead of just skipping)
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org> # [2.6.36+]

2.6.36+?  For the hwpoisoned part of it, I suppose.
Then you'd better mentioned the hwpoisoned case in the comment above.

> ---
>  mm/hugetlb.c | 21 ++++++++++++++++++++-
>  1 file changed, 20 insertions(+), 1 deletion(-)
> 
> diff --git mmotm-2014-08-25-16-52.orig/mm/hugetlb.c mmotm-2014-08-25-16-52/mm/hugetlb.c
> index 2aafe073cb06..1ed9df6def54 100644
> --- mmotm-2014-08-25-16-52.orig/mm/hugetlb.c
> +++ mmotm-2014-08-25-16-52/mm/hugetlb.c
> @@ -3362,7 +3362,26 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  			spin_unlock(ptl);
>  			continue;
>  		}
> -		if (!huge_pte_none(huge_ptep_get(ptep))) {
> +		pte = huge_ptep_get(ptep);
> +		if (unlikely(is_hugetlb_entry_hwpoisoned(pte))) {
> +			spin_unlock(ptl);
> +			continue;
> +		}
> +		if (unlikely(is_hugetlb_entry_migration(pte))) {
> +			swp_entry_t entry = pte_to_swp_entry(pte);
> +
> +			if (is_write_migration_entry(entry)) {
> +				pte_t newpte;
> +
> +				make_migration_entry_read(&entry);
> +				newpte = swp_entry_to_pte(entry);
> +				set_pte_at(mm, address, ptep, newpte);

set_huge_pte_at.

(As usual, I can't bear to see these is_hugetlb_entry_hwpoisoned and
is_hugetlb_entry_migration examples go past without bleating about
wanting to streamline them a little; but agreed last time to leave
that to some later cleanup once all the stable backports are stable.)

> +				pages++;
> +			}
> +			spin_unlock(ptl);
> +			continue;
> +		}
> +		if (!huge_pte_none(pte)) {
>  			pte = huge_ptep_get_and_clear(mm, address, ptep);
>  			pte = pte_mkhuge(huge_pte_modify(pte, newprot));
>  			pte = arch_make_huge_pte(pte, vma, NULL, 0);
> -- 
> 1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
