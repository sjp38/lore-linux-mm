Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 02B986B0038
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 02:03:09 -0400 (EDT)
Received: by mail-qc0-f182.google.com with SMTP id m20so11896563qcx.27
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 23:03:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l8si348569qay.57.2014.09.04.23.03.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Sep 2014 23:03:09 -0700 (PDT)
Date: Fri, 5 Sep 2014 01:27:51 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 2/6] mm/hugetlb: take page table lock in
 follow_huge_(addr|pmd|pud)()
Message-ID: <20140905052751.GA6883@nhori.redhat.com>
References: <1409276340-7054-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1409276340-7054-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.LSU.2.11.1409031243420.9023@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409031243420.9023@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

Hi Hugh,

Thank you very much for you close looking and valuable comments.
And I can't help feeling shame on many mistakes/misunderstandings
and lack of thoughts throughout the patchset.
I promise that all these will be fixed in the next version.

On Wed, Sep 03, 2014 at 02:17:41PM -0700, Hugh Dickins wrote:
> On Thu, 28 Aug 2014, Naoya Horiguchi wrote:
> 
> > We have a race condition between move_pages() and freeing hugepages,
> > where move_pages() calls follow_page(FOLL_GET) for hugepages internally
> > and tries to get its refcount without preventing concurrent freeing.
> > This race crashes the kernel, so this patch fixes it by moving FOLL_GET
> > code for hugepages into follow_huge_pmd() with taking the page table lock.
> 
> You really ought to mention how you are intentionally dropping the
> unnecessary check for NULL pte_page() in this patch: we agree on that,
> but it does need to be mentioned somewhere in the comment.

OK, I'll add it.

