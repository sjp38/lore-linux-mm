Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 22D9F6B00AB
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 01:34:22 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o296YIcK030171
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Mar 2010 15:34:19 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 966A045DE84
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 15:34:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 667B445DE82
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 15:34:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 402231DB8037
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 15:34:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DFF8C1DB803F
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 15:34:17 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
In-Reply-To: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain>
References: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain>
Message-Id: <20100309153342.7CEE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Mar 2010 15:34:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> __zone_pcp_update() iterates over NR_CPUS instead of limiting the
> access to the possible cpus. This might result in access to
> uninitialized areas as the per cpu allocator only populates the per
> cpu memory for possible cpus.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Looks good.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 
> Index: linux-2.6/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.orig/mm/page_alloc.c
> +++ linux-2.6/mm/page_alloc.c
> @@ -3224,7 +3224,7 @@ static int __zone_pcp_update(void *data)
>  	int cpu;
>  	unsigned long batch = zone_batchsize(zone), flags;
>  
> -	for (cpu = 0; cpu < NR_CPUS; cpu++) {
> +	for_each_possible_cpu(cpu) {
>  		struct per_cpu_pageset *pset;
>  		struct per_cpu_pages *pcp;
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
