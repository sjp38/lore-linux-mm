From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH v4 06/40] mm: Demarcate and maintain pageblocks in
 region-order in the zones' freelists
Date: Wed, 23 Oct 2013 11:17:03 +0100
Message-ID: <20131023101703.GC2043@cmpxchg.org>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
 <20130925231454.26184.19783.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130925231454.26184.19783.stgit@srivatsabhat.in.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, Sep 26, 2013 at 04:44:56AM +0530, Srivatsa S. Bhat wrote:
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -517,6 +517,111 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>  	return 0;
>  }
>  
> +static void add_to_freelist(struct page *page, struct free_list *free_list)
> +{
> +	struct list_head *prev_region_list, *lru;
> +	struct mem_region_list *region;
> +	int region_id, i;
> +
> +	lru = &page->lru;
> +	region_id = page_zone_region_id(page);
> +
> +	region = &free_list->mr_list[region_id];
> +	region->nr_free++;
> +
> +	if (region->page_block) {
> +		list_add_tail(lru, region->page_block);
> +		return;
> +	}
> +
> +#ifdef CONFIG_DEBUG_PAGEALLOC
> +	WARN(region->nr_free != 1, "%s: nr_free is not unity\n", __func__);
> +#endif
> +
> +	if (!list_empty(&free_list->list)) {
> +		for (i = region_id - 1; i >= 0; i--) {
> +			if (free_list->mr_list[i].page_block) {
> +				prev_region_list =
> +					free_list->mr_list[i].page_block;
> +				goto out;
> +			}
> +		}
> +	}
> +
> +	/* This is the first region, so add to the head of the list */
> +	prev_region_list = &free_list->list;
> +
> +out:
> +	list_add(lru, prev_region_list);
> +
> +	/* Save pointer to page block of this region */
> +	region->page_block = lru;

"Pageblock" has a different meaning in the allocator already.

The things you string up here are just called pages, regardless of
which order they are in and how many pages they can be split into.
