Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0FF3E8D0041
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 18:58:12 -0400 (EDT)
Date: Thu, 17 Mar 2011 18:56:57 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110317225657.GI10482@redhat.com>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <AANLkTimeH-hFiqtALfzyyrHiLz52qQj0gCisaJ-taCdq@mail.gmail.com>
 <20110317173223.GG4116@quack.suse.cz>
 <AANLkTimwUrvyEJdF7s2XZCv4JaC_rsTA1Rg9u68xMs=O@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimwUrvyEJdF7s2XZCv4JaC_rsTA1Rg9u68xMs=O@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Curt Wohlgemuth <curtw@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Justin TerAvest <teravest@google.com>

On Thu, Mar 17, 2011 at 11:55:34AM -0700, Curt Wohlgemuth wrote:
> On Thu, Mar 17, 2011 at 10:32 AM, Jan Kara <jack@suse.cz> wrote:
> > On Thu 17-03-11 08:46:23, Curt Wohlgemuth wrote:
> >> On Tue, Mar 8, 2011 at 2:31 PM, Jan Kara <jack@suse.cz> wrote:
> >> The design of IO-less foreground throttling of writeback in the context of
> >> memory cgroups is being discussed in the memcg patch threads (e.g.,
> >> "[PATCH v6 0/9] memcg: per cgroup dirty page accounting"), but I've got
> >> another concern as well.  And that's how restricting per-BDI writeback to a
> >> single task will affect proposed changes for tracking and accounting of
> >> buffered writes to the IO scheduler ("[RFC] [PATCH 0/6] Provide cgroup
> >> isolation for buffered writes", https://lkml.org/lkml/2011/3/8/332 ).
> >>
> >> It seems totally reasonable that reducing competition for write requests to
> >> a BDI -- by using the flusher thread to "handle" foreground writeout --
> >> would increase throughput to that device.  At Google, we experiemented with
> >> this in a hacked-up fashion several months ago (FG task would enqueue a work
> >> item and sleep for some period of time, wake up and see if it was below the
> >> dirty limit), and found that we were indeed getting better throughput.
> >>
> >> But if one of one's goals is to provide some sort of disk isolation based on
> >> cgroup parameters, than having at most one stream of write requests
> >> effectively neuters the IO scheduler.  We saw that in practice, which led to
> >> abandoning our attempt at "IO-less throttling."
> 
> >  Let me check if I understand: The problem you have with one flusher
> > thread is that when written pages all belong to a single memcg, there is
> > nothing IO scheduler can prioritize, right?
> 
> Correct.  Well, perhaps.  Given that the memory cgroups and the IO
> cgroups may not overlap, it's possible that write requests from a
> single memcg might be targeted to multiple IO cgroups, and scheduling
> priorities can be maintained.  Of course, the other way round might be
> the case as well.

[CCing some folks who were involved in other mail thread]

I think that for buffered write case it would make most sense when memory
controller and IO controller are co-mounted and working with each other.
The reason being that for async writes we need to control the dirty share of
a cgroup as well as try to prioritize the IO at device level from cgroup.

It would not make any sense that a low prio async group is choked at device
level and its footprint in page cache is increasing resulting in choking
other fast writers. 

So we need to make sure that slow writers don't have huge page cache
footprint and hence I think using memory and IO controller together
makes sense. Do you have other use cases where it does not make sense?

> 
> The point is just that from however many memcgs the flusher thread is
> working on behalf of, there's only a single stream of requests, which
> are *likely* for a single IO cgroup, and hence there's nothing to
> prioritize.

I think even single submitter stream can also make sense if underlying
device/bdi is slow and submitter is fast and switches frequently between
memory cgroups for selection of inodes.

So we have IO control at device level and we have IO queues for each
cgroup and if flusher thread can move quickly (say submit 512 pages
from one cgroup and then move to next), from one cgroup to other,
then we should automatically get the IO difference.

In other mail I suggested that if we can keep per memory cgroup per BDI stats
for number of writes in progress, then flusher thread can skip submitting
IO from cgroups which are slow and there are many pending writebacks. That is
a hint to flusher thread that IO scheduler is giving this cgroup a lower
priority hence high number of writes in flight which are simply queued up at
IO schduler. For high priority cgroups which are making progress, pending
writebacks will be small or zero and flusher can submit more inodes/pages
from that memory cgroup. That way a higher weight group should get more IO
done as compared to a slower group.

I am assuming that prioritizing async request is primarily is for slow
media like single SATA disk. If yes, then flusher thread should be
able to submit pages much faster then device can complete those and
can cgroup IO queues busy at end device hence IO scheduler should be
able to prioritize.

Thoughts?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
