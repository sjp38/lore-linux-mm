Subject: Re: [RFC][-mm PATCH 6/8] Memory controller add per container LRU and
 reclaim (v3)
In-Reply-To: Your message of "Fri, 20 Jul 2007 13:55:04 +0530"
	<20070720082504.20752.62858.sendpatchset@balbir-laptop>
References: <20070720082504.20752.62858.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20070724115100.B7A9B1BF959@siro.lan>
Date: Tue, 24 Jul 2007 20:51:00 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, containers@lists.osdl.org, menage@google.com, haveblue@us.ibm.com, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, ebiederm@xmission.com
List-ID: <linux-mm.kvack.org>

hi,

> +unsigned long mem_container_isolate_pages(unsigned long nr_to_scan,
> +					struct list_head *dst,
> +					unsigned long *scanned, int order,
> +					int mode, struct zone *z,
> +					struct mem_container *mem_cont,
> +					int active)
> +{
> +	unsigned long nr_taken = 0;
> +	struct page *page;
> +	unsigned long scan;
> +	LIST_HEAD(mp_list);
> +	struct list_head *src;
> +	struct meta_page *mp;
> +
> +	if (active)
> +		src = &mem_cont->active_list;
> +	else
> +		src = &mem_cont->inactive_list;
> +
> +	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
> +		mp = list_entry(src->prev, struct meta_page, lru);
> +		page = mp->page;
> +

- is it safe to pick the lists without mem_cont->lru_lock held?

- what prevents mem_container_uncharge from freeing this meta_page
 behind us?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
