Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7B6FC6B005A
	for <linux-mm@kvack.org>; Sat, 16 May 2009 21:57:47 -0400 (EDT)
Date: Sun, 17 May 2009 09:58:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/3] vmscan: report vm_flags in page_referenced()
Message-ID: <20090517015806.GA6809@localhost>
References: <20090516090005.916779788@intel.com> <20090516090448.249602749@intel.com> <28c262360905161836u332f9e9aj6fa3f3b65da95592@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360905161836u332f9e9aj6fa3f3b65da95592@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sun, May 17, 2009 at 09:36:44AM +0800, Minchan Kim wrote:
> On Sat, May 16, 2009 at 6:00 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > Collect vma->vm_flags of the VMAs that actually referenced the page.
> >
> > This is preparing for more informed reclaim heuristics,
> > eg. to protect executable file pages more aggressively.
> > For now only the VM_EXEC bit will be used by the caller.
> >
> > CC: Minchan Kim <minchan.kim@gmail.com>
> > CC: Johannes Weiner <hannes@cmpxchg.org>
> > CC: Peter Zijlstra <peterz@infradead.org>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> > A include/linux/rmap.h | A  A 5 +++--
> > A mm/rmap.c A  A  A  A  A  A | A  37 ++++++++++++++++++++++++++-----------
> > A mm/vmscan.c A  A  A  A  A | A  A 7 +++++--
> > A 3 files changed, 34 insertions(+), 15 deletions(-)
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
> > @@ -333,7 +333,9 @@ static int page_mapped_in_vma(struct pag
> > A * repeatedly from either page_referenced_anon or page_referenced_file.
> > A */
> > A static int page_referenced_one(struct page *page,
> > - A  A  A  struct vm_area_struct *vma, unsigned int *mapcount)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A struct vm_area_struct *vma,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A unsigned int *mapcount,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A unsigned long *vm_flags)
> > A {
> > A  A  A  A struct mm_struct *mm = vma->vm_mm;
> > A  A  A  A unsigned long address;
> > @@ -381,11 +383,14 @@ out_unmap:
> > A  A  A  A (*mapcount)--;
> > A  A  A  A pte_unmap_unlock(pte, ptl);
> > A out:
> > + A  A  A  if (referenced)
> > + A  A  A  A  A  A  A  *vm_flags |= vma->vm_flags;
> > A  A  A  A return referenced;
> > A }
> >
> > A static int page_referenced_anon(struct page *page,
> > - A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct mem_cgroup *mem_cont)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  struct mem_cgroup *mem_cont,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  unsigned long *vm_flags)
> > A {
> > A  A  A  A unsigned int mapcount;
> > A  A  A  A struct anon_vma *anon_vma;
> > @@ -405,7 +410,8 @@ static int page_referenced_anon(struct p
> > A  A  A  A  A  A  A  A  */
> > A  A  A  A  A  A  A  A if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
> > A  A  A  A  A  A  A  A  A  A  A  A continue;
> > - A  A  A  A  A  A  A  referenced += page_referenced_one(page, vma, &mapcount);
> > + A  A  A  A  A  A  A  referenced += page_referenced_one(page, vma,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  &mapcount, vm_flags);
> > A  A  A  A  A  A  A  A if (!mapcount)
> > A  A  A  A  A  A  A  A  A  A  A  A break;
> > A  A  A  A }
> > @@ -418,6 +424,7 @@ static int page_referenced_anon(struct p
> > A * page_referenced_file - referenced check for object-based rmap
> > A * @page: the page we're checking references on.
> > A * @mem_cont: target memory controller
> > + * @vm_flags: collect encountered vma->vm_flags
> 
> I missed this.
> To clarify, how about ?
> collect encountered vma->vm_flags among vma which referenced the page

Good catch! I'll resubmit the whole patchset :)

[ In fact I was thinking about changing those comments - and then
  forgot it over night. I should really put some notepad around me. ]

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
