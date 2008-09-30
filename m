Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8UFlxTf014786
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 11:47:59 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8UFltNl274540
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 11:47:55 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8UFltlr021177
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 11:47:55 -0400
Subject: Re: [PATCH] properly reserve in bootmem the lmb reserved regions
	that cross numa nodes
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <48E23D6C.4030406@linux.vnet.ibm.com>
References: <48E23D6C.4030406@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Tue, 30 Sep 2008 10:47:55 -0500
Message-Id: <1222789675.13978.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: linuxppc-dev <linuxppc-dev@ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Adam Litke <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This seems like the right approach to me.  I have pointed out a few
stylistic issues below.

On Tue, 2008-09-30 at 09:53 -0500, Jon Tollefson wrote:
<snip>
> +	/* Mark reserved regions */
> +	for (i = 0; i < lmb.reserved.cnt; i++) {
> +		unsigned long physbase = lmb.reserved.region[i].base;
> +		unsigned long size = lmb.reserved.region[i].size;
> +		unsigned long start_pfn = physbase >> PAGE_SHIFT;
> +		unsigned long end_pfn = ((physbase+size-1) >> PAGE_SHIFT);

CodingStyle dictates that this should be:
unsigned long end_pfn = ((physbase + size - 1) >> PAGE_SHIFT);

<snip>

> +/**
> + * get_node_active_region - Return active region containing start_pfn
> + * @start_pfn The page to return the region for.
> + *
> + * It will return NULL if active region is not found.
> + */
> +struct node_active_region *get_node_active_region(
> +							unsigned long start_pfn)

Bad style.  I think the convention would be to write it like this:

struct node_active_region *
get_node_active_region(unsigned long start_pfn)

> +{
> +	int i;
> +	for (i = 0; i < nr_nodemap_entries; i++) {
> +		unsigned long node_start_pfn = early_node_map[i].start_pfn;
> +		unsigned long node_end_pfn = early_node_map[i].end_pfn;
> +
> +		if (node_start_pfn <= start_pfn && node_end_pfn > start_pfn)
> +			return &early_node_map[i];
> +	}
> +	return NULL;
> +}

Since this is using the early_node_map[], should we mark the function
__mminit?  

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
