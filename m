Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1D78D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:29:47 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p2EITcoS025527
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:29:39 -0700
Received: from qwf6 (qwf6.prod.google.com [10.241.194.70])
	by kpbe20.cbf.corp.google.com with ESMTP id p2EIPpqx028946
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:29:37 -0700
Received: by qwf6 with SMTP id 6so1734015qwf.30
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:29:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110311171006.ec0d9c37.akpm@linux-foundation.org>
References: <1299869011-26152-1-git-send-email-gthelen@google.com> <20110311171006.ec0d9c37.akpm@linux-foundation.org>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 14 Mar 2011 11:29:17 -0700
Message-ID: <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Fri, Mar 11, 2011 at 5:10 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 11 Mar 2011 10:43:22 -0800
> Greg Thelen <gthelen@google.com> wrote:
>
>>
>> ...
>>
>> This patch set provides the ability for each cgroup to have independent dirty
>> page limits.
>
> Here, it would be helpful to describe the current kernel behaviour.
> And to explain what is wrong with it and why the patch set improves
> things!

Good question.

The memcg dirty limits offer similar value to a cgroup as the global dirty
limits offer to the system.

Prior to this patch series, memcg had neither dirty limits nor background
reclaim.  So when a memcg hit its limit_in_bytes it would enter memcg direct
reclaim.  If the memcg memory was mostly dirty, then direct reclaim would be
slow, so page allocation latency would stink.  By placing limits on the portion
of cgroup memory that can be dirty, page allocation latencies are improved.
These patches provide more performance guarantees for page allocations.  Another
value is the ability to put a heavy dirtier in a small dirty memory jail which
is less than system dirty memory.

 dd if=/dev/zero of=/data/input bs=1M count=50
 sync
 echo 3 > /proc/sys/vm/drop_caches
 mkdir /dev/cgroup/memory/A
 echo $$ > /dev/cgroup/memory/A/tasks
 echo 100M > /dev/cgroup/memory/A/memory.dirty_limit_in_bytes
 echo 200M > /dev/cgroup/memory/A/memory.limit_in_bytes
 dd if=/dev/zero of=/data/output bs=1M &
 dd if=/data/input of=/dev/null bs=1M

If the setting of memory.dirty_limit_in_bytes is omitted (as if this patch
series was not available), then the dd writer is able to fill the cgroup with
dirty memory increasing the page allocation latency for the dd reader.

With this sample, the dd reader sees a difference of 2x (6.5 MB/s vs 4.5 MB/s if
setting A/memory.dirty_limit_in_bytes is omitted).

>>
>> ...
>>
>> Known shortcomings (see the patch 1/9 update to Documentation/cgroups/memory.txt
>> for more details):
>> - When a cgroup dirty limit is exceeded, then bdi writeback is employed to
>>   writeback dirty inodes.  Bdi writeback considers inodes from any cgroup, not
>>   just inodes contributing dirty pages to the cgroup exceeding its limit.
>
> This is a pretty large shortcoming, I suspect.  Will it be addressed?

Yes.  The two issues in this email are my next priorities for memcg dirty
limits.

> There's a risk that a poorly (or maliciously) configured memcg could
> have a pretty large affect upon overall system behaviour.  Would
> elevated premissions be needed to do this?

Such an affect is possible.  But root permissions are required to create it
because the new memory.dirty* limit files are 0644, this is similar to
/proc/sys/vm/dirty*.  I suspect it would be easier to trash system performance
with sync().

> We could just crawl the memcg's page LRU and bring things under control
> that way, couldn't we?  That would fix it.  What were the reasons for
> not doing this?

My rational for pursuing bdi writeback was I/O locality.  I have heard that
per-page I/O has bad locality.  Per inode bdi-style writeback should have better
locality.

My hunch is the best solution is a hybrid which uses a) bdi writeback with a
target memcg filter and b) using the memcg lru as a fallback to identify the bdi
that needed writeback.  I think the part a) memcg filtering is likely something
like:
 http://marc.info/?l=linux-kernel&m=129910424431837

The part b) bdi selection should not be too hard assuming that page-to-mapping
locking is doable.

