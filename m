Received: from toip7.srvr.bell.ca ([209.226.175.124])
          by tomts22-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071120173920.NPUG18413.tomts22-srv.bellnexxia.net@toip7.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 20 Nov 2007 12:39:20 -0500
Date: Tue, 20 Nov 2007 12:34:19 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH] Cast page_to_pfn to unsigned long in CONFIG_SPARSEMEM
Message-ID: <20071120173418.GA650@Krystal>
References: <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost> <20071116144742.GA17255@Krystal> <1195495626.27759.119.camel@localhost> <20071119185258.GA998@Krystal> <1195501381.27759.127.camel@localhost> <20071119195257.GA3440@Krystal> <1195502983.27759.134.camel@localhost> <20071119202023.GA5086@Krystal> <20071119130801.bd7b7021.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <20071119130801.bd7b7021.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

* Andrew Morton (akpm@linux-foundation.org) wrote:
> On Mon, 19 Nov 2007 15:20:23 -0500
> Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> 
> > * Dave Hansen (haveblue@us.ibm.com) wrote:
> > > The only thing I might suggest doing differently is actually using the
> > > page_to_pfn() definition itself:
> > > 
> > > memory_model.h:#define page_to_pfn __page_to_pfn
> > > 
> > > The full inline function version should do this already, and we
> > > shouldn't have any real direct __page_to_pfn() users anyway.    
> > > 
> > 
> > Like this then..
> > 
> > Cast page_to_pfn to unsigned long in CONFIG_SPARSEMEM
> > 
> > Make sure the type returned by page_to_pfn is always unsigned long. If we
> > don't cast it explicitly, it can be int on i386, but long on x86_64.
> 
> formally ptrdiff_t, I believe.
> 
> > This is
> > especially inelegant for printks.
> > 
> > Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> > CC: Dave Hansen <haveblue@us.ibm.com>
> > CC: linux-mm@kvack.org
> > CC: linux-kernel@vger.kernel.org
> > ---
> >  include/asm-generic/memory_model.h |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > Index: linux-2.6-lttng/include/asm-generic/memory_model.h
> > ===================================================================
> > --- linux-2.6-lttng.orig/include/asm-generic/memory_model.h	2007-11-19 15:06:40.000000000 -0500
> > +++ linux-2.6-lttng/include/asm-generic/memory_model.h	2007-11-19 15:18:57.000000000 -0500
> > @@ -76,7 +76,7 @@ struct page;
> >  extern struct page *pfn_to_page(unsigned long pfn);
> >  extern unsigned long page_to_pfn(struct page *page);
> >  #else
> > -#define page_to_pfn __page_to_pfn
> > +#define page_to_pfn ((unsigned long)__page_to_pfn)
> >  #define pfn_to_page __pfn_to_page
> >  #endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
> 
> I'd have thought that __pfn_to_page() was the place to fix this: the
> lower-level point.  Because someone might later start using __pfn_to_page()
> for something.
> 
> Heaven knows why though - why does __pfn_to_page() even exist?

Since it all does away with Christoph's patchset anyway, please drop
this patch. (I think there is also an issue with this patch version,
which is that the define should take the arguments...).

Mathieu

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
