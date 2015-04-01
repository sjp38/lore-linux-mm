Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 61D5B6B0032
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 18:02:51 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so83183267wia.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 15:02:51 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id r6si5558032wjx.75.2015.04.01.15.02.49
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 15:02:50 -0700 (PDT)
Date: Thu, 2 Apr 2015 01:02:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: use PageAnon() and PageKsm() helpers in
 page_anon_vma()
Message-ID: <20150401220246.GA19758@node.dhcp.inet.fi>
References: <1427802647-16764-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.11.1503310810320.13959@gentwo.org>
 <20150331143534.GA10808@node.dhcp.inet.fi>
 <20150331133338.ed4ab6cc9a5ab6f6ad4301eb@linux-foundation.org>
 <20150401115054.GB17153@node.dhcp.inet.fi>
 <20150401125745.421a6af61bd20246a76c5b83@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150401125745.421a6af61bd20246a76c5b83@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>

On Wed, Apr 01, 2015 at 12:57:45PM -0700, Andrew Morton wrote:
> On Wed, 1 Apr 2015 14:50:54 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > >From adc384977898173d65c2567fc5eb421da9b272e0 Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Wed, 1 Apr 2015 14:33:56 +0300
> > Subject: [PATCH] mm: uninline and cleanup page-mapping related helpers
> > 
> > Most-used page->mapping helper -- page_mapping() -- has already
> > uninlined. Let's uninline also page_rmapping() and page_anon_vma().
> > It saves us depending on configuration around 400 bytes in text:
> > 
> >    text	   data	    bss	    dec	    hex	filename
> >  660318	  99254	 410000	1169572	 11d8a4	mm/built-in.o-before
> >  659854	  99254	 410000	1169108	 11d6d4	mm/built-in.o
> 
> Well, code size isn't the only thing to care about.  Some functions
> really should be inlined for performance reasons even if that makes the
> overall code larger.  But the changes you're proposing here look OK to
> me.
> 
> > As side effect page_anon_vma() now works properly on tail pages.
> 
> Let's fix the bug in a separate patch, please.  One which can be
> backported to earlier kernels if that should be needed.  ie: it should
> precede any uninlining.

The bug is not triggerable in current upsteam. AFAIK, we don't call
page_anon_vma() on tail pages of THP, since we don't map THP with PTEs
yet. For rest of cases we will get NULL, which is valid answer.

Do you still want "page = compound_head(page);" line in separate patch?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
