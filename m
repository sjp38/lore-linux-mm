Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RLNg4m025095
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:23:42 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RLNe7u052516
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:23:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RLNd9s011444
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:23:40 -0600
Subject: Re: [patch 11/23] hugetlb: support larger than MAX_ORDER
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143453.269965000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143453.269965000@nick.local0.net>
Content-Type: text/plain
Date: Tue, 27 May 2008 16:23:38 -0500
Message-Id: <1211923418.12036.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> @@ -549,6 +560,51 @@ static struct page *alloc_huge_page(stru
>  	return page;
>  }
> 
> +static __initdata LIST_HEAD(huge_boot_pages);
> +
> +struct huge_bootmem_page {
> +	struct list_head list;
> +	struct hstate *hstate;
> +};
> +
> +static int __init alloc_bootmem_huge_page(struct hstate *h)
> +{
> +	struct huge_bootmem_page *m;
> +	int nr_nodes = nodes_weight(node_online_map);
> +
> +	while (nr_nodes) {
> +		m = __alloc_bootmem_node_nopanic(NODE_DATA(h->hugetlb_next_nid),
> +					huge_page_size(h), huge_page_size(h),
> +					0);
> +		if (m)
> +			goto found;
> +		hstate_next_node(h);
> +		nr_nodes--;
> +	}
> +	return 0;
> +
> +found:
> +	BUG_ON((unsigned long)virt_to_phys(m) & (huge_page_size(h) - 1));
> +	/* Put them into a private list first because mem_map is not up yet */
> +	list_add(&m->list, &huge_boot_pages);
> +	m->hstate = h;
> +	return 1;
> +}

At first I was pretty confused by how you are directly using the
newly-allocated bootmem page to create a temporary list until the mem
map comes up.  Clever.  I bet I would have understood right away if it
were written like the following:

void *vaddr;
struct huge_bootmem_page *m;

vaddr = __alloc_bootmem_node_nopanic(...);
if (vaddr) {
	/*
	 * Use the beginning of this block to store some temporary
	 * meta-data until the mem_map comes up.
	 */
	m = (huge_bootmem_page *) vaddr;
	goto found;
}

If you don't like that level of verbosity, could we add a comment just
to make it immediately clear to the reader?

> +/* Put bootmem huge pages into the standard lists after mem_map is up */
> +static void __init gather_bootmem_prealloc(void)
> +{
> +	struct huge_bootmem_page *m;
> +	list_for_each_entry (m, &huge_boot_pages, list) {
> +		struct page *page = virt_to_page(m);
> +		struct hstate *h = m->hstate;
> +		__ClearPageReserved(page);
> +		WARN_ON(page_count(page) != 1);
> +		prep_compound_page(page, h->order);
> +		prep_new_huge_page(h, page, page_to_nid(page));
> +	}
> +}
> +
>  static void __init hugetlb_init_one_hstate(struct hstate *h)
>  {
>  	unsigned long i;

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
