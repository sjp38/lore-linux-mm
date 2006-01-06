Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k06JLcbR007973
	for <linux-mm@kvack.org>; Fri, 6 Jan 2006 14:21:38 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k06JNcA8172148
	for <linux-mm@kvack.org>; Fri, 6 Jan 2006 12:23:38 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k06JLbAa006949
	for <linux-mm@kvack.org>; Fri, 6 Jan 2006 12:21:38 -0700
Subject: Re: [PATCH] Simple memory hot-add for ia64.
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060106114249.5649.Y-GOTO@jp.fujitsu.com>
References: <20060106114249.5649.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 06 Jan 2006 11:21:36 -0800
Message-Id: <1136575296.8189.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>, Mike Kravetz <kravetz@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-01-06 at 11:50 +0900, Yasunori Goto wrote:
> Fortunately, 2.6.15 includes memory hot-add function for i386 and ppc.
> So, I made a patch for ia64.
> This doesn't make new pgdat. All of new memory will belong to
> node 0 by this patch. But this is simplest first step and best start for
> future work.

It does look quite simple.  Nice work.

> +#ifdef CONFIG_MEMORY_HOTPLUG
> +void online_page(struct page *page)
> +{
> +	ClearPageReserved(page);
> +	set_page_count(page, 1);
> +	__free_page(page);
> +	totalram_pages++;
> +	num_physpages++;
> +}

You're the first one to get one of these in for an alternate
architecture.  We'll need to keep an eye out so that one of these
doesn't pop up on each of the 64-bit arches with no highmem as we add
support.  But, this should be just fine for now. 

> +int add_memory(u64 start, u64 size)
> +{
> +	pg_data_t *pgdat;
> +	struct zone *zone;
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	int ret;
> +
> +	pgdat = NODE_DATA(0);
> +
> +	zone = pgdat->node_zones + ZONE_NORMAL;
> +	ret = __add_pages(zone, start_pfn, nr_pages);
> +
> +	if (ret)
> +		printk("%s: Problem encountered in __add_pages() as ret=%d\n", __func__,  ret);

For some reason, I thought we were officially supposed to use
__FUNCTION__ for stuff like this.  However, I am usually lazy in my
debugging patches and use __func__.  I'm a bad example.

This also looks a bit past 80 columns.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
