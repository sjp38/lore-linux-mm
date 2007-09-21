Date: Fri, 21 Sep 2007 13:48:28 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH] page->mapping clarification [1/3] base functions
Message-ID: <20070921134828.45ca967e@twins>
In-Reply-To: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, ricknu-0@student.ltu.se
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007 16:43:08 +0900 KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:

> A clarification of page <-> fs interface (page cache).
> 
> At first, each FS has to access to struct page->mapping directly.
> But it's not just pointer. (we use special 1bit enconding for anon.)
> 
> Although there is historical consensus that page->mapping points to its inode's
> address space, I think adding some neat helper functon is not bad.
> 
> This patch adds page-cache.h which containes page<->address_space<->inode
> function which is required (used) by subsystems.
> 
> Following functions are added
> 
>  * page_mapping_cache() ... returns address space if a page is page cache
>  * page_mapping_anon()  ... returns anon_vma if a page is anonymous page.
>  * page_is_pagecache()  ... returns true if a page is page-cache.
>  * page_inode()         ... returns inode which a page-cache belongs to.
>  * is_page_consistent() ... returns true if a page is still valid page cache 
> 
> Followings are moved 
>  * page_mapping()       ... returns swapper_space or address_space a page is on.
> 			    (from mm.h)
>  * page_index()         ... returns position of a page in its inode
> 			    (from mm.h)
>  * remove_mapping()     ... a safe routine to remove page->mapping from page.
> 			    (from swap.h)

I have two other functions that might want integration with this scheme:

  page_file_mapping()     ... returns backing address space
  page_file_index()       ... returns the index therein

They are identical to page_mapping_cache() and page_index() for
page cache pages, but they also work on swap cache pages.

That is, for swapcache pages they return:

page_file_mapping:
  page_swap_info(page)->swap_file->f_mapping

page_file_index:
  swp_offset((swp_offset_t)page_private(page))

When a filesystem uses these functions instead of page->mapping and
page->index, it allows passing swap cache pages into the regular
filesystem read/write paths.

This is useful for things like swap over NFS, where swap is backed by a
swapfile on a 'regular' filesystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
