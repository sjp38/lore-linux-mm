Date: Mon, 25 Feb 2008 15:40:51 +0900 (JST)
Message-Id: <20080225.154051.90170566.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [6/7] radix-tree
 based page cgroup
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080225121744.a90704fb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225121744.a90704fb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, yamamoto@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I looked into the code a bit and I have some comments.

> Each radix-tree entry contains base address of array of page_cgroup.
> As sparsemem does, this registered base address is subtracted by base_pfn
> for that entry. See sparsemem's logic if unsure.
> 
> Signed-off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

  (snip)

> +#define PCGRP_SHIFT	(8)
> +#define PCGRP_SIZE	(1 << PCGRP_SHIFT)

I wonder where the value of PCGRP_SHIFT comes from.

  (snip)

> +static struct page_cgroup *alloc_init_page_cgroup(unsigned long pfn, int nid,
> +					gfp_t mask)
> +{
> +	int size, order;
> +	struct page *page;
> +
> +	size = PCGRP_SIZE * sizeof(struct page_cgroup);
> +	order = get_order(PAGE_ALIGN(size));

I wonder if this alignment will waste some memory.

> +	page = alloc_pages_node(nid, mask, order);

I think you should make "order" be 0 not to cause extra memory pressure
if possible.

> +	if (!page)
> +		return NULL;
> +
> +	init_page_cgroup(page_address(page), pfn);
> +
> +	return page_address(page);
> +}


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
