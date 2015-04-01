Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id AB7D76B0032
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 18:06:55 -0400 (EDT)
Received: by pacgg7 with SMTP id gg7so64405774pac.0
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 15:06:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y9si476580pbt.175.2015.04.01.15.06.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Apr 2015 15:06:54 -0700 (PDT)
Date: Wed, 1 Apr 2015 15:06:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: use PageAnon() and PageKsm() helpers in
 page_anon_vma()
Message-Id: <20150401150653.92c0490016e3e3577cfabb31@linux-foundation.org>
In-Reply-To: <20150401220246.GA19758@node.dhcp.inet.fi>
References: <1427802647-16764-1-git-send-email-kirill.shutemov@linux.intel.com>
	<alpine.DEB.2.11.1503310810320.13959@gentwo.org>
	<20150331143534.GA10808@node.dhcp.inet.fi>
	<20150331133338.ed4ab6cc9a5ab6f6ad4301eb@linux-foundation.org>
	<20150401115054.GB17153@node.dhcp.inet.fi>
	<20150401125745.421a6af61bd20246a76c5b83@linux-foundation.org>
	<20150401220246.GA19758@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>

On Thu, 2 Apr 2015 01:02:46 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Wed, Apr 01, 2015 at 12:57:45PM -0700, Andrew Morton wrote:
> > On Wed, 1 Apr 2015 14:50:54 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > 
> > > >From adc384977898173d65c2567fc5eb421da9b272e0 Mon Sep 17 00:00:00 2001
> > > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > Date: Wed, 1 Apr 2015 14:33:56 +0300
> > > Subject: [PATCH] mm: uninline and cleanup page-mapping related helpers
> > > 
> > > Most-used page->mapping helper -- page_mapping() -- has already
> > > uninlined. Let's uninline also page_rmapping() and page_anon_vma().
> > > It saves us depending on configuration around 400 bytes in text:
> > > 
> > >    text	   data	    bss	    dec	    hex	filename
> > >  660318	  99254	 410000	1169572	 11d8a4	mm/built-in.o-before
> > >  659854	  99254	 410000	1169108	 11d6d4	mm/built-in.o
> > 
> > Well, code size isn't the only thing to care about.  Some functions
> > really should be inlined for performance reasons even if that makes the
> > overall code larger.  But the changes you're proposing here look OK to
> > me.
> > 
> > > As side effect page_anon_vma() now works properly on tail pages.
> > 
> > Let's fix the bug in a separate patch, please.  One which can be
> > backported to earlier kernels if that should be needed.  ie: it should
> > precede any uninlining.
> 
> The bug is not triggerable in current upsteam. AFAIK, we don't call
> page_anon_vma() on tail pages of THP, since we don't map THP with PTEs
> yet. For rest of cases we will get NULL, which is valid answer.

argh.  It rather helps if you can tell me when this happens (and which
patch it fixes).  I sometimes spend quite a bit of time runnnig around
in circles wondering what the heck tree/patch just got fixed.

> Do you still want "page = compound_head(page);" line in separate patch?

I think that would be best.  That way the offending patch gets fixed
and doesn't get bundled up with an unrelated change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
