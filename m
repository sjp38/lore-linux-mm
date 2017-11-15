Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51A086B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 23:11:56 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id r58so4467554qtc.7
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 20:11:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o8sor2673004qtf.78.2017.11.14.20.11.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 20:11:55 -0800 (PST)
Subject: Re: Allocation failure of ring buffer for trace
References: <9631b871-99cc-82bb-363f-9d429b56f5b9@gmail.com>
 <20171114114633.6ltw7f4y7qwipcqp@suse.de>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <9afee361-8a6f-1c41-5c30-0ed682608c4c@gmail.com>
Date: Tue, 14 Nov 2017 23:11:52 -0500
MIME-Version: 1.0
In-Reply-To: <20171114114633.6ltw7f4y7qwipcqp@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: rostedt@goodmis.org, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, koki.sanagi@us.fujitsu.com, yasu.isimatu@gmail.com

Hi Mel,

Your patch works good.

Here are the results of your patch.

- boot up without trace_buf_size boot option

When system boots up without trace_buf_size boot option, deferred_init_memmap()
runs after booting SMP configuration. There no change of boot sequence between
4.14.0 and 4.14.0 with your patch.

[    0.256285] x86: Booting SMP configuration:
...
[    5.313195] node 0 initialised, 15530251 pages in 653ms
[    5.330691] node 1 initialised, 15988494 pages in 670ms
[    5.331746] node 2 initialised, 15988493 pages in 671ms
[    5.332166] node 6 initialised, 15982779 pages in 670ms
[    5.332673] node 3 initialised, 15988494 pages in 671ms
[    5.332618] node 4 initialised, 15988494 pages in 672ms
[    5.334187] node 7 initialised, 15987304 pages in 672ms
[    5.334976] node 5 initialised, 15988494 pages in 673ms

- boot up with trace_buf_size boot option

When system boots up with trace_buf_size boot option, deferred_init_memmap()
runs before booting SMP configuration. So every memory on all nodes is
initialised before allocating trace buffer. And system can boot up even if
we set trace_buf_size boot option.

[    0.932114] node 0 initialised, 15530251 pages in 684ms
[    1.604918] node 1 initialised, 15988494 pages in 671ms
[    2.278933] node 2 initialised, 15988494 pages in 673ms
[    2.965076] node 3 initialised, 15988494 pages in 686ms
[    3.669064] node 4 initialised, 15988494 pages in 703ms
[    4.354983] node 5 initialised, 15988493 pages in 684ms
[    5.028681] node 6 initialised, 15982779 pages in 673ms
[    5.716102] node 7 initialised, 15987304 pages in 687ms
[    5.727855] smp: Bringing up secondary CPUs ...
[    5.745937] x86: Booting SMP configuration:

Thanks,
Yasuaki Ishimatsu

On 11/14/2017 06:46 AM, Mel Gorman wrote:
> On Mon, Nov 13, 2017 at 12:48:36PM -0500, YASUAKI ISHIMATSU wrote:
>> When using trace_buf_size= boot option, memory allocation of ring buffer
>> for trace fails as follows:
>>
>> [ ] x86: Booting SMP configuration:
>> <SNIP>
>>
>> In my server, there are 384 CPUs, 512 GB memory and 8 nodes. And
>> "trace_buf_size=100M" is set.
>>
>> When using trace_buf_size=100M, kernel allocates 100 MB memory
>> per CPU before calling free_are_init_core(). Kernel tries to
>> allocates 38.4GB (100 MB * 384 CPU) memory. But available memory
>> at this time is about 16GB (2 GB * 8 nodes) due to the following commit:
>>
>>   3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages
>>                  if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
>>
> 
> 1. What is the use case for such a large trace buffer being allocated at
>    boot time?
> 2. Is disabling CONFIG_DEFERRED_STRUCT_PAGE_INIT at compile time an
>    option for you given that it's a custom-built kernel and not a
>    distribution kernel?
> 
> Basically, as the allocation context is within smp_init(), there are no
> opportunities to do the deferred meminit early. Furthermore, the partial
> initialisation of memory occurs before the size of the trace buffers is
> set so there is no opportunity to adjust the amount of memory that is
> pre-initialised. We could potentially catch when memory is low during
> system boot and adjust the amount that is initialised serially but the
> complexity would be high. Given that deferred meminit is basically a minor
> optimisation that only affects very large machines and trace_buf_size being
> used is somewhat specialised, I think the most straight-forward option is
> to go back to serialised meminit if trace_buf_size is specified like this;
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 710143741eb5..6ef0ab13f774 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -558,6 +558,19 @@ void drain_local_pages(struct zone *zone);
>  
>  void page_alloc_init_late(void);
>  
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +extern void __init disable_deferred_meminit(void);
> +extern void page_alloc_init_late_prepare(void);
> +#else
> +static inline void disable_deferred_meminit(void)
> +{
> +}
> +
> +static inline void page_alloc_init_late_prepare(void)
> +{
> +}
> +#endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
> +
>  /*
>   * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
>   * GFP flags are used before interrupts are enabled. Once interrupts are
> diff --git a/init/main.c b/init/main.c
> index 0ee9c6866ada..0248b8b5bc3a 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -1058,6 +1058,8 @@ static noinline void __init kernel_init_freeable(void)
>  	do_pre_smp_initcalls();
>  	lockup_detector_init();
>  
> +	page_alloc_init_late_prepare();
> +
>  	smp_init();
>  	sched_init_smp();
>  
> diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
> index 752e5daf0896..cfa7175ff093 100644
> --- a/kernel/trace/trace.c
> +++ b/kernel/trace/trace.c
> @@ -1115,6 +1115,13 @@ static int __init set_buf_size(char *str)
>  	if (buf_size == 0)
>  		return 0;
>  	trace_buf_size = buf_size;
> +
> +	/*
> +	 * The size of buffers are unpredictable so initialise all memory
> +	 * before the allocation attempt occurs.
> +	 */
> +	disable_deferred_meminit();
> +
>  	return 1;
>  }
>  __setup("trace_buf_size=", set_buf_size);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 77e4d3c5c57b..4dd0e153b0f2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -290,6 +290,19 @@ EXPORT_SYMBOL(nr_online_nodes);
>  int page_group_by_mobility_disabled __read_mostly;
>  
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +bool __initdata deferred_meminit_disabled;
> +
> +/*
> + * Allow deferred meminit to be disabled by subsystems that require large
> + * allocations before the memory allocator is fully initialised. It should
> + * only be used in cases where the size of the allocation may not fit into
> + * the 2G per node that is allocated serially.
> + */
> +void __init disable_deferred_meminit(void)
> +{
> +	deferred_meminit_disabled = true;
> +}
> +
>  static inline void reset_deferred_meminit(pg_data_t *pgdat)
>  {
>  	unsigned long max_initialise;
> @@ -1567,6 +1580,23 @@ static int __init deferred_init_memmap(void *data)
>  }
>  #endif /* CONFIG_DEFERRED_STRUCT_PAGE_INIT */
>  
> +#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
> +/*
> + * Serialised init of remaining memory if large buffers of unknown size
> + * are required that might fail before parallelised meminit can start
> + */
> +void __init page_alloc_init_late_prepare(void)
> +{
> +	int nid;
> +
> +	if (!deferred_meminit_disabled)
> +		return;
> +
> +	for_each_node_state(nid, N_MEMORY)
> +		deferred_init_memmap(NODE_DATA(nid));
> +}
> +#endif
> +
>  void __init page_alloc_init_late(void)
>  {
>  	struct zone *zone;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
