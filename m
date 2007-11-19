Received: from toip6.srvr.bell.ca ([209.226.175.125])
          by tomts22-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071119195258.TCZK18413.tomts22-srv.bellnexxia.net@toip6.srvr.bell.ca>
          for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:52:58 -0500
Date: Mon, 19 Nov 2007 14:52:58 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [PATCH] Cast __page_to_pfn to unsigned long in CONFIG_SPARSEMEM
Message-ID: <20071119195257.GA3440@Krystal>
References: <20071113193349.214098508@polymtl.ca> <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost> <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost> <20071116144742.GA17255@Krystal> <1195495626.27759.119.camel@localhost> <20071119185258.GA998@Krystal> <1195501381.27759.127.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1195501381.27759.127.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

* Dave Hansen (haveblue@us.ibm.com) wrote:
> On Mon, 2007-11-19 at 13:52 -0500, Mathieu Desnoyers wrote:
> > > > So I guess the result is a pointer ? Should this be expected ?
> > > 
> > > Nope.  'pointer - pointer' is an integer.  Just solve this equation for
> > > integer:
> > > 
> > >       'pointer + integer = pointer'
> > > 
> > 
> > Well, using page_to_pfn turns out to be ugly in markers (and in
> > printks) then. Depending on the architecture, it will result in either
> > an unsigned long (x86_64) or an unsigned int (i386), which corresponds
> > to %lu or %u and will print a warning if we don't cast it explicitly. 
> 
> Casting the i386 one to be an unconditional 'unsigned long' shouldn't be
> an issue.  We don't generally expect pfns to fit into ints anyway. 

So would this make sense ?

Cast __page_to_pfn to unsigned long in CONFIG_SPARSEMEM

Make sure the type returned by __page_to_pfn is always unsigned long. If we
don't cast it explicitly, it can be int on i386, but long on x86_64. This is
especially inelegant for printks.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: Dave Hansen <haveblue@us.ibm.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 include/asm-generic/memory_model.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-lttng/include/asm-generic/memory_model.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-generic/memory_model.h	2007-11-19 14:47:30.000000000 -0500
+++ linux-2.6-lttng/include/asm-generic/memory_model.h	2007-11-19 14:48:30.000000000 -0500
@@ -50,7 +50,7 @@
 
 /* memmap is virtually contigious.  */
 #define __pfn_to_page(pfn)	(vmemmap + (pfn))
-#define __page_to_pfn(page)	((page) - vmemmap)
+#define __page_to_pfn(page)	((unsigned long)((page) - vmemmap))
 
 #elif defined(CONFIG_SPARSEMEM)
 /*

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
