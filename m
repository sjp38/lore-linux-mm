Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 70A0E6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 00:48:33 -0400 (EDT)
Date: Tue, 06 Aug 2013 00:48:13 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1375764493-7m92dted-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <87eha7oa4l.fsf@linux.vnet.ibm.com>
References: <1375734465-scgr8g4z-mutt-n-horiguchi@ah.jp.nec.com>
 <87eha7oa4l.fsf@linux.vnet.ibm.com>
Subject: Re: [PATCH 9/8] hugetlb: add pmd_huge_support() to migrate only
 pmd-based hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Aug 06, 2013 at 07:26:10AM +0530, Aneesh Kumar K.V wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> > This patch is motivated by the discussion with Aneesh about "extend
> > hugepage migration" patchset.
> >   http://thread.gmane.org/gmane.linux.kernel.mm/103933/focus=104391
> > I'll append this to the patchset in the next post, but before that
> > I want this patch to be reviewed (I don't want to repeat posting the
> > whole set for just minor changes.)
> >
> > Any comments?
> >
> > Thanks,
> > Naoya Horiguchi
> > ---
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Mon, 5 Aug 2013 13:33:02 -0400
> > Subject: [PATCH] hugetlb: add pmd_huge_support() to migrate only pmd-based
> >  hugepage
> >
> > Currently hugepage migration works well only for pmd-based hugepages,
> > because core routines of hugepage migration use pmd specific internal
> > functions like huge_pte_offset(). So we should not enable the migration
> > of other levels of hugepages until we are ready for it.
> 
> I guess huge_pte_offset may not be the right reason because archs do
> implement huge_pte_offsets even if they are not pmd-based hugepages
> 
> pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
> {
> 	/* Only called for hugetlbfs pages, hence can ignore THP */
> 	return find_linux_pte_or_hugepte(mm->pgd, addr, NULL);
> }

You're right, sorry.
Honestly saying, I tested only on x86 and my testing on pud-based hugepage
is not enough (I experienced undissolved bugs,) so I want to restrict the
target for now.

> >
> > Some users of hugepage migration (mbind, move_pages, and migrate_pages)
> > do page table walk and check pud/pmd_huge() there, so they are safe.
> > But the other users (softoffline and memory hotremove) don't do this,
> > so they can try to migrate unexpected types of hugepages.
> >
> > To prevent this, we introduce an architecture dependent check of whether
> > hugepage are implemented on a pmd basis or not. It returns 0 if pmd_huge()
> > returns always 0, and 1 otherwise.
> >
> 
> so why not #define pmd_huge_support pmd_huge or use pmd_huge directly ?

The caller (unmap_and_move_huge_page) doesn't have pmd, so we need do
rmap to get the pmd associated with the source hugepage. Maybe the patch
becomes smaller with this, but maybe it's slower.

Thanks,
Naoya Horiguchi

> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  arch/arm/mm/hugetlbpage.c     |  5 +++++
> >  arch/arm64/mm/hugetlbpage.c   |  5 +++++
> >  arch/ia64/mm/hugetlbpage.c    |  5 +++++
> >  arch/metag/mm/hugetlbpage.c   |  5 +++++
> >  arch/mips/mm/hugetlbpage.c    |  5 +++++
> >  arch/powerpc/mm/hugetlbpage.c | 10 ++++++++++
> >  arch/s390/mm/hugetlbpage.c    |  5 +++++
> >  arch/sh/mm/hugetlbpage.c      |  5 +++++
> >  arch/sparc/mm/hugetlbpage.c   |  5 +++++
> >  arch/tile/mm/hugetlbpage.c    |  5 +++++
> >  arch/x86/mm/hugetlbpage.c     |  8 ++++++++
> >  include/linux/hugetlb.h       |  2 ++
> >  mm/migrate.c                  | 11 +++++++++++
> >  13 files changed, 76 insertions(+)
> >
> > diff --git a/arch/arm/mm/hugetlbpage.c b/arch/arm/mm/hugetlbpage.c
> > index 3d1e4a2..3f3b6a7 100644
> > --- a/arch/arm/mm/hugetlbpage.c
> > +++ b/arch/arm/mm/hugetlbpage.c
> > @@ -99,3 +99,8 @@ int pmd_huge(pmd_t pmd)
> >  {
> >  	return pmd_val(pmd) && !(pmd_val(pmd) & PMD_TABLE_BIT);
> >  }
> > +
> > +int pmd_huge_support(void)
> > +{
> > +	return 1;
> > +}
> 
> -aneesh
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
