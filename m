Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C7E9A620002
	for <linux-mm@kvack.org>; Wed, 23 Dec 2009 01:10:07 -0500 (EST)
Date: Wed, 23 Dec 2009 15:09:48 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH 25 of 28] transparent hugepage core
Message-ID: <20091223060948.GA30983@linux-sh.org>
References: <patchbomb.1261076403@v2.random> <4d96699c8fb89a4a22eb.1261076428@v2.random> <20091218200345.GH21194@csn.ul.ie> <20091219164143.GC29790@random.random> <20091221203149.GD23345@csn.ul.ie> <20091223000640.GI6429@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091223000640.GI6429@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, linux-sh@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 23, 2009 at 01:06:40AM +0100, Andrea Arcangeli wrote:
> On Mon, Dec 21, 2009 at 08:31:50PM +0000, Mel Gorman wrote:
> > IA-64 can't in its currently implementation. Due to the page table format
> > they use, huge pages can only be mapped at specific ranges in the virtual
> > address space. If the long-format version of the page table was used, they
> 
> Hmm ok, so it sounds like hugetlbfs limitations are a software feature
> for ia64 too.
> 
> > would be able to but I bet it's not happening any time soon. The best bet
> > for other architectures supporting this would be sparc and maybe sh.
> > It might be worth poking Paul Mundt in particular because he expressed
> > an interest in transparent support of some sort in the past for sh.
> 
> I added him to CC.
> 
Thanks. It's probably worth going over a bit of background of the SH TLB
and the hugetlb support. For starters, it's a software loaded TLB, and
while we have 2-levels in hardware, extra levels do get abused in
software for certain configurations.

Varying page sizes are just PTE attributes and these are supported at
4kB, 8kB, 64kB, 256kB, 1MB, 4MB, and 64MB on general parts. SH-5 also has
a 512MB page size, but this tends to mainly be used for fixed-purpose
section mappings. Where the system page sizes stop and the hugetlb sizes
start are pretty arbitrary, generally these were from 64kB and up, but
there are systems using a 64kB PAGE_SIZE as well in which case the
huge pages start at the next available size (you can see the dependencies
for these in arch/sh/mm/Kconfig).

Beyond that, there is also a section mapping buffer (PMB) that supports
sizes of 16MB, 64MB, 128MB, and 512MB. This has no miss exception
associated with it, or permission bits, so only tends to get used for
large kernel mappings (it has a wide range of differing cache attributes
at least, and all entries are pre-faulted). ioremap() backs through this
transparently at the moment, but there is no hugetlb support for it yet.
If hugetlb is going to become more transparent on the other hand, then
it's certainly worth looking at doing support for something like this at
the PMD level with special attributes and piggybacking the TLB miss. The
closest example to this on any other platform would probably be the PPC
SLB, which also seems to be a bit more capable.

As we have a software managed TLB, most of what I've toyed with in
regards to transparency has been using larger TLBs for contiguous page
ranges from the TLB miss while retaining a smaller PAGE_SIZE. We tend not
to have very many > 1 order contiguous allocations though, so 64kB and up
TLBs rarely get loaded. Some folks (it might have been Christoph) were
doing similar things on IA-64 by using special encodings for size and
section placement hinting, but I don't recall what became of this. There
were also some ARM folks who had attempted to do similar things by
scanning at set_pte() time at least for the XScale parts (due to having
to contend with hardware table walking), but that seems to have been
abandoned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
