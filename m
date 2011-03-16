Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 321A08D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 08:45:37 -0400 (EDT)
Date: Wed, 16 Mar 2011 13:45:17 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-ID: <20110316124517.GL2140@cmpxchg.org>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299869011-26152-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Fri, Mar 11, 2011 at 10:43:22AM -0800, Greg Thelen wrote:
> This patch set provides the ability for each cgroup to have independent dirty
> page limits.
> 
> Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
> page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
> not be able to consume more than their designated share of dirty pages and will
> be throttled if they cross that limit.
> 
> Example use case:
>   #!/bin/bash
>   #
>   # Here is a test script that shows a situation where memcg dirty limits are
>   # beneficial.
>   #
>   # The script runs two programs:
>   # 1) a dirty page background antagonist (dd)
>   # 2) an interactive foreground process (tar).
>   #
>   # If the script's argument is false, then both processes are run together in
>   # the root cgroup sharing system-wide dirty memory in classic fashion.  If the
>   # script is given a true argument, then a cgroup is used to contain dd dirty
>   # page consumption.  The cgroup isolates the dd dirty memory consumption from
>   # the rest of the system processes (tar in this case).
>   #
>   # The time used by the tar process is printed (lower is better).
>   #
>   # The tar process had faster and more predictable performance.  memcg dirty
>   # ratios might be useful to serve different task classes (interactive vs
>   # batch).  A past discussion touched on this:
>   # http://lkml.org/lkml/2010/5/20/136
>   #
>   # When called with 'false' (using memcg without dirty isolation):
>   #  tar takes 8s
>   #  dd reports 69 MB/s
>   #
>   # When called with 'true' (using memcg for dirty isolation):
>   #  tar takes 6s
>   #  dd reports 66 MB/s
>   #
>   echo memcg_dirty_limits: $1
>   
>   # Declare system limits.
>   echo $((1<<30)) > /proc/sys/vm/dirty_bytes
>   echo $((1<<29)) > /proc/sys/vm/dirty_background_bytes
>   
>   mkdir /dev/cgroup/memory/A
>   
>   # start antagonist
>   if $1; then    # if using cgroup to contain 'dd'...
>     echo 400M > /dev/cgroup/memory/A/memory.dirty_limit_in_bytes
>   fi
>   
>   (echo $BASHPID > /dev/cgroup/memory/A/tasks; \
>    dd if=/dev/zero of=big.file count=10k bs=1M) &
>   
>   # let antagonist get warmed up
>   sleep 10
>   
>   # time interactive job
>   time tar -xzf linux.tar.gz
>   
>   wait
>   sleep 10
>   rmdir /dev/cgroup/memory/A
> 
> 
> The patches are based on a series proposed by Andrea Righi in Mar 2010.
> 
> 
> Overview:
> - Add page_cgroup flags to record when pages are dirty, in writeback, or nfs
>   unstable.
> 
> - Extend mem_cgroup to record the total number of pages in each of the 
>   interesting dirty states (dirty, writeback, unstable_nfs).  
> 
> - Add dirty parameters similar to the system-wide /proc/sys/vm/dirty_* limits to
>   mem_cgroup.  The mem_cgroup dirty parameters are accessible via cgroupfs
>   control files.
> 
> - Consider both system and per-memcg dirty limits in page writeback when
>   deciding to queue background writeback or throttle dirty memory production.
> 
> Known shortcomings (see the patch 1/9 update to Documentation/cgroups/memory.txt
> for more details):
> - When a cgroup dirty limit is exceeded, then bdi writeback is employed to
>   writeback dirty inodes.  Bdi writeback considers inodes from any cgroup, not
>   just inodes contributing dirty pages to the cgroup exceeding its limit.

The smaller your cgroups wrt overall system size, the less likely it
becomes that writeback will find the pages that unblock throttled
cgrouped dirtiers.

Your example was probably not much affected from this because the
'needle' of 400MB dirty memory from the cgroup would have to be
searched for only in the 1G 'haystack' that is the sum total of dirty
memory before the dirtier could continue (and considering.  Even
memcg-unaware writeback has a decent chance of writing back the right
pages by accident.

The performance of the throttled dirtier already dropped by 5% in your
testcase, so I would be really interested in a case where you have 100
cgroups with dirty limits relatively small to the global dirty limit.

> - A cgroup may exceed its dirty limit if the memory is dirtied by a process in a
>   different memcg.

I do wonder if we should hide the knobs from userspace as long as the
limits can not be strictly enforced.  Just proportionally apply the
global dirty limit (memory.limit_in_bytes * dirty_ratio / 100) and
make it a best-effort optimization.  It would be an improvement for
the common case without promising anything.  Does that make sense?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
