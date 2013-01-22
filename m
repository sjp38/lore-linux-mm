Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 667AA6B0002
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 17:40:26 -0500 (EST)
Date: Tue, 22 Jan 2013 14:40:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] mm: numa: Handle side-effects in
 count_vm_numa_events() for !CONFIG_NUMA_BALANCING
Message-Id: <20130122144024.8ded0f53.akpm@linux-foundation.org>
In-Reply-To: <1358874762-19717-4-git-send-email-mgorman@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
	<1358874762-19717-4-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 22 Jan 2013 17:12:39 +0000
Mel Gorman <mgorman@suse.de> wrote:

> The current definitions for count_vm_numa_events() is wrong for
> !CONFIG_NUMA_BALANCING as the following would miss the side-effect.
> 
> 	count_vm_numa_events(NUMA_FOO, bar++);

Stupid macros.

> There are no such users of count_vm_numa_events() but it is a potential
> pitfall. This patch fixes it and converts count_vm_numa_event() so that
> the definitions look similar.

Confused.  The patch doesn't alter count_vm_numa_event().  No matter.

> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -85,7 +85,7 @@ static inline void vm_events_fold_cpu(int cpu)
>  #define count_vm_numa_events(x, y) count_vm_events(x, y)
>  #else
>  #define count_vm_numa_event(x) do {} while (0)
> -#define count_vm_numa_events(x, y) do {} while (0)
> +#define count_vm_numa_events(x, y) do { (void)(y); } while (0)
>  #endif /* CONFIG_NUMA_BALANCING */
>  
>  #define __count_zone_vm_events(item, zone, delta) \

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
