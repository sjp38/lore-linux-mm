Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 768246B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 21:56:24 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 6 Aug 2013 11:48:13 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id F3BB72BB0054
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 11:56:15 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r761eZjh590122
	for <linux-mm@kvack.org>; Tue, 6 Aug 2013 11:40:36 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r761uDKp004495
	for <linux-mm@kvack.org>; Tue, 6 Aug 2013 11:56:14 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 9/8] hugetlb: add pmd_huge_support() to migrate only pmd-based hugepage
In-Reply-To: <1375734465-scgr8g4z-mutt-n-horiguchi@ah.jp.nec.com>
References: <1375734465-scgr8g4z-mutt-n-horiguchi@ah.jp.nec.com>
Date: Tue, 06 Aug 2013 07:26:10 +0530
Message-ID: <87eha7oa4l.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

> This patch is motivated by the discussion with Aneesh about "extend
> hugepage migration" patchset.
>   http://thread.gmane.org/gmane.linux.kernel.mm/103933/focus=104391
> I'll append this to the patchset in the next post, but before that
> I want this patch to be reviewed (I don't want to repeat posting the
> whole set for just minor changes.)
>
> Any comments?
>
> Thanks,
> Naoya Horiguchi
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Mon, 5 Aug 2013 13:33:02 -0400
> Subject: [PATCH] hugetlb: add pmd_huge_support() to migrate only pmd-based
>  hugepage
>
> Currently hugepage migration works well only for pmd-based hugepages,
> because core routines of hugepage migration use pmd specific internal
> functions like huge_pte_offset(). So we should not enable the migration
> of other levels of hugepages until we are ready for it.

I guess huge_pte_offset may not be the right reason because archs do
implement huge_pte_offsets even if they are not pmd-based hugepages

pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
{
	/* Only called for hugetlbfs pages, hence can ignore THP */
	return find_linux_pte_or_hugepte(mm->pgd, addr, NULL);
}

>
> Some users of hugepage migration (mbind, move_pages, and migrate_pages)
> do page table walk and check pud/pmd_huge() there, so they are safe.
> But the other users (softoffline and memory hotremove) don't do this,
> so they can try to migrate unexpected types of hugepages.
>
> To prevent this, we introduce an architecture dependent check of whether
> hugepage are implemented on a pmd basis or not. It returns 0 if pmd_huge()
> returns always 0, and 1 otherwise.
>

so why not #define pmd_huge_support pmd_huge or use pmd_huge directly ?

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  arch/arm/mm/hugetlbpage.c     |  5 +++++
>  arch/arm64/mm/hugetlbpage.c   |  5 +++++
>  arch/ia64/mm/hugetlbpage.c    |  5 +++++
>  arch/metag/mm/hugetlbpage.c   |  5 +++++
>  arch/mips/mm/hugetlbpage.c    |  5 +++++
>  arch/powerpc/mm/hugetlbpage.c | 10 ++++++++++
>  arch/s390/mm/hugetlbpage.c    |  5 +++++
>  arch/sh/mm/hugetlbpage.c      |  5 +++++
>  arch/sparc/mm/hugetlbpage.c   |  5 +++++
>  arch/tile/mm/hugetlbpage.c    |  5 +++++
>  arch/x86/mm/hugetlbpage.c     |  8 ++++++++
>  include/linux/hugetlb.h       |  2 ++
>  mm/migrate.c                  | 11 +++++++++++
>  13 files changed, 76 insertions(+)
>
> diff --git a/arch/arm/mm/hugetlbpage.c b/arch/arm/mm/hugetlbpage.c
> index 3d1e4a2..3f3b6a7 100644
> --- a/arch/arm/mm/hugetlbpage.c
> +++ b/arch/arm/mm/hugetlbpage.c
> @@ -99,3 +99,8 @@ int pmd_huge(pmd_t pmd)
>  {
>  	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
>  }
> +
> +int pmd_huge_support(void)
> +{
> +	return 1;
> +}

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
