Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C76A6B0292
	for <linux-mm@kvack.org>; Sun, 23 Jul 2017 17:34:28 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h126so1089591wmf.10
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 14:34:28 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id 191si2668423wms.107.2017.07.23.14.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 14:34:26 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id 79so2990086wmg.1
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 14:34:26 -0700 (PDT)
Date: Mon, 24 Jul 2017 00:34:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/gup: Make __gup_device_* require THP
Message-ID: <20170723213424.wjuvqo4ivdb7ilvs@node.shutemov.name>
References: <20170626063833.11094-1-oohall@gmail.com>
 <20170721161322.98c5cd44b5b3612be0f7fe14@linux-foundation.org>
 <CAOSf1CG+jc=Z64_5G4FyvhO5a9rfeOjdQXKNzgZFsKYVxramqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOSf1CG+jc=Z64_5G4FyvhO5a9rfeOjdQXKNzgZFsKYVxramqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver <oohall@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Sat, Jul 22, 2017 at 01:49:23PM +1000, Oliver wrote:
> On Sat, Jul 22, 2017 at 9:13 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Mon, 26 Jun 2017 16:38:33 +1000 "Oliver O'Halloran" <oohall@gmail.com> wrote:
> >
> >> These functions are the only bits of generic code that use
> >> {pud,pmd}_pfn() without checking for CONFIG_TRANSPARENT_HUGEPAGE.
> >> This works fine on x86, the only arch with devmap support, since the
> >> *_pfn() functions are always defined there, but this isn't true for
> >> every architecture.
> >>
> >> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
> >> ---
> >>  mm/gup.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/mm/gup.c b/mm/gup.c
> >> index d9e6fddcc51f..04cf79291321 100644
> >> --- a/mm/gup.c
> >> +++ b/mm/gup.c
> >> @@ -1287,7 +1287,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
> >>  }
> >>  #endif /* __HAVE_ARCH_PTE_SPECIAL */
> >>
> >> -#ifdef __HAVE_ARCH_PTE_DEVMAP
> >> +#if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
> >>  static int __gup_device_huge(unsigned long pfn, unsigned long addr,
> >>               unsigned long end, struct page **pages, int *nr)
> >>  {
> >
> > (cc Kirill)
> >
> > Please provide a full description of the bug which is being fixed.  I
> > assume it's a build error.  What are the error messages and under what
> > circumstances.
> >
> > Etcetera.  Enough info for me (and others) to decide which kernel
> > version(s) need the fix.
> 
> It fixes a build breakage that you will only ever see when enabling
> the devmap pte bit for another architecture. Given it requires new
> code to hit the bug I don't see much point in backporting it to 4.12,
> but taking it as a fix for 4.13 wouldn't hurt.
> 
> The root problem is that the arch doesn't need to provide pmd_pfn()
> and friends when THP is disabled. They're provided unconditionally by
> x86 and ppc, but I did a cursory check and found that mips only
> defines pmd_pfn() when THP is enabled so I figured this should be
> fixed. Making each arch provide them unconditionally might be a better
> idea, but that seemed like it'd be a lot of churn for a minor bug.

This makes sense to me.

Assuming updated commit message,

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
