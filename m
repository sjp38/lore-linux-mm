Message-ID: <379979481.69222@ustc.edu.cn>
Date: Thu, 24 May 2007 12:04:53 +0800
From: Fengguang Wu <fengguang.wu@gmail.com>
Subject: Re: [RFC 10/16] Variable Order Page Cache: Readahead fixups
Message-ID: <20070524040453.GA10662@mail.ustc.edu.cn>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com> <20070423064937.5458.59638.sendpatchset@schroedinger.engr.sgi.com> <20070425113613.GF19942@skynet.ie> <Pine.LNX.4.64.0704250854420.24530@schroedinger.engr.sgi.com> <379744113.16390@ustc.edu.cn> <Pine.LNX.4.64.0705210947450.25871@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705210947450.25871@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Dave Hansen <hansendc@us.ibm.com>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

On Mon, May 21, 2007 at 09:53:18AM -0700, Christoph Lameter wrote:
> On Mon, 21 May 2007, Fengguang Wu wrote:
> 
> > > I am not sure how to solve that one yet. With the above fix we stay at the 
> > > 2M sized readahead. As the compound order increases so the number of pages
> > > is reduced. We could keep the number of pages constant but then very high
> > > orders may cause a excessive use of memory for readahead.
> > 
> > Do we need to support very high orders(i.e. >2MB)?
> 
> Yes actually we could potentially be using up to 1 TB page size on our 
> new machines that can support several petabytes of RAM. But the read 
> ahead is likely irrelevant in that case. And this is an extreme case that 
> will be rarely used but a customer has required that we will be able to 
> handle such a situation. I think 2-4 megabytes may be more typical.

So we do not want to enforce a maximum page size.
The patch is updated to only decrease the readahead pages on increased
page size, until it falls to 1. If page size continues to increase,
the I/O size will increase anyway.

===================================================================
---
 include/linux/mm.h |    2 +-
 mm/fadvise.c       |    4 ++--
 mm/filemap.c       |    5 ++---
 mm/madvise.c       |    2 +-
 mm/readahead.c     |   22 ++++++++++++++--------
 5 files changed, 20 insertions(+), 15 deletions(-)

--- linux-2.6.22-rc1-mm1.orig/mm/fadvise.c
+++ linux-2.6.22-rc1-mm1/mm/fadvise.c
@@ -86,10 +86,10 @@ asmlinkage long sys_fadvise64_64(int fd,
 		nrpages = end_index - start_index + 1;
 		if (!nrpages)
 			nrpages = ~0UL;
-		
+
 		ret = force_page_cache_readahead(mapping, file,
 				start_index,
-				max_sane_readahead(nrpages));
+				nrpages);
 		if (ret > 0)
 			ret = 0;
 		break;
--- linux-2.6.22-rc1-mm1.orig/mm/filemap.c
+++ linux-2.6.22-rc1-mm1/mm/filemap.c
@@ -1287,8 +1287,7 @@ do_readahead(struct address_space *mappi
 	if (!mapping || !mapping->a_ops || !mapping->a_ops->readpage)
 		return -EINVAL;
 
-	force_page_cache_readahead(mapping, filp, index,
-					max_sane_readahead(nr));
+	force_page_cache_readahead(mapping, filp, index, nr);
 	return 0;
 }
 
@@ -1426,7 +1425,7 @@ retry_find:
 			count_vm_event(PGMAJFAULT);
 		}
 		did_readaround = 1;
-		ra_pages = max_sane_readahead(file->f_ra.ra_pages);
+		ra_pages = file->f_ra.ra_pages;
 		if (ra_pages) {
 			pgoff_t start = 0;
 
--- linux-2.6.22-rc1-mm1.orig/mm/madvise.c
+++ linux-2.6.22-rc1-mm1/mm/madvise.c
@@ -124,7 +124,7 @@ static long madvise_willneed(struct vm_a
 	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
 	force_page_cache_readahead(file->f_mapping,
-			file, start, max_sane_readahead(end - start));
+			file, start, end - start);
 	return 0;
 }
 
--- linux-2.6.22-rc1-mm1.orig/mm/readahead.c
+++ linux-2.6.22-rc1-mm1/mm/readahead.c
@@ -44,7 +44,8 @@ EXPORT_SYMBOL_GPL(default_backing_dev_in
 void
 file_ra_state_init(struct file_ra_state *ra, struct address_space *mapping)
 {
-	ra->ra_pages = mapping->backing_dev_info->ra_pages;
+	ra->ra_pages = DIV_ROUND_UP(mapping->backing_dev_info->ra_pages,
+				    page_cache_size(mapping));
 	ra->prev_index = -1;
 }
 EXPORT_SYMBOL_GPL(file_ra_state_init);
@@ -84,7 +85,7 @@ int read_cache_pages(struct address_spac
 			put_pages_list(pages);
 			break;
 		}
-		task_io_account_read(PAGE_CACHE_SIZE);
+		task_io_account_read(page_cache_size(mapping));
 	}
 	pagevec_lru_add(&lru_pvec);
 	return ret;
@@ -151,7 +152,7 @@ __do_page_cache_readahead(struct address
 	if (isize == 0)
 		goto out;
 
-	end_index = ((isize - 1) >> PAGE_CACHE_SHIFT);
+ 	end_index = page_cache_index(mapping, isize - 1);
 
 	/*
 	 * Preallocate as many pages as we will need.
@@ -204,10 +205,12 @@ int force_page_cache_readahead(struct ad
 	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
 		return -EINVAL;
 
+	nr_to_read = max_sane_readahead(nr_to_read, mapping_order(mapping));
 	while (nr_to_read) {
 		int err;
 
-		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_CACHE_SIZE;
+		unsigned long this_chunk = DIV_ROUND_UP(2 * 1024 * 1024,
+						page_cache_size(mapping));
 
 		if (this_chunk > nr_to_read)
 			this_chunk = nr_to_read;
@@ -237,17 +240,20 @@ int do_page_cache_readahead(struct addre
 	if (bdi_read_congested(mapping->backing_dev_info))
 		return -1;
 
+	nr_to_read = max_sane_readahead(nr_to_read, mapping_order(mapping));
 	return __do_page_cache_readahead(mapping, filp, offset, nr_to_read, 0);
 }
 
 /*
- * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
+ * Given a desired number of page order readahead pages, return a
  * sensible upper limit.
  */
-unsigned long max_sane_readahead(unsigned long nr)
+unsigned long max_sane_readahead(unsigned long nr, int order)
 {
-	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE)
-		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
+	unsigned long base_pages = node_page_state(numa_node_id(), NR_INACTIVE)
+			+ node_page_state(numa_node_id(), NR_FREE_PAGES);
+
+	return min(nr, (base_pages / 2) >> order);
 }
 
 /*
--- linux-2.6.22-rc1-mm1.orig/include/linux/mm.h
+++ linux-2.6.22-rc1-mm1/include/linux/mm.h
@@ -1163,7 +1163,7 @@ unsigned long page_cache_readahead_ondem
 			  struct page *page,
 			  pgoff_t offset,
 			  unsigned long size);
-unsigned long max_sane_readahead(unsigned long nr);
+unsigned long max_sane_readahead(unsigned long nr, int order);
 
 /* Do stack extension */
 extern int expand_stack(struct vm_area_struct *vma, unsigned long address);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
