Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id BFF786B0044
	for <linux-mm@kvack.org>; Thu,  8 Nov 2012 01:35:24 -0500 (EST)
Message-ID: <509B533B.7090907@redhat.com>
Date: Thu, 08 Nov 2012 14:37:47 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/19] Foundation for automatic NUMA balancing
References: <1352193295-26815-1-git-send-email-mgorman@suse.de> <509A2970.9000408@redhat.com> <20121107152558.GZ8218@suse.de>
In-Reply-To: <20121107152558.GZ8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, CAI Qian <caiqian@redhat.com>

On 11/07/2012 11:25 PM, Mel Gorman wrote:
> On Wed, Nov 07, 2012 at 05:27:12PM +0800, Zhouping Liu wrote:
>> Hello Mel,
>>
>> my 2 nodes machine hit a panic fault after applied the patch
>> set(based on kernel-3.7.0-rc4), please review it:
>>
>> <SNIP>
> Early initialisation problem by the looks of things. Try this please

Tested the patch, and the issue is gone.

>
> ---8<---
> mm: numa: Check that preferred_node_policy is initialised
>
> Zhouping Liu reported the following
>
> [ 0.000000] ------------[ cut here ]------------
> [ 0.000000] kernel BUG at mm/mempolicy.c:1785!
> [ 0.000000] invalid opcode: 0000 [#1] SMP
> [ 0.000000] Modules linked in:
> [ 0.000000] CPU 0
> ....
> [    0.000000] Call Trace:
> [    0.000000] [<ffffffff81176966>] alloc_pages_current+0xa6/0x170
> [    0.000000] [<ffffffff81137a44>] __get_free_pages+0x14/0x50
> [    0.000000] [<ffffffff819efd9b>] kmem_cache_init+0x53/0x2d2
> [    0.000000] [<ffffffff819caa53>] start_kernel+0x1e0/0x3c7
>
> Problem is that early in boot preferred_nod_policy and SLUB
> initialisation trips up. Check it is initialised.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Tested-by: Zhouping Liu <zliu@redhat.com>

Thanks,
Zhouping

> ---
>   mm/mempolicy.c |    4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 11d4b6b..8cfa6dc 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -129,6 +129,10 @@ static struct mempolicy *get_task_policy(struct task_struct *p)
>   		node = numa_node_id();
>   		if (node != -1)
>   			pol = &preferred_node_policy[node];
> +
> +		/* preferred_node_policy is not initialised early in boot */
> +		if (!pol->mode)
> +			pol = NULL;
>   	}
>   
>   	return pol;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
