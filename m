Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C761E6B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 00:32:19 -0400 (EDT)
Date: Thu, 4 Jun 2009 12:32:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [12/16] Refactor truncate to allow direct truncating
	of page
Message-ID: <20090604043208.GB15682@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184646.B915B1D0292@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090603184646.B915B1D0292@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "npiggin@suse.de" <npiggin@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 02:46:46AM +0800, Andi Kleen wrote:
> 
> From: Nick Piggin <npiggin@suse.de>
> 
> Extract out truncate_inode_page() out of the truncate path so that
> it can be used by memory-failure.c
> 
> [AK: description, headers, fix typos]
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  include/linux/mm.h |    2 ++
>  mm/truncate.c      |   24 ++++++++++++------------
>  2 files changed, 14 insertions(+), 12 deletions(-)
> 
> Index: linux/mm/truncate.c
> ===================================================================
> --- linux.orig/mm/truncate.c	2009-06-03 19:37:38.000000000 +0200
> +++ linux/mm/truncate.c	2009-06-03 20:13:43.000000000 +0200
> @@ -135,6 +135,16 @@
>  	return ret;
>  }
>  
> +void truncate_inode_page(struct address_space *mapping, struct page *page)
> +{
> +	if (page_mapped(page)) {
> +		unmap_mapping_range(mapping,
> +		  (loff_t)page->index<<PAGE_CACHE_SHIFT,
> +		  PAGE_CACHE_SIZE, 0);
> +	}
> +	truncate_complete_page(mapping, page);
> +}
> +

Small style cleanup:

---
 mm/truncate.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- sound-2.6.orig/mm/truncate.c
+++ sound-2.6/mm/truncate.c
@@ -139,8 +139,8 @@ void truncate_inode_page(struct address_
 {
 	if (page_mapped(page)) {
 		unmap_mapping_range(mapping,
-		  (loff_t)page->index<<PAGE_CACHE_SHIFT,
-		  PAGE_CACHE_SIZE, 0);
+				    (loff_t)page->index << PAGE_CACHE_SHIFT,
+				    PAGE_CACHE_SIZE, 0);
 	}
 	truncate_complete_page(mapping, page);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
