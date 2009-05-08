Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 89C0A6B003D
	for <linux-mm@kvack.org>; Fri,  8 May 2009 08:16:04 -0400 (EDT)
Date: Fri, 8 May 2009 20:15:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] vmscan: report vm_flags in page_referenced()
Message-ID: <20090508121549.GA17077@localhost>
References: <20090430195439.e02edc26.akpm@linux-foundation.org> <49FB01C1.6050204@redhat.com> <20090501123541.7983a8ae.akpm@linux-foundation.org> <20090503031539.GC5702@localhost> <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org> <1241709466.11251.164.camel@twins> <20090508041700.GC8892@localhost> <28c262360905080509q333ec8acv2d2be69d99e1dfa3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360905080509q333ec8acv2d2be69d99e1dfa3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 08, 2009 at 08:09:24PM +0800, Minchan Kim wrote:
> On Fri, May 8, 2009 at 1:17 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Thu, May 07, 2009 at 11:17:46PM +0800, Peter Zijlstra wrote:
> >> On Thu, 2009-05-07 at 17:10 +0200, Johannes Weiner wrote:
> >>
> >> > > @@ -1269,8 +1270,15 @@ static void shrink_active_list(unsigned
> >> > >
> >> > > A  A  A  A  A  /* page_referenced clears PageReferenced */
> >> > > A  A  A  A  A  if (page_mapping_inuse(page) &&
> >> > > - A  A  A  A  A  A  page_referenced(page, 0, sc->mem_cgroup))
> >> > > + A  A  A  A  A  A  page_referenced(page, 0, sc->mem_cgroup)) {
> >> > > + A  A  A  A  A  A  A  A  struct address_space *mapping = page_mapping(page);
> >> > > +
> >> > > A  A  A  A  A  A  A  A  A  pgmoved++;
> >> > > + A  A  A  A  A  A  A  A  if (mapping && test_bit(AS_EXEC, &mapping->flags)) {
> >> > > + A  A  A  A  A  A  A  A  A  A  A  A  list_add(&page->lru, &l_active);
> >> > > + A  A  A  A  A  A  A  A  A  A  A  A  continue;
> >> > > + A  A  A  A  A  A  A  A  }
> >> > > + A  A  A  A  }
> >> >
> >> > Since we walk the VMAs in page_referenced anyway, wouldn't it be
> >> > better to check if one of them is executable? A This would even work
> >> > for executable anon pages. A After all, there are applications that cow
> >> > executable mappings (sbcl and other language environments that use an
> >> > executable, run-time modified core image come to mind).
> >>
> >> Hmm, like provide a vm_flags mask along to page_referenced() to only
> >> account matching vmas... seems like a sensible idea.
> >
> > Here is a quick patch for your opinions. Compile tested.
> >
> > With the added vm_flags reporting, the mlock=>unevictable logic can
> > possibly be made more straightforward.
> >
> > Thanks,
> > Fengguang
> > ---
> > vmscan: report vm_flags in page_referenced()
> >
> > This enables more informed reclaim heuristics, eg. to protect executable
> > file pages more aggressively.
> >
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> > A include/linux/rmap.h | A  A 5 +++--
> > A mm/rmap.c A  A  A  A  A  A | A  30 +++++++++++++++++++++---------
> > A mm/vmscan.c A  A  A  A  A | A  A 7 +++++--
> > A 3 files changed, 29 insertions(+), 13 deletions(-)
> >
> > --- linux.orig/include/linux/rmap.h
> > +++ linux/include/linux/rmap.h
> > @@ -83,7 +83,8 @@ static inline void page_dup_rmap(struct
> > A /*
> > A * Called from mm/vmscan.c to handle paging out
> > A */
> > -int page_referenced(struct page *, int is_locked, struct mem_cgroup *cnt);
> > +int page_referenced(struct page *, int is_locked,
> > + A  A  A  A  A  A  A  A  A  A  A  struct mem_cgroup *cnt, unsigned long *vm_flags);
> > A int try_to_unmap(struct page *, int ignore_refs);
> >
> > A /*
> > @@ -128,7 +129,7 @@ int page_wrprotect(struct page *page, in
> > A #define anon_vma_prepare(vma) A (0)
> > A #define anon_vma_link(vma) A  A  do {} while (0)
> >
> > -#define page_referenced(page,l,cnt) TestClearPageReferenced(page)
> > +#define page_referenced(page, locked, cnt, flags) TestClearPageReferenced(page)
> > A #define try_to_unmap(page, refs) SWAP_FAIL
> >
> > A static inline int page_mkclean(struct page *page)
> > --- linux.orig/mm/rmap.c
> > +++ linux/mm/rmap.c
> > @@ -333,7 +333,8 @@ static int page_mapped_in_vma(struct pag
> > A * repeatedly from either page_referenced_anon or page_referenced_file.
> > A */
> > A static int page_referenced_one(struct page *page,
> > - A  A  A  struct vm_area_struct *vma, unsigned int *mapcount)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A struct vm_area_struct *vma,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A unsigned int *mapcount)
> > A {
> > A  A  A  A struct mm_struct *mm = vma->vm_mm;
> > A  A  A  A unsigned long address;
> > @@ -385,7 +386,8 @@ out:
> > A }
> >
> > A static int page_referenced_anon(struct page *page,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct mem_cgroup *mem_cont)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct mem_cgroup *mem_cont,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long *vm_flags)
> > A {
> > A  A  A  A unsigned int mapcount;
> > A  A  A  A struct anon_vma *anon_vma;
> > @@ -406,6 +408,7 @@ static int page_referenced_anon(struct p
> > A  A  A  A  A  A  A  A if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
> > A  A  A  A  A  A  A  A  A  A  A  A continue;
> > A  A  A  A  A  A  A  A referenced += page_referenced_one(page, vma, &mapcount);
> > + A  A  A  A  A  A  A  *vm_flags |= vma->vm_flags;
> 
> Sometime this vma don't contain the anon page.
> That's why we need page_check_address.
> For such a case, wrong *vm_flag cause be harmful to reclaim.
> It can be happen in your first class citizen patch, I think.

Yes I'm aware of that - the VMA area covers that page, but have no pte
actually installed for that page. That should be OK - the presentation
of such VMA is a good indication of it being some executable text.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
