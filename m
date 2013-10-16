Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 293A86B0039
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 05:56:40 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so653478pde.24
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 02:56:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAMuHMdUqQVphjUbvPg+47ZjFmS8WUK_70VMb43w4jaBOcGfNxA@mail.gmail.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1381428359-14843-20-git-send-email-kirill.shutemov@linux.intel.com>
 <CAMuHMdUqQVphjUbvPg+47ZjFmS8WUK_70VMb43w4jaBOcGfNxA@mail.gmail.com>
Subject: Re: [PATCH 19/34] m68k: handle pgtable_page_ctor() fail
Content-Transfer-Encoding: 7bit
Message-Id: <20131016095612.34707E0090@blue.fi.intel.com>
Date: Wed, 16 Oct 2013 12:56:12 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux/m68k <linux-m68k@vger.kernel.org>

Geert Uytterhoeven wrote:
> On Thu, Oct 10, 2013 at 8:05 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> > ---
> >  arch/m68k/include/asm/motorola_pgalloc.h | 5 ++++-
> >  arch/m68k/include/asm/sun3_pgalloc.h     | 5 ++++-
> >  2 files changed, 8 insertions(+), 2 deletions(-)
> >
> > diff --git a/arch/m68k/include/asm/motorola_pgalloc.h b/arch/m68k/include/asm/motorola_pgalloc.h
> > index 2f02f264e6..dd254eeb03 100644
> > --- a/arch/m68k/include/asm/motorola_pgalloc.h
> > +++ b/arch/m68k/include/asm/motorola_pgalloc.h
> > @@ -40,7 +40,10 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addres
> >         flush_tlb_kernel_page(pte);
> >         nocache_page(pte);
>         ^^^^^^^^^^^^^^^^^^
> >         kunmap(page);
> > -       pgtable_page_ctor(page);
> > +       if (!pgtable_page_ctor(page)) {
> > +               __free_page(page);
> 
> Shouldn't you mark the page cacheable again, like is done in pte_free()?

Hm. You're right. Updated patch below.

BTW, what's the point of playing with kmap()/kunmap() there? Looks like
m68k doesn't support highmem.

And even if it will support, code in pte_alloc_one() doesn't make any
sense: kmap() creates temporary mapping for highmem page and it
nocache_page() sets flags in pte which will be destroyed by kunmap().

It think kmap() should be replaced by page_address() and kunmap() should
be dropped.
