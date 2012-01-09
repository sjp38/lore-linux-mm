Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id E8C566B0071
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 12:25:52 -0500 (EST)
Date: Mon, 9 Jan 2012 17:25:48 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120109172548.GJ27881@csn.ul.ie>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
 <4F033EC9.4050909@gmail.com>
 <20120105142017.GA27881@csn.ul.ie>
 <20120105144011.GU11810@n2100.arm.linux.org.uk>
 <20120105161739.GD27881@csn.ul.ie>
 <20120105140645.42498cdd.akpm@linux-foundation.org>
 <20120105223106.GG27881@csn.ul.ie>
 <20120105151919.37d64365.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120105151919.37d64365.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Thu, Jan 05, 2012 at 03:19:19PM -0800, Andrew Morton wrote:
> On Thu, 5 Jan 2012 22:31:06 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Thu, Jan 05, 2012 at 02:06:45PM -0800, Andrew Morton wrote:
> > > On Thu, 5 Jan 2012 16:17:39 +0000
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > mm: page allocator: Guard against CPUs going offline while draining per-cpu page lists
> > > > 
> > > > While running a CPU hotplug stress test under memory pressure, I
> > > > saw cases where under enough stress the machine would halt although
> > > > it required a machine with 8 cores and plenty memory. I think the
> > > > problems may be related.
> > > 
> > > When we first implemented them, the percpu pages in the page allocator
> > > were of really really marginal benefit.  I didn't merge the patches at
> > > all for several cycles, and it was eventually a 49/51 decision.
> > > 
> > > So I suggest that our approach to solving this particular problem
> > > should be to nuke the whole thing, then see if that caused any
> > > observeable problems.  If it did, can we solve those problems by means
> > > other than bringing the dang things back?
> > > 
> > 
> > Sounds drastic.
> 
> Wrong thinking ;)
> 

:)

> Simplifying the code should always be the initial proposal.  Adding
> more complexity on top is the worst-case when-all-else-failed option. 
> Yet we so often reach for that option first :(
> 

Enngghh, I really want to agree with you but reducing lock contention
has been such an important goal for a long time that I am really loathe
to just rip it out and hope for the best.

> > It would be less controversial to replace this patch
> > with a version that calls get_online_cpu() in drain_all_pages() but
> > remove the call to drain_all_pages() call from the page allocator on
> > the grounds it is not safe against CPU hotplug and to hell with the
> > slightly elevated allocation failure rates and stalls. That would avoid
> > the try_get_online_cpus() crappiness and be less complex.
> 
> If we can come up with a reasonably simple patch which improves or even
> fixes the problem then I suppose there is some value in that, as it
> provides users of earlier kernels with something to backport if they
> hit problems.
> 

I'm preparing a patch that is a simplier fix but not sending an IPI at
all. There is also a sysfs fix that is necessary for tests to complete
successfully. The details will be in the series.

> But the social downside of that is that everyone would shuffle off
> towards other bright and shiny things and we'd be stuck with more
> complexity piled on top of dubiously beneficial code.
> 
> > If you really want to consider deleting the per-cpu allocator, maybe
> > it could be a LSF/MM topic?
> 
> eek, spare me.
> 

It was worth a shot.

> Anyway, we couldn't discuss such a topic without data.  Such data would
> be obtained by deleting the code and measuring the results.  Which is
> what I just said ;)
> 

Crap. ok. I've added a TODO list to implement a patch that removes it.
It is at a lower priority than removing lumpy reclaim though -
eventally this TODO list will start shrinking. I'll need to put
some thought into how it can be tested but even then I probably am
not the best person to test it. I don't have regular access to a 2+
socket machine to test NUMA effects for example.

> > Personally I would be wary of deleting
> > it but mostly because I lack regular access to the type of hardware
> > to evaulate whether it was safe to remove or not. Minimally, removing
> > the per-cpu allocator could make the zone lock very hot even though slub
> > probably makes it very hot already.
> 
> Much of the testing of the initial code was done on mbligh's weirdass
> NUMAq box: 32-way 386 NUMA which suffered really badly if there were
> contention issues.  And even on that box, the code was marginal.  So
> I'm hopeful that things will be similar on current machines.  Of
> course, it's possible that calling patterns have changed in ways which
> make the code more beneficial than it used to be.
> 

Core counts are also higher and some workloads might be more
allocator intensive than they used to be - netperf and network-related
allocations for socket receive might be a problem for example.

> But this all ties into my proposal yesterday to remove
> mm/swap.c:lru_*_pvecs.  Most or all of the heavy one-page-at-a-time
> code can pretty easily be converted to operate on batches of pages. 
>
> Folowing on from that, it should be pretty simple to extend the
> batching down into the page freeing.  Look at put_pages_list() and
> weep.  And stuff like free_hot_cold_page_list() which could easily free
> the pages directly whilebatching the locking.
> 
> Page freeing should be relatively straightforward.  Batching page
> allocation is hard in some cases (anonymous pagefaults).
> 

Page faulting would certainly be hard to batch but it would only be
really a big problem if they are intensive enough and on enough CPUs to
cause zone lock contention that was a problem.

> Please do note that the above suggestions are only needed if removing
> the pcp lists causes a problem!  It may not.
> 

True.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
