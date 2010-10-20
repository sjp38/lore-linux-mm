Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 51C566B00B5
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 20:17:19 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K0HDFs015958
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 20 Oct 2010 09:17:13 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8660845DE52
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:17:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6964845DE4E
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:17:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E82C1DB803C
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:17:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B3E2E1DB8043
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:17:12 +0900 (JST)
Date: Wed, 20 Oct 2010 09:11:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 02/11] memcg: document cgroup dirty memory interfaces
Message-Id: <20101020091109.ccd7b39a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr93lj5t5245.fsf@ninji.mtv.corp.google.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-3-git-send-email-gthelen@google.com>
	<20101019172744.45e0a8dc.nishimura@mxp.nes.nec.co.jp>
	<xr93lj5t5245.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010 14:00:58 -0700
Greg Thelen <gthelen@google.com> wrote:

> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> writes:
> 
> > On Mon, 18 Oct 2010 17:39:35 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> >
> >> Document cgroup dirty memory interfaces and statistics.
> >> 
> >> Signed-off-by: Andrea Righi <arighi@develer.com>
> >> Signed-off-by: Greg Thelen <gthelen@google.com>
> >> ---
> >> 
> >> Changelog since v1:
> >> - Renamed "nfs"/"total_nfs" to "nfs_unstable"/"total_nfs_unstable" in per cgroup
> >>   memory.stat to match /proc/meminfo.
> >> 
> >> - Allow [kKmMgG] suffixes for newly created dirty limit value cgroupfs files.
> >> 
> >> - Describe a situation where a cgroup can exceed its dirty limit.
> >> 
> >>  Documentation/cgroups/memory.txt |   60 ++++++++++++++++++++++++++++++++++++++
> >>  1 files changed, 60 insertions(+), 0 deletions(-)
> >> 
> >> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> >> index 7781857..02bbd6f 100644
> >> --- a/Documentation/cgroups/memory.txt
> >> +++ b/Documentation/cgroups/memory.txt
> >> @@ -385,6 +385,10 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
> >>  pgpgin		- # of pages paged in (equivalent to # of charging events).
> >>  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
> >>  swap		- # of bytes of swap usage
> >> +dirty		- # of bytes that are waiting to get written back to the disk.
> >> +writeback	- # of bytes that are actively being written back to the disk.
> >> +nfs_unstable	- # of bytes sent to the NFS server, but not yet committed to
> >> +		the actual storage.
> >>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
> >>  		LRU list.
> >>  active_anon	- # of bytes of anonymous and swap cache memory on active
> >
> > Shouldn't we add description of "total_diryt/writeback/nfs_unstable" too ?
> > Seeing [5/11], it will be showed in memory.stat.
> 
> Good catch.  See patch (below).
> 
> >> @@ -453,6 +457,62 @@ memory under it will be reclaimed.
> >>  You can reset failcnt by writing 0 to failcnt file.
> >>  # echo 0 > .../memory.failcnt
> >>  
> >> +5.5 dirty memory
> >> +
> >> +Control the maximum amount of dirty pages a cgroup can have at any given time.
> >> +
> >> +Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
> >> +page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
> >> +not be able to consume more than their designated share of dirty pages and will
> >> +be forced to perform write-out if they cross that limit.
> >> +
> >> +The interface is equivalent to the procfs interface: /proc/sys/vm/dirty_*.  It
> >> +is possible to configure a limit to trigger both a direct writeback or a
> >> +background writeback performed by per-bdi flusher threads.  The root cgroup
> >> +memory.dirty_* control files are read-only and match the contents of
> >> +the /proc/sys/vm/dirty_* files.
> >> +
> >> +Per-cgroup dirty limits can be set using the following files in the cgroupfs:
> >> +
> >> +- memory.dirty_ratio: the amount of dirty memory (expressed as a percentage of
> >> +  cgroup memory) at which a process generating dirty pages will itself start
> >> +  writing out dirty data.
> >> +
> >> +- memory.dirty_limit_in_bytes: the amount of dirty memory (expressed in bytes)
> >> +  in the cgroup at which a process generating dirty pages will start itself
> >> +  writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to indicate
> >> +  that value is kilo, mega or gigabytes.
> >> +
> >> +  Note: memory.dirty_limit_in_bytes is the counterpart of memory.dirty_ratio.
> >> +  Only one of them may be specified at a time.  When one is written it is
> >> +  immediately taken into account to evaluate the dirty memory limits and the
> >> +  other appears as 0 when read.
> >> +
> >> +- memory.dirty_background_ratio: the amount of dirty memory of the cgroup
> >> +  (expressed as a percentage of cgroup memory) at which background writeback
> >> +  kernel threads will start writing out dirty data.
> >> +
> >> +- memory.dirty_background_limit_in_bytes: the amount of dirty memory (expressed
> >> +  in bytes) in the cgroup at which background writeback kernel threads will
> >> +  start writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to
> >> +  indicate that value is kilo, mega or gigabytes.
> >> +
> >> +  Note: memory.dirty_background_limit_in_bytes is the counterpart of
> >> +  memory.dirty_background_ratio.  Only one of them may be specified at a time.
> >> +  When one is written it is immediately taken into account to evaluate the dirty
> >> +  memory limits and the other appears as 0 when read.
> >> +
> >> +A cgroup may contain more dirty memory than its dirty limit.  This is possible
> >> +because of the principle that the first cgroup to touch a page is charged for
> >> +it.  Subsequent page counting events (dirty, writeback, nfs_unstable) are also
> >> +counted to the originally charged cgroup.
> >> +
> >> +Example: If page is allocated by a cgroup A task, then the page is charged to
> >> +cgroup A.  If the page is later dirtied by a task in cgroup B, then the cgroup A
> >> +dirty count will be incremented.  If cgroup A is over its dirty limit but cgroup
> >> +B is not, then dirtying a cgroup A page from a cgroup B task may push cgroup A
> >> +over its dirty limit without throttling the dirtying cgroup B task.
> >> +
> >>  6. Hierarchy support
> >>  
> >>  The memory controller supports a deep hierarchy and hierarchical accounting.
> >> -- 
> >> 1.7.1
> >> 
> > Can you clarify whether we can limit the "total" dirty pages under hierarchy
> > in use_hierarchy==1 case ?
> > If we can, I think it would be better to note it in this documentation.
> >
> >
> > Thanks,
> > Daisuke Nishimura.
> 
> Here is a second version of this -v3 doc patch:
> 
> Author: Greg Thelen <gthelen@google.com>
> Date:   Sat Apr 10 15:34:28 2010 -0700
> 
>     memcg: document cgroup dirty memory interfaces
>     
>     Document cgroup dirty memory interfaces and statistics.
>     
>     Signed-off-by: Andrea Righi <arighi@develer.com>
>     Signed-off-by: Greg Thelen <gthelen@google.com>
> 

