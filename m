Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id E1A756B0078
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 23:11:36 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D730D3EE0AE
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 13:11:34 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AE86E45DEBC
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 13:11:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 964B045DEB6
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 13:11:34 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78D711DB8041
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 13:11:34 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 20B811DB803C
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 13:11:34 +0900 (JST)
Message-ID: <50AC545F.5080303@jp.fujitsu.com>
Date: Wed, 21 Nov 2012 13:11:11 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, memcg: avoid unnecessary function call when memcg
 is disabled fix
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com> <20121120134932.055bc192.akpm@linux-foundation.org> <50AC282A.4070309@jp.fujitsu.com> <alpine.DEB.2.00.1211201847450.2278@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211201847450.2278@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

(2012/11/21 11:48), David Rientjes wrote:
> Move the check for !mm out of line as suggested by Andrew.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Thank you very much !

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>   include/linux/memcontrol.h |    2 +-
>   mm/memcontrol.c            |    3 +++
>   2 files changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -185,7 +185,7 @@ void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
>   static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
>   					     enum vm_event_item idx)
>   {
> -	if (mem_cgroup_disabled() || !mm)
> +	if (mem_cgroup_disabled())
>   		return;
>   	__mem_cgroup_count_vm_event(mm, idx);
>   }
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1021,6 +1021,9 @@ void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
>   {
>   	struct mem_cgroup *memcg;
>
> +	if (!mm)
> +		return;
> +
>   	rcu_read_lock();
>   	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
>   	if (unlikely(!memcg))
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
