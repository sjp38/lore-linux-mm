Message-Id: <4sur0l$s7b0u@fmsmga001.fm.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [RFC] Hugetlb fallback to normal pages
Date: Thu, 27 Apr 2006 16:31:06 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <1146080780.3872.69.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Adam Litke' <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke wrote on Wednesday, April 26, 2006 12:46 PM
> The problem: Random SIGBUS crashes for applications using large pages
> are not acceptable.  We need a way to handle the fault without giving up
> and killing the process.
> 
> So I've been mulling it over and as I see it, we either 1) Swap out huge
> pages, or 2) Demote huge pages.  In either case we need to be willing to
> accept the performance penalty to gain stability.  At this point, I
> think swapping is too intrusive and way too slow so I am considering
> demotion options.  To simplify things at first, I am only considering
> i386 (and demoting only private mappings of course).

Maybe hugetlb needs a page reclaim logic?


> Here's my idea:  When we fail to instantiate a new page at fault time,
> split the affected vma such that we have a new vma to cover the 1 huge
> page we are demoting.  Allocate HPAGE_SIZE/PAGE_SIZE normal pages.  Use
> the page table to locate any populated hugetlb pages.  Copy the data
> into the normal pages and install them in the page table.  Do any other
> fixup required to make the new VMA anonymous.  Return.
> 
> Any general opinions on the idea (flame retardant suit is equipped)?  As
> far as I can tell, we don't split vmas during fault anywhere else.  Is
> there inherent problems with doing so?  What about the conversion
> process to an anonymous VMA?  Since we are dealing with private mappings
> only, divorcing the vma from the hugetlbfs file should be okay afaics.

Some arch don't support mixed page size within a range of virtual address.
So automatic fallback to smaller page won't work on that arch :-(

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
