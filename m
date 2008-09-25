From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm: pageable memory allocator (for DRM-GEM?)
Date: Thu, 25 Sep 2008 17:45:13 +0900
Message-ID: <20080925174513.fd44bc08.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080923091017.GB29718@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753340AbYIYIkD@vger.kernel.org>
In-Reply-To: <20080923091017.GB29718@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Nick Piggin <npiggin@suse.de>
Cc: keith.packard@intel.com, eric@anholt.net, hugh@veritas.com, hch@infradead.org, airlied@linux.ie, jbarnes@virtuousgeek.org, thomas@tungstengraphics.com, dri-devel@lists.sourceforge.net, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Tue, 23 Sep 2008 11:10:17 +0200
Nick Piggin <npiggin@suse.de> wrote:

> +void *pageable_vmap_object(pgobj_t *object, unsigned long start, unsigned long end)
> +{
> +	struct file *filp = (struct file *)object;
> +	struct address_space *mapping = filp->f_dentry->d_inode->i_mapping;
> +	unsigned int offset = start & ~PAGE_CACHE_MASK;
> +	pgoff_t first, last, i;
> +	struct page **pages;
> +	int nr;
> +	void *ret;
> +
> +	BUG_ON(start >= end);
> +
> +	first = start / PAGE_SIZE;
> +	last = DIV_ROUND_UP(end, PAGE_SIZE);
> +	nr = last - first;
> +
> +#ifndef CONFIG_HIGHMEM
> +	if (nr == 1) {
> +		struct page *page;
> +
> +		rcu_read_lock();
> +		page = radix_tree_lookup(&mapping->page_tree, first);
> +		rcu_read_unlock();
> +		BUG_ON(!page);
> +		BUG_ON(page_count(page) < 2);
> +
> +		ret = page_address(page);
> +
> +		goto out;
> +	}
> +#endif
> +
> +	pages = kmalloc(sizeof(struct page *) * nr, GFP_KERNEL);
> +	if (!pages)
> +		return NULL;
> +
> +	for (i = first; i < last; i++) {
> +		struct page *page;
> +
> +		rcu_read_lock();
> +		page = radix_tree_lookup(&mapping->page_tree, i);
> +		rcu_read_unlock();
> +		BUG_ON(!page);
> +		BUG_ON(page_count(page) < 2);
> +
> +		pages[i] = page;
> +	}
> +
> +	ret = vmap(pages, nr, VM_MAP, PAGE_KERNEL);
> +	kfree(pages);
> +	if (!ret)
> +		return NULL;
> +
> +out:
> +	return ret + offset;
> +}
> +
> +void pageable_vunmap_object(pgobj_t *object, void *ptr, unsigned long start, unsigned long end)
> +{
> +#ifndef CONFIG_HIGHMEM
> +	pgoff_t first, last;
> +	int nr;
> +
> +	BUG_ON(start >= end);
> +
> +	first = start / PAGE_SIZE;
> +	last = DIV_ROUND_UP(end, PAGE_SIZE);
> +	nr = last - first;
> +	if (nr == 1)
> +		return;
> +#endif
> +
> +	vunmap((void *)((unsigned long)ptr & PAGE_CACHE_MASK));
> +}
> +

Some questions..

 - could you use GFP_HIGHUSER rather than GFP_HIGHUSER_MOVABLE ?
   I think setting mapping_gfp_mask() (address_space->flags) to appropriate
   value is enough.

 - Can we mlock pages while it's vmapped ? (or Reserve and remove from LRU)
   Then, new split-lru can ignore these pages while there are mapped. over-killing ?

 - Doesn't we need to increase page->mapcount ?

 - memory resource contorller should account these pages ?
   (Maybe this is question to myself....)

Thanks,
-Kame