> > 
> > This patch also adds the similar locking to follow_huge_(addr|pud)
> > for consistency.
> > 
> > Here is the reproducer:
> > 
> >   $ cat movepages.c
> >   #include <stdio.h>
> >   #include <stdlib.h>
> >   #include <numaif.h>
> > 
> >   #define ADDR_INPUT      0x700000000000UL
> >   #define HPS             0x200000
> >   #define PS              0x1000
> > 
> >   int main(int argc, char *argv[]) {
> >           int i;
> >           int nr_hp = strtol(argv[1], NULL, 0);
> >           int nr_p  = nr_hp * HPS / PS;
> >           int ret;
> >           void **addrs;
> >           int *status;
> >           int *nodes;
> >           pid_t pid;
> > 
> >           pid = strtol(argv[2], NULL, 0);
> >           addrs  = malloc(sizeof(char *) * nr_p + 1);
> >           status = malloc(sizeof(char *) * nr_p + 1);
> >           nodes  = malloc(sizeof(char *) * nr_p + 1);
> > 
> >           while (1) {
> >                   for (i = 0; i < nr_p; i++) {
> >                           addrs[i] = (void *)ADDR_INPUT + i * PS;
> >                           nodes[i] = 1;
> >                           status[i] = 0;
> >                   }
> >                   ret = numa_move_pages(pid, nr_p, addrs, nodes, status,
> >                                         MPOL_MF_MOVE_ALL);
> >                   if (ret == -1)
> >                           err("move_pages");
> > 
> >                   for (i = 0; i < nr_p; i++) {
> >                           addrs[i] = (void *)ADDR_INPUT + i * PS;
> >                           nodes[i] = 0;
> >                           status[i] = 0;
> >                   }
> >                   ret = numa_move_pages(pid, nr_p, addrs, nodes, status,
> >                                         MPOL_MF_MOVE_ALL);
> >                   if (ret == -1)
> >                           err("move_pages");
> >           }
> >           return 0;
> >   }
> > 
> >   $ cat hugepage.c
> >   #include <stdio.h>
> >   #include <sys/mman.h>
> >   #include <string.h>
> > 
> >   #define ADDR_INPUT      0x700000000000UL
> >   #define HPS             0x200000
> > 
> >   int main(int argc, char *argv[]) {
> >           int nr_hp = strtol(argv[1], NULL, 0);
> >           char *p;
> > 
> >           while (1) {
> >                   p = mmap((void *)ADDR_INPUT, nr_hp * HPS, PROT_READ | PROT_WRITE,
> >                            MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
> >                   if (p != (void *)ADDR_INPUT) {
> >                           perror("mmap");
> >                           break;
> >                   }
> >                   memset(p, 0, nr_hp * HPS);
> >                   munmap(p, nr_hp * HPS);
> >           }
> >   }
> > 
> >   $ sysctl vm.nr_hugepages=40
> >   $ ./hugepage 10 &
> >   $ ./movepages 10 $(pgrep -f hugepage)
> > 
> > Note for stable inclusion:
> >   This patch fixes e632a938d914 ("mm: migrate: add hugepage migration code
> >   to move_pages()"), so is applicable to -stable kernels which includes it.
> 
> Just say
> Fixes: e632a938d914 ("mm: migrate: add hugepage migration code to move_pages()")

I just found that Documentation/SubmittingPatches started to state about
Fixes: tag. I'll use it from now.

> > 
> > ChangeLog v3:
> > - remove unnecessary if (page) check
> > - check (pmd|pud)_huge again after holding ptl
> > - do the same change also on follow_huge_pud()
> > - take page table lock also in follow_huge_addr()
> > 
> > ChangeLog v2:
> > - introduce follow_huge_pmd_lock() to do locking in arch-independent code.
> 
> ChangeLog vN info belongs below the ---

OK.
I didn't know this but it's written in SubmittingPatches, so I'll keep it
in mind.

> > 
> > Reported-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: <stable@vger.kernel.org>  # [3.12+]
> 
> No ack to this one yet, I'm afraid.

OK, I defer Reported-by until all the problems in this patch are solved.
I added this Reported-by because Andrew asked how In found this problem,
and advised me to show the reporter.
And I didn't intend by this Reported-by that you acked the patch.
In this case, should I have used some unofficial tag like
"Not-yet-Reported-by:" to avoid being rude?

> > ---
> >  arch/ia64/mm/hugetlbpage.c    |  9 +++++++--
> >  arch/metag/mm/hugetlbpage.c   |  4 ++--
> >  arch/powerpc/mm/hugetlbpage.c | 22 +++++++++++-----------
> >  include/linux/hugetlb.h       | 12 ++++++------
> >  mm/gup.c                      | 25 ++++---------------------
> >  mm/hugetlb.c                  | 43 +++++++++++++++++++++++++++++++------------
> >  6 files changed, 61 insertions(+), 54 deletions(-)
> > 
> > diff --git mmotm-2014-08-25-16-52.orig/arch/ia64/mm/hugetlbpage.c mmotm-2014-08-25-16-52/arch/ia64/mm/hugetlbpage.c
> > index 52b7604b5215..6170381bf074 100644
> > --- mmotm-2014-08-25-16-52.orig/arch/ia64/mm/hugetlbpage.c
> > +++ mmotm-2014-08-25-16-52/arch/ia64/mm/hugetlbpage.c
> > @@ -91,17 +91,22 @@ int prepare_hugepage_range(struct file *file,
> >  
> >  struct page *follow_huge_addr(struct mm_struct *mm, unsigned long addr, int write)
> >  {
> > -	struct page *page;
> > +	struct page *page = NULL;
> >  	pte_t *ptep;
> > +	spinlock_t *ptl;
> >  
> >  	if (REGION_NUMBER(addr) != RGN_HPAGE)
> >  		return ERR_PTR(-EINVAL);
> >  
> >  	ptep = huge_pte_offset(mm, addr);
> > +	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, ptep);
> 
> It was a mistake to lump this follow_huge_addr() change in with the
> rest: please defer it to your 6/6 (or send 5 and leave 6th to later).
> 
> Unless I'm missing something, all you succeed in doing here is break
> the build on ia64 and powerpc, by introducing undeclared "vma" variable.
> 
> There is no point whatever in taking and dropping this lock: the
> point was to do the get_page while holding the relevant page table lock,
> but you're not doing any get_page, and you still have an "int write"
> argument instead of "int flags" to pass down the FOLL_GET flag,
> and you still have the BUG_ON(flags & FOLL_GET) in follow_page_mask().
> 
> So, please throw these follow_huge_addr() parts out this patch.

Sorry, I'll drop them all.

> >  	if (!ptep || pte_none(*ptep))
> > -		return NULL;
> > +		goto out;
> > +
> >  	page = pte_page(*ptep);
> >  	page += ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
> > +out:
> > +	spin_unlock(ptl);
> >  	return page;
> >  }
> >  int pmd_huge(pmd_t pmd)
> > diff --git mmotm-2014-08-25-16-52.orig/arch/metag/mm/hugetlbpage.c mmotm-2014-08-25-16-52/arch/metag/mm/hugetlbpage.c
> > index 745081427659..5e96ef096df9 100644
> > --- mmotm-2014-08-25-16-52.orig/arch/metag/mm/hugetlbpage.c
> > +++ mmotm-2014-08-25-16-52/arch/metag/mm/hugetlbpage.c
> > @@ -104,8 +104,8 @@ int pud_huge(pud_t pud)
> >  	return 0;
> >  }
> >  
> > -struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
> > -			     pmd_t *pmd, int write)
> > +struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
> > +			     pmd_t *pmd, int flags)
> 
> Change from "write" to "flags" is good, but I question below whether
> we actually need to change from mm to vma in follow_huge_pmd() and
> follow_huge_pud().

