Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 7CD156B0002
	for <linux-mm@kvack.org>; Tue, 14 May 2013 18:55:13 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 14 May 2013 16:55:12 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1382919D8043
	for <linux-mm@kvack.org>; Tue, 14 May 2013 16:55:03 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4EMt9FZ345680
	for <linux-mm@kvack.org>; Tue, 14 May 2013 16:55:09 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4EMt6M7009843
	for <linux-mm@kvack.org>; Tue, 14 May 2013 16:55:09 -0600
Date: Tue, 14 May 2013 17:55:01 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv11 3/4] zswap: add to mm/
Message-ID: <20130514225501.GA11956@cerebellum>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default>
 <20130514163541.GC4024@medulla>
 <f0272a06-141a-4d33-9976-ee99467f3aa2@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f0272a06-141a-4d33-9976-ee99467f3aa2@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Tue, May 14, 2013 at 01:18:48PM -0700, Dan Magenheimer wrote:
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Subject: Re: [PATCHv11 3/4] zswap: add to mm/
> > 
> > <snip>
> >
> > > > +/* The maximum percentage of memory that the compressed pool can occupy */
> > > > +static unsigned int zswap_max_pool_percent = 20;
> > > > +module_param_named(max_pool_percent,
> > > > +			zswap_max_pool_percent, uint, 0644);
> > 
> > <snip>
> >
> > > This limit, along with the code that enforces it (by calling reclaim
> > > when the limit is reached), is IMHO questionable.  Is there any
> > > other kernel memory allocation that is constrained by a percentage
> > > of total memory rather than dynamically according to current
> > > system conditions?  As Mel pointed out (approx.), if this limit
> > > is reached by a zswap-storm and filled with pages of long-running,
> > > rarely-used processes, 20% of RAM (by default here) becomes forever
> > > clogged.
> > 
> > So there are two comments here 1) dynamic pool limit and 2) writeback
> > of pages in zswap that won't be faulted in or forced out by pressure.
> > 
> > Comment 1 feeds from the point of view that compressed pages should just be
> > another type of memory managed by the core MM.  While ideal, very hard to
> > implement in practice.  We are starting to realize that even the policy
> > governing to active vs inactive list is very hard to get right. Then shrinkers
> > add more complexity to the policy problem.  Throwing another type in the mix
> > would just that much more complex and hard to get right (assuming there even
> > _is_ a "right" policy for everyone in such a complex system).
> > 
> > This max_pool_percent policy is simple, works well, and provides a
> > deterministic policy that users can understand. Users can be assured that a
> > dynamic policy heuristic won't go nuts and allow the compressed pool to grow
> > unbounded or be so aggressively reclaimed that it offers no value.
> 
> Hi Seth --
> 
> Hmmm... I'm not sure how to politely say "bullshit". :-)
> 
> The default 20% was randomly pulled out of the air long ago for zcache
> experiments.  If you can explain why 20% is better than 19% or 21%, or
> better than 10% or 30% or even 50%, that would be a start.  Then please try
> to explain -- in terms an average sysadmin can understand -- under
> what circumstances this number should be higher or lower, that would
> be even better.  In fact if you can explain it in even very broadbrush
> terms like "higher for embedded" and "lower for server" that would be
> useful.  If the top Linux experts in compression can't answer these
> questions (and the default is a random number, which it is), I don't
> know how we can expect users to be "assured".

20% is a default maximum.  There really isn't a particular reason for the
selection other than to supply reasonable default to a tunable.  20% is enough
to show the benefit while assuring the user zswap won't eat more than that
amount of memory under any circumstance.  The point is to make it a tunable,
not to launch an incredibly in-depth study on what the default should be.

As guidance on how to tune it, switching to zbud actually made the math simpler
by bounding the best case to 2 and the expected density to very near 2.  I have
two methods, one based on calculation and another based on experimentation.

Yes, I understand that there are many things to consider, but for the sake of
those that honestly care about the answer to the question, I'll answer it.

Method 1:

If you have a workload running on a machine with x GB of RAM and an anonymous
working set of y GB of pages where x < y, a good starting point for
max_pool_percent is ((y/x)-1)*100.

For example, if you have 10GB of RAM and 12GB anon working set, (12/10-1)*100 =
20.  During operation there would be 8GB in uncompressed memory, and 4GB worth
of compressed memory occupying 2GB (i.e. 20%) of RAM.  This will reduce swap I/O
to near zero assuming the pages compress <50% on average.

Bear in mind that this formula provides a lower bound on max_pool_percent if
you want to avoid swap I/0.  Setting max_pool_percent to >20 would produce
the same situation.

Method 2:

Experimentally, one can just watch swap I/O rates while the workload is running
and increase max_pool_percent until no (or acceptable level of) swap I/O is
occurring.

As max_pool_percent increases, however, there is less and less room for
uncompressed memory, the only kind of memory on which the kernel can actually
operate. Compression/decompression activity might start dominating over useful
work.  Going over 80 is probably not advised.  If swap I/O is still observed
for high values of max_pool_percent, then the memory load should be reduced,
memory capacity should be increased, or performance degradation should be accepted.

> 
> What you mean is "works well"... on the two benchmarks you've tried it
> on.  You say it's too hard to do dynamically... even though every other
> significant RAM user in the kernel has to do it dynamically.
> Workloads are dynamic and heavy users of RAM needs to deal with that.
> You don't see a limit on the number of anonymous pages in the MM subsystem,
> and you don't see a limit on the number of inodes in btrfs.  Linus
> would rightfully barf all over those limits and (if he was paying attention
> to this discussion) he would barf on this limit too.

Putting a user-tunable hard limit on the size of the compressed pool is in _no
way_ analogous to putting an fixed upper bound on system-wide anonymous memory
or number of inodes.  In fact, they are so dissimilar, I don't know what else to
say about the attempted comparison.

zswap is not like other caches in the kernel. Most caches make use of
unused/less recently used memory in an effort to improve performance by
avoiding rereads from persistent media.  In the case of zswap, its size is near
0 until memory pressure hits a threshold; a point at which traditional caches
start shrinking.  zswap _grows_ under memory pressure while all other caches
shrink.  This is why traditional cache sizing policies and techniques don't
work with zswap. In the absence of any precedent policy for this kind of
caching, zswap goes with a simple, but understandable one: user-tunable cap
on the maximum size and shrink through pressure and (soon) age driven writeback.

Seth

> 
> It's unfortunate that my proposed topic for LSFMM was pre-empted
> by the zsmalloc vs zbud discussion and zswap vs zcache, because
> I think the real challenge of zswap (or zcache) and the value to
> distros and end users requires us to get this right BEFORE users
> start filing bugs about performance weirdness.  After which most
> users and distros will simply default to 0% (i.e. turn zswap off)
> because zswap unpredictably sometimes sucks.
> 
> <flame off> sorry...
> 
> > Comment 2 I agree is an issue. I already have patches for a "periodic
> > writeback" functionality that starts to shrink the zswap pool via
> > writeback if zswap goes idle for a period of time.  This addresses
> > the issue with long-lived, never-accessed pages getting stuck in
> > zswap forever.
> 
> Pulling the call out of zswap_frontswap_store() (and ensuring there still
> aren't any new races) would be a good start.  But this is just a mechanism;
> you haven't said anything about the policy or how you intend to
> enforce the policy.  Which just gets us back to Comment 1...
> 
> So Comment 1 and Comment 2 are really the same:  How do we appropriately
> manage the number of pages in the system that are used for storing
> compressed pages?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
