Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <520911C5.5060506@intel.com>
Date: Mon, 12 Aug 2013 09:48:05 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 0/4] mm: reclaim zbud pages on migration and compaction
References: <1376043740-10576-1-git-send-email-k.kozlowski@samsung.com> <20130812022535.GA18832@bbox>
In-Reply-To: <20130812022535.GA18832@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, guz.fnst@cn.fujitsu.com, bcrl@kvack.org

On 08/11/2013 07:25 PM, Minchan Kim wrote:
> +int set_pinned_page(struct pin_page_owner *owner,
> +			struct page *page, void *private)
> +{
> +	struct pin_page_info *pinfo = kmalloc(sizeof(pinfo), GFP_KERNEL);
> +
> +	INIT_HLIST_NODE(&pinfo->hlist);
> +	pinfo->owner = owner;
> +
> +	pinfo->pfn = page_to_pfn(page);
> +	pinfo->private = private;
> +	
> +	spin_lock(&hash_lock);
> +	hash_add(pin_page_hash, &pinfo->hlist, pinfo->pfn);
> +	spin_unlock(&hash_lock);
> +
> +	SetPinnedPage(page);
> +	return 0;
> +};

I definitely agree that we're getting to the point where we need to look
at this more generically.  We've got at least four use-cases that have a
need for deterministically relocating memory:

1. CMA (many sub use cases)
2. Memory hot-remove
3. Memory power management
4. Runtime hugetlb-GB page allocations

Whatever we do, it _should_ be good enough to largely let us replace
PG_slab with this new bit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
