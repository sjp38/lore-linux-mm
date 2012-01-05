Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 09A2C6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 00:57:59 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 484313EE0BC
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:57:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3027A45DE52
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:57:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1816F45DE4F
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:57:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CCB51DB803B
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:57:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B98871DB8037
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 14:57:57 +0900 (JST)
Date: Thu, 5 Jan 2012 14:56:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] memcg: fix NULL mem_cgroup_try_charge
Message-Id: <20120105145646.40a47300.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112281620400.8257@eggly.anvils>
References: <alpine.LSU.2.00.1112281613550.8257@eggly.anvils>
	<alpine.LSU.2.00.1112281620400.8257@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Wed, 28 Dec 2011 16:21:57 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> There is one way out of __mem_cgroup_try_charge() which claims success
> but still leaves memcg NULL, causing oops thereafter: make sure that
> it is set to root_mem_cgroup in this case.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: KAMEZWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
> Fix to memcg: return -EINTR at bypassing try_charge()
> 
>  mm/memcontrol.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> --- mmotm.orig/mm/memcontrol.c	2011-12-28 12:53:23.420367847 -0800
> +++ mmotm/mm/memcontrol.c	2011-12-28 14:41:19.803018025 -0800
> @@ -2263,7 +2263,9 @@ again:
>  		 * task-struct. So, mm->owner can be NULL.
>  		 */
>  		memcg = mem_cgroup_from_task(p);
> -		if (!memcg || mem_cgroup_is_root(memcg)) {
> +		if (!memcg)
> +			memcg = root_mem_cgroup;
> +		if (mem_cgroup_is_root(memcg)) {
>  			rcu_read_unlock();
>  			goto done;
>  		}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
