Date: Tue, 10 Feb 2004 08:22:35 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] skip offline CPUs in show_free_areas
Message-Id: <20040210082235.3ccf817d.akpm@osdl.org>
In-Reply-To: <20040210132301.GA11045@lst.de>
References: <20040210132301.GA11045@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig <hch@lst.de> wrote:
>
> Without this ouput on a box with 8cpus and NR_CPUS=64 looks rather
>  strange.
> 
> 
>  Index: mm/page_alloc.c
>  ===================================================================
>  RCS file: /home/cvs/linux/mm/page_alloc.c,v
>  retrieving revision 1.113
>  diff -u -p -r1.113 page_alloc.c
>  --- mm/page_alloc.c	10 Jan 2004 04:59:57 -0000	1.113
>  +++ mm/page_alloc.c	10 Feb 2004 13:17:43 -0000
>  @@ -972,7 +972,13 @@ void show_free_areas(void)
>   			printk("\n");
>   
>   		for (cpu = 0; cpu < NR_CPUS; ++cpu) {
>  -			struct per_cpu_pageset *pageset = zone->pageset + cpu;
>  +			struct per_cpu_pageset *pageset;
>  +	
>  +			if (!cpu_online(cpu))
>  +				continue;

Thanks.  I think I'll change that to cpu_possible().  Because there might
still be pages there from the time when that cpu used to be online. 
Otherwise we wouldn't notice leaks due to cpu downing.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
