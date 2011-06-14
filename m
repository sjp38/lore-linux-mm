Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7C61B6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:36:56 -0400 (EDT)
Date: Tue, 14 Jun 2011 09:36:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [BUGFIX][PATCH 5/5] memcg: fix percpu cached charge draining
 frequency
Message-ID: <20110614073651.GA21197@tiehlicka.suse.cz>
References: <20110613120054.3336e997.kamezawa.hiroyu@jp.fujitsu.com>
 <20110613121648.3d28afcd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110613121648.3d28afcd.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>

On Mon 13-06-11 12:16:48, KAMEZAWA Hiroyuki wrote:
> From 18b12e53f1cdf6d7feed1f9226c189c34866338c Mon Sep 17 00:00:00 2001
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
> 	D) don't call at softlimit reclaim.

I think this needs some justification. The decision is not that
obvious IMO. I would say that this is a good decision because cached
charges will not help to free any memory (at least not directly) during
background reclaim. What about something like:
"
We are not draining per cpu cached charges during soft limit reclaim 
because background reclaim doesn't care about charges. It tries to free
some memory and charges will not give any.
Cached charges might influence only selection of the biggest soft limit
offender but as the call is done only after the selection has been
already done it makes no change.
"

Anyway, wouldn't it be better to have this change separate from the
async draining logic change?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
