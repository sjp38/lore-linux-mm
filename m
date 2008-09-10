Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8AML6iY022465
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 18:21:06 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8AML5RB122062
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 16:21:05 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8AML4wG019470
	for <linux-mm@kvack.org>; Wed, 10 Sep 2008 16:21:05 -0600
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct
	page
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080910012048.GA32752@balbir.in.ibm.com>
References: <48C66AF8.5070505@linux.vnet.ibm.com>
	 <20080901161927.a1fe5afc.kamezawa.hiroyu@jp.fujitsu.com>
	 <200809091358.28350.nickpiggin@yahoo.com.au>
	 <20080909135317.cbff4871.kamezawa.hiroyu@jp.fujitsu.com>
	 <200809091500.10619.nickpiggin@yahoo.com.au>
	 <20080909141244.721dfd39.kamezawa.hiroyu@jp.fujitsu.com>
	 <30229398.1220963412858.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080910012048.GA32752@balbir.in.ibm.com>
Content-Type: text/plain
Date: Wed, 10 Sep 2008 15:21:00 -0700
Message-Id: <1221085260.6781.69.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-09 at 18:20 -0700, Balbir Singh wrote:
> +       start = pgdat->node_start_pfn;
> +       end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
> +       size = (end - start) * sizeof(struct page_cgroup);
> +       printk("Allocating %lu bytes for node %d\n", size, n);
> +       pcg_map[n] = alloc_bootmem_node(pgdat, size);
> +       /*
> +        * We can do smoother recovery
> +        */
> +       BUG_ON(!pcg_map[n]);
> +       return 0;
>  }

This will really suck for sparse memory machines.  Imagine a machine
with 1GB of memory at 0x0 and another 1GB of memory at 1TB up in the
address space.

You also need to consider how it works with memory hotplug and how
you're going to grow it at runtime.

Oh, and doesn't alloc_bootmem() panic() if it fails internally anyway?

I need to look at your other approach. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
