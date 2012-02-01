Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6EE6B6B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 19:57:20 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 754E93EE0AE
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:57:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C94245DF46
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:57:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4815C45DF49
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:57:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CD181DB803B
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:57:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EAE0E1DB803F
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:57:17 +0900 (JST)
Date: Wed, 1 Feb 2012 09:55:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [LSF/MM TOPIC] memcg topics.
Message-Id: <20120201095556.812db19c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>

Hi, I guess we have some topics on memory cgroups.

1-4 : someone has an implemanation
5   : no implemenation.

1. page_cgroup diet
   memory cgroup uses 'struct page_cgroup', it was 40bytes per 4096bytes in past.
   Johannes removed ->page and ->lru from page_cgroup, then now,
   sizeof(page_cgroup)==16. Now, I'm working on removing ->flags to make
   sizeof(page_cgroup)==8.

   Then, finally, page_cgroup can be moved into struct page on 64bit system ?
   How 32bit system will be ?

2. memory reclaim
   Johannes, Michal and Ying, ant others, are now working on memory reclaim problem
   with new LRU. Under it, LRU is per-memcg-per-zone.
   Following topics are discussed now.

   - simplificaiton/re-implemenation of softlimit
   - isolation of workload (by softlimit)
   - when we should stop memory reclaim, especially under direct-reclaim.
     (Now, we scan all zonelist..)

3. per-memcg-lru-zone-lru-lock
   I hear Hugh Dickins have some patches and are testing it.
   It will be good to discuss this if it has Pros. and Cons or implemenation issue.

4. dirty ratio
   In the last year, patches were posted but not merged. I'd like to hear
   works on this area.

5. accounting other than user pages.
   Last year, tcp buffer limiting was added to "memcg".
   If someone has other plans, I'd like to hear.
   I myself don't think 'generic kernel memory limitation' is a good thing....
   admins can't predict performance.

   Can we make accounting on dentry/inode into memcg and call shrink_slab() ?
   But I guess per-zone-shrink-slab() should go 1st...
   
More ?


x. per-memcg kswapd.
   This is good for reducing direct-reclaim latency of memcg('s limit).
   But (my) patch is not updated now, so, this will be off-topic in this year.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
