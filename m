Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id C1F9D6B0112
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:33:34 -0400 (EDT)
Received: by mail-qe0-f50.google.com with SMTP id k5so2299494qej.9
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 13:33:33 -0700 (PDT)
Message-ID: <515F351C.403@gmail.com>
Date: Fri, 05 Apr 2013 16:33:32 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] migrate: add migrate_entry_wait_huge()
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1363983835-20184-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1363983835-20184-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

> diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
> index 0a0be33..98a478e 100644
> --- v3.9-rc3.orig/mm/hugetlb.c
> +++ v3.9-rc3/mm/hugetlb.c
> @@ -2819,7 +2819,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (ptep) {
>  		entry = huge_ptep_get(ptep);
>  		if (unlikely(is_hugetlb_entry_migration(entry))) {
> -			migration_entry_wait(mm, (pmd_t *)ptep, address);
> +			migration_entry_wait_huge(mm, (pmd_t *)ptep, address);

Hm.

How do you test this? From x86 point of view, this patch seems unnecessary because
hugetlb_fault call "address &= hugetlb_mask()" at first and then migration_entry_wait()
could grab right pte lock. And from !x86 point of view, this funciton still doesn't work
because huge page != pmd on some arch.

I might be missing though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
