Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDD062012A
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 21:01:45 -0400 (EDT)
Date: Wed, 4 Aug 2010 09:55:13 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mm 3/5] memcg scalable file stat accounting method
Message-Id: <20100804095513.6fef0a3d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100802191559.6af0cded.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802191559.6af0cded.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> @@ -1074,7 +1075,49 @@ static unsigned int get_swappiness(struc
>  	return swappiness;
>  }
>  
> -/* A routine for testing mem is not under move_account */
> +static void mem_cgroup_start_move(struct mem_cgroup *mem)
> +{
> +	int cpu;
> +	/* for fast checking in mem_cgroup_update_file_stat() etc..*/
> +	spin_lock(&mc.lock);
> +	for_each_possible_cpu(cpu)
> +		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
> +	spin_unlock(&mc.lock);
> +
> +	synchronize_rcu();
> +}
> +
> +static void mem_cgroup_end_move(struct mem_cgroup *mem)
> +{
> +	int cpu;
> +
> +	if (!mem)
> +		return;
Is this check necessary?

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
