Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 748706B0005
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 07:36:48 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id b205so122585363wmb.1
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 04:36:48 -0800 (PST)
Received: from gir.skynet.ie (gir.skynet.ie. [193.1.99.77])
        by mx.google.com with ESMTPS id y133si26227545wme.72.2016.02.21.04.36.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 21 Feb 2016 04:36:47 -0800 (PST)
Date: Sun, 21 Feb 2016 12:36:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug 99471] System locks with kswapd0 and kworker taking full IO
 and mem
Message-ID: <20160221123644.GJ4537@csn.ul.ie>
References: <bug-99471-27@https.bugzilla.kernel.org/>
 <bug-99471-27-hjYeBz7jw2@https.bugzilla.kernel.org/>
 <20150910140418.73b33d3542bab739f8fd1826@linux-foundation.org>
 <20150915083919.GG2858@cmpxchg.org>
 <20151005200345.GA12889@dhcp22.suse.cz>
 <20160216144159.9335e48d65b7327984d298ac@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160216144159.9335e48d65b7327984d298ac@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, gaguilar@aguilardelgado.com, sgh@sgh.dk, Rik van Riel <riel@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, serianox@gmail.com, spam@kernelspace.de, larsnostdal@gmail.com, viktorpal@yahoo.de, shentino@gmail.com

On Tue, Feb 16, 2016 at 02:41:59PM -0800, Andrew Morton wrote:
> On Mon, 5 Oct 2015 22:03:46 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Tue 15-09-15 10:39:19, Johannes Weiner wrote:
> > > On Thu, Sep 10, 2015 at 02:04:18PM -0700, Andrew Morton wrote:
> > > > (switched to email.  Please respond via emailed reply-to-all, not via the
> > > > bugzilla web interface).
> > > > 
> > > > On Tue, 01 Sep 2015 12:32:10 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> > > > 
> > > > > https://bugzilla.kernel.org/show_bug.cgi?id=99471
> > > > 
> > > > Guys, could you take a look please?
> 
> So this isn't fixed and a number of new reporters (cc'ed) are chiming
> in (let's please keep this going via email, not via the bugzilla UI!).
> 
> We have various theories but I don't think we've nailed it down yet.
> 

So, I'm nowhere close to this at the moment. I was aware of at least one
swapping-related problem that was introduced between 4.0 and 4.1. The
commit that introduced it only affects NUMA so there is no chance they
are related. However, I'll still need to chase that down early next week
before considering this problem. Someone else may figure it out faster.

As the problem I'm aware of is NUMA only, I took a momentary look at
this. The first log shows MCE errors but they may be overheating related
so I'm willing to ignore that.

The log clearly states that a lot of memory is pinned by the GPU just
before the OOM triggers.

[ 2175.996060] Purging GPU memory, 499712 bytes freed, 615251968 bytes still pinned.

So that in itself is a major problem. Next the memory usage at the time
of failure was

[ 2175.999016] active_anon:305425 inactive_anon:141206 isolated_anon:0
                active_file:5109 inactive_file:4666 isolated_file:0
                unevictable:4 dirty:2 writeback:0 unstable:0
                free:13218 slab_reclaimable:6552 slab_unreclaimable:11310
                mapped:21203 shmem:155079 pagetables:10921 bounce:0
                free_cma:0

1.8G of anony memory usage with almost 600M of that being GPU-related.
The file usage is negligible so this is looking closer to being a true
OOM situation

[ 2175.999080] Free swap  = 1615656kB
[ 2175.999082] Total swap = 2097148kB

Load of swap available. The IO is likely high because files are probably
being continually reclaimed and paged back in so it's thrashing.
Johannes is likely correct when he says there is a problem with
balancing when the storage is fast. That's one aspect of the problem
but it does not explain why the problem is recent. The one major
candidate I can spot is this

1da58ee2: mm: vmscan: count only dirty pages as congested

That alters how and when processes are put to sleep waiting on
congestion to clear. While I can see the logic behind the patch, the
impact was no quantified and it can mean that kswapd is no longer
throttling when it used to. Try something like this untested

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2aec4241b42a..50b24a022db0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -953,8 +953,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * end of the LRU a second time.
 		 */
 		mapping = page_mapping(page);
-		if (((dirty || writeback) && mapping &&
-		     inode_write_congested(mapping->host)) ||
+		if ((mapping && inode_write_congested(mapping->host)) ||
 		    (writeback && PageReclaim(page)))
 			nr_congested++;
 
This is not necessary the right fix, it just may narrow down where the
problem is.

The problem is compounded probably by scasnning one third of the LRU before
any reclaim candidates are found. Is it known if all the people reporting
problems are using an i915 GPU? If so, Daniel, are you aware of any commits
between 3.18 and 4.1 that would potentially pin GPU memory permanently or
alternative would have busted the shrinker?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
