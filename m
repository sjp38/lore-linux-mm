Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED3C5F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 16:05:16 -0500 (EST)
Date: Mon, 2 Feb 2009 13:05:02 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [-mm patch] Show memcg information during OOM
In-Reply-To: <20090202205434.GI918@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.0902021256030.30674@chino.kir.corp.google.com>
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202215527.EC92.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090202141705.GE918@balbir.in.ibm.com> <alpine.DEB.2.00.0902021235500.26971@chino.kir.corp.google.com> <20090202205434.GI918@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009, Balbir Singh wrote:

> David, I'd agree, but since we are under printk_ratelimit() and this
> is a not-so-common path, does the log level matter much? If it does, I
> don't mind using KERN_INFO.
> 

It matters for parsing dmesg output; the only KERN_WARNING message from 
the oom killer is normally the header.  There's a couple extra ones for 
error conditions (that could certainly be changed to KERN_ERR), but only 
in very rare circumstances.

As defined by include/linux/kernel.h:

	#define KERN_WARNING	"<4>"	/* warning conditions			*/
	...
	#define KERN_INFO	"<6>"	/* informational			*/

The meminfo you are printing falls under the "informational" category, no?

While you're there, it might also be helpful to make another change 
that would also help in parsing the output:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8e4be9c..954b0d5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -813,6 +813,25 @@ bool mem_cgroup_oom_called(struct task_struct *task)
>  	rcu_read_unlock();
>  	return ret;
>  }
> +
> +void mem_cgroup_print_mem_info(struct mem_cgroup *memcg)
> +{
> +	if (!memcg)
> +		return;
> +
> +	printk(KERN_WARNING "Memory cgroups's name %s\n",
> +		memcg->css.cgroup->dentry->d_name.name);

This should be "cgroup's", but I don't think you want to print this on a 
line by itself since the only system-wide synchronization here is a 
read-lock on tasklist_lock and there could be two separate memcg's that 
are oom.

So it's quite possible, though unlikely, that two seperate oom events 
would have these messages merged together in the ring buffer, which would 
make parsing impossible.

I think you probably want to add the name to each line you print, such as:

> +	printk(KERN_WARNING "Cgroup memory: usage %llu, limit %llu"
> +		" failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
> +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> +		res_counter_read_u64(&memcg->res, RES_FAILCNT));

	const char *name = memcg->css.cgroup->dentry->d_name.name;

	printk(KERN_INFO "Cgroup %s memory: usage %llu, limit %llu"
			" failcount %llu\n", name, ...);

> +	printk(KERN_WARNING "Cgroup memory+swap: usage %llu, limit %llu "
> +		"failcnt %llu\n",
> +		res_counter_read_u64(&memcg->memsw, RES_USAGE),
> +		res_counter_read_u64(&memcg->memsw, RES_LIMIT),
> +		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));

and

	printk(KERN_INFO "Cgroup %s memory+swap: usage %llu, limit %llu "
		"failcnt %llu\n", name, ...);

> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
