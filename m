Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 7AB876B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 20:55:15 -0400 (EDT)
Date: Tue, 9 Apr 2013 09:55:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Message-ID: <20130409005547.GC21654@lge.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
 <1364548450-28254-3-git-send-email-glommer@parallels.com>
 <20130408084202.GA21654@lge.com>
 <51628412.6050803@parallels.com>
 <20130408090131.GB21654@lge.com>
 <51628877.5000701@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51628877.5000701@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

Hello, Glauber.

On Mon, Apr 08, 2013 at 01:05:59PM +0400, Glauber Costa wrote:
> On 04/08/2013 01:01 PM, Joonsoo Kim wrote:
> > On Mon, Apr 08, 2013 at 12:47:14PM +0400, Glauber Costa wrote:
> >> On 04/08/2013 12:42 PM, Joonsoo Kim wrote:
> >>> Hello, Glauber.
> >>>
> >>> On Fri, Mar 29, 2013 at 01:13:44PM +0400, Glauber Costa wrote:
> >>>> In very low free kernel memory situations, it may be the case that we
> >>>> have less objects to free than our initial batch size. If this is the
> >>>> case, it is better to shrink those, and open space for the new workload
> >>>> then to keep them and fail the new allocations.
> >>>>
> >>>> More specifically, this happens because we encode this in a loop with
> >>>> the condition: "while (total_scan >= batch_size)". So if we are in such
> >>>> a case, we'll not even enter the loop.
> >>>>
> >>>> This patch modifies turns it into a do () while {} loop, that will
> >>>> guarantee that we scan it at least once, while keeping the behaviour
> >>>> exactly the same for the cases in which total_scan > batch_size.
> >>>
> >>> Current user of shrinker not only use their own condition, but also
> >>> use batch_size and seeks to throttle their behavior. So IMHO,
> >>> this behavior change is very dangerous to some users.
> >>>
> >>> For example, think lowmemorykiller.
> >>> With this patch, he always kill some process whenever shrink_slab() is
> >>> called and their low memory condition is satisfied.
> >>> Before this, total_scan also prevent us to go into lowmemorykiller, so
> >>> killing innocent process is limited as much as possible.
> >>>
> >> shrinking is part of the normal operation of the Linux kernel and
> >> happens all the time. Not only the call to shrink_slab, but actual
> >> shrinking of unused objects.
> >>
> >> I don't know therefore about any code that would kill process only
> >> because they have reached shrink_slab.
> >>
> >> In normal systems, this loop will be executed many, many times. So we're
> >> not shrinking *more*, we're just guaranteeing that at least one pass
> >> will be made.
> > 
> > This one pass guarantee is a problem for lowmemory killer.
> > 
> >> Also, anyone looking at this to see if we should kill processes, is a
> >> lot more likely to kill something if we tried to shrink but didn't, than
> >> if we successfully shrunk something.
> > 
> > lowmemory killer is hacky user of shrink_slab interface.
> 
> Well, it says it all =)
> 
> In special, I really can't see how, hacky or not, it makes sense to kill
> a process if we *actually* shrunk memory.
> 
> Moreover, I don't see the code in drivers/staging/android/lowmemory.c
> doing anything even remotely close to that. Could you point me to some
> code that does it ?

Sorry for late. :)

lowmemkiller makes spare memory via killing a task.

Below is code from lowmem_shrink() in lowmemorykiller.c

        for (i = 0; i < array_size; i++) {
                if (other_free < lowmem_minfree[i] &&
                    other_file < lowmem_minfree[i]) {
                        min_score_adj = lowmem_adj[i];
                        break;
                }   
        } 

lowmemkiller kill a process if min_score_adj is assigned.
And then, it goes to for_each_process() loop and select target task.
And then, execute below code.

        if (selected) {
		...
                send_sig(SIGKILL, selected, 0);
                set_tsk_thread_flag(selected, TIF_MEMDIE);
		...
        }

lowmemkiller just check sc->nr_to_scan whether it is 0 or not. And it don't
check it anymore. So if we run do_shrinker_shrink() atleast once
without checking batch_size, there will be side-effect.

Thanks.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
