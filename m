Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 082236B00EA
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 11:32:22 -0400 (EDT)
Date: Tue, 30 Apr 2013 16:32:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 06/31] mm: new shrinker API
Message-ID: <20130430153218.GC11497@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
 <1367018367-11278-7-git-send-email-glommer@openvz.org>
 <20130430144033.GF6415@suse.de>
 <517FDD29.7000600@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <517FDD29.7000600@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>

On Tue, Apr 30, 2013 at 07:03:05PM +0400, Glauber Costa wrote:
> On 04/30/2013 06:40 PM, Mel Gorman wrote:
> > On Sat, Apr 27, 2013 at 03:19:02AM +0400, Glauber Costa wrote:
> >> From: Dave Chinner <dchinner@redhat.com>
> >>
> >> The current shrinker callout API uses an a single shrinker call for
> >> multiple functions. To determine the function, a special magical
> >> value is passed in a parameter to change the behaviour. This
> >> complicates the implementation and return value specification for
> >> the different behaviours.
> >>
> >> Separate the two different behaviours into separate operations, one
> >> to return a count of freeable objects in the cache, and another to
> >> scan a certain number of objects in the cache for freeing. In
> >> defining these new operations, ensure the return values and
> >> resultant behaviours are clearly defined and documented.
> >>
> >> Modify shrink_slab() to use the new API and implement the callouts
> >> for all the existing shrinkers.
> >>
> >> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> > 
> > Glauber's signed-off appears to be missing.
> > 
> I didn't sign all patches, just the ones I have changed.
> Should I sign them all ?
> 

Yes because you are on the submission path and form part of the chain of
trust. Andrew does not change every patch he signs off, neither does Greg
(-stable) or Linus (mainline).

> > 
> > As unreasonable as it is, it means that this API can no longer can handle
> > more than "long" objects. While we'd never hit the limit in practice
> > unless shrinkers are insane or the objects represent something that is
> > not stored in memory, it still looks odd to allow an API to potentially
> > say it has a negative number of objects and as as far as I can gather,
> > it's just so the shrinkers can return -1.
> > 
> > Why not leave this as unsigned long and return SHRINK_UNCOUNTABLE
> > count_objects if the number of freeable items cannot be determined and
> > SHRINK_UNFREEABLE if scan_objects cannot free without risk of deadlock.
> > Underneath, SHRINK_* would be defined as ULONG_MAX.
> > 
>
> I believe you have already saw the reason for that in the following patch.
> 

Yes, although it was to match existing behaviour, not because it was
necessarily a good idea.

> Do you still have a problem with this ?
> 

Not enough to NAK it but it would be desirable because it does feel strange
to have the API deal with negative numbers of objects just to have -1.

> > 
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index f9d2fba..ca3f690 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -205,19 +205,19 @@ static inline int do_shrinker_shrink(struct shrinker *shrinker,
> >>   *
> >>   * Returns the number of slab objects which we shrunk.
> >>   */
> >> -unsigned long shrink_slab(struct shrink_control *shrink,
> >> +unsigned long shrink_slab(struct shrink_control *sc,
> >>  			  unsigned long nr_pages_scanned,
> >>  			  unsigned long lru_pages)
> >>  {
> > 
> > In every other part of vmscan.c, sc is a scan_control but here it is a
> > shrink_control. That's an unfortunate reuse of a name that cause me to
> > scratch my head later when I looked at the tracepoint modification.
> > shrinkc? It's a crappy suggestion but if you think of a better name than
> > sc then a rename would be nice.
> >
> 
> 
> I am all in favor of being explicit. How about we rename sc to...
> shrink_control ?
> 

It has the advantage of being impossible to confuse :)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
