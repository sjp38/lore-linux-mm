Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id B45B46B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 18:47:37 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id q9so1273112ykb.11
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 15:47:37 -0700 (PDT)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id t12si13420305yhj.63.2014.06.05.15.47.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 15:47:36 -0700 (PDT)
Message-ID: <1402007914.7963.8.camel@misato.fc.hp.com>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the
 DAX page fault handler
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 05 Jun 2014 16:38:34 -0600
In-Reply-To: <1400704507.18128.23.camel@misato.fc.hp.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
	 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
	 <1400704507.18128.23.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Wed, 2014-05-21 at 14:35 -0600, Toshi Kani wrote:
> On Sun, 2014-03-23 at 15:08 -0400, Matthew Wilcox wrote:
>  :
> > +static int do_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> > +			get_block_t get_block)
> > +{
>  :
> > +	error = dax_get_pfn(inode, &bh, &pfn);
> > +	if (error > 0)
> > +		error = vm_insert_mixed(vma, vaddr, pfn);
> > +	mutex_unlock(&mapping->i_mmap_mutex);
> > +
> > +	if (page) {
> > +		delete_from_page_cache(page);
> > +		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
> > +							PAGE_CACHE_SIZE, 0);
> > +		unlock_page(page);
> > +		page_cache_release(page);
> 
> Hi Matthew,
> 
> I am seeing a problem in this code path, where it deletes a page cache
> page mapped to a hole. Sometimes, page->_mapcount is 0, not -1, which
> leads __delete_from_page_cache(), called from delete_from_page_cache(),
> to hit the following BUG_ON.
> 
>   BUG_ON(page_mapped(page))
> 
> I suppose such page has a shared mapping. Does this code need to take
> care of replacing shared mappings in such case?

Hi Matthew,

The following change works in my environment.  What do you think? 

Thanks,
-Toshi

---
 fs/dax.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index 2d6b4bc..046c6d6 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -26,6 +26,7 @@
 #include <linux/sched.h>
 #include <linux/uio.h>
 #include <linux/vmstat.h>
+#include <linux/rmap.h>
 
 int dax_clear_blocks(struct inode *inode, sector_t block, long size)
 {
@@ -385,6 +386,8 @@ static int do_dax_fault(struct vm_area_struct *vma,
struct vm_fault *vmf,
 	mutex_unlock(&mapping->i_mmap_mutex);
 
 	if (page) {
+		if (page_mapped(page))
+			try_to_unmap(page, TTU_UNMAP|TTU_IGNORE_ACCESS);
 		delete_from_page_cache(page);
 		unmap_mapping_range(mapping, vmf->pgoff << PAGE_SHIFT,
 							PAGE_CACHE_SIZE, 0);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
