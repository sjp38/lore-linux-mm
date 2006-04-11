Date: Tue, 11 Apr 2006 17:12:49 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm1 0/6] Migrate-on-fault - Overview
Message-ID: <20060411221248.GA20341@sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain> <Pine.LNX.4.64.0604111134350.1027@schroedinger.engr.sgi.com> <200604112052.50133.ak@suse.de> <20060411190330.GA21229@sgi.com> <1144788046.5160.138.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1144788046.5160.138.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, ak@suse.com
List-ID: <linux-mm.kvack.org>

On Tue, Apr 11, 2006 at 04:40:45PM -0400, Lee Schermerhorn wrote:
> On Tue, 2006-04-11 at 14:03 -0500, Jack Steiner wrote:
> > On Tue, Apr 11, 2006 at 08:52:49PM +0200, Andi Kleen wrote:
> > > On Tuesday 11 April 2006 20:46, Christoph Lameter wrote:
> > > > However, if the page is not frequently references then the 
> > > > effort required to migrate the page was not justified.
> > > 
> > > I have my doubts the whole thing is really worthwhile. It probably 
> > > would at least need some statistics to only do this for frequent
> > > accesses, but I don't know where to put this data.
> > 
> > Agree. And a way to disable the migration-on-fault.
> 
> I know.  I don't have such a control in the current series.  I've
> thought of adding one, but I think this might be better as a per task
> control.  And, to set those, I kind of like Paul Jackson's cpuset
> methodology--like "memory_spread_page".  A "migrate_on_fault" cpuset
> attribute would turn this on for tasks in the cpuset.  Default should
> probably be off.
> 
> Might even want separate controls for migrating anon, file backed, shmem
> pages on fault.  Depends on how the policy for file backed pages gets
> sorted out.

Agree. Adding the controls thru cpuset options seems like a good way 
to go. 


> 
> > 
> > > 
> > > At least it would be a serious research project to figure out 
> > > a good way to do automatic migration. From what I was told by
> > > people who tried this (e.g. in Irix) it is really hard and
> > > didn't turn out to be a win for them.
> > 
> > IRIX had hardware support for counting offnode vs. onnode references
> > to a page & sending interrupts when migration appeared to be beneficial
> > 
> > We intended to use this info to migrate pages.  Unfortunately, we were 
> > never able to demonstrate a performance benefit of migrating pages. 
> > The overhead always exceeded the cost except in a very small number
> > of carefully selected benchmarks.
> 
> This was the work that I heard about.  I don't think I'm trying to do
> that.  The migrate-on-fault series just migrates a cached page that is
> eligible [mapcount==0] and misplaced.  Seems like a good time to
> evaluate the policy.  If enabled, of course.

I realize that what you are doing is somewhat different - particularily in
the way that you decide to migrate a page. However, you still have
some of the same problems that we had on IRIX. If the
page is remote, it is not worth the cost to migrate the page unless
the app will take many cache misses to the page. At one extreme,
if the app is short lived or references only a portion of the page,
migrating the page may have no benefit. Even if the app is long
lived and references most of the page, many apps have a small cache
footprint & sucessfully keep the page in the cache. Again, there many
be no benefit of migration. 

OTOH, if the app is long lived OR has big cache footprint, migration can
be a definite win. 


> 
> I do think that one could find some interesting research in measuring
> the cost of migrating pages vs the benefits of having them local. 

Yes! 

> One
> might want to track per node RSS [as Eric Focht and Martin Bligh, maybe
> others, have previously attempted] and prefer those with smaller memory
> footprints to move offnode during load balancing.  One might chose to
> move larger tasks less frequently based on the cost of migrating and/or
> remote accesses.
> 
> We plan on doing a lot of this measurement and testing.  But, I needed
> the basic infrastructure [migrate on fault, auto-migrate] in place to do
> the testing.  I've already seen benefit in how the system settles back
> into a "good" [if not optimum] state after transient perturbations with
> the multithread streams benchmark results that I posted with V0.1 of the
> auto-migration series.  No fancy page use statistics.  Unmapping pages
> controlled by default policy when the task migrates to a new node caused
> the tasks to pull pages they were using close to themselves.  For a
> multi-threaded OMP job, this tended to do the right thing [to achieve
> maximum throughput] without any explicit placement.  Just start'em up,
> give 'em a good swift kick, and let them fall back into place.  
> 
> Real soon now, I'll take some time out from tracking the bleeding edge
> and run some more benchmarks on our NUMA platforms, with and without
> hardware interleaving, with and without these patches, ...    I'll, uh,
> keep you posted ;-).
> 
> Lee

-- 
Jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
