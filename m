Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A295C6B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 11:44:10 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so7715012pab.29
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 08:44:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAMo8Bf+oo4WCE366+bPoD5Y=Q3pCF0NVnfjXVqz8=nZ45_XY7Q@mail.gmail.com>
References: <1381761155-19166-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1381761155-19166-2-git-send-email-kirill.shutemov@linux.intel.com>
 <CAMo8Bf+oo4WCE366+bPoD5Y=Q3pCF0NVnfjXVqz8=nZ45_XY7Q@mail.gmail.com>
Subject: Re: [PATCHv2 2/2] xtensa: use buddy allocator for PTE table
Content-Transfer-Encoding: 7bit
Message-Id: <20131014154403.562B2E0090@blue.fi.intel.com>
Date: Mon, 14 Oct 2013 18:44:03 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Max Filippov <jcmvbkbc@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Chris Zankel <chris@zankel.net>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>

Max Filippov wrote:
> On Mon, Oct 14, 2013 at 6:32 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > At the moment xtensa uses slab allocator for PTE table. It doesn't work
> > with enabled split page table lock: slab uses page->slab_cache and
> > page->first_page for its pages. These fields share stroage with
> > page->ptl.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Chris Zankel <chris@zankel.net>
> > Cc: Max Filippov <jcmvbkbc@gmail.com>
> > ---
> > v2:
> >  - add missed return in pte_alloc_one_kernel;
> >
> >  arch/xtensa/include/asm/pgalloc.h | 20 ++++++++++++--------
> >  arch/xtensa/include/asm/pgtable.h |  3 +--
> >  arch/xtensa/mm/mmu.c              | 20 --------------------
> >  3 files changed, 13 insertions(+), 30 deletions(-)
> >
> > diff --git a/arch/xtensa/include/asm/pgalloc.h b/arch/xtensa/include/asm/pgalloc.h
> > index b8774f1e21..8507b32d6e 100644
> > --- a/arch/xtensa/include/asm/pgalloc.h
> > +++ b/arch/xtensa/include/asm/pgalloc.h
> > @@ -38,14 +38,18 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
> >         free_page((unsigned long)pgd);
> >  }
> >
> > -/* Use a slab cache for the pte pages (see also sparc64 implementation) */
> > -
> > -extern struct kmem_cache *pgtable_cache;
> > -
> >  static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
> >                                          unsigned long address)
> >  {
> > -       return kmem_cache_alloc(pgtable_cache, GFP_KERNEL|__GFP_REPEAT);
> > +       pte_t *ptep;
> > +       int i;
> > +
> > +       ptep = (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT);
> > +       if (!ptep)
> > +               return NULL;
> > +       for (i = 0; i < 1024; i++, ptep++)
> > +               pte_clear(NULL, 0, ptep);
> > +       return ptep;
> 
> You're returning modified ptep, not the allocated one.

Erghh.. Stupid me.

Corrected patch below.
