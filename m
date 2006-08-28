Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SHMvI7004687
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 13:22:57 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SHMvQR334404
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 11:22:57 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SHMvHZ017367
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 11:22:57 -0600
Subject: Re: [RFC][PATCH 2/7] ia64 generic PAGE_SIZE
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0608281003070.27677@schroedinger.engr.sgi.com>
References: <20060828154413.E05721BD@localhost.localdomain>
	 <20060828154414.38AEDAA2@localhost.localdomain>
	 <Pine.LNX.4.64.0608281003070.27677@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 28 Aug 2006 10:22:53 -0700
Message-Id: <1156785773.5913.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-08-28 at 10:04 -0700, Christoph Lameter wrote:
> On Mon, 28 Aug 2006, Dave Hansen wrote:
> > -config IA64_PAGE_SIZE_64KB
> > -     depends on !ITANIUM
> > -     bool "64KB"
> > -
> > -endchoice
> 
> Uhh.. arch specific stuff in mm/Kconfig. Each arch needs to modify the 
> mm/Kconfig?

Yes and no.  First of all, 15 of the 24 architectures use the Kconfig
default of 4k pages.  Anybody adding an architecture with 4k pages only
has to include asm-generic/page.h in their arch, and they don't add
*anything* to Kconfig.  If they want completely fixed page sizes other
than 4k, they only add '|| ARCH' on one line in the Kconfig.

There are a couple of ways to go about enabling the configurable page
sizes.  One is to do what I did, hand have all of the architectures
enumerated in mm/Kconfig.  The other is to have something along the
lines of:

        choice
                prompt "Kernel Page Size"
                depends on ARCH_CHOOSES_PAGE_SIZE
        	...
        
Then in arch/{ia64,...}/Kconfig, have
        
        config ARCH_CHOOSES_PAGE_SIZE
        	def_bool y
        
That would be easy enough to do.  However, what I wanted to get out of
this was to be able to look at mm/Kconfig and get a really nice overview
of what *everybody* is doing.  I'd be more inclined to do the
ARCH_CHOOSES... stuff if the architecture-specific conditions were
actually complicated.  They really aren't.

Admittedly, this is a bit different from how it has been done
traditionally, but is is a really great tool for anyone working on
arch-generic code that wants to know "what architectures have an 8k page
size", or "what arches have a configurable page size".  This makes one
place to go look, with zero grepping.  

> Also cc linux-ia64@vger.kernel.org on these. 

Sure thing.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
