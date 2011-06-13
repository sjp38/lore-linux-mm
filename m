Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 81CCB900117
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 17:25:40 -0400 (EDT)
Date: Mon, 13 Jun 2011 14:25:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUGFIX][PATCH 5/5] memcg: fix percpu cached charge draining
 frequency
Message-Id: <20110613142501.15e14b2f.akpm@linux-foundation.org>
In-Reply-To: <20110613121648.3d28afcd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
	<20110613121648.3d28afcd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Mon, 13 Jun 2011 12:16:48 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> >From 18b12e53f1cdf6d7feed1f9226c189c34866338c Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Mon, 13 Jun 2011 11:25:43 +0900
> Subject: [PATCH 5/5] memcg: fix percpu cached charge draining frequency
> 
>  For performance, memory cgroup caches some "charge" from res_counter
>  into per cpu cache. This works well but because it's cache,
>  it needs to be flushed in some cases. Typical cases are
>          1. when someone hit limit.
>          2. when rmdir() is called and need to charges to be 0.
> 
> But "1" has problem.
> 
> Recently, with large SMP machines, we see many kworker runs because
> of flushing memcg's cache. Bad things in implementation are
> that even if a cpu contains a cache for memcg not related to
> a memcg which hits limit, drain code is called.
> 
> This patch does
> 	A) check percpu cache contains a useful data or not.
> 	B) check other asynchronous percpu draining doesn't run.
> 	C) don't call local cpu callback.
> 	D) don't call at softlimit reclaim.
> 
>
> ...
>
> +DEFINE_MUTEX(percpu_charge_mutex);

I made this static.  If we later wish to give it kernel-wide scope then
"percpu_charge_mutex" will not be a good choice of name.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
