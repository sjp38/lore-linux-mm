Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A04876B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 06:07:55 -0400 (EDT)
Date: Wed, 10 Apr 2013 20:07:52 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 02/28] vmscan: take at least one pass with shrinkers
Message-ID: <20130410100752.GA10481@dastard>
References: <20130408084202.GA21654@lge.com>
 <51628412.6050803@parallels.com>
 <20130408090131.GB21654@lge.com>
 <51628877.5000701@parallels.com>
 <20130409005547.GC21654@lge.com>
 <20130409012931.GE17758@dastard>
 <20130409020505.GA4218@lge.com>
 <20130409123008.GM17758@dastard>
 <20130410025115.GA5872@lge.com>
 <20130410084606.GA10235@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130410084606.GA10235@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Apr 10, 2013 at 04:46:06PM +0800, Wanpeng Li wrote:
> On Wed, Apr 10, 2013 at 11:51:16AM +0900, Joonsoo Kim wrote:
> >On Tue, Apr 09, 2013 at 10:30:08PM +1000, Dave Chinner wrote:
> >> On Tue, Apr 09, 2013 at 11:05:05AM +0900, Joonsoo Kim wrote:
> >> > I don't think so.
> >> > Yes, lowmem_shrink() return number of (in)active lru pages
> >> > when nr_to_scan is 0. And in shrink_slab(), we divide it by lru_pages.
> >> > lru_pages can vary where shrink_slab() is called, anyway, perhaps this
> >> > logic makes total_scan below 128.
> >> 
> >> "perhaps"
> >> 
> >> 
> >> There is no "perhaps" here - there is *zero* guarantee of the
> >> behaviour you are claiming the lowmem killer shrinker is dependent
> >> on with the existing shrinker infrastructure. So, lets say we have:
.....
> >> IOWs, this algorithm effectively causes the shrinker to be called
> >> 127 times out of 128 in this arbitrary scenario. It does not behave
> >> as you are assuming it to, and as such any code based on those
> >> assumptions is broken....
> >
> >Thanks for good example. I got your point :)
> >But, my concern is not solved entirely, because this is not problem
> >just for lowmem killer and I can think counter example. And other drivers
> >can be suffered from this change.
> >
> >I look at the code for "huge_zero_page_shrinker".
> >They return HPAGE_PMD_NR if there is shrikerable object.

<sigh>

Yet another new shrinker that is just plain broken. it tracks a
*single object*, and returns a value only when the ref count value
is 1 which will result in freeing the zero page at some
random time in the future after some number of other calls to the
shrinker where the refcount is also 1.

This is *insane*.

> >I try to borrow your example for this case.
> >
> > 	nr_pages_scanned = 1,000
> > 	lru_pages = 100,000
> > 	batch_size = SHRINK_BATCH = 128
> > 	max_pass= 512 (HPAGE_PMD_NR)
> >
> > 	total_scan = shrinker->nr_in_batch = 0
> > 	delta = 4 * 1,000 / 2 = 2,000
> > 	delta = 2,000 * 512 = 1,024,000
> > 	delta = 1,024,000 / 100,001 = 10
> > 	total_scan += delta = 10
> >
> >As you can see, before this patch, do_shrinker_shrink() for
> >"huge_zero_page_shrinker" is not called until we call shrink_slab() more
> >than 13 times. *Frequency* we call do_shrinker_shrink() actually is
> >largely different with before.

If the frequency of the shrinker calls breaks the shrinker
functionality or the subsystem because it pays no attention to
nr_to_scan, then the shrinker is fundamentally broken. The shrinker
has *no control* over the frequency of the calls to it or the bathc
size, and so being dependent on "small numbers means few calls" for
correct behaviour is dangerously unpredictable and completely
non-deterministic.

Besides, if you don't want to be shrunk, return a count of -1.
Shock, horror, it is even documented in the API!

 * 'sc' is passed shrink_control which includes a count 'nr_to_scan'             
 * and a 'gfpmask'.  It should look through the least-recently-used              
 * 'nr_to_scan' entries and attempt to free them up.  It should return           
 * the number of objects which remain in the cache.  If it returns -1, it means  
 * it cannot do any scanning at this time (eg. there is a risk of deadlock).     

> >With this patch, we actually call
> >do_shrinker_shrink() for "huge_zero_page_shrinker" 12 times more
> >than before. Can we be convinced that there will be no problem?
> >
> >This is why I worry about this change.
> >Am I worried too much? :)

You're worrying about the wrong thing. You're assuming that
shrinkers are implemented correctly and sanely, but the reality is
that most shrinkers are fundamentally broken in some way or another.

These are just two examples of many. We are trying to fix the API
and shrinker infrastructure to remove the current insanity. We want
to make the shrinkers more flexible so that stuff like one-shot low
memory event notifications can be implemented without grotesque
hacks like the shrinkers you've used as examples so far...

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
