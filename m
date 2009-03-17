Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 255026B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 23:49:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2H3n49D006536
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 12:49:04 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 28A3C45DE55
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 12:49:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 081E145DE51
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 12:49:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E671E1DB803C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 12:49:03 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A52BF1DB803B
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 12:49:03 +0900 (JST)
Date: Tue, 17 Mar 2009 12:47:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v6)
Message-Id: <20090317124740.d8356d01.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090316121915.GB16897@balbir.in.ibm.com>
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain>
	<20090314173111.16591.68465.sendpatchset@localhost.localdomain>
	<20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316083512.GV16897@balbir.in.ibm.com>
	<20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316091024.GX16897@balbir.in.ibm.com>
	<2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com>
	<20090316113853.GA16897@balbir.in.ibm.com>
	<969730ee419be9fbe4aca3ec3249650e.squirrel@webmail-b.css.fujitsu.com>
	<20090316121915.GB16897@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009 17:49:15 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16 20:58:30]:

> A run away application can do that. Like I mentioned with the tests I
> did for your patches. Soft limits were at 1G/2G and the applications
> (two) tried to touch all the memory in the system. The point is that
> shrink_slab() will be called if the normal system experiences
> watermark issues, soft limits will tackle/control cgroups running out
> of their soft limits and causing memory contention to take place.
> 
Ok, then, how about this ?

 Because our target is "softlimit" and not "memory shortage"
 - don't call soft limit from alloc_pages().
 - don't call soft limit from kswapd and others.
 
Instead of this, add sysctl like this.

  - vm.softlimit_ratio

If vm.softlimit_ratio = 99%, 
  when sum of all usage of memcg is over 99% of system memory,
  softlimit runs and reclaim memory until the whole usage will be below 99%.
   (or some other trigger can be considered.)

Then,
 - We don't have to take care of misc. complicated aspects of memory reclaiming
   We reclaim memory based on our own logic, then, no influence to global LRU.

I think this approach will hide the all corner case and make merging softlimit 
to mainline much easier. If you use this approach, RB-tree is the best one
to go with (and we don't have to care zone's status.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
