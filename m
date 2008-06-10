Date: Tue, 10 Jun 2008 16:09:20 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-ID: <20080610160920.74a0da14@cuia.bos.redhat.com>
In-Reply-To: <20080606180506.081f686a.akpm@linux-foundation.org>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.291472052@redhat.com>
	<20080606180506.081f686a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jun 2008 18:05:06 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > +config NORECLAIM_LRU
> > +	bool "Add LRU list to track non-reclaimable pages (EXPERIMENTAL, 64BIT only)"
> > +	depends on EXPERIMENTAL && 64BIT
> > +	help
> > +	  Supports tracking of non-reclaimable pages off the [in]active lists
> > +	  to avoid excessive reclaim overhead on large memory systems.  Pages
> > +	  may be non-reclaimable because:  they are locked into memory, they
> > +	  are anonymous pages for which no swap space exists, or they are anon
> > +	  pages that are expensive to unmap [long anon_vma "related vma" list.]
> 
> Aunt Tillie might be struggling with some of that.

I have now Aunt Tillified the description:

+++ linux-2.6.26-rc5-mm2/mm/Kconfig     2008-06-10 14:56:19.000000000 -0400
@@ -205,3 +205,13 @@ config NR_QUICK
 config VIRT_TO_BUS
        def_bool y
        depends on !ARCH_NO_VIRT_TO_BUS
+
+config UNEVICTABLE_LRU
+       bool "Add LRU list to track non-evictable pages"
+       default y
+       help
+         Keeps unevictable pages off of the active and inactive pageout
+         lists, so kswapd will not waste CPU time or have its balancing
+         algorithms thrown off by scanning these pages.  Selecting this
+         will use one page flag and increase the code size a little,
+         say Y unless you know what you are doing.
 
> Can we think of a new term which uniquely describes this new concept
> and use that, rather than flogging the old horse?

I have also switched to "unevictable".

> > +/**
> > + * add_page_to_noreclaim_list
> > + * @page:  the page to be added to the noreclaim list
> > + *
> > + * Add page directly to its zone's noreclaim list.  To avoid races with
> > + * tasks that might be making the page reclaimble while it's not on the
> > + * lru, we want to add the page while it's locked or otherwise "invisible"
> > + * to other tasks.  This is difficult to do when using the pagevec cache,
> > + * so bypass that.
> > + */
> 
> How does a task "make a page reclaimable"?  munlock()?  fsync()? 
> exit()?
> 
> Choice of terminology matters...

I have added a linuxdoc function description here and
amended the comment to specify the ways in which a task
can make a page evictable.

> > +		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
> 
> If this ever triggers, you'll wish that it had been coded with two
> separate assertions.

Good catch.  I separated these.
 
> > +/**
> > + * putback_lru_page
> > + * @page to be put back to appropriate lru list

> The kerneldoc function description is missing.

Added this one, as well as a few others that were missing.
 
> > +	} else if (page_reclaimable(page, NULL)) {
> > +		/*
> > +		 * For reclaimable pages, we can use the cache.
> > +		 * In event of a race, worst case is we end up with a
> > +		 * non-reclaimable page on [in]active list.
> > +		 * We know how to handle that.
> > +		 */
> > +		lru += page_file_cache(page);
> > +		lru_cache_add_lru(page, lru);
> > +		mem_cgroup_move_lists(page, lru);

> <stares for a while>
> 
> <penny drops>
> 
> So THAT'S what the magical "return 2" is doing in page_file_cache()!
> 
> <looks>
> 
> OK, after all the patches are applied, the "2" becomes LRU_FILE and the
> enumeration of `enum lru_list' reflects that.

In most places I have turned this into a call to page_lru(page).
 
> > +static inline void cull_nonreclaimable_page(struct page *page)

> Did you check whether all these inlined functions really should have
> been inlined?  Even ones like this are probably too large.

Turned this into just a "static void" and renamed it
to cull_unevictable_page.
 
> > +	/*
> > +	 * Non-reclaimable pages shouldn't make it onto either the active
> > +	 * nor the inactive list. However, when doing lumpy reclaim of
> > +	 * higher order pages we can still run into them.
> 
> I guess that something along the lines of "when this function is being
> called for lumpy reclaim we can still .." would be clearer.

+       /*
+        * When this function is being called for lumpy reclaim, we
+        * initially look into all LRU pages, active, inactive and
+        * unreclaimable; only give shrink_page_list evictable pages.
+        */
+       if (PageUnevictable(page))
+               return ret;

... on to the next patch!

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
