Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBHFxl8F005418
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 10:59:47 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBHFxi86287274
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 10:59:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBHFxiLv011188
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 10:59:44 -0500
Subject: Re: [patch] [RFC] make WANT_PAGE_VIRTUAL a config option
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0412171132560.793@scrub.home>
References: <E1Cf3bP-0002el-00@kernel.beaverton.ibm.com>
	 <Pine.LNX.4.61.0412170133560.793@scrub.home>
	 <1103244171.13614.2525.camel@localhost>
	 <Pine.LNX.4.61.0412170150080.793@scrub.home>
	 <1103246050.13614.2571.camel@localhost>
	 <Pine.LNX.4.61.0412170256500.793@scrub.home>
	 <1103257482.13614.2817.camel@localhost>
	 <Pine.LNX.4.61.0412171132560.793@scrub.home>
Content-Type: text/plain
Message-Id: <1103299179.13614.3551.camel@localhost>
Mime-Version: 1.0
Date: Fri, 17 Dec 2004 07:59:39 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, geert@linux-m68k.org, ralf@linux-mips.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2004-12-17 at 05:26, Roman Zippel wrote:
> On Thu, 16 Dec 2004, Dave Hansen wrote:
> > Sorry I didn't provide this.  My recent effort started to clean up some
> > ugliness in some current patches that worked around this actually
> > happening a few months ago.  The original example didn't survive :)
> 
> There are two points, which did originally catch my attention.
> 1) Where/why do you want to remove the dependency on asm/page.h?

The basic reason is that I think it's important to know exactly what
you're getting into when you include a header, especially when you're
authoring new headers.  

That said, it doesn't appear that asm/page.h is a header that causes any
real problems.  In any case, when there are variables that need to be
created based on Kconfig parameters, I believe the "correct" thing to do
is make a Kconfig variable.  But, that is a separate conversation. :)

> 2) Does every structure really needs its own header?

No.  But, I do think that most of the very basic VM structures do, as it
stands.  That's limited to struct page, zone, and pgdat as I see it
now.  

> If you want to do such a cleanup, it would be helpful to have some more 
> information about where you want to go, otherwise you may create a more 
> twisted maze of header files.

One thing I'd like to point out is that I don't necessarily think that
the normal foo.c user should see any change.  They can still include
mmzone.h for the same stuff, but *inside* the headers, there's some more
organization.  Here's an example from a new header that I'm working on
after shifting the headers around.

#include <asm/page-consts.h>      /* for PAGE_SHIFT */
#include <asm/addr-convert.h>     /* for __pa() */
#include <linux/structpage.h>     /* for struct page */
#include <linux/sparse-consts.h>  /* for NR_MEM_SECTIONS... */
#include <linux/sparse-structs.h> /* for mem_section[] */

The dependencies aren't very twisted at all.  In fact, I don't think any
of those are deeper than two.  More importantly, I never have to cope
with 'struct page;' keeping me from doing arithmetic. 

> The big question here is what further cleanups are possible in this area?
> What basically needs to be done is to separate the definitions from its 
> users, that doesn't mean every definition needs its own header file. Why 
> not create a single header file which collects a number of mm related 
> definitions? E.g. struct vm_area_struct is also used by a number of header 
> files, although its main users have already been separated into 
> asm/tlbflush.h and so created even more headers.
> So to allow further header cleanup, we should look what other definitions 
> can be pulled out of mm.h and related headers. mm.h should probably stay a 
> high level header, but I'd also like to see a cleanup of asm/page.h. The 
> page table definitions in there should be available to every mm related 
> header.

I agree that I'm probably getting a bit carried away.  But, I don't
really see the harm in having both high-level headers and more finely
grained ones.  You could even think of the finely grained ones as
internal only.

In my example above the header is called linux/sparse.h.  It end up
including linux/sparse-consts.h and linux/sparse-structs.h.  So, any .c
file users can just include linux/sparse.h and forget about it.  But, if
any crazy header authors need either of the components in a different
order, they can have it.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
