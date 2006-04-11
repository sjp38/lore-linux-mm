Subject: Re: [PATCH 2.6.17-rc1-mm1 0/6] Migrate-on-fault - Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200604112052.50133.ak@suse.de>
References: <1144441108.5198.36.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0604111134350.1027@schroedinger.engr.sgi.com>
	 <200604112052.50133.ak@suse.de>
Content-Type: text/plain
Date: Tue, 11 Apr 2006 16:40:19 -0400
Message-Id: <1144788020.5160.136.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>, ak@suse.com
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-11 at 20:52 +0200, Andi Kleen wrote:
> On Tuesday 11 April 2006 20:46, Christoph Lameter wrote:
> > However, if the page is not frequently references then the 
> > effort required to migrate the page was not justified.
> 
> I have my doubts the whole thing is really worthwhile. It probably 
> would at least need some statistics to only do this for frequent
> accesses, but I don't know where to put this data.
> 
> At least it would be a serious research project to figure out 
> a good way to do automatic migration. From what I was told by
> people who tried this (e.g. in Irix) it is really hard and
> didn't turn out to be a win for them.

My understanding is that it IS really hard to optimize this or try to
use statistics to do this.  Especially if your goal is to eke out the
last ounce of performance, as HPC apps are wont to do.  I'm not
interested in this.  

> 
> The better way is to just provide the infrastructure
> and let batch managers or program itselves take care of migration.

I agree, for that last ounce of performance.  But, I still think we can
do better [have on other systems] than just letting the scheduler move
tasks around a numa system with no attention to their memory locality.
Not everybody want to be locking tasks down to prevent this, either.

> 
> That was the whole idea behind NUMA API - some problems 
> are too hard to figure out automatically by the kernel, so 
> allow the user or application to give it a hand.

I really don't want the kernel to have to figure too much out.  You KNOW
that when you move a task to a different node that either you're moving
away from some memory footprint or, if you're lucky, back close to some
earlier footprint.  How lucky you need to be to achieve the latter
depends on how many nodes you have and how badly the tasks memory
footprint is spread around the nodes due to involuntary migration.
Migrate on fault provides the first piece of infrastructure to address
this.  

The first time a task touches a page that is not in memory, that task's
policies get to choose where the page goes.  Presumably, we go through
some amount of effort to get the page somewhere close to the task or
where it wants it.  We've got a lot of vm infrastructure in support of
this endeavor.  What migrate on fault does is allow that same decision
to be made when a task finds a cached page for which no other tasks
currently have translations [ptes].  Seems like a good time to
reevaluate this.  Now, arranging for a significant number of the task's
pages to be in that state is the subject of another patch series.

> 
> And frankly the defaults we have currently are not that bad,
> perhaps with some small tweaks (e.g. i'm still liking the idea
> of interleaving file cache by default)

No, the defaults aren't bad for initial allocation.  But, they don't
prevent scheduling/load balancing from undoing all the good work done up
front.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
