Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3D36B0078
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 19:57:19 -0500 (EST)
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id o150vGMM008100
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 16:57:17 -0800
Received: from ywh41 (ywh41.prod.google.com [10.192.8.41])
	by spaceape12.eur.corp.google.com with ESMTP id o150vF45001835
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 16:57:15 -0800
Received: by ywh41 with SMTP id 41so335062ywh.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2010 16:57:14 -0800 (PST)
Date: Thu, 4 Feb 2010 16:57:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup
In-Reply-To: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002041656290.5798@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Feb 2010, KAMEZAWA Hiroyuki wrote:

> Now, oom-killer kills process's chidlren at first. But this means
> a child in other cgroup can be killed. But it's not checked now.
> 
> This patch fixes that.
> 
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

> ---
>  mm/oom_kill.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> Index: mmotm-2.6.33-Feb03/mm/oom_kill.c
> ===================================================================
> --- mmotm-2.6.33-Feb03.orig/mm/oom_kill.c
> +++ mmotm-2.6.33-Feb03/mm/oom_kill.c
> @@ -459,6 +459,9 @@ static int oom_kill_process(struct task_
>  	list_for_each_entry(c, &p->children, sibling) {
>  		if (c->mm == p->mm)
>  			continue;
> +		/* Children may be in other cgroup */
> +		if (mem && !task_in_mem_cgroup(c, mem))
> +			continue;
>  		if (!oom_kill_task(c))
>  			return 0;
>  	}
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
