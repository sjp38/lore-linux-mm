Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 111CE6B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 21:47:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 17-v6so7868065pgs.18
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 18:47:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l15-v6sor25964650pfb.67.2018.10.11.18.47.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Oct 2018 18:47:28 -0700 (PDT)
Date: Thu, 11 Oct 2018 18:47:25 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Message-ID: <20181012014725.GA12431@joelaf.mtv.corp.google.com>
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <20181009220222.26nzajhpsbt7syvv@kshutemo-mobl1>
 <20181009230447.GA17911@joelaf.mtv.corp.google.com>
 <20181010100011.6jqjvgeslrvvyhr3@kshutemo-mobl1>
 <20181011004618.GA237677@joelaf.mtv.corp.google.com>
 <20181011051419.2rkfbooqc3auk5ji@kshutemo-mobl1>
 <20181011081111.mfbhuantvxmkd33p@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181011081111.mfbhuantvxmkd33p@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: g@kshutemo-mobl1.kvack.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@android.com, minchan@google.com, hughd@google.com, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Oct 11, 2018 at 11:11:11AM +0300, Kirill A. Shutemov wrote:
> On Thu, Oct 11, 2018 at 08:14:19AM +0300, Kirill A. Shutemov wrote:
> > On Wed, Oct 10, 2018 at 05:46:18PM -0700, Joel Fernandes wrote:
> > > diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
> > > index 391ed2c3b697..8a33f2044923 100644
> > > --- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
> > > +++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
> > > @@ -192,14 +192,12 @@ static inline pgtable_t pmd_pgtable(pmd_t pmd)
> > >  	return (pgtable_t)pmd_page_vaddr(pmd);
> > >  }
> > >  
> > > -static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
> > > -					  unsigned long address)
> > > +static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
> > >  {
> > >  	return (pte_t *)pte_fragment_alloc(mm, address, 1);
> > >  }
> > 
> > This is obviously broken.

I was actually aware of this, I was in the early stages of writing the script
but just shared the diff to give an idea the number of changes.

> I've checked pte_fragment_alloc() and it doesn't use the address too.
> We need to modify it too.

I rewrote the Coccinelle script and manually fixed pte_fragment_alloc in
that. I sent an update with you and Michal on CC, please check it. Thanks a
lot.

 - Joel
