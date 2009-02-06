Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7FECB6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:03:25 -0500 (EST)
Message-ID: <498BA857.3080809@cn.fujitsu.com>
Date: Fri, 06 Feb 2009 11:02:47 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
References: <20090203172135.GF918@balbir.in.ibm.com>
In-Reply-To: <20090203172135.GF918@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> +	mem_cgrp = memcg->css.cgroup;
> +	task_cgrp = mem_cgroup_from_task(p)->css.cgroup;

I just noticed since v2, task's cgroup is also printed. Then 2 issues here:

1. this is better: task_cgrp = task_subsys_state(p, mem_cgroup_subsys_id);
2. getting cgroup from a task should be protected by task_lock or rcu_read_lock,
   so we can put the above statement inside rcu_read_lock below.

> +
> +	rcu_read_lock();
> +	ret = cgroup_path(task_cgrp, task_memcg_name, PATH_MAX);
> +	if (ret < 0) {
> +		/*
> +		 * Unfortunately, we are unable to convert to a useful name
> +		 * But we'll still print out the usage information
> +		 */
> +		rcu_read_unlock();
> +		goto done;
> +	}
> +	ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
> +	 if (ret < 0) {
> +		rcu_read_unlock();
> +		goto done;
> +	}
> +
> +	rcu_read_unlock();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
