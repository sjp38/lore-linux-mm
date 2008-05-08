Date: Thu, 8 May 2008 12:14:08 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 0/3] Guarantee faults for processes that call mmap(MAP_PRIVATE) on hugetlbfs v2
Message-ID: <20080508111408.GB30870@shadowen.org>
References: <20080507193826.5765.49292.sendpatchset@skynet.skynet.ie> <20080508014822.GE5156@yookeroo.seuss>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080508014822.GE5156@yookeroo.seuss>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <dwg@au1.ibm.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, andi@firstfloor.org, kenchen@google.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2008 at 11:48:22AM +1000, David Gibson wrote:
> On Wed, May 07, 2008 at 08:38:26PM +0100, Mel Gorman wrote:
> > MAP_SHARED mappings on hugetlbfs reserve huge pages at mmap() time.
> > This guarantees all future faults against the mapping will succeed.
> > This allows local allocations at first use improving NUMA locality whilst
> > retaining reliability.
> > 
> > MAP_PRIVATE mappings do not reserve pages. This can result in an application
> > being SIGKILLed later if a huge page is not available at fault time. This
> > makes huge pages usage very ill-advised in some cases as the unexpected
> > application failure cannot be detected and handled as it is immediately fatal.
> > Although an application may force instantiation of the pages using mlock(),
> > this may lead to poor memory placement and the process may still be killed
> > when performing COW.
> > 
> > This patchset introduces a reliability guarantee for the process which creates
> > a private mapping, i.e. the process that calls mmap() on a hugetlbfs file
> > successfully.  The first patch of the set is purely mechanical code move to
> > make later diffs easier to read. The second patch will guarantee faults up
> > until the process calls fork(). After patch two, as long as the child keeps
> > the mappings, the parent is no longer guaranteed to be reliable. Patch
> > 3 guarantees that the parent will always successfully COW by unmapping
> > the pages from the child in the event there are insufficient pages in the
> > hugepage pool in allocate a new page, be it via a static or dynamic pool.
> 
> I don't think patch 3 is a good idea.  It's a fair bit of code to
> implement a pretty bizarre semantic that I really don't think is all
> that useful.  Patches 1-2 are already sufficient to cover the
> fork()/exec() case and a fair proportion of fork()/minor
> frobbing/exit() cases.  If the child also needs to write the hugepage
> area, chances are it's doing real work and we care about its
> reliability too.

Without patch 3 the parent is still vunerable during the period the
child exists.  Even if that child does nothing with the pages not even
referencing them, and then execs immediatly.  As soon as we fork any
reference from the parent will trigger a COW, at which point there may
be no pages available and the parent will have to be killed.  That is
regardless of the fact the child is not going to reference the page and
leave the address space shortly.  With patch 3 on COW if we find no memory
available the page may be stolen for the parent saving it, and the _risk_
of reference death moves to the child; the child is killed only should it
then re-reference the page.

Without patch 3 a both the parent and child are immediatly vunerable on
fork() until the child leaves the address space.  With patch 3 only the
child is vunerable.  The main scenario where mapper protection is useful
is for main payload applications which fork helpers.  The parent by
definition is using the mapping heavily whereas we do not expect the
children to even be aware of it.  As the child will not touch the
mapping both parent and child should be safe even if we do have to steal
to save the parent.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
