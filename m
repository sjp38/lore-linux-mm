Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1DADA8D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 12:08:28 -0500 (EST)
Message-ID: <4D669089.6080007@redhat.com>
Date: Thu, 24 Feb 2011 12:08:25 -0500
From: Satoru Moriya <smoriya@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3][RESEND] Provide control over unmapped pages (v4)
References: <20110201165329.12377.13683.stgit@localhost6.localdomain6> <20110201165533.12377.11775.stgit@localhost6.localdomain6>
In-Reply-To: <20110201165533.12377.11775.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

On 02/01/2011 11:55 AM, Balbir Singh wrote:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7b56473..2ac8549 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1660,6 +1660,9 @@ zonelist_scan:
>  			unsigned long mark;
>  			int ret;
>  
> +			if (should_reclaim_unmapped_pages(zone))
> +				wakeup_kswapd(zone, order, classzone_idx);
> +
>  			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
>  			if (zone_watermark_ok(zone, order, mark,
>  				    classzone_idx, alloc_flags))

<snip>

> +int sysctl_max_unmapped_ratio_sysctl_handler(ctl_table *table, int write,
> +	void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +	struct zone *zone;
> +	int rc;
> +
> +	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
> +	if (rc)
> +		return rc;
> +
> +	for_each_zone(zone)
> +		zone->max_unmapped_pages = (zone->present_pages *
> +				sysctl_max_unmapped_ratio) / 100;
> +	return 0;
> +}
> +#endif
> +

<snip>

> +
> +bool should_reclaim_unmapped_pages(struct zone *zone)
> +{
> +	if (unlikely(unmapped_page_control) &&
> +		(zone_unmapped_file_pages(zone) > zone->max_unmapped_pages))
> +		return true;
> +	return false;
> +}
> +#endif

Why don't you limit the amount of unmapped pages for the whole system?
Current implementation, which limit unmapped pages per zone, may cause unnecessary
reclaiming. Because if memory access is not balanced among zones(or nodes),
the kernel may reclaim unmapped pages even though other zones/nodes have enough
spaces for them.

Anyway, I'm interested in this patchset. Because my customers in enterprise area
want this kind of feature for a long time to avoid direct reclaim completely 
in a certain situation.

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
