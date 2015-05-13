Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 935B26B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 11:53:32 -0400 (EDT)
Received: by pdea3 with SMTP id a3so55474527pde.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 08:53:32 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id po6si22119419pbb.244.2015.05.13.08.53.31
        for <linux-mm@kvack.org>;
        Wed, 13 May 2015 08:53:31 -0700 (PDT)
Message-ID: <5553737D.8080904@sgi.com>
Date: Wed, 13 May 2015 10:53:33 -0500
From: nzimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages before
 basic setup
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>	<554030D1.8080509@hp.com>	<5543F802.9090504@hp.com>	<554415B1.2050702@hp.com>	<20150504143046.9404c572486caf71bdef0676@linux-foundation.org>	<20150505104514.GC2462@suse.de>	<20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>	<20150507072518.GL2462@suse.de> <20150507150932.79e038167f70dd467c25d6ee@linux-foundation.org>
In-Reply-To: <20150507150932.79e038167f70dd467c25d6ee@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>
Cc: Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

I am just noticed a hang on my largest box.
I can only reproduce with large core counts, if I turn down the number 
of cpus it doesn't have an issue.

Also as time goes on the amount of time required to initialize pages 
goes up.


log_uv48_05121052:[  177.250385] node 0 initialised, 14950072 pages in 544ms
log_uv48_05121052:[  177.269629] node 1 initialised, 15990505 pages in 564ms
log_uv48_05121052:[  177.436047] node 215 initialised, 3600110 pages in 
724ms
log_uv48_05121052:[  177.464056] node 102 initialised, 3604205 pages in 
756ms
log_uv48_05121052:[  178.073822] node 30 initialised, 7732972 pages in 
1368ms
log_uv48_05121052:[  178.082888] node 31 initialised, 7728877 pages in 
1372ms
log_uv48_05121052:[  178.080060] node 29 initialised, 7728877 pages in 
1376ms
....
log_uv48_05121052:[  178.217980] node 197 initialised, 7728877 pages in 
1504ms
log_uv48_05121052:[  178.217851] node 196 initialised, 7732972 pages in 
1504ms
log_uv48_05121052:[  178.219992] node 247 initialised, 7726418 pages in 
1504ms
log_uv48_05121052:[  178.325299] node 3 initialised, 15986409 pages in 
1624ms
log_uv48_05121052:[  178.328455] node 2 initialised, 15990505 pages in 
1624ms
log_uv48_05121052:[  178.383371] node 4 initialised, 15990505 pages in 
1680ms
...
log_uv48_05121052:[  178.438401] node 19 initialised, 15986409 pages in 
1728ms

I apologize for the tardiness of this report but I have not been able to 
get to the largest boxes reliably.
Hopefully I will have more access this week.


On 05/07/2015 05:09 PM, Andrew Morton wrote:
> On Thu, 7 May 2015 08:25:18 +0100 Mel Gorman <mgorman@suse.de> wrote:
>
>> Waiman Long reported that 24TB machines hit OOM during basic setup when
>> struct page initialisation was deferred. One approach is to initialise memory
>> on demand but it interferes with page allocator paths. This patch creates
>> dedicated threads to initialise memory before basic setup. It then blocks
>> on a rw_semaphore until completion as a wait_queue and counter is overkill.
>> This may be slower to boot but it's simplier overall and also gets rid of a
>> section mangling which existed so kswapd could do the initialisation.
> Seems a reasonable compromise.  It makes a bit of a mess of the patch
> sequencing.
>
> Have some tweaklets:
>
>
>
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix
>
> include rwsem.h, use DECLARE_RWSEM, fix comment, remove unneeded cast
>
> Cc: Daniel J Blueman <daniel@numascale.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Nathan Zimmer <nzimmer@sgi.com>
> Cc: Scott Norton <scott.norton@hp.com>
> Cc: Waiman Long <waiman.long@hp.com
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>   mm/page_alloc.c |    8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff -puN mm/page_alloc.c~mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix
> +++ a/mm/page_alloc.c
> @@ -18,6 +18,7 @@
>   #include <linux/mm.h>
>   #include <linux/swap.h>
>   #include <linux/interrupt.h>
> +#include <linux/rwsem.h>
>   #include <linux/pagemap.h>
>   #include <linux/jiffies.h>
>   #include <linux/bootmem.h>
> @@ -1075,12 +1076,12 @@ static void __init deferred_free_range(s
>   		__free_pages_boot_core(page, pfn, 0);
>   }
>   
> -static struct rw_semaphore __initdata pgdat_init_rwsem;
> +static __initdata DECLARE_RWSEM(pgdat_init_rwsem);
>   
>   /* Initialise remaining memory on a node */
>   static int __init deferred_init_memmap(void *data)
>   {
> -	pg_data_t *pgdat = (pg_data_t *)data;
> +	pg_data_t *pgdat = data;
>   	int nid = pgdat->node_id;
>   	struct mminit_pfnnid_cache nid_init_state = { };
>   	unsigned long start = jiffies;
> @@ -1096,7 +1097,7 @@ static int __init deferred_init_memmap(v
>   		return 0;
>   	}
>   
> -	/* Bound memory initialisation to a local node if possible */
> +	/* Bind memory initialisation thread to a local node if possible */
>   	if (!cpumask_empty(cpumask))
>   		set_cpus_allowed_ptr(current, cpumask);
>   
> @@ -1200,7 +1201,6 @@ void __init page_alloc_init_late(void)
>   {
>   	int nid;
>   
> -	init_rwsem(&pgdat_init_rwsem);
>   	for_each_node_state(nid, N_MEMORY) {
>   		down_read(&pgdat_init_rwsem);
>   		kthread_run(deferred_init_memmap, NODE_DATA(nid), "pgdatinit%d", nid);
> _
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