An alternative approach is to bind each inode to exactly one cgroup (possibly
the root cgroup).  Both the cache page allocations and dirtying charges would be
accounted to the i_cgroup.  With this approach there is no foreign dirtier issue
because all pages are in a single cgroup.  I find this undesirable because the
first memcg to touch an inode is charged for all pages later cached even by
other memcg.

>> - A cgroup may exceed its dirty limit if the memory is dirtied by a process in a
>>   different memcg.
>
> Please describe this scenario in (a lot) more detail?

The documentation in patch 1/9 discusses this issue somewhat:
 A cgroup may contain more dirty memory than its dirty limit.  This is possible
 because of the principle that the first cgroup to touch a page is charged for
 it.  Subsequent page counting events (dirty, writeback, nfs_unstable) are also
 counted to the originally charged cgroup.  Example: If page is allocated by a
 cgroup A task, then the page is charged to cgroup A.  If the page is later
 dirtied by a task in cgroup B, then the cgroup A dirty count will be
 incremented.  If cgroup A is over its dirty limit but cgroup B is not, then
 dirtying a cgroup A page from a cgroup B task may push cgroup A over its dirty
 limit without throttling the dirtying cgroup B task.

Here are some additional thoughts on this foreign dirtier issue:

When a page is allocated it is charged to the current task's memcg.  When a
memcg page is later marked dirty the dirty charge is billed to the memcg from
the original page allocation.  The billed memcg may be different than the
dirtying task's memcg.

After a rate limited number of file backed pages have been dirtied,
balance_dirty_pages() is called to enforce dirty limits by a) throttling
production of more dirty pages by current and b) queuing background writeback to
the current bdi.

balance_dirty_pages() receives a mapping and page count, which indicate what may
have been dirtied and the max number of pages that may have been dirtied.  Due
to per cpu rate limiting and batching (when nr_pages_dirtied > 0),
balance_dirty_pages() does not know which memcg were charged for recently dirty
pages.

I think both bdi and system limits have the same issue in that a bdi may be
pushed over its dirty limit but not immediately checked due to rate limits.  If
future dirtied pages are backed by different bdi, then future
balance_dirty_page() calls will check the second, compliant bdi ignoring the
first, over-limit bdi.  The safety net is that the system wide limits are also
checked in balance_dirty_pages.  However, per bdi writeback is employed in this
situation.

Note: This memcg foreign dirtier issue does not make it any more likely that a
memcg is pushed above its usage limit (limit_in_bytes).  The only limit with
this weak contract is the dirty limit.

For reference, this issue was touch on in
http://marc.info/?l=linux-mm&m=128840780125261

There are ways to handle this issue (my preferred option is option #1).

1) keep a (global?) foreign_dirtied_memcg list of memcg that were recently
  charged for dirty pages by tasks outside of memcg.  When a memcg dirty page
  count is elevated, the page's memcg would be queued to the list if current's
  memcg does not match the pages cgroup.  mem_cgroup_balance_dirty_pages()
  would balance the current memcg and each memcg it dequeues from this list.
  This should be a straightforward fix.

2) When pages are dirtied, migrate them to the current task's memcg.
  mem_cgroup_balance_dirty_pages would then have a better chance at seeing all
  pages dirtied by the current operation.  This is still not perfect solution
  due to rate limiting.  This also is bad because such a migration would
  involve charging and possibly memcg direct reclaim because the destination
  memcg may be at its memory usage limit.  Doing all of this in
  account_page_dirtied() seems like trouble, so I do not like this approach.

3) Pass in some context which is represents a set of pages recently dirtied into
  [mem_cgroup]_balance_dirty_pages.  What would be a good context to collect
  the set of memcg that should be balanced?
  - an extra passed in parameter - yuck.
  - address_space extension - does not feel quite right because address space
    is not a io context object, I presume it can be shared by concurrent
    threads.
  - something hanging on current.  Are there cases where pages become dirty
    that are not followed by a call to balance dirty pages Note: this option
    (3) is not a good idea because rate limiting make dirty limit enforcement
    an inexact science.  There is no guarantee that a caller will have context
    describing the pages (or bdis) recently dirtied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
