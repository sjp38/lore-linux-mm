Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 22AE45F0048
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 23:58:32 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH v3 02/11] memcg: document cgroup dirty memory interfaces
Date: Tue, 19 Oct 2010 17:45:08 -0700
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-3-git-send-email-gthelen@google.com>
	<20101019172744.45e0a8dc.nishimura@mxp.nes.nec.co.jp>
	<xr93lj5t5245.fsf@ninji.mtv.corp.google.com>
	<20101020091109.ccd7b39a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <xr93r5fl1poc.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:

> On Tue, 19 Oct 2010 14:00:58 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> writes:
>> 
>> > On Mon, 18 Oct 2010 17:39:35 -0700
>> > Greg Thelen <gthelen@google.com> wrote:
>> >
>> >> Document cgroup dirty memory interfaces and statistics.
>> >> 
>> >> Signed-off-by: Andrea Righi <arighi@develer.com>
>> >> Signed-off-by: Greg Thelen <gthelen@google.com>
>> >> ---
>> >> 
>> >> Changelog since v1:
>> >> - Renamed "nfs"/"total_nfs" to "nfs_unstable"/"total_nfs_unstable" in per cgroup
>> >>   memory.stat to match /proc/meminfo.
>> >> 
>> >> - Allow [kKmMgG] suffixes for newly created dirty limit value cgroupfs files.
>> >> 
>> >> - Describe a situation where a cgroup can exceed its dirty limit.
>> >> 
>> >>  Documentation/cgroups/memory.txt |   60 ++++++++++++++++++++++++++++++++++++++
>> >>  1 files changed, 60 insertions(+), 0 deletions(-)
>> >> 
>> >> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
>> >> index 7781857..02bbd6f 100644
>> >> --- a/Documentation/cgroups/memory.txt
>> >> +++ b/Documentation/cgroups/memory.txt
>> >> @@ -385,6 +385,10 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
>> >>  pgpgin		- # of pages paged in (equivalent to # of charging events).
>> >>  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
>> >>  swap		- # of bytes of swap usage
>> >> +dirty		- # of bytes that are waiting to get written back to the disk.
>> >> +writeback	- # of bytes that are actively being written back to the disk.
>> >> +nfs_unstable	- # of bytes sent to the NFS server, but not yet committed to
>> >> +		the actual storage.
>> >>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>> >>  		LRU list.
>> >>  active_anon	- # of bytes of anonymous and swap cache memory on active
>> >
>> > Shouldn't we add description of "total_diryt/writeback/nfs_unstable" too ?
>> > Seeing [5/11], it will be showed in memory.stat.
>> 
>> Good catch.  See patch (below).
>> 
>> >> @@ -453,6 +457,62 @@ memory under it will be reclaimed.
>> >>  You can reset failcnt by writing 0 to failcnt file.
>> >>  # echo 0 > .../memory.failcnt
>> >>  
>> >> +5.5 dirty memory
>> >> +
>> >> +Control the maximum amount of dirty pages a cgroup can have at any given time.
>> >> +
>> >> +Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
>> >> +page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
>> >> +not be able to consume more than their designated share of dirty pages and will
>> >> +be forced to perform write-out if they cross that limit.
>> >> +
>> >> +The interface is equivalent to the procfs interface: /proc/sys/vm/dirty_*.  It
>> >> +is possible to configure a limit to trigger both a direct writeback or a
>> >> +background writeback performed by per-bdi flusher threads.  The root cgroup
>> >> +memory.dirty_* control files are read-only and match the contents of
>> >> +the /proc/sys/vm/dirty_* files.
>> >> +
>> >> +Per-cgroup dirty limits can be set using the following files in the cgroupfs:
>> >> +
>> >> +- memory.dirty_ratio: the amount of dirty memory (expressed as a percentage of
>> >> +  cgroup memory) at which a process generating dirty pages will itself start
>> >> +  writing out dirty data.
>> >> +
>> >> +- memory.dirty_limit_in_bytes: the amount of dirty memory (expressed in bytes)
>> >> +  in the cgroup at which a process generating dirty pages will start itself
>> >> +  writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to indicate
>> >> +  that value is kilo, mega or gigabytes.
>> >> +
>> >> +  Note: memory.dirty_limit_in_bytes is the counterpart of memory.dirty_ratio.
>> >> +  Only one of them may be specified at a time.  When one is written it is
>> >> +  immediately taken into account to evaluate the dirty memory limits and the
>> >> +  other appears as 0 when read.
>> >> +
>> >> +- memory.dirty_background_ratio: the amount of dirty memory of the cgroup
>> >> +  (expressed as a percentage of cgroup memory) at which background writeback
>> >> +  kernel threads will start writing out dirty data.
>> >> +
>> >> +- memory.dirty_background_limit_in_bytes: the amount of dirty memory (expressed
>> >> +  in bytes) in the cgroup at which background writeback kernel threads will
>> >> +  start writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to
>> >> +  indicate that value is kilo, mega or gigabytes.
>> >> +
>> >> +  Note: memory.dirty_background_limit_in_bytes is the counterpart of
>> >> +  memory.dirty_background_ratio.  Only one of them may be specified at a time.
>> >> +  When one is written it is immediately taken into account to evaluate the dirty
>> >> +  memory limits and the other appears as 0 when read.
>> >> +
>> >> +A cgroup may contain more dirty memory than its dirty limit.  This is possible
>> >> +because of the principle that the first cgroup to touch a page is charged for
>> >> +it.  Subsequent page counting events (dirty, writeback, nfs_unstable) are also
>> >> +counted to the originally charged cgroup.
>> >> +
>> >> +Example: If page is allocated by a cgroup A task, then the page is charged to
>> >> +cgroup A.  If the page is later dirtied by a task in cgroup B, then the cgroup A
>> >> +dirty count will be incremented.  If cgroup A is over its dirty limit but cgroup
>> >> +B is not, then dirtying a cgroup A page from a cgroup B task may push cgroup A
>> >> +over its dirty limit without throttling the dirtying cgroup B task.
>> >> +
>> >>  6. Hierarchy support
>> >>  
>> >>  The memory controller supports a deep hierarchy and hierarchical accounting.
>> >> -- 
>> >> 1.7.1
>> >> 
>> > Can you clarify whether we can limit the "total" dirty pages under hierarchy
>> > in use_hierarchy==1 case ?
>> > If we can, I think it would be better to note it in this documentation.
>> >
>> >
>> > Thanks,
>> > Daisuke Nishimura.
>> 
>> Here is a second version of this -v3 doc patch:
>> 
>> Author: Greg Thelen <gthelen@google.com>
>> Date:   Sat Apr 10 15:34:28 2010 -0700
>> 
>>     memcg: document cgroup dirty memory interfaces
>>     
>>     Document cgroup dirty memory interfaces and statistics.
>>     
>>     Signed-off-by: Andrea Righi <arighi@develer.com>
>>     Signed-off-by: Greg Thelen <gthelen@google.com>
>> 
>
> nitpicks. and again, why you always drop Acks ?

