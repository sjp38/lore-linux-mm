Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 54AB06B00CE
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 15:23:32 -0500 (EST)
Date: Tue, 9 Mar 2010 12:22:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: Do not iterate over NR_CPUS in __zone_pcp_update()
Message-Id: <20100309122253.3f3d4a53.akpm@linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain>
References: <alpine.LFD.2.00.1003081018070.22855@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Mar 2010 10:21:04 +0100 (CET)
Thomas Gleixner <tglx@linutronix.de> wrote:

> __zone_pcp_update() iterates over NR_CPUS instead of limiting the
> access to the possible cpus. This might result in access to
> uninitialized areas as the per cpu allocator only populates the per
> cpu memory for possible cpus.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
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

I'm having trouble working out whether we want to backport this into
2.6.33.x or earlier.  Help?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
