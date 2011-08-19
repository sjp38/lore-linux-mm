Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3B56B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 09:56:10 -0400 (EDT)
Date: Fri, 19 Aug 2011 15:55:57 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] memcg: replace ss->id_lock with a rwlock
Message-ID: <20110819135556.GA9662@redhat.com>
References: <1313000433-11537-1-git-send-email-abrestic@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1313000433-11537-1-git-send-email-abrestic@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Bresticker <abrestic@google.com>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org

Hello Andrew,

On Wed, Aug 10, 2011 at 11:20:33AM -0700, Andrew Bresticker wrote:
> While back-porting Johannes Weiner's patch "mm: memcg-aware global reclaim"
> for an internal effort, we noticed a significant performance regression
> during page-reclaim heavy workloads due to high contention of the ss->id_lock.
> This lock protects idr map, and serializes calls to idr_get_next() in
> css_get_next() (which is used during the memcg hierarchy walk).  Since
> idr_get_next() is just doing a look up, we need only serialize it with
> respect to idr_remove()/idr_get_new().  By making the ss->id_lock a
> rwlock, contention is greatly reduced and performance improves.
> 
> Tested: cat a 256m file from a ramdisk in a 128m container 50 times
> on each core (one file + container per core) in parallel on a NUMA
> machine.  Result is the time for the test to complete in 1 of the
> containers.  Both kernels included Johannes' memcg-aware global
> reclaim patches.
> Before rwlock patch: 1710.778s
> After rwlock patch: 152.227s

The reason why there is much more hierarchy walking going on is
because there was actually a design bug in the hierarchy reclaim.

The old code would pick one memcg and scan it at decreasing priority
levels until SCAN_CLUSTER_MAX pages were reclaimed.  For each memcg
scanned with priority level 12, there were SWAP_CLUSTER_MAX pages
reclaimed.

My last revision would bail the whole hierarchy walk once it reclaimed
SWAP_CLUSTER_MAX.  Also, at the time, small memcgs were not
force-scanned yet.  So 128m containers would force the priority level
to 10 before scanning anything at all (128M / pagesize >> priority),
and then bail after one or two scanned memcgs.  This means that for
each SWAP_CLUSTER_MAX reclaimed pages there was a nr_of_containers * 2
overhead of just walking the hierarchy to no avail.

I changed this and removed the bail condition based on the number of
reclaimed pages.  Instead, the cycle ends when all reclaimers together
made a full round-trip through the hierarchy.  The more cgroups, the
more likely that there are several tasks going into reclaim
concurrently, it should be a reasonable share of work for each one.

The number of reclaim invocations, thus the number of hierarchy walks,
is back to sane levels again and the id_lock contention should be less
of an issue.

Your patch still makes sense, but it's probably less urgent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