I dropped acks because the patch changed and I did not want to assume
that it was still acceptable.  Is this incorrect protocol?

>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
>> index 7781857..8bf6d3b 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -385,6 +385,10 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
>>  pgpgin		- # of pages paged in (equivalent to # of charging events).
>>  pgpgout		- # of pages paged out (equivalent to # of uncharging events).
>>  swap		- # of bytes of swap usage
>> +dirty		- # of bytes that are waiting to get written back to the disk.
>
> extra tab ?

There is no extra tab here.  It's a display artifact.  When the patch is
applied the columns line up.

>> +writeback	- # of bytes that are actively being written back to the disk.
>> +nfs_unstable	- # of bytes sent to the NFS server, but not yet committed to
>> +		the actual storage.
>>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>>  		LRU list.
>>  active_anon	- # of bytes of anonymous and swap cache memory on active
>> @@ -406,6 +410,9 @@ total_mapped_file	- sum of all children's "cache"
>>  total_pgpgin		- sum of all children's "pgpgin"
>>  total_pgpgout		- sum of all children's "pgpgout"
>>  total_swap		- sum of all children's "swap"
>> +total_dirty		- sum of all children's "dirty"
>> +total_writeback		- sum of all children's "writeback"
>
> here, too.

There is no extra tab here.  It's a display artifact.  When the patch is
applied the columns line up.

