Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1817D6B0005
	for <linux-mm@kvack.org>; Sun, 13 Mar 2016 19:08:10 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id p65so80991690wmp.1
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 16:08:10 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id iz6si23561402wjb.183.2016.03.13.16.08.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Mar 2016 16:08:08 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n186so12369687wmn.0
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 16:08:08 -0700 (PDT)
Date: Mon, 14 Mar 2016 02:08:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 1/2] mm, vmstat: calculate particular vm event
Message-ID: <20160313230806.GA10438@node.shutemov.name>
References: <1457861335-23297-1-git-send-email-ebru.akagunduz@gmail.com>
 <1457861335-23297-2-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457861335-23297-2-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On Sun, Mar 13, 2016 at 11:28:54AM +0200, Ebru Akagunduz wrote:
> Currently, vmstat can calculate specific vm event with all_vm_events()
> however it allocates all vm events to stack. This patch introduces
> a helper to sum value of a specific vm event over all cpu, without
> loading all the events.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> ---
> Changes in v2:
>  - this patch newly created in this version
>  - create sum event function to
>    calculate particular vm event (Kirill A. Shutemov)
> 
>  include/linux/vmstat.h |  2 ++
>  mm/vmstat.c            | 12 ++++++++++++
>  2 files changed, 14 insertions(+)
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 73fae8c..add0cc1 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -53,6 +53,8 @@ static inline void count_vm_events(enum vm_event_item item, long delta)
>  
>  extern void all_vm_events(unsigned long *);
>  
> +extern unsigned long sum_vm_event(enum vm_event_item item);
> +
>  extern void vm_events_fold_cpu(int cpu);
>  
>  #else

You need dumy definition of the function for !CONFIG_VM_EVENT_COUNTERS
case here. Otherwise build will fail. See 0-day report.

Otherwise looks good to me:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 5e43004..b76d664 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -34,6 +34,18 @@
>  DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
>  EXPORT_PER_CPU_SYMBOL(vm_event_states);
>  
> +unsigned long sum_vm_event(enum vm_event_item item)
> +{
> +	int cpu;
> +	unsigned long ret = 0;
> +
> +	get_online_cpus();
> +	for_each_online_cpu(cpu)
> +		ret += per_cpu(vm_event_states, cpu).event[item];
> +	put_online_cpus();
> +	return ret;
> +}
> +
>  static void sum_vm_events(unsigned long *ret)
>  {
>  	int cpu;
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
