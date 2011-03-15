Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4A98D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:02:51 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6658E3EE0C7
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:02:47 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4802945DE5B
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:02:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1749B45DE56
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:02:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EC6FFE18005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:02:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A4AC0E08001
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 11:02:46 +0900 (JST)
Date: Tue, 15 Mar 2011 10:56:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 0/9] memcg: per cgroup dirty page accounting
Message-Id: <20110315105612.f600a659.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
References: <1299869011-26152-1-git-send-email-gthelen@google.com>
	<20110311171006.ec0d9c37.akpm@linux-foundation.org>
	<AANLkTimT-kRMQW3JKcJAZP4oD3EXuE-Bk3dqumH_10Oe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, linux-fsdevel@vger.kernel.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Mon, 14 Mar 2011 11:29:17 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Fri, Mar 11, 2011 at 5:10 PM, Andrew Morton

> My rational for pursuing bdi writeback was I/O locality.  I have heard that
> per-page I/O has bad locality.  Per inode bdi-style writeback should have better
> locality.
> 
> My hunch is the best solution is a hybrid which uses a) bdi writeback with a
> target memcg filter and b) using the memcg lru as a fallback to identify the bdi
> that needed writeback.  I think the part a) memcg filtering is likely something
> like:
>  http://marc.info/?l=linux-kernel&m=129910424431837
> 
> The part b) bdi selection should not be too hard assuming that page-to-mapping
> locking is doable.
> 

For now, I like b). 

> An alternative approach is to bind each inode to exactly one cgroup (possibly
> the root cgroup).  Both the cache page allocations and dirtying charges would be
> accounted to the i_cgroup.  With this approach there is no foreign dirtier issue
> because all pages are in a single cgroup.  I find this undesirable because the
> first memcg to touch an inode is charged for all pages later cached even by
> other memcg.
> 

I don't think 'foreign dirtier' is a big problem. When program does write(),
the file to be written is tend to be under control of the application in
the cgroup. I don't think 'written file' is shared between several cgroups, 
typically. But /var/log/messages is a shared one ;)

But I know some other OSs has 'group for file cache'. I'll not nack if you
propose such patch. Maybe there are some guys who want to limit the amount of
file cache.



> When a page is allocated it is charged to the current task's memcg.  When a
> memcg page is later marked dirty the dirty charge is billed to the memcg from
> the original page allocation.  The billed memcg may be different than the
> dirtying task's memcg.
> 
yes.

> After a rate limited number of file backed pages have been dirtied,
> balance_dirty_pages() is called to enforce dirty limits by a) throttling
> production of more dirty pages by current and b) queuing background writeback to
> the current bdi.
> 
> balance_dirty_pages() receives a mapping and page count, which indicate what may
> have been dirtied and the max number of pages that may have been dirtied.  Due
> to per cpu rate limiting and batching (when nr_pages_dirtied > 0),
> balance_dirty_pages() does not know which memcg were charged for recently dirty
> pages.
> 
> I think both bdi and system limits have the same issue in that a bdi may be
> pushed over its dirty limit but not immediately checked due to rate limits.  If
> future dirtied pages are backed by different bdi, then future
> balance_dirty_page() calls will check the second, compliant bdi ignoring the
> first, over-limit bdi.  The safety net is that the system wide limits are also
> checked in balance_dirty_pages.  However, per bdi writeback is employed in this
> situation.
> 
> Note: This memcg foreign dirtier issue does not make it any more likely that a
> memcg is pushed above its usage limit (limit_in_bytes).  The only limit with
> this weak contract is the dirty limit.
> 
> For reference, this issue was touch on in
> http://marc.info/?l=linux-mm&m=128840780125261
> 
> There are ways to handle this issue (my preferred option is option #1).
> 
> 1) keep a (global?) foreign_dirtied_memcg list of memcg that were recently
>   charged for dirty pages by tasks outside of memcg.  When a memcg dirty page
>   count is elevated, the page's memcg would be queued to the list if current's
>   memcg does not match the pages cgroup.  mem_cgroup_balance_dirty_pages()
>   would balance the current memcg and each memcg it dequeues from this list.
>   This should be a straightforward fix.
> 

Can you implement this in an efficient way ? (without taking any locks ?)
It seems cost > benefit.



> 2) When pages are dirtied, migrate them to the current task's memcg.
>   mem_cgroup_balance_dirty_pages would then have a better chance at seeing all
>   pages dirtied by the current operation.  This is still not perfect solution
>   due to rate limiting.  This also is bad because such a migration would
>   involve charging and possibly memcg direct reclaim because the destination
>   memcg may be at its memory usage limit.  Doing all of this in
>   account_page_dirtied() seems like trouble, so I do not like this approach.
> 

I think this cannot be implemented in an efficnent way.



> 3) Pass in some context which is represents a set of pages recently dirtied into
>   [mem_cgroup]_balance_dirty_pages.  What would be a good context to collect
>   the set of memcg that should be balanced?
>   - an extra passed in parameter - yuck.
>   - address_space extension - does not feel quite right because address space
>     is not a io context object, I presume it can be shared by concurrent
>     threads.
>   - something hanging on current.  Are there cases where pages become dirty
>     that are not followed by a call to balance dirty pages Note: this option
>     (3) is not a good idea because rate limiting make dirty limit enforcement
>     an inexact science.  There is no guarantee that a caller will have context
>     describing the pages (or bdis) recently dirtied.
> 

I'd like to have an option  'cgroup only for file cache' rather than adding more
hooks and complicated operations.

But, if we need to record 'who dirtied ?' information, record it in page_cgroup
or radix-tree and do filtering is what I can consider, now.
In this case, some tracking information will be required to be stored into
struct inode, too.


How about this ?

 1. record 'who dirtied memcg' into page_cgroup or radix-tree.
   I prefer recording in radix-tree rather than using more field in page_cgroup.
 2. bdi-writeback does some extra queueing operation per memcg.
   find a page, check 'who dirtied', enqueue it(using page_cgroup or list of pagevec)
 3. writeback it's own queue.(This can be done before 2. if cgroup has queue, already)
 4. Some GC may be required...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
