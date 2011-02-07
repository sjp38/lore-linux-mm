Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0F6DC8D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 21:17:05 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E1B743EE0BD
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 11:17:01 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C806F45DE5D
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 11:17:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A466545DE5E
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 11:17:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 98ED21DB8044
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 11:17:01 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C9B1E08001
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 11:17:01 +0900 (JST)
Date: Mon, 7 Feb 2011 11:10:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [LSF/MM TOPIC] Kernel memory tracking in memcg
Message-Id: <20110207111059.2cf5c801.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=bMvdnxJOJTsNpg=KCSG40cgDkx+ZMPXXJh8UN@mail.gmail.com>
References: <AANLkTi=bMvdnxJOJTsNpg=KCSG40cgDkx+ZMPXXJh8UN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: lsf-pc@lists.linuxfoundation.org, linux-mm@kvack.org

On Fri, 4 Feb 2011 16:09:57 -0800
Suleiman Souhlal <suleiman@google.com> wrote:

> Hi,
> 
> Currently, memcg only tracks user memory.
> 
> However, some workloads can cause heavy kernel memory use (for
> example, when doing a lot of network I/O), which would ideally be
> counted towards the limit in memory cgroup.
> 

Hmm, memory usage by network I/O here is size of allowed RECV/SEND buffer,
window_size ? or memory usage per (incoming) packet ?

IMHO, packet accounting should be discussed under network layer, mostly
because of performance. I think it's not memory usage problem, but
traffic throttoling problem. Without relationship with network layer,
"packet dropping by limit of memory" will make the system (including all cluster)
bad. It's better to shape traffic before dropping into such pit-fall.


But checking SEND/RECV buffer size (or window_size) at creation of socket()
and limiting it...can be done in memory layer, IMHO.
But I'm a novice about network implemanation ;)


> Without this, memory isolation could be damaged, as one cgroup using a
> lot of kernel memory could penalize other cgroups by causing global
> reclaim on the machine.
> 
> Things that could potentially be discussed:
> - Should all kinds of kernel allocations be accounted (get_free_pages,
> slab, vmalloc)?

I think no. We should show details, what amount of pages are used for what
purpose. Without that information, users can't modify workloads.
So, accounting should be done by the caller of memory allocation not by
the memory allocation function itself.

Or, Adding wrapper function to pass "purpose" information is good.


> - Should every allocation done in a process context be accounted?

I think no. But I think most of usage can be accounted into process as
 - file struct, socket send/recv buffer, page tables etc...
can be accoutned. Maybe users can imagine why memory is used for...
and they can see what resource are more used than they planned and
they can consider how to avoid it.

But some special memory uasge by drivers etc..or small allocation as
some control structure should not be accounted. IOW, when hit limits,
 - users can know/imagine details of usage, what amount of pages are used
   for what.

When users see -ENOMEM, only users can do is just making limit large. 
This makes estimation of memory limit difficult.


> - Should kernel memory be counted towards the memcg limit, or should a
> different limit be used?

If users can get enough information about memory usage details, I think
it's ok to have a limit.

For example, in my customer, 1000+ threads shares a 4GB shared memory. It 
consumes XXGB of memory and make the system slow down or OOM.

In this case, "kmalloc-4096 uses up XXGB!" has no information, at all.
My costomers asked us to look into crash dump ;) And we did.
And the user used hugepage instead of making limit larger.

In above case, "page table uses 4GB!" information is better than
"kmalloc-4096 uses 4GB!" and I think this meets usage of cgroup.

> - Implementation.
> 
 - Overhead of counter 
 - how to track all pages and details of them.
 - how to handle hierarchy.

> Is this worth discussing?
> 

Maybe. If some others have interests.

Personally, I think dirty-ratio and writeback, and blkio-cgroup relationship
will be main topic, this year. So, compact discussion will be appreciated.


Thanks,
-Kame











> [ My initial thoughts on the issue: Slab makes for the bulk of kernel
> allocations, and any solution would need a slab component, so it's a
> good starting point.
> Also, most kernel allocations in process context belong to that
> process (although there are some exceptions), so it should be mostly
> ok to account every allocation in process context.
> For slab, we can do tracking per slab (instead of per-object), by
> making sure objects from a slab are only used by one cgroup. ]
> 
> -- Suleiman
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
