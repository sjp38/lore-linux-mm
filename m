Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA7LBsro005589
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:11:54 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA7LBsMf120478
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:11:54 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jA7LBr4N004436
	for <linux-mm@kvack.org>; Mon, 7 Nov 2005 16:11:54 -0500
Subject: RE: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1131396662.18176.41.camel@akash.sc.intel.com>
References: <20051107003452.3A0B41855A0@thermo.lanl.gov>
	 <1131389934.25133.69.camel@localhost.localdomain>
	 <1131396662.18176.41.camel@akash.sc.intel.com>
Content-Type: text/plain
Date: Mon, 07 Nov 2005 15:11:07 -0600
Message-Id: <1131397867.25133.92.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: Andy Nelson <andy@thermo.lanl.gov>, ak@suse.de, nickpiggin@yahoo.com.au, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, gmaxwell@gmail.com, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, mingo@elte.hu, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>

On Mon, 2005-11-07 at 12:51 -0800, Rohit Seth wrote:
> On Mon, 2005-11-07 at 12:58 -0600, Adam Litke wrote:
> 
> > I am currently working on an new approach to what you tried.  It
> > requires fewer changes to the kernel and implements the special large
> > page usage entirely in an LD_PRELOAD library.  And on newer kernels,
> > programs linked with the .x ldscript you mention above can run using all
> > small pages if not enough large pages are available.
> > 
> 
> Isn't it true that most of the times we'll need to be worrying about
> run-time allocation of memory (using malloc or such) as compared to
> static.

It really depends on the workload.  I've run HPC apps with 10+GB data
segments.  I've also worked with applications that would benefit from a
hugetlb-enabled morecore (glibc malloc/sbrk).  I'd like to see one
standard hugetlb preload library that handles every different "memory
object" we care about (static and dynamic).  That's what I'm working on
now.

> > For the curious, here's how this all works:
> > 1) Link the unmodified application source with a custom linker script which
> > does the following:
> >   - Align elf segments to large page boundaries
> >   - Assert a non-standard Elf program header flag (PF_LINUX_HTLB)
> >     to signal something (see below) to use large pages.
> 
> We'll need a similar flag for even code pages to start using hugetlb
> pages. In this case to keep the kernel changes to minimum, RTLD will
> need to modified.

Yes, I foresee the functionality currently in my preload lib to exist in
RTLD at some point way down the road.

> > 2) Boot a kernel that supports copy-on-write for PRIVATE hugetlb pages
> > 3) Use an LD_PRELOAD library which reloads the PF_LINUX_HTLB segments into
> > large pages and transfers control back to the application.
> > 
> 
> COW, swap etc. are all very nice (little!) features that make hugetlb to
> get used more transparently.

Indeed.  See my parallel post of a hugetlb-COW RFC :)

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
