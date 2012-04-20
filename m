Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 949556B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 21:49:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DC0F13EE0B6
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:49:00 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BFEE245DE53
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:49:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A622845DE52
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:49:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 85A191DB803E
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:49:00 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CDFB1DB8041
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 10:49:00 +0900 (JST)
Message-ID: <4F90C01E.3040909@jp.fujitsu.com>
Date: Fri, 20 Apr 2012 10:47:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix Bad page state after replace_page_cache
References: <alpine.LSU.2.00.1204182325350.3700@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204182325350.3700@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <mszeredi@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(2012/04/19 15:34), Hugh Dickins wrote:

> My 9ce70c0240d0 "memcg: fix deadlock by inverting lrucare nesting" put a
> nasty little bug into v3.3's version of mem_cgroup_replace_page_cache(),
> sometimes used for FUSE.  Replacing __mem_cgroup_commit_charge_lrucare()
> by __mem_cgroup_commit_charge(), I used the "pc" pointer set up earlier:
> but it's for oldpage, and needs now to be for newpage.  Once oldpage was
> freed, its PageCgroupUsed bit (cleared above but set again here) caused
> "Bad page state" messages - and perhaps worse, being missed from newpage.
> (I didn't find this by using FUSE, but in reusing the function for tmpfs.)
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org [v3.3 only]


Thanks,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
> 
>  mm/memcontrol.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- 3.4-rc3/mm/memcontrol.c	2012-04-15 20:47:37.151777506 -0700
> +++ linux/mm/memcontrol.c	2012-04-18 22:29:18.490639511 -0700
> @@ -3392,6 +3392,7 @@ void mem_cgroup_replace_page_cache(struc
>  	 * the newpage may be on LRU(or pagevec for LRU) already. We lock
>  	 * LRU while we overwrite pc->mem_cgroup.
>  	 */
> +	pc = lookup_page_cgroup(newpage);
>  	__mem_cgroup_commit_charge(memcg, newpage, 1, pc, type, true);
>  }
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