Without changing mm with vma, we need call find_vma() to get the relevant
vma to get ptl, which looks expensive than getting mm from vma.
The caller already has vma, so I thought that passing vma is better.

... but as you wrote below, there's a better way to get ptl.
With your suggestion, there's no need to change mm.

> >  {
> >  	return NULL;
> >  }
> > diff --git mmotm-2014-08-25-16-52.orig/arch/powerpc/mm/hugetlbpage.c mmotm-2014-08-25-16-52/arch/powerpc/mm/hugetlbpage.c
> > index 9517a93a315c..1d8854a56309 100644
> > --- mmotm-2014-08-25-16-52.orig/arch/powerpc/mm/hugetlbpage.c
> > +++ mmotm-2014-08-25-16-52/arch/powerpc/mm/hugetlbpage.c
> > @@ -677,38 +677,38 @@ struct page *
> >  follow_huge_addr(struct mm_struct *mm, unsigned long address, int write)
> >  {
> >  	pte_t *ptep;
> > -	struct page *page;
> > +	struct page *page = ERR_PTR(-EINVAL);
> >  	unsigned shift;
> >  	unsigned long mask;
> > +	spinlock_t *ptl;
> >  	/*
> >  	 * Transparent hugepages are handled by generic code. We can skip them
> >  	 * here.
> >  	 */
> >  	ptep = find_linux_pte_or_hugepte(mm->pgd, address, &shift);
> > -
> > +	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, ptep);
> 
> As above, you're breaking the build with a lock that serves no purpose
> in the current patch.

I just drop it, sorry for the silly code.

> >  	/* Verify it is a huge page else bail. */
> >  	if (!ptep || !shift || pmd_trans_huge(*(pmd_t *)ptep))
> > -		return ERR_PTR(-EINVAL);
> > +		goto out;
> >  
> >  	mask = (1UL << shift) - 1;
> > -	page = pte_page(*ptep);
> > -	if (page)
> > -		page += (address & mask) / PAGE_SIZE;
> > -
> > +	page = pte_page(*ptep) + ((address & mask) >> PAGE_SHIFT);
> > +out:
> > +	spin_unlock(ptl);
> >  	return page;
> >  }
> >  
> >  struct page *
> > -follow_huge_pmd(struct mm_struct *mm, unsigned long address,
> > -		pmd_t *pmd, int write)
> > +follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
> > +		pmd_t *pmd, int flags)
> >  {
> >  	BUG();
> >  	return NULL;
> >  }
> >  
> >  struct page *
> > -follow_huge_pud(struct mm_struct *mm, unsigned long address,
> > -		pmd_t *pmd, int write)
> > +follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
> > +		pud_t *pud, int flags)
> >  {
> >  	BUG();
> >  	return NULL;
> > diff --git mmotm-2014-08-25-16-52.orig/include/linux/hugetlb.h mmotm-2014-08-25-16-52/include/linux/hugetlb.h
> > index 6e6d338641fe..b3200fce07aa 100644
> > --- mmotm-2014-08-25-16-52.orig/include/linux/hugetlb.h
> > +++ mmotm-2014-08-25-16-52/include/linux/hugetlb.h
> > @@ -98,10 +98,10 @@ pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
> >  int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
> >  struct page *follow_huge_addr(struct mm_struct *mm, unsigned long address,
> >  			      int write);
> > -struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
> > -				pmd_t *pmd, int write);
> > -struct page *follow_huge_pud(struct mm_struct *mm, unsigned long address,
> > -				pud_t *pud, int write);
> > +struct page *follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
> > +				pmd_t *pmd, int flags);
> > +struct page *follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
> > +				pud_t *pud, int flags);
> >  int pmd_huge(pmd_t pmd);
> >  int pud_huge(pud_t pmd);
> >  unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
> > @@ -133,8 +133,8 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
> >  static inline void hugetlb_show_meminfo(void)
> >  {
> >  }
> > -#define follow_huge_pmd(mm, addr, pmd, write)	NULL
> > -#define follow_huge_pud(mm, addr, pud, write)	NULL
> > +#define follow_huge_pmd(vma, addr, pmd, flags)	NULL
> > +#define follow_huge_pud(vma, addr, pud, flags)	NULL
> >  #define prepare_hugepage_range(file, addr, len)	(-EINVAL)
> >  #define pmd_huge(x)	0
> >  #define pud_huge(x)	0
> > diff --git mmotm-2014-08-25-16-52.orig/mm/gup.c mmotm-2014-08-25-16-52/mm/gup.c
> > index 91d044b1600d..597a5e92e265 100644
> > --- mmotm-2014-08-25-16-52.orig/mm/gup.c
> > +++ mmotm-2014-08-25-16-52/mm/gup.c
> > @@ -162,33 +162,16 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> >  	pud = pud_offset(pgd, address);
> >  	if (pud_none(*pud))
> >  		return no_page_table(vma, flags);
> > -	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
> > -		if (flags & FOLL_GET)
> > -			return NULL;
> > -		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
> > -		return page;
> > -	}
> > +	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB)
> > +		return follow_huge_pud(vma, address, pud, flags);
> 
> Yes, this part is good, except I think mm rather than vma.

