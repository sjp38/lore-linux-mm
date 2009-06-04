Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D49A66B004D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 20:36:31 -0400 (EDT)
Date: Thu, 4 Jun 2009 08:36:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [10/16] HWPOISON: Handle poisoned pages in
	set_page_dirty()
Message-ID: <20090604003621.GA12210@localhost>
References: <20090603846.816684333@firstfloor.org> <20090603184644.190E71D0281@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090603184644.190E71D0281@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 04, 2009 at 02:46:43AM +0800, Andi Kleen wrote:
> 
> Bail out early in set_page_dirty for poisoned pages. We don't want any
> of the dirty accounting done or file system write back started, because
> the page will be just thrown away.
 
I'm afraid this patch is not necessary and could be harmful.

It is not necessary because a poisoned page will normally already be
isolated from page cache, or likely cannot be isolated because it has
dirty buffers.

It is harmful because it put the page into dirty state without queuing
it for IO by moving it to s_io. When more normal pages are dirtied
later, __set_page_dirty_nobuffers() won't move the inode into s_io,
hence delaying the writeback of good pages for arbitrary long time.

Thanks,
Fengguang

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
