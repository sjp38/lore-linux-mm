Date: Sat, 28 Jun 2008 13:22:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 5/5] Memory controller soft limit reclaim on contention
Message-Id: <20080628132247.01e1ed30.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080627151906.31664.7247.sendpatchset@balbir-laptop>
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop>
	<20080627151906.31664.7247.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jun 2008 20:49:06 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> +
> +		while (count-- &&
> +			((mem = heap_delete_max(&mem_cgroup_heap)) != NULL)) {
> +			BUG_ON(!mem->on_heap);
> +			spin_unlock_irqrestore(&mem_cgroup_heap_lock, flags);
> +			nr_reclaimed += try_to_free_mem_cgroup_pages(mem,
> +								gfp_mask);
> +			cond_resched();
> +			spin_lock_irqsave(&mem_cgroup_heap_lock, flags);
> +			mem->on_heap = 0;
It seems "mem* is not on heap after heap_delete_max(), right ?
If so, I think this on_heap should be cleared right after heap_delete_max().


> +			/*
> +			 * What should be the basis of breaking out?
> +			 */
> +			if (nr_reclaimed)
> +				goto done;

why stops here ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
