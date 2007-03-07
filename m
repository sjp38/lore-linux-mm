Date: Tue, 6 Mar 2007 23:26:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] swap prefetch: avoid repeating entry
Message-Id: <20070306232620.1162457a.akpm@linux-foundation.org>
In-Reply-To: <200703071814.04531.kernel@kolivas.org>
References: <200703071814.04531.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2007 18:14:04 +1100 Con Kolivas <kernel@kolivas.org> wrote:

> I've been unable for 4 months to find someone to test this Andrew. I'm going
> to assume it fixes the problem on numa=64 (or something like that) so please
> apply it.
> 
> ---
> Avoid entering trickle_swap() when first initialising kprefetchd to prevent
> endless loops.
> 
> Signed-off-by: Con Kolivas <kernel@kolivas.org>
> 
> ---
>  mm/swap_prefetch.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> Index: linux-2.6.21-rc2-mm2/mm/swap_prefetch.c
> ===================================================================
> --- linux-2.6.21-rc2-mm2.orig/mm/swap_prefetch.c	2007-03-06 22:23:26.000000000 +1100
> +++ linux-2.6.21-rc2-mm2/mm/swap_prefetch.c	2007-03-07 18:11:50.000000000 +1100
> @@ -515,6 +515,10 @@ static int kprefetchd(void *__unused)
>  	/* Set ioprio to lowest if supported by i/o scheduler */
>  	sys_ioprio_set(IOPRIO_WHO_PROCESS, 0, IOPRIO_CLASS_IDLE);
>  
> +	/* kprefetchd has nothing to do until it is woken up the first time */
> +	set_current_state(TASK_INTERRUPTIBLE);
> +	schedule();
> +
>  	do {
>  		try_to_freeze();
>  

hm, yes, strange.

You can do poor-man's NUMA by setting CONFIG_NUMA_EMU and booting with
`numa=fake=16'  Requires x86_64 and perhaps the fake-numa fixes in -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
