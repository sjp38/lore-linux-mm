Date: Thu, 24 Apr 2008 09:47:37 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [RFC] Reserve huge pages for reliable MAP_PRIVATE hugetlbfs mappings
Message-ID: <20080424084736.GA25266@shadowen.org>
References: <20080421183621.GA13100@csn.ul.ie> <87hcdsznep.fsf@basil.nowhere.org> <20080423151428.GA15834@csn.ul.ie> <20080423154323.GA29087@one.firstfloor.org> <20080423160112.GC15834@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423160112.GC15834@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andi Kleen <andi@firstfloor.org>, wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 05:01:13PM +0100, Mel Gorman wrote:
> On (23/04/08 17:43), Andi Kleen didst pronounce:
> > > If the large pages exist to satisfy the mapping, the application will not
> > > even notice this change. They will only break if the are creating larger
> > > mappings than large pages exist for (or can be allocated for in the event
> > > they have enabled dynamic resizing with nr_overcommit_hugepages). If they
> > > are doing that, they are running a big risk as they may get arbitrarily
> > > killed later. 
> > 
> > The point is it is pretty common (especially when you have enough 
> > address space) just create a huge mapping and only use the begining.
> 
> Clearly these applications are assuming that overcommit is always allowed
> because otherwise they would be failing. Also, the behaviour with reservations
> is currently inconsistent as MAP_SHARED always tries to reserve the pages.
> Maybe large shared mappings are rarer than large private mappings, but
> this inconsistency is still shoddy.

As I remember history, in the beginning we had pre-fault semantics for all
mappings.  This meant that for the longest time we had the equivalent to
"reserve at mmap" semantics, indeed probabally had reserve at fork() too.
When dynamic faulting went in (to get locality of allocation to reference
for performance in numa systems) that changed, but mostly because it
was seen as hard to implement, or perhaps hard to decide what the sane
semantics were.

During the evolution since its been clear that the biggest problem is
unreliable semantics.  A semantic difference between private and shared
mappings is annoying enough, but the random SIGKILL at a random time in
the future has always been a festering thorn.  How many customers would
accept a support response of "yeah it'll do that on day 5 one time in
20 or so *beam*" not many I would bet.

In an ideal world we would have the same semantics for small and large
pages, but that would be to ignore the obvious difference in quantity and
availability of these mappings.  Of the strict and sloppy semantic options
we have had, the former are cirtainly easier to rely on if potentially
harder to work with.

> > This avoids costly resize operations later and is a quite useful
> > strategy on 64bit (but even on 32bit).  Now the upper size will
> > likely be incredibly huge (far beyond available physical memory), but it's 
> > obviously impossible really uses all of it.
> > 
> > It's also common in languages who don't support dynamic allocation well (like 
> > older fortran dialects). Given these won't use hugetlbfs directly either, 
> > but I couldn't rule out that someone wrote a special fortran run time library 
> > which transparently allocates large arrays from hugetlbfs. 
> > 
> > In fact i would be surprised if a number of such beasts don't exist -- it is 
> > really an obvious simple tuning option for old HPC fortran applications.
> > 
> 
> I don't know if such a run-time library exists but libhugetlbfs is occasionally
> used in situations like this to back the data segment backed by huge pages. It
> first copies the data MAP_SHARED to fake the reservation before remapping
> private and kinda hopes for the best.

Indeed we do see a number of such fortran apps.  The nice thing about them
is that they actually have only static allocations and so that in reality we
know how big they are up front and can use that information when sizing
the mappings to back them.  So those are actually the _easiest_ to handle.

> > > Sometimes their app will run, other times it dies. If more
> > > than one application is running on the system that is behaving like this,
> > > they are really playing with fire.
> > 
> > With your change such an application will not run at all. Doesn't
> > seem like an improvement to me.
> > 
> 
> I disagree. mmap() failing is something an application should be able to
> take care of and at least it possible as opposed to SIGKILL where it's
> "game over". Even if they are using run-time helpers like libhugetlbfs,
> it should be able to detect when a large-page-backed is flaky and use small
> pages instead. As it is, it's very difficult to detect in advance if future
> faults will succeed, particularly when more than one application is running.
> 
> If the application is unable to handle mmap() failing, then yes, it'll
> exit. But at least it'll exit consistently and not get SIGKILLed
> randomly which to me is a far worse situation.
>
> > > With this change, a mmap() failure is a clear indication that the mapping
> > > would have been unsafe to use and they should try mmap()ing with small pages
> > > instead. 
> > 
> > I don't have a problem with having an optional strict overcommit checking 
> > mode (similar to what standard VM has), but it should be configurable
> > and off by default.
> > 
> 
> There already is partial strict overcommit checking for MAP_SHARED. I
> think it should be consistent and done for MAP_PRIVATE.
> 
> For disabling, I could look into adding MAP_NORESERVE support and
> something like the current overcommit_memory tunable for hugetlbfs.
> However with yet another proc tunable, I would push for enabling strict
> checking by default for safe behaviour than disabled by default for
> random SIGKILLs.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
