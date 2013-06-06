Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 11DDF6B0034
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:44:43 -0400 (EDT)
Date: Thu, 6 Jun 2013 13:44:40 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 00/35] kmemcg shrinkers
Message-ID: <20130606034440.GU29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <20130605160721.da995af82eb247ccf8f8537f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605160721.da995af82eb247ccf8f8537f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>

On Wed, Jun 05, 2013 at 04:07:21PM -0700, Andrew Morton wrote:
> On Mon,  3 Jun 2013 23:29:29 +0400 Glauber Costa <glommer@openvz.org> wrote:
> 
> > Andrew,
> > 
> > This submission contains one small bug fix over the last one. I have been
> > testing it regularly and believe this is ready for merging. I have follow up
> > patches for this series, with a few improvements (namely: dynamic sized
> > list_lru node arrays, memcg flush-at-destruction, kmemcg shrinking setting
> > limit < usage).  But since this series is already quite mature - and very
> > extensive, I don't believe that adding new patches would make them receive the
> > appropriate level of review. So please advise me if there is anything crucial
> > missing in here. Thanks!
> > 
> > Hi,
> > 
> > This patchset implements targeted shrinking for memcg when kmem limits are
> > present. So far, we've been accounting kernel objects but failing allocations
> > when short of memory. This is because our only option would be to call the
> > global shrinker, depleting objects from all caches and breaking isolation.
> > 
> > The main idea is to associate per-memcg lists with each of the LRUs. The main
> > LRU still provides a single entry point and when adding or removing an element
> > from the LRU, we use the page information to figure out which memcg it belongs
> > to and relay it to the right list.
> > 
> > Base work:
> > ==========
> > 
> > Please note that this builds upon the recent work from Dave Chinner that
> > sanitizes the LRU shrinking API and make the shrinkers node aware. Node
> > awareness is not *strictly* needed for my work, but I still perceive it
> > as an advantage. The API unification is a major need, and I build upon it
> > heavily. That allows us to manipulate the LRUs without knowledge of the
> > underlying objects with ease. This time, I am including that work here as
> > a baseline.
> 
> This patchset is huge.

*nod*

> My overall take is that the patchset is massive and intrusive and scary
> :( I'd like to see more evidence that the memcg people (mhocko, hannes,
> kamezawa etc) have spent quality time reviewing and testing this code. 
> There really is a lot of it!
> 
> I haven't seen any show-stoppers yet so I guess I'll slam it all into
> -next and cross fingers.  I would ask that the relevant developers set
> aside a solid day to read and runtime test it all.  Realistically, it's
> likely to take considerably more time that that.

Yes, it will.

> I do expect that I'll drop the entire patchset again for the next
> version, if only because the next version should withdraw all the
> switch-random-code-to-xfs-coding-style changes...
> 
> 
> I'm thinking that we should approach this in two stages: all the new
> shrinker stuff separated from the memcg_kmem work.  So we merge
> everything up to "shrinker: Kill old ->shrink API" and then continue to
> work on the memcg things?

Fine by me. I'll work with Glauber to get all the documentation and
formatting and bugs you found fixed for the LRU/shrinker part of the 
patchset as quickly as possible...

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
