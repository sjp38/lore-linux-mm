Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 33A826B010D
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:59:46 -0400 (EDT)
Received: by mail-ye0-f175.google.com with SMTP id m10so642830yen.6
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 11:59:45 -0700 (PDT)
Message-ID: <515F1F1F.6060900@gmail.com>
Date: Fri, 05 Apr 2013 14:59:43 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 3/3] hugetlbfs: add swap entry check in follow_hugetlb_page()
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1365014138-19589-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365014138-19589-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(4/3/13 2:35 PM), Naoya Horiguchi wrote:
> With applying the previous patch "hugetlbfs: stop setting VM_DONTDUMP in
> initializing vma(VM_HUGETLB)" to reenable hugepage coredump, if a memory
> error happens on a hugepage and the affected processes try to access
> the error hugepage, we hit VM_BUG_ON(atomic_read(&page->_count) <= 0)
> in get_page().
> 
> The reason for this bug is that coredump-related code doesn't recognise
> "hugepage hwpoison entry" with which a pmd entry is replaced when a memory
> error occurs on a hugepage.
> In other words, physical address information is stored in different bit layout
> between hugepage hwpoison entry and pmd entry, so follow_hugetlb_page()
> which is called in get_dump_page() returns a wrong page from a given address.
> 
> We need to filter out only hwpoison hugepages to have data on healthy
> hugepages in coredump. So this patch makes follow_hugetlb_page() avoid
> trying to get page when a pmd is in swap entry like format.
> 
> ChangeLog v3:
>  - add comment about using is_swap_pte()
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: stable@vger.kernel.org
> ---
>  mm/hugetlb.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
> index 0d1705b..3bc20bd 100644
> --- v3.9-rc3.orig/mm/hugetlb.c
> +++ v3.9-rc3/mm/hugetlb.c
> @@ -2966,9 +2966,15 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		 * Some archs (sparc64, sh*) have multiple pte_ts to
>  		 * each hugepage.  We have to make sure we get the
>  		 * first, for the page indexing below to work.
> +		 *
> +		 * is_swap_pte test covers both is_hugetlb_entry_hwpoisoned
> +		 * and hugepages under migration in which case
> +		 * hugetlb_fault waits for the migration and bails out
> +		 * properly for HWPosined pages.
>  		 */
>  		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
> -		absent = !pte || huge_pte_none(huge_ptep_get(pte));
> +		absent = !pte || huge_pte_none(huge_ptep_get(pte)) ||
> +			is_swap_pte(huge_ptep_get(pte));

Hmmm...

Now absent has two meanings. 1) skip hugetlb_fault() and return immediately if FOLL_DUMP is used.
2) call hugetlb_fault() if to be need page population or cow.

The description of this patch only explain about (2). and I'm not convinced why we don't need to
dump pages under migraion.












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
