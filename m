Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 943B86B0062
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 01:20:46 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F6KiAK006074
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 15:20:44 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 61A0345DD75
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:20:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3ACFB45DD72
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:20:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EF4A1DB803F
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:20:41 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 16AF01DB8048
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:20:41 +0900 (JST)
Date: Thu, 15 Jan 2009 15:19:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/4] memcg: use CSS ID in memcg
Message-Id: <20090115151936.9836878f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090112121424.GC27129@balbir.in.ibm.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108183003.accef865.kamezawa.hiroyu@jp.fujitsu.com>
	<20090112121424.GC27129@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Jan 2009 17:44:24 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
					   get_swappiness(next_mem));
> > +	struct mem_cgroup *victim;
> > +	unsigned long start_age;
> > +	int ret, total = 0;
> > +	/*
> > +	 * Reclaim memory from cgroups under root_mem in round robin.
> > +	 */
> > +	start_age = root_mem->scan_age;
> > +
> > +	while (time_after((start_age + 2UL), root_mem->scan_age)) {
> 
> This is confusing, why do we use time_after with scan_age. scan_age
> seems to be incremented every time we scan and has no relationship
> with time. 

time_after() is useful macro for checking counter which can go MAX-1->MAX->0->1>...


> The second thing is what happens if time_after() always
> returns 0, if we've been aggressively scanning? 
That never happens.

> The logic needs some  commenting, why the magic number 2?
> 
memcg->scan_age is update when 
 - the memcg is root of hierarchy.
 - we reclaim memory from memcg.

So, memcg->scan_age is update by 2 means, all memcg under hierarchy is accessed
by reclaim routine.

example) Consider hierarhy like this.
 
          xxx(ID=8)
             /yyy (ID=4)
             /zzz (ID=9)
             /www (ID=3)

In this case, scan will be done in following order

  .....->3->4->8->9->3->4->8->9->...
(start point is determined by last_scanned_child)

everytime we visit "8", 8's scan_age is updated.

So, if we see "8"  2 times, all other groups 4,9,3 is all accessed for freeing
memory. (by me or other threads.)


-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
