Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id CB8096B0006
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 18:18:16 -0500 (EST)
Date: Thu, 17 Jan 2013 15:18:15 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2]swap: make each swap partition have one
 address_space
Message-Id: <20130117151815.8fdca4d0.akpm@linux-foundation.org>
In-Reply-To: <20121210012439.GA18570@kernel.org>
References: <20121210012439.GA18570@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org

On Mon, 10 Dec 2012 09:24:39 +0800
Shaohua Li <shli@kernel.org> wrote:

> When I use several fast SSD to do swap, swapper_space.tree_lock is heavily
> contended. This makes each swap partition have one address_space to reduce the
> lock contention. There is an array of address_space for swap. The swap entry
> type is the index to the array.
> 
> In my test with 3 SSD, this increases the swapout throughput 20%.
> 
> There are some code here which looks unnecessary, for example, moving some code
> from swapops.h to swap.h and soem changes in audit_tree.c. Those are to make
> the code compile.
> 

Although it appears to be pretty mechanical, the patch is rather hard
to read due to these irrelevancies.  Can it be split up a bit?  Surely
the audit_tree rename can be done in a preparatory change.

The patches have bitrotted and there's a build error in memcontrol.c
(s/entry/*entry).

Refresh, retest and resend, please?

> --- linux.orig/include/linux/mm.h	2012-12-10 08:51:21.809919763 +0800
> +++ linux/include/linux/mm.h	2012-12-10 09:02:45.029330611 +0800
>
> ...
>
> @@ -788,15 +789,17 @@ void page_address_init(void);
>  #define PAGE_MAPPING_KSM	2
>  #define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
>  
> -extern struct address_space swapper_space;
>  static inline struct address_space *page_mapping(struct page *page)
>  {
>  	struct address_space *mapping = page->mapping;
>  
>  	VM_BUG_ON(PageSlab(page));
> -	if (unlikely(PageSwapCache(page)))
> -		mapping = &swapper_space;
> -	else if ((unsigned long)mapping & PAGE_MAPPING_ANON)
> +	if (unlikely(PageSwapCache(page))) {
> +		swp_entry_t entry;
> +
> +		entry.val = page_private(page);
> +		mapping = swap_address_space(entry);
> +	} else if ((unsigned long)mapping & PAGE_MAPPING_ANON)
>  		mapping = NULL;
>  	return mapping;
>  }

I think that's kinda the last straw for page_mapping().  A quick test
here indicates that uninlining page_mapping() saves half a k of text
from mm/built-in.o.  Wanna include this as #2 in the patch series, please?

--- a/mm/util.c~a
+++ a/mm/util.c
@@ -382,6 +382,21 @@ unsigned long vm_mmap(struct file *file,
 }
 EXPORT_SYMBOL(vm_mmap);
 
+struct address_space *page_mapping(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+
+	VM_BUG_ON(PageSlab(page));
+	if (unlikely(PageSwapCache(page))) {
+		swp_entry_t entry;
+
+		entry.val = page_private(page);
+		mapping = swap_address_space(entry);
+	} else if ((unsigned long)mapping & PAGE_MAPPING_ANON)
+		mapping = NULL;
+	return mapping;
+}
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
diff -puN include/linux/mm.h~a include/linux/mm.h
--- a/include/linux/mm.h~a
+++ a/include/linux/mm.h
@@ -819,20 +819,7 @@ void page_address_init(void);
 #define PAGE_MAPPING_KSM	2
 #define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
 
-static inline struct address_space *page_mapping(struct page *page)
-{
-	struct address_space *mapping = page->mapping;
-
-	VM_BUG_ON(PageSlab(page));
-	if (unlikely(PageSwapCache(page))) {
-		swp_entry_t entry;
-
-		entry.val = page_private(page);
-		mapping = swap_address_space(entry);
-	} else if ((unsigned long)mapping & PAGE_MAPPING_ANON)
-		mapping = NULL;
-	return mapping;
-}
+extern struct address_space *page_mapping(struct page *page);
 
 /* Neutral page->mapping pointer to address_space or anon_vma or other */
 static inline void *page_rmapping(struct page *page)

>
> ...
>
>  void show_swap_cache_info(void)
>  {
> -	printk("%lu pages in swap cache\n", total_swapcache_pages);
> +	printk("%lu pages in swap cache\n", total_swapcache_pages());
>  	printk("Swap cache stats: add %lu, delete %lu, find %lu/%lu\n",
>  		swap_cache_info.add_total, swap_cache_info.del_total,
>  		swap_cache_info.find_success, swap_cache_info.find_total);
> @@ -76,17 +86,18 @@ static int __add_to_swap_cache(struct pa
>  	VM_BUG_ON(!PageSwapBacked(page));
>  
>  	page_cache_get(page);
> -	SetPageSwapCache(page);
>  	set_page_private(page, entry.val);
> +	SetPageSwapCache(page);
>  
> -	spin_lock_irq(&swapper_space.tree_lock);
> -	error = radix_tree_insert(&swapper_space.page_tree, entry.val, page);
> +	spin_lock_irq(&swap_address_space(entry)->tree_lock);
> +	error = radix_tree_insert(&swap_address_space(entry)->page_tree,
> +					entry.val, page);
>  	if (likely(!error)) {
> -		total_swapcache_pages++;
> +		swap_address_space(entry)->nrpages++;
>  		__inc_zone_page_state(page, NR_FILE_PAGES);
>  		INC_CACHE_INFO(add_total);
>  	}
> -	spin_unlock_irq(&swapper_space.tree_lock);
> +	spin_unlock_irq(&swap_address_space(entry)->tree_lock);

Four separate evaluations of swap_address_space(entry).  The compiler
*should* save the result in a temporary and avoid this, but please
check this.  If it doesn't, do it manually.  Here and in several other
places.

>  	if (unlikely(error)) {
>  		/*
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
