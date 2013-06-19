Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id A399F6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 05:18:43 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 14:42:36 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6827CE004F
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 14:48:01 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5J9IiZt9175134
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 14:48:45 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5J9IYMv017108
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:18:34 +1000
Message-ID: <51C176AC.4000709@linux.vnet.ibm.com>
Date: Wed, 19 Jun 2013 14:45:24 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc: remove repetitious local_irq_save() in
 __zone_pcp_update()
References: <1371593437-30002-1-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1371593437-30002-1-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On 06/19/2013 03:40 AM, Cody P Schafer wrote:
> __zone_pcp_update() is called via stop_machine(), which already disables
> local irq.
> 
> Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>

Reviewed-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Regards,
Srivatsa S. Bhat

> ---
>  mm/page_alloc.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bac3107..b46b54a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6179,7 +6179,7 @@ static int __meminit __zone_pcp_update(void *data)
>  {
>  	struct zone *zone = data;
>  	int cpu;
> -	unsigned long batch = zone_batchsize(zone), flags;
> +	unsigned long batch = zone_batchsize(zone);
> 
>  	for_each_possible_cpu(cpu) {
>  		struct per_cpu_pageset *pset;
> @@ -6188,12 +6188,10 @@ static int __meminit __zone_pcp_update(void *data)
>  		pset = per_cpu_ptr(zone->pageset, cpu);
>  		pcp = &pset->pcp;
> 
> -		local_irq_save(flags);
>  		if (pcp->count > 0)
>  			free_pcppages_bulk(zone, pcp->count, pcp);
>  		drain_zonestat(zone, pset);
>  		setup_pageset(pset, batch);
> -		local_irq_restore(flags);
>  	}
>  	return 0;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
