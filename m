Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id D6C8C6B004D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 16:01:54 -0400 (EDT)
Date: Mon, 08 Apr 2013 16:00:12 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365451212-xj25037p-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <515F351C.403@gmail.com>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F351C.403@gmail.com>
Subject: Re: [PATCH 01/10] migrate: add migrate_entry_wait_huge()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org

On Fri, Apr 05, 2013 at 04:33:32PM -0400, KOSAKI Motohiro wrote:
> > diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
> > index 0a0be33..98a478e 100644
> > --- v3.9-rc3.orig/mm/hugetlb.c
> > +++ v3.9-rc3/mm/hugetlb.c
> > @@ -2819,7 +2819,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	if (ptep) {
> >  		entry = huge_ptep_get(ptep);
> >  		if (unlikely(is_hugetlb_entry_migration(entry))) {
> > -			migration_entry_wait(mm, (pmd_t *)ptep, address);
> > +			migration_entry_wait_huge(mm, (pmd_t *)ptep, address);
> 
> Hm.
> 
> How do you test this? From x86 point of view, this patch seems unnecessary because
> hugetlb_fault call "address &= hugetlb_mask()" at first and then migration_entry_wait()
> could grab right pte lock. And from !x86 point of view, this funciton still doesn't work
> because huge page != pmd on some arch.

I kicked hugepage migration for address range where I repeat to access
in a loop, and checked what happened (whether soft lockup happens or not.)
But I don't fully understand what the problem is, and I might wrongly define
the problem. So give me time to clarify it.

And I fully agree that this function should be arch dependent.

> I might be missing though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
