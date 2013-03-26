Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id EBECD6B00B4
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 00:25:16 -0400 (EDT)
Date: Tue, 26 Mar 2013 00:25:00 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364271900-byj82fk2-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130325101340.GQ2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325101340.GQ2154@dhcp22.suse.cz>
Subject: Re: [PATCH 01/10] migrate: add migrate_entry_wait_huge()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Mon, Mar 25, 2013 at 11:13:40AM +0100, Michal Hocko wrote:
> On Fri 22-03-13 16:23:46, Naoya Horiguchi wrote:
> > When we have a page fault for the address which is backed by a hugepage
> > under migration, the kernel can't wait correctly until the migration
> > finishes. This is because pte_offset_map_lock() can't get a correct
> > migration entry for hugepage. This patch adds migration_entry_wait_huge()
> > to separate code path between normal pages and hugepages.
> 
> The changelog is missing a description what is the effect of the bug. I
> assume that we end up busy looping on the huge page page fault until
> migration finishes, right?

Right. I'll add it in the description.

> Should this be applied to the stable tree or the current usage of the huge
> page migration (HWPOISON) is not spread enough?

Yes, it's better to also send it to stable.

> I like how you got rid of the duplication but I think this still doesn't
> work for all archs/huge page sizes.
> 
> [...]
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
> e.g. ia64 returns pte_t *

We need arch-independent fix.

> [...]
> > +void migration_entry_wait_huge(struct mm_struct *mm, pmd_t *pmd,
> > +				unsigned long address)
> > +{
> > +	spinlock_t *ptl = pte_lockptr(mm, pmd);
> > +	__migration_entry_wait(mm, (pte_t *)pmd, ptl);
> 
> So you are trying to get lockptr from pmd but you have pte in fact. No
> biggy for !USE_SPLIT_PTLOCKS but doesn't work otherwise. So you probably
> need a arch specific huge_pte_lockptr callback for USE_SPLIT_PTLOCKS.

I must fix it, thanks.
And it might be good to generalize the idea of USE_SPLIT_PTLOCKS to pud and pmd.

> Or am I missing something here? All the pte usage in hugetlb is one
> giant mess and I wouldn't be surprised if there were more places
> hardcoded to pmd there.

Yes, that's a big problem on hugetlb and we need many clean-ups.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
