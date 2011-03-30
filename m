Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A67988D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 12:17:38 -0400 (EDT)
Date: Wed, 30 Mar 2011 17:17:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Lsf] [LSF][MM] page allocation & direct reclaim latency
Message-ID: <20110330161716.GA3876@csn.ul.ie>
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com>
 <20110329190520.GJ12265@random.random>
 <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>

On Wed, Mar 30, 2011 at 07:13:42AM +0900, Minchan Kim wrote:
> On Wed, Mar 30, 2011 at 4:05 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > Hi Rik, Hugh and everyone,
> >
> > On Tue, Mar 29, 2011 at 11:35:09AM -0400, Rik van Riel wrote:
> >> On 03/29/2011 12:36 AM, James Bottomley wrote:
> >> > Hi All,
> >> >
> >> > Since LSF is less than a week away, the programme committee put together
> >> > a just in time preliminary agenda for LSF.  As you can see there is
> >> > still plenty of empty space, which you can make suggestions
> >>
> >> There have been a few patches upstream by people for who
> >> page allocation latency is a concern.
> >>
> >> It may be worthwhile to have a short discussion on what
> >> we can do to keep page allocation (and direct reclaim?)
> >> latencies down to a minimum, reducing the slowdown that
> >> direct reclaim introduces on some workloads.
> >
> > I don't see the patches you refer to, but checking schedule we've a
> > slot with Mel&Minchan about "Reclaim, compaction and LRU
> > ordering". Compaction only applies to high order allocations and it
> > changes nothing to PAGE_SIZE allocations, but it surely has lower
> > latency than the older lumpy reclaim logic so overall it should be a
> > net improvement compared to what we had before.
> >
> > Should the latency issues be discussed in that track?
> 
> It's okay to me. LRU ordering issue wouldn't take much time.
> But I am not sure Mel would have a long time. :)
> 

What might be worth discussing on LRU ordering is encountering dirty pages
at the end of the LRU. This is a long-standing issues and patches have been
merged to mitigate the problem since the last LSF/MM. For example [e11da5b4:
tracing, vmscan: add trace events for LRU list shrinking] was the beginning
of a series that added some tracing around catching when this happened
and to mitigate it somewhat (at least according to the report included in
that changelog).

This happened since the last LSF/MM so it might be worth re-discussing if the
dirty-pages-at-end-of-LRU has mitigated somewhat. The last major bug
report that I'm aware of in that area was due to compaction rather than
reclaim but that could just mean people have given up raising the issue.

A trickier subject on LRU ordering is to consider if we are recycling
pages through the LRU too aggressively and aging too quickly. There have
been some patches in this area recently but it's not really clear if we
are happy with how the LRU lists age at the moment.

> About reclaim latency, I sent a patch in the old days.
> http://marc.info/?l=linux-mm&m=129187231129887&w=4
> 

Andy Whitcroft also posted patches ages ago that were related to lumpy reclaim
which would capture high-order pages being reclaimed for the exclusive use
of the reclaimer. It was never shown to be necessary though. I'll read this
thread in a bit because I'm curious to see why it came up now.

> And some guys on embedded had a concern about latency.
> They want OOM rather than eviction of working set and undeterministic
> latency of reclaim.
> 
> As another issue of related to latency, there is a OOM.
> To accelerate task's exit, we raise a priority of the victim process
> but it had a problem so Kosaki decided reverting the patch. It's
> totally related to latency issue but it would
> 

I think we should be very wary of conflating OOM latency, reclaim latency and
allocation latency as they are very different things with different causes.

> In addition, Kame and I sent a patch to prevent forkbomb. Kame's
> apprach is to track the history of mm and mine is to use sysrq to kill
> recently created tasks. The approaches have pros and cons.
> But anyone seem to not has a interest about forkbomb protection.
> So I want to listen other's opinion we really need it
> 
> I am not sure this could become a topic of LSF/MM
> If it is proper, I would like to talk above issues in "Reclaim,
> compaction and LRU ordering" slot.
> 

I'd prefer to see OOM-related issues treated as a separate-but-related
problem if possible so;

1. LRU ordering - are we aging pages properly or recycling through the
   list too aggressively? The high_wmark*8 change made recently was
   partially about list rotations and the associated cost so it might
   be worth listing out whatever issues people are currently aware of.
2. LRU ordering - dirty pages at the end of the LRU. Are we still going
   the right direction on this or is it still a shambles?
3. Compaction latency, other issues (IRQ disabling latency was the last
   one I'm aware of)
4. OOM killing and OOM latency - Whole load of churn going on in there.

?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
