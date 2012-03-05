Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 8275B6B002C
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 19:21:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 760683EE0C2
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:21:11 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A7C845DE4D
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:21:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 356AE45DE53
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:21:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 202AE1DB8042
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:21:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C924C1DB803C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:21:10 +0900 (JST)
Date: Mon, 5 Mar 2012 09:19:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memcg usage_in_bytes does not account file mapped and
 slab memory
Message-Id: <20120305091934.588c160b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120302162753.GA11748@oksana.dev.rtsoft.ru>
References: <20120302162753.GA11748@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, John Stultz <john.stultz@linaro.org>

On Fri, 2 Mar 2012 20:27:53 +0400
Anton Vorontsov <anton.vorontsov@linaro.org> wrote:

> ... and thus is useless for low memory notifications.
> 
> Hi all!
> 
> While working on userspace low memory killer daemon (a supposed
> substitution for the kernel low memory killer, i.e.
> drivers/staging/android/lowmemorykiller.c), I noticed that current
> cgroups memory notifications aren't suitable for such a daemon.
> 
> Suppose we want to install a notification when free memory drops below
> 8 MB. Logically (taking memory hotplug aside), using current usage_in_bytes
> notifications we would install an event on 'total_ram - 8MB' threshold.
> 
> But as usage_in_bytes doesn't account file mapped memory and memory
> used by kernel slab, the formula won't work.
> 
> Currently I use the following patch that makes things going:
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 228d646..c8abdc5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3812,6 +3812,9 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  
>         val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
>         val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_RSS);
> +       val += mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
> +       val += global_page_state(NR_SLAB_RECLAIMABLE);
> +       val += global_page_state(NR_SLAB_UNRECLAIMABLE);
> 
> 
> But here are some questions:
> 
> 1. Is there any particular reason we don't currently account file mapped
>    memory in usage_in_bytes?
> 

CACHE includes all file caches. Why do you think FILE_MAPPED is not included in CACHE ?


>    To me, MEM_CGROUP_STAT_FILE_MAPPED hunk seems logical even if we
>    don't use it for lowmemory notifications.
> 
>    Plus, it seems that FILE_MAPPED _is_ accounted for the non-root
>    cgroups, so I guess it's clearly a bug for the root memcg?
> 
> 2. As for NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE, it seems that
>    these numbers are only applicable for the root memcg.
>    I'm not sure that usage_in_bytes semantics should actually account
>    these, but I tend to think that we should.
> 

Now, SLAB is not accounted by memcg at all.
See memifo if necessary.

> All in all, not accounting both 1. and 2. looks like bugs to me.
> 

It's spec. not bug. If you want to see slab status in memcg's file,
Please add kernel memory accounting feature. There has been already 2 proposals.
Check them and comment.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
