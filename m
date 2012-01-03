Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D6C2A6B0075
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 12:47:50 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so17229135vbb.14
        for <linux-mm@kvack.org>; Tue, 03 Jan 2012 09:47:49 -0800 (PST)
Message-ID: <4F033F44.6020403@gmail.com>
Date: Tue, 03 Jan 2012 12:47:48 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 8/8] mm: add vmstat counters for tracking PCP drains
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com> <1325499859-2262-9-git-send-email-gilad@benyossef.com>
In-Reply-To: <1325499859-2262-9-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>

(1/2/12 5:24 AM), Gilad Ben-Yossef wrote:
> This patch introduces two new vmstat counters: pcp_global_drain
> that counts the number of times a per-cpu pages global drain was
> requested and pcp_global_ipi_saved that counts the number of times
> the number of CPUs with per-cpu pages in any zone were less then
> 1/2 of the number of online CPUs.
> 
> The patch purpose is to show the usefulness of only sending an IPI
> asking to drain per-cpu pages to CPUs that actually have them
> instead of a blind global IPI. It is probably not useful by itself.
> 
> Signed-off-by: Gilad Ben-Yossef<gilad@benyossef.com>
> CC: Christoph Lameter<cl@linux.com>
> CC: Chris Metcalf<cmetcalf@tilera.com>
> CC: Peter Zijlstra<a.p.zijlstra@chello.nl>
> CC: Frederic Weisbecker<fweisbec@gmail.com>
> CC: linux-mm@kvack.org
> CC: Pekka Enberg<penberg@kernel.org>
> CC: Matt Mackall<mpm@selenic.com>
> CC: Sasha Levin<levinsasha928@gmail.com>
> CC: Rik van Riel<riel@redhat.com>
> CC: Andi Kleen<andi@firstfloor.org>
> CC: Mel Gorman<mel@csn.ul.ie>
> CC: Andrew Morton<akpm@linux-foundation.org>
> CC: Alexander Viro<viro@zeniv.linux.org.uk>
> CC: Avi Kivity<avi@redhat.com>
> ---
>   include/linux/vm_event_item.h |    1 +
>   mm/page_alloc.c               |    4 ++++
>   mm/vmstat.c                   |    2 ++
>   3 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 03b90cd..3657f6f 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -58,6 +58,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>   		THP_COLLAPSE_ALLOC_FAILED,
>   		THP_SPLIT,
>   #endif
> +		PCP_GLOBAL_DRAIN, PCP_GLOBAL_IPI_SAVED,
>   		NR_VM_EVENT_ITEMS
>   };
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 092c331..4ca6bfa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1140,6 +1140,10 @@ void drain_all_pages(void)
>   				cpumask_clear_cpu(cpu, cpus_with_pcps);
>   		}
>   	on_each_cpu_mask(cpus_with_pcps, drain_local_pages, NULL, 1);
> +
> +	count_vm_event(PCP_GLOBAL_DRAIN);
> +	if (cpumask_weight(cpus_with_pcps)<  (cpumask_weight(cpu_online_mask) / 2))
> +		count_vm_event(PCP_GLOBAL_IPI_SAVED);

NAK.

PCP_GLOBAL_IPI_SAVED is only useful at development phase. I can't
imagine normal admins use it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
