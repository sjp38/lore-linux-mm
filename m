Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 67F038D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 22:08:10 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E4C5D3EE0C2
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:08:02 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C27DF45DE5A
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:08:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A98C045DE55
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:08:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BFEE1DB8047
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:08:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DF421DB8040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:08:02 +0900 (JST)
Date: Thu, 31 Mar 2011 11:01:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [LSF][MM] rough agenda for memcg.
Message-Id: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf@lists.linux-foundation.org
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, walken@google.com


Hi,

In this LSF/MM, we have some memcg topics in the 1st day.

>From schedule,

1. Memory cgroup : Where next ? 1hour (Balbir Singh/Kamezawa) 
2. Memcg Dirty Limit and writeback 30min(Greg Thelen)
3. Memcg LRU management 30min (Ying Han, Michal Hocko)
4. Page cgroup on a diet (Johannes Weiner)

2.5 hours. This seems long...or short ? ;)

I'd like to sort out topics before going. Please fix if I don't catch enough.

mentiont to 1. later...

Main topics on 2. Memcg Dirty Limit and writeback ....is

 a) How to implement per-memcg dirty inode finding method (list) and
    how flusher threads handle memcg.

 b) Hot to interact with IO-Less dirty page reclaim.
    IIUC, if memcg doesn't handle this correctly, OOM happens.

 Greg, do we need to have a shared session with I/O guys ?
 If needed, current schedule is O.K. ?

Main topics on 3. Memcg LRU management

 a) Isolation/Gurantee for memcg.
    Current memcg doesn't have enough isolation when globarl reclaim runs.
    .....Because it's designed not to affect global reclaim.
    But from user's point of view, it's nonsense and we should have some hints
    for isolate set of memory or implement a guarantee.
    
    One way to go is updating softlimit better. To do this, we should know what
    is problem now. I'm sorry I can't prepare data on this until LSF/MM.
    Another way is implementing a guarantee. But this will require some interaction
    with page allocator and pgscan mechanism. This will be a big work.

 b) single LRU and per memcg zone->lru_lock.
    I hear zone->lru_lock contention caused by memcg is a problem on Google servers.
    Okay, please show data. (I've never seen it.)
    Then, we need to discuss Pros. and Cons. of current design and need to consinder
    how to improve it. I think Google and Michal have their own implementation.

    Current design of double-LRU is from the 1st inclusion of memcg to the kernel.
    But I don't know that discussion was there. Balbir, could you explain the reason
    of this design ? Then, we can go ahead, somewhere.


Main topics on 4. Page cgroup on diet is...

  a) page_cgroup is too big!, we need diet....
     I think Johannes removes -> page pointer already. Ok, what's the next to
     be removed ?

  I guess the next candidate is ->lru which is related to 3-b).
  
Main topics on 1.Memory control groups: where next? is..

To be honest, I just do bug fixes in these days. And hot topics are on above..
I don't have concrete topics. What I can think of from recent linux-mm emails are...

  a) Kernel memory accounting.
  b) Need some work with Cleancache ?
  c) Should we provide a auto memory cgroup for file caches ?
     (Then we can implement a file-cache-limit.)
  d) Do we have a problem with current OOM-disable+notifier design ?
  e) ROOT cgroup should have a limit/softlimit, again ?
  f) vm_overcommit_memory should be supproted with memcg ?
     (I remember there was a trial. But I think it should be done in other cgroup
      as vmemory cgroup.)
...

I think
  a) discussing about this is too early. There is no patch.
     I think we'll just waste time.

  b) enable/disable cleancache per memcg or some share/limit ??
     But we can discuss this kind of things after cleancache is in production use...

  c) AFAIK, some other OSs have this kind of feature, a box for file-cache.
     Because file-cache is a shared object between all cgroups, it's difficult
     to handle. It may be better to have a auto cgroup for file caches and add knobs
     for memcg.

  d) I think it works well. 

  e) It seems Michal wants this for lazy users. Hmm, should we have a knob ?
     It's helpful that some guy have a performance number on the latest kernel
     with and without memcg (in limitless case).
     IIUC, with THP enabled as 'always', the number of page fault dramatically reduced and
     memcg's accounting cost gets down...

  f) I think someone mention about this...

Maybe c) and d) _can_ be a topic but seems not very important.

So, for this slot, I'd like to discuss

  I) Softlimit/Isolation (was 3-A) for 1hour
     If we have extra time, kernel memory accounting or file-cache handling
     will be good.
   
  II) Dirty page handling. (for 30min)
     Maybe we'll discuss about per-memcg inode queueing issue.

  III) Discussing the current and future design of LRU.(for 30+min)

  IV) Diet of page_cgroup (for 30-min)
      Maybe this can be combined with III.

Thanks,
-Kame

















--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
