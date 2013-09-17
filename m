Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id E82EF6B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 11:19:13 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1379366550-9vhj3y8s-mutt-n-horiguchi@ah.jp.nec.com>
References: <1379117362-gwv3vrog-mutt-n-horiguchi@ah.jp.nec.com>
 <20130916104205.5605CE0090@blue.fi.intel.com>
 <1379366550-9vhj3y8s-mutt-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4] hugetlbfs: support split page table lock
Content-Transfer-Encoding: 7bit
Message-Id: <20130917151851.09771E0090@blue.fi.intel.com>
Date: Tue, 17 Sep 2013 18:18:51 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Alex Thorlton <athorlton@sgi.com>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

Naoya Horiguchi wrote:
> On Mon, Sep 16, 2013 at 01:42:05PM +0300, Kirill A. Shutemov wrote:
> > Naoya Horiguchi wrote:
> > > Hi,
> > > 
> > > Kirill posted split_ptl patchset for thp today, so in this version
> > > I post only hugetlbfs part. I added Kconfig variables in following
> > > Kirill's patches (although without CONFIG_SPLIT_*_PTLOCK_CPUS.)
> > > 
> > > This patch changes many lines, but all are in hugetlbfs specific code,
> > > so I think we can apply this independent of thp patches.
> > > -----
> > > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Date: Fri, 13 Sep 2013 18:12:30 -0400
> > > Subject: [PATCH v4] hugetlbfs: support split page table lock
> > > 
> > > Currently all of page table handling by hugetlbfs code are done under
> > > mm->page_table_lock. So when a process have many threads and they heavily
> > > access to the memory, lock contention happens and impacts the performance.
> > > 
> > > This patch makes hugepage support split page table lock so that we use
> > > page->ptl of the leaf node of page table tree which is pte for normal pages
> > > but can be pmd and/or pud for hugepages of some architectures.
> > > 
> > > ChangeLog v4:
> > >  - introduce arch dependent macro ARCH_ENABLE_SPLIT_HUGETLB_PTLOCK
> > >    (only defined for x86 for now)
> > >  - rename USE_SPLIT_PTLOCKS_HUGETLB to USE_SPLIT_HUGETLB_PTLOCKS
> > > 
> > > ChangeLog v3:
> > >  - disable split ptl for ppc with USE_SPLIT_PTLOCKS_HUGETLB.
> > >  - remove replacement in some architecture dependent code. This is justified
> > >    because an allocation of pgd/pud/pmd/pte entry can race with other
> > >    allocation, not with read/write access, so we can use different locks.
> > >    http://thread.gmane.org/gmane.linux.kernel.mm/106292/focus=106458
> > > 
> > > ChangeLog v2:
> > >  - add split ptl on other archs missed in v1
> > >  - drop changes on arch/{powerpc,tile}/mm/hugetlbpage.c
> > > 
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > ---
> > >  arch/x86/Kconfig         |  4 +++
> > >  include/linux/hugetlb.h  | 20 +++++++++++
> > >  include/linux/mm_types.h |  2 ++
> > >  mm/Kconfig               |  3 ++
> > >  mm/hugetlb.c             | 92 +++++++++++++++++++++++++++++-------------------
> > >  mm/mempolicy.c           |  5 +--
> > >  mm/migrate.c             |  4 +--
> > >  mm/rmap.c                |  2 +-
> > >  8 files changed, 91 insertions(+), 41 deletions(-)
> > > 
> > > diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> > > index 6a5cf6a..5b83d14 100644
> > > --- a/arch/x86/Kconfig
> > > +++ b/arch/x86/Kconfig
> > > @@ -1884,6 +1884,10 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
> > >  	def_bool y
> > >  	depends on X86_64 || X86_PAE
> > >  
> > > +config ARCH_ENABLE_SPLIT_HUGETLB_PTLOCK
> > > +	def_bool y
> > > +	depends on X86_64 || X86_PAE
> > > +
> > >  menu "Power management and ACPI options"
> > >  
> > >  config ARCH_HIBERNATION_HEADER
> > > diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> > > index 0393270..2cdac68 100644
> > > --- a/include/linux/hugetlb.h
> > > +++ b/include/linux/hugetlb.h
> > > @@ -80,6 +80,24 @@ extern const unsigned long hugetlb_zero, hugetlb_infinity;
> > >  extern int sysctl_hugetlb_shm_group;
> > >  extern struct list_head huge_boot_pages;
> > >  
> > > +#if USE_SPLIT_HUGETLB_PTLOCKS
> > > +#define huge_pte_lockptr(mm, ptep) ({__pte_lockptr(virt_to_page(ptep)); })
> > > +#else	/* !USE_SPLIT_HUGETLB_PTLOCKS */
> > > +#define huge_pte_lockptr(mm, ptep) ({&(mm)->page_table_lock; })
> > > +#endif	/* USE_SPLIT_HUGETLB_PTLOCKS */
> > > +
> > > +#define huge_pte_offset_lock(mm, address, ptlp)		\
> > > +({							\
> > > +	pte_t *__pte = huge_pte_offset(mm, address);	\
> > > +	spinlock_t *__ptl = NULL;			\
> > > +	if (__pte) {					\
> > > +		__ptl = huge_pte_lockptr(mm, __pte);	\
> > > +		*(ptlp) = __ptl;			\
> > > +		spin_lock(__ptl);			\
> > > +	}						\
> > > +	__pte;						\
> > > +})
> > > +
> > 
> > [ Disclaimer: I don't know much about hugetlb. ]
> > 
> > I don't think it's correct. Few points:
> > 
> >  - Hugetlb supports multiple page sizes: on x86_64 2M (PMD) and 1G (PUD).
> >    My patchset only implements it for PMD. We don't even initialize
> >    spinlock in struct page for PUD.
> 
> In hugetlbfs code, we use huge_pte_offset() to get leaf level entries
> which can be pud or pmd in x86. huge_pte_lockptr() uses this function,
> so we can always get the correct ptl regardless of hugepage sizes.
> As for spinlock initialization, you're right. I'll add it on huge_pte_alloc().

Please, don't.
If USE_SPLIT_PMD_PTLOCKS is true, pmd_alloc_one() will do it for you
already for PMD table.

For pud it should be done in pud_alloc_one(), not in hugetlb code.

We already have too many special cases for hugetlb. Don't contribute to
the mess.

> >  - If we enable split PMD lock we should use it *globally*. With you patch
> >    we can end up with different locks used by hugetlb and rest of kernel
> >    to protect the same PMD table if USE_SPLIT_HUGETLB_PTLOCKS !=
> >    USE_SPLIT_PMD_PTLOCKS. It's just broken.
> 
> I don't think so. Thp specific operations (like thp allocation, split,
> and collapse) are never called on the virtual address range covered by
> vma(VM_HUGETLB) by checking VM_HUGETLB. So no one tries to lock/unlock
> a ptl concurrently from thp context and hugetlbfs context.

Two vma's can be next to each other and share the same PMD table (not
entries) and in this case I don't see what will serialize pmd_alloc() if
USE_SPLIT_HUGETLB_PTLOCKS != USE_SPLIT_PMD_PTLOCKS.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
