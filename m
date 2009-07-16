Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5A34A6B0087
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 21:12:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G1CMDf022733
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 10:12:23 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 88FF445DE53
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:12:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 54D8145DE4D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:12:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E737E0800C
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:12:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B816C1DB803C
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:12:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] profile: Suppress warning about large allocations when profile=1 is specified
In-Reply-To: <1247656992-19846-3-git-send-email-mel@csn.ul.ie>
References: <1247656992-19846-1-git-send-email-mel@csn.ul.ie> <1247656992-19846-3-git-send-email-mel@csn.ul.ie>
Message-Id: <20090716100305.9D16.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 10:12:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Heinz Diehl <htd@fancy-poultry.org>, David Miller <davem@davemloft.net>, Arnaldo Carvalho de Melo <acme@redhat.com>
List-ID: <linux-mm.kvack.org>

> When profile= is used, a large buffer is allocated early at boot. This
> can be larger than what the page allocator can provide so it prints a
> warning. However, the caller is able to handle the situation so this patch
> suppresses the warning.

I'm confused.

Currently caller doesn't handle error return.

----------------------------------------------------------
asmlinkage void __init start_kernel(void)
{
(snip)
        init_timers();
        hrtimers_init();
        softirq_init();
        timekeeping_init();
        time_init();
        sched_clock_init();
        profile_init();           <-- ignore return value
------------------------------------------------------------

and, if user want to use linus profiler, the user should choice select
proper bucket size by boot parameter.
Currently, allocation failure message tell user about specified bucket size
is wrong.
I think this patch hide it.


> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  kernel/profile.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/profile.c b/kernel/profile.c
> index 69911b5..419250e 100644
> --- a/kernel/profile.c
> +++ b/kernel/profile.c
> @@ -117,11 +117,12 @@ int __ref profile_init(void)
>  
>  	cpumask_copy(prof_cpu_mask, cpu_possible_mask);
>  
> -	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL);
> +	prof_buffer = kzalloc(buffer_bytes, GFP_KERNEL|__GFP_NOWARN);
>  	if (prof_buffer)
>  		return 0;
>  
> -	prof_buffer = alloc_pages_exact(buffer_bytes, GFP_KERNEL|__GFP_ZERO);
> +	prof_buffer = alloc_pages_exact(buffer_bytes,
> +					GFP_KERNEL|__GFP_ZERO|__GFP_NOWARN);
>  	if (prof_buffer)
>  		return 0;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
