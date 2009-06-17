Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7B9536B0055
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 20:20:57 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5H0LW0H005451
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Jun 2009 09:21:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CB9945DE50
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 09:21:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DBE6F45DE4F
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 09:21:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4618F1DB8038
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 09:21:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E90271DB8040
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 09:21:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: + page_alloc-oops-when-setting-percpu_pagelist_fraction.patch added to -mm tree
In-Reply-To: <200906161901.n5GJ1osY026940@imap1.linux-foundation.org>
References: <200906161901.n5GJ1osY026940@imap1.linux-foundation.org>
Message-Id: <20090617091040.99BB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Jun 2009 09:21:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: sivanich@sgi.com
Cc: kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, mel@csn.ul.ie, nickpiggin@yahoo.com.au, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

(switch to lkml)

Sorry for late review.

> 
> The patch titled
>      page_alloc: Oops when setting percpu_pagelist_fraction
> has been added to the -mm tree.  Its filename is
>      page_alloc-oops-when-setting-percpu_pagelist_fraction.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> out what to do about this
> 
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
> 
> ------------------------------------------------------
> Subject: page_alloc: Oops when setting percpu_pagelist_fraction
> From: Dimitri Sivanich <sivanich@sgi.com>
> 
> After downing/upping a cpu, an attempt to set
> /proc/sys/vm/percpu_pagelist_fraction results in an oops in
> percpu_pagelist_fraction_sysctl_handler().
> 
> To reproduce this:
>   localhost:/sys/devices/system/cpu/cpu6 # echo 0 >online
>   localhost:/sys/devices/system/cpu/cpu6 # echo 1 >online
>   localhost:/sys/devices/system/cpu/cpu6 # cd /proc/sys/vm
>   localhost:/proc/sys/vm # echo 100000 >percpu_pagelist_fraction
> 
>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000004
>   IP: [<ffffffff80286946>] percpu_pagelist_fraction_sysctl_handler+0x4a/0x96
> 
> This is because the zone->pageset[cpu] value has not been set when the cpu
> has been brought back up for unpopulated zones (the "Movable" zone in the
> case I'm running into).  Prior to downing/upping the cpu it had been set
> to &boot_pageset[cpu].
> 
> There are two possible fixes that come to mind.  One is to check for an
> unpopulated zone or NULL zone pageset for that cpu in
> percpu_pagelist_fraction_sysctl_handler(), and simply not set a pagelist
> highmark for that zone/cpu combination.
> 
> The other, and the one I'm proposing here, is to set the zone's pageset
> back to the boot_pageset when the cpu is brought back up if the zone is
> unpopulated.
> 
> Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Nick Piggin <nickpiggin@yahoo.com.au>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/page_alloc.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff -puN mm/page_alloc.c~page_alloc-oops-when-setting-percpu_pagelist_fraction mm/page_alloc.c
> --- a/mm/page_alloc.c~page_alloc-oops-when-setting-percpu_pagelist_fraction
> +++ a/mm/page_alloc.c
> @@ -2806,7 +2806,11 @@ static int __cpuinit process_zones(int c
>  
>  	node_set_state(node, N_CPU);	/* this node has a cpu */
>  
> -	for_each_populated_zone(zone) {
> +	for_each_zone(zone) {
> +		if (!populated_zone(zone)) {
> +			zone_pcp(zone, cpu) = &boot_pageset[cpu];
> +			continue;
> +		}
>  		zone_pcp(zone, cpu) = kmalloc_node(sizeof(struct per_cpu_pageset),
>  					 GFP_KERNEL, node);
>  		if (!zone_pcp(zone, cpu))

I don't think this code works.
pcp is only protected local_irq_save(), not spin lock. it assume
each cpu have different own pcp. but this patch break this assumption.
Now, we can share boot_pageset by multiple cpus.




> _
> 
> Patches currently in -mm which might be from sivanich@sgi.com are
> 
> page_alloc-oops-when-setting-percpu_pagelist_fraction.patch
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
