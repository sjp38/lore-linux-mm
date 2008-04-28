Date: Mon, 28 Apr 2008 10:34:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/4] Add a basic debugging framework for memory initialisation
Message-ID: <20080428093426.GB3294@csn.ul.ie>
References: <20080422183133.13750.57133.sendpatchset@skynet.skynet.ie> <20080422183153.13750.61533.sendpatchset@skynet.skynet.ie> <20080425231028.cb4a57b1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080425231028.cb4a57b1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mingo@elte.hu, linux-kernel@vger.kernel.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On (25/04/08 23:10), Andrew Morton didst pronounce:
> > On Tue, 22 Apr 2008 19:31:53 +0100 (IST) Mel Gorman <mel@csn.ul.ie> wrote:
> >
> > This patch creates a new file mm/mm_init.c which is conditionally compiled
> > to have almost all of the debugging and verification code to avoid further
> > polluting page_alloc.c. Ideally other mm initialisation code will be moved
> > here over time and the file partially compiled depending on Kconfig.
> 
> I was wondering why the file was misnamed ;)
> 

:) I named it mm_debug.c at one point before figuring another attempt to
move the init code out of page_alloc.c might help make that file more
readable in the long term.

> I worry that
> 
> a) MM developers will forget to turn on the debug option (ask me about
>    this) and the code in mm_init.c will break and 
> 
> b) The mm_init.c code is broken (or will break) on some architecture(s)
>    and people who run that arch won't turn on the debug option either.
> 
> So hm.  I think that we should be more inclined to at least compile the
> code even if we don't run it.  To catch compile-time breakage.
> 

Ok, that seems fair as CONFIG_DEBUG_VM is probably not enabled a lot of the
time. I had slightly different concerns where it would compile fine, but the
verification code would be broken at runtime due to some change in the core
(zonelist handling for example) and not caught quickly. I will set this
to always build unless CONFIG_EMBEDDED in which case it iss optional. The
default logging level will be set to only print messages on errors. The
possibility will exist that a change later will cause compile-breakage on
CONFIG_EMBEDDED && !CONFIG_DEBUG_MEMORY_INIT.

Is this a reasonable approach?

> And it would be good if we could have a super-quick version of the checks
> just so that more people at least partially run them.  Or something.
> 

As it is, the checks should not cause noticable slowdown on boot. The
most common tests is the one run on each initialised struct page

+void __meminit mminit_verify_page_links(struct page *page, enum zone_type zone,
+                       unsigned long nid, unsigned long pfn)
+{
+       BUG_ON(page_to_nid(page) != nid);
+       BUG_ON(page_zonenum(page) != zone);
+       BUG_ON(page_to_pfn(page) != pfn);
+}

I doubt the overhead will be noticed.

If future expensive tests become, they could run conditionally depending
on the value of mminit_level=.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
