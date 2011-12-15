Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 7B7CE6B00D4
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 05:04:51 -0500 (EST)
Date: Thu, 15 Dec 2011 11:04:43 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] [PATCH 1/5] memcg: simplify account moving check
Message-ID: <20111215100443.GH3047@cmpxchg.org>
References: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
 <20111215150522.180da280.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111215150522.180da280.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Thu, Dec 15, 2011 at 03:05:22PM +0900, KAMEZAWA Hiroyuki wrote:
> >From 528f5f2667da17c26e40d271b24691412e1cbe81 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 15 Dec 2011 11:41:18 +0900
> Subject: [PATCH 1/5] memcg: simplify account moving check
> 
> Now, percpu variable MEM_CGROUP_ON_MOVE is used for indicating that
> a memcg is under move_account() and pc->mem_cgroup under it may be
> overwritten.
> 
> But this value is almost read only and not worth to be percpu.
> Using atomic_t instread.

I like this, but I think you can go one further.  The only place I see
where the per-cpu counter is actually read is to avoid taking the
lock, but if you make that counter an atomic anyway - why bother?

Couldn't you remove the counter completely and just take move_lock
unconditionally in the page stat updating?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
