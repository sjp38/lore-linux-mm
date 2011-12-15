Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id CDE0A6B00D6
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 05:18:29 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0CDB53EE0BD
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 19:18:28 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E2F1B45DF02
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 19:18:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C2CE745DE66
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 19:18:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B4F971DB8051
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 19:18:27 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 69F9D1DB8047
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 19:18:27 +0900 (JST)
Date: Thu, 15 Dec 2011 19:17:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 1/5] memcg: simplify account moving check
Message-Id: <20111215191712.334b4a16.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111215100443.GH3047@cmpxchg.org>
References: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
	<20111215150522.180da280.kamezawa.hiroyu@jp.fujitsu.com>
	<20111215100443.GH3047@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, 15 Dec 2011 11:04:43 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Dec 15, 2011 at 03:05:22PM +0900, KAMEZAWA Hiroyuki wrote:
> > >From 528f5f2667da17c26e40d271b24691412e1cbe81 Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Thu, 15 Dec 2011 11:41:18 +0900
> > Subject: [PATCH 1/5] memcg: simplify account moving check
> > 
> > Now, percpu variable MEM_CGROUP_ON_MOVE is used for indicating that
> > a memcg is under move_account() and pc->mem_cgroup under it may be
> > overwritten.
> > 
> > But this value is almost read only and not worth to be percpu.
> > Using atomic_t instread.
> 
> I like this, but I think you can go one further.  The only place I see
> where the per-cpu counter is actually read is to avoid taking the
> lock, but if you make that counter an atomic anyway - why bother?
> 
> Couldn't you remove the counter completely and just take move_lock
> unconditionally in the page stat updating?
> 

Hmm, I (and Greg Thelen) warned that 'please _never_ add atomic ops to
this path' by Peter Zilstra. That 'moving_account' condition checking
was for avoiding atomic ops in this path (for most of cases.)

We'll need to gather enough performance data after implementing per-memcg
dirty ratio accounting. So, could you wait for a while ?

Anyway, my patch '[PATCH 5/5]  memcg: remove PCG_MOVE_LOCK' may not work
enough well without the moving_account check. I'll consider more.

Thank you for review.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
