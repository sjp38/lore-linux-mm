From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Bug: early_pfn_in_nid() called when not early
Date: Thu, 14 Dec 2006 00:37:51 +0100
References: <200612131920.59270.arnd@arndb.de> <20061213231717.GC10708@monkey.ibm.com>
In-Reply-To: <20061213231717.GC10708@monkey.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200612140037.53477.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: cbe-oss-dev@ozlabs.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andy Whitcroft <apw@shadowen.org>, Michael Kravetz <mkravetz@us.ibm.com>, hch@infradead.org, Jeremy Kerr <jk@ozlabs.org>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thursday 14 December 2006 00:17, Mike Kravetz wrote:
> Thanks for the debug work!  Just curious if you really need
> CONFIG_NODES_SPAN_OTHER_NODES defined for your platform?  Can you get
> those types of memory layouts?  If not, an easy/immediate fix for you
> might be to simply turn off the option.

We want to be able to run the same kernel as pseries, e.g. on
distributions that ship only one kernel. Cell should be able to
live without CONFIG_NODES_SPAN_OTHER_NODES, but that does not solve
the problem for us.

> > --- linux-2.6.orig/mm/page_alloc.c
> > +++ linux-2.6/mm/page_alloc.c
> > @@ -1962,7 +1962,8 @@ void __meminit memmap_init_zone(unsigned
> >       for (pfn = start_pfn; pfn < end_pfn; pfn++) {
> >               if (!early_pfn_valid(pfn))
> >                       continue;
> > -             if (!early_pfn_in_nid(pfn, nid))
> > +             if (!slab_is_available() &&
> > +                 !early_pfn_in_nid(pfn, nid))
> >                       continue;
> >               page = pfn_to_page(pfn);
> >               set_page_links(page, zone, nid, pfn);
> 
> I know you don't recommend this as a fix, but it has the interesting
> quality of doing exactly what we want for powerpc.  When
> slab_is_available() we are performing a 'memory add' operation
> and there is no need to do the 'pfn_in_nid' check.  We know that
> the range of added pages will all be on the same (passed) nid.

Right, that was at least my intention, though I wasn't sure
if pseries can live without the check.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
