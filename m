Date: Thu, 14 Feb 2008 16:30:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit
 under memory pressure
Message-Id: <20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080213151242.7529.79924.sendpatchset@localhost.localdomain>
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
	<20080213151242.7529.79924.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2008 20:42:42 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> +	read_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
> +	while (!list_empty(&mem_cgroup_sl_exceeded_list)) {
> +		mem = list_first_entry(&mem_cgroup_sl_exceeded_list,
> +				struct mem_cgroup, sl_exceeded_list);
> +		list_move(&mem->sl_exceeded_list, &reclaimed_groups);
> +		read_unlock_irqrestore(&mem_cgroup_sl_list_lock, flags);
> +
> +		nr_bytes_over_sl = res_counter_sl_excess(&mem->res);
> +		if (nr_bytes_over_sl <= 0)
> +			goto next;
> +		nr_pages = (nr_bytes_over_sl >> PAGE_SHIFT);
> +		ret += try_to_free_mem_cgroup_pages(mem, gfp_mask, nr_pages,
> +							zones);
> +next:
> +		read_lock_irqsave(&mem_cgroup_sl_list_lock, flags);

Hmm... 
This is triggered by page allocation failure (fast path) in alloc_pages()
after try_to_free_pages(). Then, what pages should be reclaimed is 
depends on zones[]. Because nr-bytes_over_sl is counted globally, cgroup's
pages may not be included in zones[].

And I think it's big workload to relclaim all excessed pages at once.

How about just reclaiming small # of pages ? like
==
if (nr_bytes_over_sl <= 0)
	goto next;
nr_pages = SWAP_CLUSTER_MAX;
==

Regards,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
