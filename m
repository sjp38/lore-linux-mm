Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id CB9FF6B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 21:29:36 -0400 (EDT)
Date: Tue, 9 Apr 2013 11:29:31 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Message-ID: <20130409012931.GE17758@dastard>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
 <1364548450-28254-3-git-send-email-glommer@parallels.com>
 <20130408084202.GA21654@lge.com>
 <51628412.6050803@parallels.com>
 <20130408090131.GB21654@lge.com>
 <51628877.5000701@parallels.com>
 <20130409005547.GC21654@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130409005547.GC21654@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Tue, Apr 09, 2013 at 09:55:47AM +0900, Joonsoo Kim wrote:
> Hello, Glauber.
> 
> On Mon, Apr 08, 2013 at 01:05:59PM +0400, Glauber Costa wrote:
> > On 04/08/2013 01:01 PM, Joonsoo Kim wrote:
> > > On Mon, Apr 08, 2013 at 12:47:14PM +0400, Glauber Costa wrote:
> > >> On 04/08/2013 12:42 PM, Joonsoo Kim wrote:
> > >>> Hello, Glauber.
> > >>>
> > >>> On Fri, Mar 29, 2013 at 01:13:44PM +0400, Glauber Costa wrote:
> > >>>> In very low free kernel memory situations, it may be the case that we
> > >>>> have less objects to free than our initial batch size. If this is the
> > >>>> case, it is better to shrink those, and open space for the new workload
> > >>>> then to keep them and fail the new allocations.
> > >>>>
> > >>>> More specifically, this happens because we encode this in a loop with
> > >>>> the condition: "while (total_scan >= batch_size)". So if we are in such
> > >>>> a case, we'll not even enter the loop.
> > >>>>
> > >>>> This patch modifies turns it into a do () while {} loop, that will
> > >>>> guarantee that we scan it at least once, while keeping the behaviour
> > >>>> exactly the same for the cases in which total_scan > batch_size.
> > >>>
> > >>> Current user of shrinker not only use their own condition, but also
> > >>> use batch_size and seeks to throttle their behavior. So IMHO,
> > >>> this behavior change is very dangerous to some users.
> > >>>
> > >>> For example, think lowmemorykiller.
> > >>> With this patch, he always kill some process whenever shrink_slab() is
> > >>> called and their low memory condition is satisfied.
> > >>> Before this, total_scan also prevent us to go into lowmemorykiller, so
> > >>> killing innocent process is limited as much as possible.
> > >>>
> > >> shrinking is part of the normal operation of the Linux kernel and
> > >> happens all the time. Not only the call to shrink_slab, but actual
> > >> shrinking of unused objects.
> > >>
> > >> I don't know therefore about any code that would kill process only
> > >> because they have reached shrink_slab.
> > >>
> > >> In normal systems, this loop will be executed many, many times. So we're
> > >> not shrinking *more*, we're just guaranteeing that at least one pass
> > >> will be made.
> > > 
> > > This one pass guarantee is a problem for lowmemory killer.
> > > 
> > >> Also, anyone looking at this to see if we should kill processes, is a
> > >> lot more likely to kill something if we tried to shrink but didn't, than
> > >> if we successfully shrunk something.
> > > 
> > > lowmemory killer is hacky user of shrink_slab interface.
> > 
> > Well, it says it all =)
> > 
> > In special, I really can't see how, hacky or not, it makes sense to kill
> > a process if we *actually* shrunk memory.
> > 
> > Moreover, I don't see the code in drivers/staging/android/lowmemory.c
> > doing anything even remotely close to that. Could you point me to some
> > code that does it ?
> 
> Sorry for late. :)
> 
> lowmemkiller makes spare memory via killing a task.
> 
> Below is code from lowmem_shrink() in lowmemorykiller.c
> 
>         for (i = 0; i < array_size; i++) {
>                 if (other_free < lowmem_minfree[i] &&
>                     other_file < lowmem_minfree[i]) {
>                         min_score_adj = lowmem_adj[i];
>                         break;
>                 }   
>         } 

I don't think you understand what the current lowmemkiller shrinker
hackery actually does.

        rem = global_page_state(NR_ACTIVE_ANON) +
                global_page_state(NR_ACTIVE_FILE) +
                global_page_state(NR_INACTIVE_ANON) +
                global_page_state(NR_INACTIVE_FILE);
        if (sc->nr_to_scan <= 0 || min_score_adj == OOM_SCORE_ADJ_MAX + 1) {
                lowmem_print(5, "lowmem_shrink %lu, %x, return %d\n",
                             sc->nr_to_scan, sc->gfp_mask, rem);
                return rem;
        }

So, when nr_to_scan == 0 (i.e. the count phase), the shrinker is
going to return a count of active/inactive pages in the cache. That
is almost always going to be non-zero, and almost always be > 1000
because of the minimum working set needed to run the system.
Even after applying the seek count adjustment, total_scan is almost
always going to be larger than the shrinker default batch size of
128, and that means this shrinker will almost always run at least
once per shrink_slab() call.

And, interestingly enough, when the file cache has been pruned down
to it's smallest possible size, that's when the shrinker *won't run*
because the that's when the total_scan will be smaller than the
batch size and hence shrinker won't get called.

The shrinker is hacky, abuses the shrinker API, and doesn't appear
to do what it is intended to do.  You need to fix the shrinker, not
use it's brokenness as an excuse to hold up a long overdue shrinker
rework.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
