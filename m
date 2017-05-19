Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CED6B831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 05:05:39 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u96so3857787wrc.7
        for <linux-mm@kvack.org>; Fri, 19 May 2017 02:05:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r51si9456297edr.191.2017.05.19.02.05.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 May 2017 02:05:38 -0700 (PDT)
Subject: Re: [PATCH] mm/vmstat: add oom_kill counter
References: <149517718482.32770.939520643229572472.stgit@buzz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7683805d-e0ac-3ab9-0a73-47eea945436d@suse.cz>
Date: Fri, 19 May 2017 11:05:37 +0200
MIME-Version: 1.0
In-Reply-To: <149517718482.32770.939520643229572472.stgit@buzz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>

On 05/19/2017 08:59 AM, Konstantin Khlebnikov wrote:
> Show count of global oom killer invocations in /proc/vmstat

Maybe some more rationale why is that useful?

Vlastimil

> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  include/linux/vm_event_item.h |    1 +
>  mm/oom_kill.c                 |    1 +
>  mm/vmstat.c                   |    1 +
>  3 files changed, 3 insertions(+)
> 
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index d84ae90ccd5c..1707e0a7d943 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -41,6 +41,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
>  		PAGEOUTRUN, PGROTATED,
>  		DROP_PAGECACHE, DROP_SLAB,
> +		OOM_KILL,
>  #ifdef CONFIG_NUMA_BALANCING
>  		NUMA_PTE_UPDATES,
>  		NUMA_HUGE_PTE_UPDATES,
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 04c9143a8625..c734c42826cf 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -883,6 +883,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	 */
>  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
>  	mark_oom_victim(victim);
> +	count_vm_event(OOM_KILL);
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
>  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 76f73670200a..fe80b81a86e0 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1018,6 +1018,7 @@ const char * const vmstat_text[] = {
>  
>  	"drop_pagecache",
>  	"drop_slab",
> +	"oom_kill",
>  
>  #ifdef CONFIG_NUMA_BALANCING
>  	"numa_pte_updates",
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
