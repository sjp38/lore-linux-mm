Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 4A5FB6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 00:45:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DBC1E3EE0BB
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:45:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2C4D45DEB3
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:45:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A434945DE9E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:45:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 958791DB803E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:45:30 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AC171DB8038
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:45:30 +0900 (JST)
Message-ID: <4FFA616B.4000608@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 13:43:23 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memcg: return -EBUSY when oom-kill-disable modified
 and memcg use_hierarchy, has children
References: <1341485708-14221-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <1341485708-14221-1-git-send-email-liwp.linux@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/07/05 19:55), Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> When oom-kill-disable modified by the user and current memcg use_hierarchy,
> the change can occur, provided the current memcg has no children. If it
> has children, return -EBUSY is enough.
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>

I'm sorry what is the point ? You think -EBUSY should be returned in this case 
rather than -EINVAl ? Then, why ?


> ---
>   mm/memcontrol.c |    7 +++++--
>   1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 63e36e7..4b64fe0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4521,11 +4521,14 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>   
>   	cgroup_lock();
>   	/* oom-kill-disable is a flag for subhierarchy. */
> -	if ((parent->use_hierarchy) ||
> -	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
> +	if (parent->use_hierarchy) {
>   		cgroup_unlock();
>   		return -EINVAL;
> +	} else if (memcg->use_hierarchy && !list_empty(&cgrp->children)) {
> +		cgroup_unlock();
> +		return -EBUSY;
>   	}
> +
>   	memcg->oom_kill_disable = val;
>   	if (!val)
>   		memcg_oom_recover(memcg);
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
