Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C694C6B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 19:50:39 -0400 (EDT)
Date: Fri, 9 Oct 2009 16:50:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] memcg: coalescing charge by percpu (Oct/9)
Message-Id: <20091009165002.629a91d2.akpm@linux-foundation.org>
In-Reply-To: <20091009170105.170e025f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091009165826.59c6f6e3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091009170105.170e025f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, h-shimamoto@ct.jp.nec.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Oct 2009 17:01:05 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> +static void drain_all_stock_async(void)
> +{
> +	int cpu;
> +	/* This function is for scheduling "drain" in asynchronous way.
> +	 * The result of "drain" is not directly handled by callers. Then,
> +	 * if someone is calling drain, we don't have to call drain more.
> +	 * Anyway, work_pending() will catch if there is a race. We just do
> +	 * loose check here.
> +	 */
> +	if (atomic_read(&memcg_drain_count))
> +		return;
> +	/* Notify other cpus that system-wide "drain" is running */
> +	atomic_inc(&memcg_drain_count);
> +	get_online_cpus();
> +	for_each_online_cpu(cpu) {
> +		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> +		if (work_pending(&stock->work))
> +			continue;
> +		INIT_WORK(&stock->work, drain_local_stock);
> +		schedule_work_on(cpu, &stock->work);
> +	}
> + 	put_online_cpus();
> +	atomic_dec(&memcg_drain_count);
> +	/* We don't wait for flush_work */
> +}

It's unusual to run INIT_WORK() each time we use a work_struct. 
Usually we will run INIT_WORK a single time, then just repeatedly use
that structure.  Because after the work has completed, it is still in a
ready-to-use state.

Running INIT_WORK() repeatedly against the same work_struct adds a risk
that we'll scribble on an in-use work_struct, which would make a big
mess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
