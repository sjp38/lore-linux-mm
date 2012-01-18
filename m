Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 534C66B004D
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 19:08:14 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7A5493EE0BC
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:08:12 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 63E6045DE5D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:08:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4724745DE5B
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:08:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AF0F1DB8045
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:08:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E23BC1DB8044
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 09:08:11 +0900 (JST)
Date: Wed, 18 Jan 2012 09:06:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 2/7 v2] memcg: add memory barrier for checking
 account move.
Message-Id: <20120118090656.83268b3e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120117152635.GA22142@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113173347.6231f510.kamezawa.hiroyu@jp.fujitsu.com>
	<20120117152635.GA22142@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Tue, 17 Jan 2012 16:26:35 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 13-01-12 17:33:47, KAMEZAWA Hiroyuki wrote:
> > I think this bugfix is needed before going ahead. thoughts?
> > ==
> > From 2cb491a41782b39aae9f6fe7255b9159ac6c1563 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Fri, 13 Jan 2012 14:27:20 +0900
> > Subject: [PATCH 2/7] memcg: add memory barrier for checking account move.
> > 
> > At starting move_account(), source memcg's per-cpu variable
> > MEM_CGROUP_ON_MOVE is set. The page status update
> > routine check it under rcu_read_lock(). But there is no memory
> > barrier. This patch adds one.
> 
> OK this would help to enforce that the CPU would see the current value
> but what prevents us from the race with the value update without the
> lock? This is as racy as it was before AFAICS.
> 

Hm, do I misunderstand ?
==
   update                     reference

   CPU A                        CPU B
  set value                rcu_read_lock()
  smp_wmb()                smp_rmb()
                           read_value
                           rcu_read_unlock()
  synchronize_rcu().
==
I expect
If synchronize_rcu() is called before rcu_read_lock() => move_lock_xxx will be held.
If synchronize_rcu() is called after rcu_read_lock() => update will be delayed.

Here, cpu B needs to read most recently updated value.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
