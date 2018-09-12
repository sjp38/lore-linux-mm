Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECB38E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:25:02 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id z17-v6so1325042wrr.16
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 03:25:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k41-v6sor518338wre.19.2018.09.12.03.25.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 03:25:00 -0700 (PDT)
Date: Wed, 12 Sep 2018 13:24:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, thp: Fix mlocking THP page with migration enabled
Message-ID: <20180912102457.deuqtyx2b67zfi7u@kshutemo-mobl1>
References: <20180911103403.38086-1-kirill.shutemov@linux.intel.com>
 <6fcb5b5b-43fa-f1d0-ce78-37fb51b46a75@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6fcb5b5b-43fa-f1d0-ce78-37fb51b46a75@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneeshkumar.opensource@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Sep 12, 2018 at 03:28:24PM +0530, Aneesh Kumar K.V wrote:
> On 9/11/18 4:04 PM, Kirill A. Shutemov wrote:
> > A transparent huge page is represented by a single entry on an LRU list.
> > Therefore, we can only make unevictable an entire compound page, not
> > individual subpages.
> > 
> > If a user tries to mlock() part of a huge page, we want the rest of the
> > page to be reclaimable.
> > 
> > We handle this by keeping PTE-mapped huge pages on normal LRU lists: the
> > PMD on border of VM_LOCKED VMA will be split into PTE table.
> > 
> > Introduction of THP migration breaks the rules around mlocking THP
> > pages. If we had a single PMD mapping of the page in mlocked VMA, the
> > page will get mlocked, regardless of PTE mappings of the page.
> > 
> > For tmpfs/shmem it's easy to fix by checking PageDoubleMap() in
> > remove_migration_pmd().
> > 
> > Anon THP pages can only be shared between processes via fork(). Mlocked
> > page can only be shared if parent mlocked it before forking, otherwise
> > CoW will be triggered on mlock().
> > 
> > For Anon-THP, we can fix the issue by munlocking the page on removing PTE
> > migration entry for the page. PTEs for the page will always come after
> > mlocked PMD: rmap walks VMAs from oldest to newest.
> > 
> > Test-case:
> > 
> > 	#include <unistd.h>
> > 	#include <sys/mman.h>
> > 	#include <sys/wait.h>
> > 	#include <linux/mempolicy.h>
> > 	#include <numaif.h>
> > 
> > 	int main(void)
> > 	{
> > 	        unsigned long nodemask = 4;
> > 	        void *addr;
> > 
> > 		addr = mmap((void *)0x20000000UL, 2UL << 20, PROT_READ | PROT_WRITE,
> > 			MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKED, -1, 0);
> > 
> > 	        if (fork()) {
> > 			wait(NULL);
> > 			return 0;
> > 	        }
> > 
> > 	        mlock(addr, 4UL << 10);
> > 	        mbind(addr, 2UL << 20, MPOL_PREFERRED | MPOL_F_RELATIVE_NODES,
> > 	                &nodemask, 4, MPOL_MF_MOVE | MPOL_MF_MOVE_ALL);
> > 
> > 	        return 0;
> > 	}
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
> > Fixes: 616b8371539a ("mm: thp: enable thp migration in generic path")
> > Cc: <stable@vger.kernel.org> [v4.14+]
> > Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >   mm/huge_memory.c | 2 +-
> >   mm/migrate.c     | 3 +++
> >   2 files changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 533f9b00147d..00704060b7f7 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2931,7 +2931,7 @@ void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
> >   	else
> >   		page_add_file_rmap(new, true);
> >   	set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
> > -	if (vma->vm_flags & VM_LOCKED)
> > +	if ((vma->vm_flags & VM_LOCKED) && !PageDoubleMap(new))
> >   		mlock_vma_page(new);
> >   	update_mmu_cache_pmd(vma, address, pvmw->pmd);
> >   }
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index d6a2e89b086a..01dad96b25b5 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -275,6 +275,9 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
> >   		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(new))
> >   			mlock_vma_page(new);
> > +		if (PageTransCompound(new) && PageMlocked(page))
> > +			clear_page_mlock(page);
> > +
> 
> Can you explain this more? I am confused by the usage of 'new' and 'page'
> there.

'new' is the PTE subpage of 'page'. clear_page_mlock() wants to see head
page.

I guess we can rewrite it more clearly:

+		if (PageTransHuge(page) && PageMlocked(page))
+			clear_page_mlock(page);
+

> I guess the idea is if we are removing the migration pte at level 4
> table, and if we found the backing page compound don't mark the page
> Mlocked?

We has to clear mlock, not only don't mark it as such.
remove_migration_pmd() for other VMA may mark it as mlock and we want to
revert it on the first PTE mapping of the page.

-- 
 Kirill A. Shutemov
