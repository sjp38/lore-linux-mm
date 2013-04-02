Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 4E4886B0006
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 10:35:57 -0400 (EDT)
Date: Tue, 02 Apr 2013 10:35:50 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364913350-hwvx480l-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130402092441.GE24345@dhcp22.suse.cz>
References: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1364485358-8745-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130329135730.GB21879@dhcp22.suse.cz>
 <1364577818-615ipxeo-mutt-n-horiguchi@ah.jp.nec.com>
 <20130402092441.GE24345@dhcp22.suse.cz>
Subject: Re: [PATCH 2/2] hugetlbfs: add swap entry check in
 follow_hugetlb_page()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 02, 2013 at 11:24:41AM +0200, Michal Hocko wrote:
> On Fri 29-03-13 13:23:38, Naoya Horiguchi wrote:
> > Hi,
> > 
> > On Fri, Mar 29, 2013 at 02:57:30PM +0100, Michal Hocko wrote:
> > > On Thu 28-03-13 11:42:38, Naoya Horiguchi wrote:
> > > [...]
> > > > @@ -2968,7 +2968,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > > >  		 * first, for the page indexing below to work.
> > > >  		 */
> > > >  		pte = huge_pte_offset(mm, vaddr & huge_page_mask(h));
> > > > -		absent = !pte || huge_pte_none(huge_ptep_get(pte));
> > > > +		absent = !pte || huge_pte_none(huge_ptep_get(pte)) ||
> > > > +			is_swap_pte(huge_ptep_get(pte));
> > > 
> > > is_swap_pte doesn't seem right. Shouldn't you use is_hugetlb_entry_hwpoisoned
> > > instead?
> > 
> > I tested only hwpoisoned hugepage, but the same can happen for hugepages
> > under migration. So I intended to filter out all types of swap entries.
> > The local variable 'absent' seems to mean whether data on the address
> > is immediately available, so swap type entry isn't included in it.
> 
> OK, I didn't consider huge pages under migration and I was merely worried
> that is_hugetlb_entry_hwpoisoned sounds more appropriate than
> is_swap_pte.
> 
> Could you add a comment which would clarify that is_swap_pte covers both
> migration and hwpoison pages, please? Something like:
> 
> 		/*
> 		 * is_swap_pte test covers both is_hugetlb_entry_hwpoisoned
> 		 * and hugepages under migration in which case
> 		 * hugetlb_fault waits for the migration and bails out
> 		 * properly for HWPosined pages.
> 		 */
> 		 absent = !pte || huge_pte_none(huge_ptep_get(pte)) ||
> 		 	 is_swap_pte(huge_ptep_get(pte));

OK, I'll add this.

> Other than that feel free to add
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thank you!
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
