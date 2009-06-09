Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 48AAF6B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 05:27:53 -0400 (EDT)
Date: Tue, 9 Jun 2009 11:59:20 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [10/16] HWPOISON: Handle poisoned pages in set_page_dirty()
Message-ID: <20090609095920.GD14820@wotan.suse.de>
References: <20090603846.816684333@firstfloor.org> <20090603184644.190E71D0281@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090603184644.190E71D0281@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 03, 2009 at 08:46:43PM +0200, Andi Kleen wrote:
> 
> Bail out early in set_page_dirty for poisoned pages. We don't want any
> of the dirty accounting done or file system write back started, because
> the page will be just thrown away.

I don't agree with adding overhead to fastpaths like this. Your
MCE handler should have already taken care of this so I can't
see what it can gain.

> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  mm/page-writeback.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> Index: linux/mm/page-writeback.c
> ===================================================================
> --- linux.orig/mm/page-writeback.c	2009-06-03 19:36:20.000000000 +0200
> +++ linux/mm/page-writeback.c	2009-06-03 19:36:23.000000000 +0200
> @@ -1304,6 +1304,10 @@
>  {
>  	struct address_space *mapping = page_mapping(page);
>  
> +	if (unlikely(PageHWPoison(page))) {
> +		SetPageDirty(page);
> +		return 0;
> +	}
>  	if (likely(mapping)) {
>  		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
>  #ifdef CONFIG_BLOCK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