nitpicks. and again, why you always drop Acks ?

> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 7781857..8bf6d3b 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -385,6 +385,10 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
>  pgpgin		- # of pages paged in (equivalent to # of charging events).
>  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
>  swap		- # of bytes of swap usage
> +dirty		- # of bytes that are waiting to get written back to the disk.

extra tab ?

> +writeback	- # of bytes that are actively being written back to the disk.
> +nfs_unstable	- # of bytes sent to the NFS server, but not yet committed to
> +		the actual storage.
>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>  		LRU list.
>  active_anon	- # of bytes of anonymous and swap cache memory on active
> @@ -406,6 +410,9 @@ total_mapped_file	- sum of all children's "cache"
>  total_pgpgin		- sum of all children's "pgpgin"
>  total_pgpgout		- sum of all children's "pgpgout"
>  total_swap		- sum of all children's "swap"
> +total_dirty		- sum of all children's "dirty"
> +total_writeback		- sum of all children's "writeback"

here, too.

> +total_nfs_unstable	- sum of all children's "nfs_unstable"
>  total_inactive_anon	- sum of all children's "inactive_anon"
>  total_active_anon	- sum of all children's "active_anon"
>  total_inactive_file	- sum of all children's "inactive_file"
> @@ -453,6 +460,71 @@ memory under it will be reclaimed.
>  You can reset failcnt by writing 0 to failcnt file.
>  # echo 0 > .../memory.failcnt
>  
> +5.5 dirty memory
> +
> +Control the maximum amount of dirty pages a cgroup can have at any given time.
> +
> +Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
> +page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
> +not be able to consume more than their designated share of dirty pages and will
> +be forced to perform write-out if they cross that limit.
> +
> +The interface is equivalent to the procfs interface: /proc/sys/vm/dirty_*.  It
> +is possible to configure a limit to trigger both a direct writeback or a
> +background writeback performed by per-bdi flusher threads.  The root cgroup
> +memory.dirty_* control files are read-only and match the contents of
> +the /proc/sys/vm/dirty_* files.
> +
> +Per-cgroup dirty limits can be set using the following files in the cgroupfs:
> +
> +- memory.dirty_ratio: the amount of dirty memory (expressed as a percentage of
> +  cgroup memory) at which a process generating dirty pages will itself start
> +  writing out dirty data.
> +
> +- memory.dirty_limit_in_bytes: the amount of dirty memory (expressed in bytes)
> +  in the cgroup at which a process generating dirty pages will start itself
> +  writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to indicate
> +  that value is kilo, mega or gigabytes.
> +
> +  Note: memory.dirty_limit_in_bytes is the counterpart of memory.dirty_ratio.
> +  Only one of them may be specified at a time.  When one is written it is
> +  immediately taken into account to evaluate the dirty memory limits and the
> +  other appears as 0 when read.
> +
> +- memory.dirty_background_ratio: the amount of dirty memory of the cgroup
> +  (expressed as a percentage of cgroup memory) at which background writeback
> +  kernel threads will start writing out dirty data.
> +
> +- memory.dirty_background_limit_in_bytes: the amount of dirty memory (expressed
> +  in bytes) in the cgroup at which background writeback kernel threads will
> +  start writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to
> +  indicate that value is kilo, mega or gigabytes.
> +
> +  Note: memory.dirty_background_limit_in_bytes is the counterpart of
> +  memory.dirty_background_ratio.  Only one of them may be specified at a time.
> +  When one is written it is immediately taken into account to evaluate the dirty
> +  memory limits and the other appears as 0 when read.
> +
> +A cgroup may contain more dirty memory than its dirty limit.  This is possible
> +because of the principle that the first cgroup to touch a page is charged for
> +it.  Subsequent page counting events (dirty, writeback, nfs_unstable) are also
> +counted to the originally charged cgroup.
> +
> +Example: If page is allocated by a cgroup A task, then the page is charged to
> +cgroup A.  If the page is later dirtied by a task in cgroup B, then the cgroup A
> +dirty count will be incremented.  If cgroup A is over its dirty limit but cgroup
> +B is not, then dirtying a cgroup A page from a cgroup B task may push cgroup A
> +over its dirty limit without throttling the dirtying cgroup B task.
> +
> +When use_hierarchy=0, each cgroup has independent dirty memory usage and limits.
> +
> +When use_hierarchy=1, a parent cgroup increasing its dirty memory usage will
> +compare its total_dirty memory (which includes sum of all child cgroup dirty
> +memory) to its dirty limits.  This keeps a parent from explicitly exceeding its
> +dirty limits.  However, a child cgroup can increase its dirty usage without
> +considering the parent's dirty limits.  Thus the parent's total_dirty can exceed
> +the parent's dirty limits as a child dirties pages.

Hmm. in short, dirty_ratio in use_hierarchy=1 doesn't work as an user expects.
Is this a spec. or a current implementation ?

I think as following.
 - add a limitation as "At setting chidlren's dirty_ratio, it must be below parent's.
   If it exceeds parent's dirty_ratio, EINVAL is returned."

Could you modify setting memory.dirty_ratio code ?
Then, parent's dirty_ratio will never exceeds its own. (If I understand correctly.)

"memory.dirty_limit_in_bytes" will be a bit more complecated, but I think you can.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
