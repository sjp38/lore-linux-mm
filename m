Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2256B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 18:03:56 -0400 (EDT)
Date: Mon, 13 Jul 2009 15:29:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4][resend]  Show kernel stack usage in /proc/meminfo
 and OOM log output
Message-Id: <20090713152952.9b1f6388.akpm@linux-foundation.org>
In-Reply-To: <20090713150114.6260.A69D9226@jp.fujitsu.com>
References: <20090713144924.6257.A69D9226@jp.fujitsu.com>
	<20090713150114.6260.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, cl@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, 13 Jul 2009 15:02:25 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> ChangeLog
>   Since v1
>    - Rewrote the descriptin (Thanks Christoph!)
> 
> =====================
> Subject: [PATCH] Show kernel stack usage in /proc/meminfo and OOM log output
> 
> The amount of memory allocated to kernel stacks can become significant and
> cause OOM conditions. However, we do not display the amount of memory
> consumed by stacks.
> 
> Add code to display the amount of memory used for stacks in /proc/meminfo.
> 
> ...
>  
> +static void account_kernel_stack(struct thread_info *ti, int account)
> +{
> +	struct zone *zone = page_zone(virt_to_page(ti));
> +
> +	mod_zone_page_state(zone, NR_KERNEL_STACK, account);
> +}
> +
>  void free_task(struct task_struct *tsk)
>  {
>  	prop_local_destroy_single(&tsk->dirties);
> +	account_kernel_stack(tsk->stack, -1);

But surely there are other less expensive ways of calculating this. 
The number we want is small-known-constant * number-of-tasks.

number-of-tasks probably isn't tracked, but can be calculated along the
lines of nr_running(), nr_uninterruptible() and nr_iowait().

number-of-tasks is also equal to number-of-task_structs and
number-of_thread_infos which can be obtained from slab (if the arch
implemented these via slab - uglier).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
