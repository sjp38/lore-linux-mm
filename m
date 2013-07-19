Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 6FA126B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 00:14:08 -0400 (EDT)
Date: Fri, 19 Jul 2013 00:13:44 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1374207224-agckpfwt-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAJd=RBB8D0YgEPwRKTB5+OXMEX9kfpFM5gXdWekrjfQ66EXrgA@mail.gmail.com>
References: <1374183272-10153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1374183272-10153-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CAJd=RBB8D0YgEPwRKTB5+OXMEX9kfpFM5gXdWekrjfQ66EXrgA@mail.gmail.com>
Subject: Re: [PATCH 3/8] migrate: add hugepage migration code to
 migrate_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jul 19, 2013 at 11:05:37AM +0800, Hillf Danton wrote:
> On Fri, Jul 19, 2013 at 5:34 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > This patch extends check_range() to handle vma with VM_HUGETLB set.
> > We will be able to migrate hugepage with migrate_pages(2) after
> > applying the enablement patch which comes later in this series.
> >
> > Note that for larger hugepages (covered by pud entries, 1GB for
> > x86_64 for example), we simply skip it now.
> >
> > Note that using pmd_huge/pud_huge assumes that hugepages are pointed to
> > by pmd/pud. This is not true in some architectures implementing hugepage
> > with other mechanisms like ia64, but it's OK because pmd_huge/pud_huge
> > simply return 0 in such arch and page walker simply ignores such hugepages.
> >
> > ChangeLog v3:
> >  - revert introducing migrate_movable_pages
> >  - use isolate_huge_page
> >
> > ChangeLog v2:
> >  - remove unnecessary extern
> >  - fix page table lock in check_hugetlb_pmd_range
> >  - updated description and renamed patch title
> >
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/mempolicy.c | 39 ++++++++++++++++++++++++++++++++++-----
> >  1 file changed, 34 insertions(+), 5 deletions(-)
> >
> > diff --git v3.11-rc1.orig/mm/mempolicy.c v3.11-rc1/mm/mempolicy.c
> > index 7431001..f3b65c0 100644
> > --- v3.11-rc1.orig/mm/mempolicy.c
> > +++ v3.11-rc1/mm/mempolicy.c
> > @@ -512,6 +512,27 @@ static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >         return addr != end;
> >  }
> >
> > +static void check_hugetlb_pmd_range(struct vm_area_struct *vma, pmd_t *pmd,
> > +               const nodemask_t *nodes, unsigned long flags,
> > +                                   void *private)
> > +{
> > +#ifdef CONFIG_HUGETLB_PAGE
> > +       int nid;
> > +       struct page *page;
> > +
> > +       spin_lock(&vma->vm_mm->page_table_lock);
> > +       page = pte_page(huge_ptep_get((pte_t *)pmd));
> > +       nid = page_to_nid(page);
> 
> Can you please add a brief comment for the if block?

Hmm, honestly saying, I just copied this complex if-condition from
check_pte_range() and opened migrate_page_add(), and refactored.
But this refactoring might not be good considering readability.
I will factorize duplicated logic into a single function and
add some comment to make it more readable.

Thanks,
Naoya

> > +       if (node_isset(nid, *nodes) != !!(flags & MPOL_MF_INVERT)
> > +           && ((flags & MPOL_MF_MOVE && page_mapcount(page) == 1)
> > +               || flags & MPOL_MF_MOVE_ALL))
> > +               isolate_huge_page(page, private);
> > +       spin_unlock(&vma->vm_mm->page_table_lock);
> > +#else
> > +       BUG();
> > +#endif
> > +}
> > +
> >  static inline int check_pmd_range(struct vm_area_struct *vma, pud_t *pud,
> >                 unsigned long addr, unsigned long end,
> >                 const nodemask_t *nodes, unsigned long flags,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
