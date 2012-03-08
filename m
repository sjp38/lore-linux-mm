Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 173CA6B00E9
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 01:14:09 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AB14D3EE0B6
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:14:07 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B34645DE55
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:14:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 482A145DE50
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:14:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33D2E1DB8044
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:14:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DF3DC1DB8037
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:14:06 +0900 (JST)
Date: Thu, 8 Mar 2012 15:12:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3.3] memcg: free mem_cgroup by RCU to fix oops
Message-Id: <20120308151232.8a9c6e3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1203072155140.11048@eggly.anvils>
References: <alpine.LSU.2.00.1203072155140.11048@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Tejun Heo <tj@kernel.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 Mar 2012 22:01:50 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> After fixing the GPF in mem_cgroup_lru_del_list(), three times one
> machine running a similar load (moving and removing memcgs while swapping)
> has oopsed in mem_cgroup_zone_nr_lru_pages(), when retrieving memcg zone
> numbers for get_scan_count() for shrink_mem_cgroup_zone(): this is where a
> struct mem_cgroup is first accessed after being chosen by mem_cgroup_iter().
> 
> Just what protects a struct mem_cgroup from being freed, in between
> mem_cgroup_iter()'s css_get_next() and its css_tryget()?  css_tryget()
> fails once css->refcnt is zero with CSS_REMOVED set in flags, yes: but
> what if that memory is freed and reused for something else, which sets
> "refcnt" non-zero?  Hmm, and scope for an indefinite freeze if refcnt
> is left at zero but flags are cleared.
> 
> It's tempting to move the css_tryget() into css_get_next(), to make it
> really "get" the css, but I don't think that actually solves anything:
> the same difficulty in moving from css_id found to stable css remains.
> 
> But we already have rcu_read_lock() around the two, so it's easily
> fixed if __mem_cgroup_free() just uses kfree_rcu() to free mem_cgroup.
> 
> However, a big struct mem_cgroup is allocated with vzalloc() instead
> of kzalloc(), and we're not allowed to vfree() at interrupt time:
> there doesn't appear to be a general vfree_rcu() to help with this,
> so roll our own using schedule_work().  The compiler decently removes
> vfree_work() and vfree_rcu() when the config doesn't need them.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
