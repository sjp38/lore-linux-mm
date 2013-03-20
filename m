Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 689E96B0036
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 18:00:18 -0400 (EDT)
Date: Wed, 20 Mar 2013 17:59:53 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1363816793-7eq6pu0l-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <5149034A.5050907@gmail.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130318154057.GS10192@dhcp22.suse.cz>
 <1363651636-3lsf20se-mutt-n-horiguchi@ah.jp.nec.com>
 <5149034A.5050907@gmail.com>
Subject: Re: [PATCH 5/9] migrate: enable migrate_pages() to migrate hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Wed, Mar 20, 2013 at 08:31:06AM +0800, Simon Jeons wrote:
...
> >>> diff --git v3.8.orig/mm/mempolicy.c v3.8/mm/mempolicy.c
> >>> index e2df1c1..8627135 100644
> >>> --- v3.8.orig/mm/mempolicy.c
> >>> +++ v3.8/mm/mempolicy.c
> >>> @@ -525,6 +525,27 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >>>  	return addr != end;
> >>>  }
> >>>  
> >>> +static void check_hugetlb_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
> >>> +		const nodemask_t *nodes, unsigned long flags,
> >>> +				    void *private)
> >>> +{
> >>> +#ifdef CONFIG_HUGETLB_PAGE
> >>> +	int nid;
> >>> +	struct page *page;
> >>> +
> >>> +	spin_lock(&vma->vm_mm->page_table_lock);
> >>> +	page = pte_page(huge_ptep_get((pte_t *)pmd));
> >>> +	spin_unlock(&vma->vm_mm->page_table_lock);
> >> I am a bit confused why page_table_lock is used here and why it doesn't
> >> cover the page usage.
> > I expected this function to do the same for pmd as check_pte_range() does
> > for pte, but the above code didn't do it. I should've put spin_unlock
> > below migrate_hugepage_add(). Sorry for the confusion.
> 
> I still confuse! Could you explain more in details?

With the above code, check_hugetlb_pmd_range() checks page_mapcount
outside the page table lock, but mapcount can be decremented by
__unmap_hugepage_range(), so there's a race.
__unmap_hugepage_range() calls page_remove_rmap() inside page table lock,
so we can avoid this race by doing whole check_hugetlb_pmd_range()'s work
inside the page table lock.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