I'll fix it.

> >  	if (unlikely(pud_bad(*pud)))
> >  		return no_page_table(vma, flags);
> >  
> >  	pmd = pmd_offset(pud, address);
> >  	if (pmd_none(*pmd))
> >  		return no_page_table(vma, flags);
> > -	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
> > -		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
> > -		if (flags & FOLL_GET) {
> > -			/*
> > -			 * Refcount on tail pages are not well-defined and
> > -			 * shouldn't be taken. The caller should handle a NULL
> > -			 * return when trying to follow tail pages.
> > -			 */
> > -			if (PageHead(page))
> > -				get_page(page);
> > -			else
> > -				page = NULL;
> > -		}
> > -		return page;
> > -	}
> > +	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB)
> > +		return follow_huge_pmd(vma, address, pmd, flags);
> 
> And this part is good, except I think mm rather than vma.

I'll fix it, too.

> >  	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
> >  		return no_page_table(vma, flags);
> >  	if (pmd_trans_huge(*pmd)) {
> > diff --git mmotm-2014-08-25-16-52.orig/mm/hugetlb.c mmotm-2014-08-25-16-52/mm/hugetlb.c
> > index 022767506c7b..c5345c5edb50 100644
> > --- mmotm-2014-08-25-16-52.orig/mm/hugetlb.c
> > +++ mmotm-2014-08-25-16-52/mm/hugetlb.c
> > @@ -3667,26 +3667,45 @@ follow_huge_addr(struct mm_struct *mm, unsigned long address,
> >  }
> >  
> >  struct page * __weak
> > -follow_huge_pmd(struct mm_struct *mm, unsigned long address,
> > -		pmd_t *pmd, int write)
> > +follow_huge_pmd(struct vm_area_struct *vma, unsigned long address,
> > +		pmd_t *pmd, int flags)
> >  {
> > -	struct page *page;
> > +	struct page *page = NULL;
> > +	spinlock_t *ptl;
> >  
> > -	page = pte_page(*(pte_t *)pmd);
> > -	if (page)
> > -		page += ((address & ~PMD_MASK) >> PAGE_SHIFT);
> > +	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pmd);
> 
> So, this is why you have had to change from "mm" to "vma" throughout.
> And we might end up deciding that that is the right thing to do.
> 
> But here we are deep in page table code, dealing with a huge pmd entry:
> I protest that it's very lame to be asking vma->vm_file to tell us what
> lock the page table code needs at this level.  Isn't it pmd_lockptr()?

Right, inside huge_pte_lock() we call pmd_lockptr() when huge_page_size(h)
== PMD_SIZE to get the ptl. And this code can assume that it's true, so
calling pmd_lockptr() directly is better/faster.

> Now, I'm easily confused, and there may be reasons why it's more subtle
> than that, and you really are forced to use huge_pte_lockptr(); but I'd
> much rather not if we can avoid doing so, just as a matter of principle.

Using huge_pte_lockptr() is useful when we can't assume the hugepage's
info like hugepage size or whether it's pmd/pud-based or not.

> One subtlety to take care over: it's a long time since I've had to
> worry about pmd folding and pud folding (what happens when you only
> have 2 or 3 levels of page table instead of the full 4): macros get
> defined to each other, and levels get optimized out (perhaps
> differently on different architectures).
> 
> So although at first sight the lock to take in follow_huge_pud()
> would seem to be mm->page_table_lock, I am not at this point certain
> that that's necessarily so - sometimes pud_huge might be pmd_huge,
> and the size PMD_SIZE, and pmd_lockptr appropriate at what appears
> to be the pud level.  Maybe: needs checking through the architectures
> and their configs, not obvious to me.

I think that every architecture uses mm->page_table_lock for pud-level
locking at least for now, but that could be changed in the future,
for example when 1GB hugepages or pud-based hugepages become common and
someone are interested in splitting lock for pud level.
So it would be helpful to introduce pud_lockptr() which just returns
mm->page_table_lock now, so that developers never forget to update it
when considering splitting pud lock.

> 
> I realize that I am asking for you (or I) to do more work, when using
> huge_pte_lock(hstate_vma(vma),,) would work it out "automatically";
> but I do feel quite strongly that that's the right approach here
> (and I'm not just trying to avoid a few edits of "mm" to "vma").

Yes, I agree.

> Cc'ing Kirill, who may have a strong view to the contrary,
> or a good insight on where the problems if any might be.
> 
> Also Cc'ing Kirill because I'm not convinced that huge_pte_lockptr()
> necessarily does the right thing on follow_huge_addr() architectures,
> ia64 and powerpc.  Do they, for example, allocate the memory for their
> hugetlb entries in such a way that we can indeed use pmd_lockptr() to
> point to a useable spinlock, in the case when huge_page_size(h) just
> happens to equal PMD_SIZE?
> 
> I don't know if this was thought through thoroughly
> (now that's a satisfying phrase hugh thinks hugh never wrote before!)
> when huge_pte_lockptr() was invented or not.  I think it would be safer
> if huge_pte_lockptr() just gave mm->page_table_lock on follow_huge_addr()
> architectures.

Yes, this seems a real problem and is worth discussing with maintainers
of these architectures. Maybe we can do this as a separate work.

> 
> > +
> > +	if (!pmd_huge(*pmd))
> > +		goto out;
> > +
> > +	page = pte_page(*(pte_t *)pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
> > +
> > +	if (flags & FOLL_GET)
> > +		if (!get_page_unless_zero(page))
> > +			page = NULL;
> 
> get_page() should be quite good enough, shouldn't it?  We are holding
> the necessary lock, and have tested pmd_huge(*pmd), so it would be a
> bug if page_count(page) were zero here.

Yes, get_page() is enough, I'll fix it.

> > +out:
> > +	spin_unlock(ptl);
> >  	return page;
> >  }
> >  
> >  struct page * __weak
> > -follow_huge_pud(struct mm_struct *mm, unsigned long address,
> > -		pud_t *pud, int write)
> > +follow_huge_pud(struct vm_area_struct *vma, unsigned long address,
> > +		pud_t *pud, int flags)
> >  {
> > -	struct page *page;
> > +	struct page *page = NULL;
> > +	spinlock_t *ptl;
> >  
> > -	page = pte_page(*(pte_t *)pud);
> > -	if (page)
> > -		page += ((address & ~PUD_MASK) >> PAGE_SHIFT);
> > +	if (flags & FOLL_GET)
> > +		return NULL;
> > +
> > +	ptl = huge_pte_lock(hstate_vma(vma), vma->vm_mm, (pte_t *)pud);
> 
> Well, you do have vma declared here, but otherwise it's like what you
> had in follow_huge_addr(): there is no point in taking and dropping
> the lock if you're not getting the page while the lock is held.
> 
> So, which way to go on follow_huge_pud()?  I certainly think that we
> should implement FOLL_GET on it, as we should for follow_huge_addr(),
> simply for completeness, and so we don't need to come back here.

Right, this will become important when thinking of 1GB hugepage migration,

> But whether we should do so in a patch which is Cc'ed to stable is not
> so clear.  And leaving follow_huge_pmd() and follow_huge_addr() out
> of this patch may avoid those awkward where-is-the-lock questions
> for now.  Convert follow_huge_pmd() in a separate patch?

... but 1GB hugepage migration is not available now, so no reason to
send follow_huge_pud to stable. I agree to separate that part.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
