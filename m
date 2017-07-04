Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B0D1F6B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 08:07:04 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u110so45314864wrb.14
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 05:07:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o84si19918693wmb.180.2017.07.04.05.07.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 05:07:03 -0700 (PDT)
Subject: Re: [patch V2 1/2] mm: swap: Provide lru_add_drain_all_cpuslocked()
References: <20170704093232.995040438@linutronix.de>
 <20170704093421.419329357@linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b2522a26-334b-c66e-4cca-c9eeb4aa6f93@suse.cz>
Date: Tue, 4 Jul 2017 14:07:01 +0200
MIME-Version: 1.0
In-Reply-To: <20170704093421.419329357@linutronix.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

On 07/04/2017 11:32 AM, Thomas Gleixner wrote:
> The rework of the cpu hotplug locking unearthed potential deadlocks with
> the memory hotplug locking code.
> 
> The solution for these is to rework the memory hotplug locking code as well
> and take the cpu hotplug lock before the memory hotplug lock in
> mem_hotplug_begin(), but this will cause a recursive locking of the cpu
> hotplug lock when the memory hotplug code calls lru_add_drain_all().
> 
> Split out the inner workings of lru_add_drain_all() into
> lru_add_drain_all_cpuslocked() so this function can be invoked from the
> memory hotplug code with the cpu hotplug lock held.
> 
> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

A question below.

> ---
>  include/linux/swap.h |    1 +
>  mm/swap.c            |   11 ++++++++---
>  2 files changed, 9 insertions(+), 3 deletions(-)
> 
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -277,6 +277,7 @@ extern void mark_page_accessed(struct pa
>  extern void lru_add_drain(void);
>  extern void lru_add_drain_cpu(int cpu);
>  extern void lru_add_drain_all(void);
> +extern void lru_add_drain_all_cpuslocked(void);
>  extern void rotate_reclaimable_page(struct page *page);
>  extern void deactivate_file_page(struct page *page);
>  extern void mark_page_lazyfree(struct page *page);
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -687,7 +687,7 @@ static void lru_add_drain_per_cpu(struct
>  
>  static DEFINE_PER_CPU(struct work_struct, lru_add_drain_work);
>  
> -void lru_add_drain_all(void)
> +void lru_add_drain_all_cpuslocked(void)
>  {
>  	static DEFINE_MUTEX(lock);
>  	static struct cpumask has_work;
> @@ -701,7 +701,6 @@ void lru_add_drain_all(void)
>  		return;
>  
>  	mutex_lock(&lock);
> -	get_online_cpus();

Is there a an assertion check that we are locked, that could be put in
e.g. VM_WARN_ON_ONCE()?

>  	cpumask_clear(&has_work);
>  
>  	for_each_online_cpu(cpu) {
> @@ -721,10 +720,16 @@ void lru_add_drain_all(void)
>  	for_each_cpu(cpu, &has_work)
>  		flush_work(&per_cpu(lru_add_drain_work, cpu));
>  
> -	put_online_cpus();
>  	mutex_unlock(&lock);
>  }
>  
> +void lru_add_drain_all(void)
> +{
> +	get_online_cpus();
> +	lru_add_drain_all_cpuslocked();
> +	put_online_cpus();
> +}
> +
>  /**
>   * release_pages - batched put_page()
>   * @pages: array of pages to release
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
