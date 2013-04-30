Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 33B6C6B014D
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 18:47:52 -0400 (EDT)
Date: Tue, 30 Apr 2013 23:47:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 00/31] kmemcg shrinkers
Message-ID: <20130430224748.GP6415@suse.de>
References: <1367018367-11278-1-git-send-email-glommer@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1367018367-11278-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Sat, Apr 27, 2013 at 03:18:56AM +0400, Glauber Costa wrote:
> Numbers (not updated since last time):
> ======================================
> 
> I've run kernbench with 2Gb setups and 3 different kernels. All of them are
> capable of cgroup kmem accounting,  but the first two ones won't be able to
> shrink it.
> 
> Kernels
> -------
> base: the current -mm
> davelru: that + dave's patches applied
> fulllru: that + my patches applied.
> 
> I've ran all of them in a 1st level cgroup. Please note that the first
> two kernels are not capable of shrinking metadata, so I had to select a
> size that is enough to be in relatively constant pressure, but at the
> same time not having that pressure to be exclusively from kernel memory.
> 2Gb did the job. This is a 2-node 24-way machine.
> 
> Results:
> --------
> 
> Base:
> Average Optimal load -j 24 Run (std deviation):
> Elapsed Time 415.988 (8.37909)
> User Time 4142 (759.964)
> System Time 418.483 (62.0377)
> Percent CPU 1030.7 (267.462)
> Context Switches 391509 (268361)
> Sleeps 738483 (149934)
> 

This took longer than I expected and I ran out of beans by the time I hit
the memcg parts but I had started pagereclaim tests earlier and picked
up the results. There are some oddities in there that imply that slab
shrinkers are now way more aggressive, particularly when called from
kswapd. In some cases it looks like it's favouring shrinking slab over
pages which is not what I expected.  I've no idea if the oddities were
introduced by the patches I reviewed and I missed (or miscalculated)
or in the later patches that I haven't read yet.

http://www.csn.ul.ie/~mel/postings/shrinker-20130430/report.html

This is based on the configs/config-global-dhp__pagereclaim-performance
from mmtests with alterations to run the test on a freshly created ext4
filesystem.

postmark
  o Overall performance is good but ...
  o kswapd pages scanned went from 9957291 to 4486. Thats a very
    suspiciously high drop
  o Same for kswapd pages reclaimed
  o kswapd inode steals are through the roof
  o graphs indicate almost no kswapd scanning activity
  o free memory now has a very sawtooth pattern freeing pages in spikes

  In combination this implies we are shrinking slab aggressively and
  barely reclaiming user pages as the slab shrink is sufficient to free
  enough memory.

largedd
  o there is now direct reclaim activity
  o kswapd scan and reclaim rates are again drastically altered
  o slabs scanned is apparently through the roof
  o memory is getting freed in LARGE chunks, look at the free memory
    over time graph and look at the big sawtooth pattern for the patched
    kernel
  o kswapd CPU usage is highly variable. It might indicate a pattern of
    sleep, WAKE UP RECLAIM EVERYTHING, sleep ages, ARGH WAKE UP KILL WORLD

fsmark-single
  o very similar observations to largedd

micro
  o slabs scanned looks a bit mental again

I've queued another test to run just the patches up to and including
"shrinker: Kill old ->shrink API".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