>> +total_nfs_unstable	- sum of all children's "nfs_unstable"
>>  total_inactive_anon	- sum of all children's "inactive_anon"
>>  total_active_anon	- sum of all children's "active_anon"
>>  total_inactive_file	- sum of all children's "inactive_file"
>> @@ -453,6 +460,71 @@ memory under it will be reclaimed.
>>  You can reset failcnt by writing 0 to failcnt file.
>>  # echo 0 > .../memory.failcnt
>>  
>> +5.5 dirty memory
>> +
>> +Control the maximum amount of dirty pages a cgroup can have at any given time.
>> +
>> +Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
>> +page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
>> +not be able to consume more than their designated share of dirty pages and will
>> +be forced to perform write-out if they cross that limit.
>> +
>> +The interface is equivalent to the procfs interface: /proc/sys/vm/dirty_*.  It
>> +is possible to configure a limit to trigger both a direct writeback or a
>> +background writeback performed by per-bdi flusher threads.  The root cgroup
>> +memory.dirty_* control files are read-only and match the contents of
>> +the /proc/sys/vm/dirty_* files.
>> +
>> +Per-cgroup dirty limits can be set using the following files in the cgroupfs:
>> +
>> +- memory.dirty_ratio: the amount of dirty memory (expressed as a percentage of
>> +  cgroup memory) at which a process generating dirty pages will itself start
>> +  writing out dirty data.
>> +
>> +- memory.dirty_limit_in_bytes: the amount of dirty memory (expressed in bytes)
>> +  in the cgroup at which a process generating dirty pages will start itself
>> +  writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to indicate
>> +  that value is kilo, mega or gigabytes.
>> +
>> +  Note: memory.dirty_limit_in_bytes is the counterpart of memory.dirty_ratio.
>> +  Only one of them may be specified at a time.  When one is written it is
>> +  immediately taken into account to evaluate the dirty memory limits and the
>> +  other appears as 0 when read.
>> +
>> +- memory.dirty_background_ratio: the amount of dirty memory of the cgroup
>> +  (expressed as a percentage of cgroup memory) at which background writeback
>> +  kernel threads will start writing out dirty data.
>> +
>> +- memory.dirty_background_limit_in_bytes: the amount of dirty memory (expressed
>> +  in bytes) in the cgroup at which background writeback kernel threads will
>> +  start writing out dirty data.  Suffix (k, K, m, M, g, or G) can be used to
>> +  indicate that value is kilo, mega or gigabytes.
>> +
>> +  Note: memory.dirty_background_limit_in_bytes is the counterpart of
>> +  memory.dirty_background_ratio.  Only one of them may be specified at a time.
>> +  When one is written it is immediately taken into account to evaluate the dirty
>> +  memory limits and the other appears as 0 when read.
>> +
>> +A cgroup may contain more dirty memory than its dirty limit.  This is possible
>> +because of the principle that the first cgroup to touch a page is charged for
>> +it.  Subsequent page counting events (dirty, writeback, nfs_unstable) are also
>> +counted to the originally charged cgroup.
>> +
>> +Example: If page is allocated by a cgroup A task, then the page is charged to
>> +cgroup A.  If the page is later dirtied by a task in cgroup B, then the cgroup A
>> +dirty count will be incremented.  If cgroup A is over its dirty limit but cgroup
>> +B is not, then dirtying a cgroup A page from a cgroup B task may push cgroup A
>> +over its dirty limit without throttling the dirtying cgroup B task.
>> +
>> +When use_hierarchy=0, each cgroup has independent dirty memory usage and limits.
>> +
>> +When use_hierarchy=1, a parent cgroup increasing its dirty memory usage will
>> +compare its total_dirty memory (which includes sum of all child cgroup dirty
>> +memory) to its dirty limits.  This keeps a parent from explicitly exceeding its
>> +dirty limits.  However, a child cgroup can increase its dirty usage without
>> +considering the parent's dirty limits.  Thus the parent's total_dirty can exceed
>> +the parent's dirty limits as a child dirties pages.
>
> Hmm. in short, dirty_ratio in use_hierarchy=1 doesn't work as an user
> expects.  Is this a spec. or a current implementation ?

This limitation is due to the current implementation.  I agree that it
is not perfect.  We could extend the page-writeback.c changes, PATCH
11/11 ( http://marc.info/?l=linux-mm&m=128744907030215 ), to also check
the dirty limit of each parent in the memcg hierarchy.  This would walk
up the tree until root or a cgroup with use_hierarchy=0 is found.
Alternatively, we could provide this functionality in a later patch
series.  The changes to page-writeback.c may be significant.

> I think as following.
>  - add a limitation as "At setting chidlren's dirty_ratio, it must be
>    below parent's.  If it exceeds parent's dirty_ratio, EINVAL is
>    returned."
>
> Could you modify setting memory.dirty_ratio code ?

I assume we are only talking about the use_hierarchy=1 case.  What if
the parent ratio is changed?  If we want to ensure that child ratios are
never larger than parent, then the code must check every child cgroup to
ensure that each child ratio is <= the new parent ratio.  Correct?

Even if we manage to prevent all child ratios from exceeding parent
ratios, we still have the problem of the sum of child ratios may exceed
parent.  Example:
         A (10%)
   B (10%)   C (10%)

There would be nothing to prevent A,B,C dirty ratios from all being set
to 10% as shown.  The current implementation would allow for B and C to
reach 10% thereby pushing the A to 20%.  We could require that each
child dirty limit must fit within parent dirty limit.  So (B+C<=A).
This would allow for:

        A (10%)
   B (7%)   C (3%)

If we had this 10/7/3 limiting code, which statically partitions dirty
memory usage, then we would not needed to walk up the memcg tree
checking each parent.  This nice because it allows us to only
complicates the setting of dirty limits, which is not part of the
performance path.  However, being static partitioning has limitations.
If the system has a dirty ratio of 50% and we create 100 cgroups with
equal dirty limits, the dirty limits for each memcg would be 0.5%.

> Then, parent's dirty_ratio will never exceeds its own. (If I
> understand correctly.)
>
> "memory.dirty_limit_in_bytes" will be a bit more complecated, but I
> think you can.
>
>
> Thanks,
> -Kame

KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> I'd like to consider a patch.  Please mention that "use_hierarchy=1
> case depends on implemenation." for now.

I will clarify the current implementation behavior in the documentation.
A later patch series can change the use_hierarchy=1 behavior.


KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
> BTW, how about supporing dirty_limit_in_bytes when use_hierarchy=0 or
> leave it as broken when use_hierarchy=1 ?  It seems we can only
> support dirty_ratio when hierarchy is used.

I am not sure what you mean here.  Are you suggesting that we prohibit
usage of dirty limits/ratios when use_hierarchy=1?  This is appealing
because it does not expose the user to unexpected behavior.  Only the
well supported case would be configurable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
