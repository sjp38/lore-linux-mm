Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 811886B007B
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 01:53:06 -0500 (EST)
Date: Tue, 12 Jan 2010 15:50:42 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: ensure list is empty at rmdir
Message-Id: <20100112155042.8a7a956d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100112145603.06dc2de0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100112140836.45e7fabb.nishimura@mxp.nes.nec.co.jp>
	<20100112145603.06dc2de0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010 14:56:03 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > This patch tries to fix this bug by ensuring not only the usage is zero but also
> > all of the LRUs are empty. mem_cgroup_del_lru_list() checks the list is empty
> > or not, so we can make use of it.
> > 
> Ah, ok. We call lru_add_drain() but doesn't check lru is really empty or not.
> It seems this patch can fix the problem.
> Thank you for great fix.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
Thank you for you ack.

> Following is nitpicks.
> 
> > -	}
> > -	ret = 0;
> > +	} while (mem->res.usage > 0 || ret);
> 
> This seems unclear. (Not your mistake, maybe mine.)
> 
I'll add a comment.

	/* "ret" should also be checked to ensure all lists are empty. */
	} while (mem->res.usage > 0 || ret);

> BTW, I think it's better to move drain_all_stock_sync(), too.
> as..
> ==
>         do {
>                 ret = -EBUSY;
>                 if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
>                         goto out;
>                 ret = -EINTR;
>                 if (signal_pending(current))
>                         goto out;
>                 /* This is for making all *used* pages to be on LRU. */
>                 lru_add_drain_all();
>                 ret = 0;
>                 for_each_node_state(node, N_HIGH_MEMORY) {
> ......
> 	
>                 cond_resched();
>                 /* Need to drain all cached "usage" befor we check counter */
>                 if (!ret)
> 			drain_all_stock_sync();
> 		if (ret == -EBUSY)
> 			cond_resched();
>         } while (mem->res.usage != 0);
> ==
> 
I agree.
We would be better not to drain stocks on failure path, but it's another topic :)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
