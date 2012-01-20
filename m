Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 02DAA6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 21:21:09 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2705B3EE0BD
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 11:21:08 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6255F2E68C4
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 11:21:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 21DF5266D18
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 11:21:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 02EDDE08001
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 11:21:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EFDD81DB803E
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 11:21:05 +0900 (JST)
Date: Fri, 20 Jan 2012 11:19:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 7/7 v2] memcg: make mem_cgroup_begin_update_stat
 to use global pcpu.
Message-Id: <20120120111947.400b2b15.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120119144712.GG13932@tiehlicka.suse.cz>
References: <20120113173001.ee5260ca.kamezawa.hiroyu@jp.fujitsu.com>
	<20120113174510.5e0f6131.kamezawa.hiroyu@jp.fujitsu.com>
	<20120119144712.GG13932@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ying Han <yinghan@google.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, cgroups@vger.kernel.org, "bsingharora@gmail.com" <bsingharora@gmail.com>

On Thu, 19 Jan 2012 15:47:12 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Fri 13-01-12 17:45:10, KAMEZAWA Hiroyuki wrote:
> > From 3df71cef5757ee6547916c4952f04a263c1b8ddb Mon Sep 17 00:00:00 2001
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Date: Fri, 13 Jan 2012 17:07:35 +0900
> > Subject: [PATCH 7/7] memcg: make mem_cgroup_begin_update_stat to use global pcpu.
> > 
> > Now, a per-cpu flag to show the memcg is under account moving is
> > now implemented as per-memcg-per-cpu.
> > 
> > So, when accessing this, we need to access memcg 1st. But this
> > function is called even when status update doesn't occur. Then,
> > accessing struct memcg is an overhead in such case.
> > 
> > This patch removes per-cpu-per-memcg MEM_CGROUP_ON_MOVE and add
> > per-cpu vairable to do the same work. For per-memcg, atomic
> > counter is added. By this, mem_cgroup_begin_update_stat() will
> > just access percpu variable in usual case and don't need to find & access
> > memcg. This reduces overhead.
> 
> I agree that move_account is not a hotpath and that we don't have
> to optimize for it but I guess we can do better. If we use a cookie
> parameter for
> mem_cgroup_{begin,end}_update_stat(struct page *page, unsigned long *cookie)
> then we can stab page_cgroup inside and use the last bit for
> locked.  Then we do not have to call lookup_page_cgroup again in
> mem_cgroup_update_page_stat and just replace page by the cookie.
> What do you think?
> 

Because these routine is called as

	mem_cgroup_begin_update_stat()
	if (condition)
		set_page_flag
		mem_cgroup_update_stat()
	mem_cgroup_end_update_stat()

In earlier version(not posted), I did so. Now, I don't because of 2 reasons.

1. I wonder it's better not to have extra arguments in begin_xxx it
   will be overhead itself.
2. my work's final purpose is integrate page_cgroup to struct page.
   If I can do, lookup_page_cgroup() cost will be almost 0 and we'll revert
   the cookie, finally.

So, can't we keep this update routine simple for a while ?
If we saw it's finally impossible to integrate page_cgroup to page,
I'd like to consider 'cookie' again.

BTW, If we use spinlock and need to do irq_disable() in begin_update_stat()
we'll need to pass *flags...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
