Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 004F16B003A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:27:40 -0400 (EDT)
Date: Mon, 08 Apr 2013 15:27:32 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365449252-9pc7knd5-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <515F1F1F.6060900@gmail.com>
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1365014138-19589-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F1F1F.6060900@gmail.com>
Subject: Re: [PATCH v3 3/3] hugetlbfs: add swap entry check in
 follow_hugetlb_page()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 05, 2013 at 02:59:43PM -0400, KOSAKI Motohiro wrote:
> (4/3/13 2:35 PM), Naoya Horiguchi wrote:
> > With applying the previous patch "hugetlbfs: stop setting VM_DONTDUMP in
> > initializing vma(VM_HUGETLB)" to reenable hugepage coredump, if a memory
> > error happens on a hugepage and the affected processes try to access
> > the error hugepage, we hit VM_BUG_ON(atomic_read(&page->_count) <= 0)
> > in get_page().
> > 
> > The reason for this bug is that coredump-related code doesn't recognise
> > "hugepage hwpoison entry" with which a pmd entry is replaced when a memory
> > error occurs on a hugepage.
> > In other words, physical address information is stored in different bit layout
> > between hugepage hwpoison entry and pmd entry, so follow_hugetlb_page()
> > which is called in get_dump_page() returns a wrong page from a given address.
> > 
> > We need to filter out only hwpoison hugepages to have data on healthy
> > hugepages in coredump. So this patch makes follow_hugetlb_page() avoid
> > trying to get page when a pmd is in swap entry like format.
> > 
> > ChangeLog v3:
> >  - add comment about using is_swap_pte()
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Reviewed-by: Michal Hocko <mhocko@suse.cz>
> > Acked-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> > Cc: stable@vger.kernel.org
> > ---
> >  mm/hugetlb.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
> > index 0d1705b..3bc20bd 100644
> > --- v3.9-rc3.orig/mm/hugetlb.c
> > +++ v3.9-rc3/mm/hugetlb.c
> > @@ -2966,9 +2966,15 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		 * Some archs (sparc64, sh*) have multiple pte_ts to
> >  		 * each hugepage.  We have to make sure we get the
> >  		 * first, for the page indexing below to work.
> > +		 *
> > +		 * is_swap_pte test covers both is_hugetlb_entry_hwpoisoned
> > +		 * and hugepages under migration in which case
> > +		 * hugetlb_fault waits for the migration and bails out
> > +		 * properly for HWPosined pages.
> >  		 */
> >  		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
> > -		absent = !pte || huge_pte_none(huge_ptep_get(pte));
> > +		absent = !pte || huge_pte_none(huge_ptep_get(pte)) ||
> > +			is_swap_pte(huge_ptep_get(pte));
> 
> Hmmm...
> 
> Now absent has two meanings. 1) skip hugetlb_fault() and return immediately if FOLL_DUMP is used.
> 2) call hugetlb_fault() if to be need page population or cow.
> 
> The description of this patch only explain about (2). and I'm not convinced why we don't need to
> dump pages under migraion.

We can/should dump hugepages under migration, and to do that we have to
put is_swap_pte() in the check of the hugetlb_falut block.
I updated this patch like below.

# I suspended Reviewed and Acked given for the previous version, because
# it has a non-minor change. If you want to restore it, please let me know.

Thanks,
Naoya
------------------------------------------------------------------------
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Thu, 28 Mar 2013 10:17:38 -0400
Subject: [PATCH v4] hugetlbfs: add swap entry check in follow_hugetlb_page()

With applying the previous patch "hugetlbfs: stop setting VM_DONTDUMP in
initializing vma(VM_HUGETLB)" to reenable hugepage coredump, if a memory
error happens on a hugepage and the affected processes try to access
the error hugepage, we hit VM_BUG_ON(atomic_read(&page->_count) <= 0)
in get_page().

The reason for this bug is that coredump-related code doesn't recognise
"hugepage hwpoison entry" with which a pmd entry is replaced when a memory
error occurs on a hugepage.
In other words, physical address information is stored in different bit layout
between hugepage hwpoison entry and pmd entry, so follow_hugetlb_page()
which is called in get_dump_page() returns a wrong page from a given address.

The expected behavior is like this:

  absent    is_swap_pte    FOLL_DUMP   Expected behavior
  ---------------------------------------------------------------------
   true      false          false      hugetlb_fault
   false     true           false      hugetlb_fault
   false     false          false      return page
   true      false          true       skip page (to avoid allocation)
   false     true           true       hugetlb_fault
   false     false          true       return page

With this patch, we can call hugetlb_fault() and take proper actions
(we can wait for migration entries, fail with VM_FAULT_HWPOISON_LARGE for
hwpoisoned entries,) and as the result we can dump all hugepages except
for hwpoisoned ones.

ChangeLog v4:
 - move is_swap_page() to right place.

ChangeLog v3:
 - add comment about using is_swap_pte()

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org
---
 mm/hugetlb.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 0d1705b..f155e59 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2983,7 +2983,13 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			break;
 		}
 
-		if (absent ||
+		/*
+		 * is_swap_pte test covers both is_hugetlb_entry_hwpoisoned
+		 * and hugepages under migration in which case
+		 * hugetlb_fault waits for the migration and bails out
+		 * properly for HWPosined pages.
+		 */
+		if (absent || is_swap_pte(huge_ptep_get(pte)) ||
 		    ((flags & FOLL_WRITE) && !pte_write(huge_ptep_get(pte)))) {
 			int ret;
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
