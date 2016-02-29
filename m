Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC33828E4
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 04:52:20 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id p65so37518692wmp.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 01:52:20 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id mc5si31345891wjb.99.2016.02.29.01.52.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 01:52:19 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id l68so50613958wml.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 01:52:18 -0800 (PST)
Date: Mon, 29 Feb 2016 12:52:16 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: __delete_from_page_cache WARN_ON(page_mapped)
Message-ID: <20160229095216.GA9616@node.shutemov.name>
References: <alpine.LSU.2.11.1602282042110.1472@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1602282042110.1472@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Feb 28, 2016 at 08:49:10PM -0800, Hugh Dickins wrote:
> Commit e1534ae95004 ("mm: differentiate page_mapped() from page_mapcount()
> for compound pages") changed the famous BUG_ON(page_mapped(page)) in
> __delete_from_page_cache() to VM_BUG_ON_PAGE(page_mapped(page)): which
> gives us more info when CONFIG_DEBUG_VM=y, but nothing at all when not.
> 
> Although it has not usually been very helpul, being hit long after the
> error in question, we do need to know if it actually happens on users'
> systems; but reinstating a crash there is likely to be opposed :)
> 
> In the non-debug case, use WARN_ON() plus dump_page() and add_taint() -
> I don't really believe LOCKDEP_NOW_UNRELIABLE, but that seems to be the
> standard procedure now.

So you put here TAINT_WARN plus TAINT_BAD_PAGE. I guess just the second
would be enough.

We can replace WARN_ON() with plain page_mapped(page), plus dump_stack()
below add_taint().

> Move that, or the VM_BUG_ON_PAGE(), up before
> the deletion from tree: so that the unNULLified page->mapping gives a
> little more information.
> 
> If the inode is being evicted (rather than truncated), it won't have
> any vmas left, so it's safe(ish) to assume that the raised mapcount is
> erroneous, and we can discount it from page_count to avoid leaking the
> page (I'm less worried by leaking the occasional 4kB, than losing a
> potential 2MB page with each 4kB page leaked).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Otherwise,

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
> I think this should go into v4.5, so I've written it with an atomic_sub
> on page->_count; but Joonsoo will probably want some page_ref thingy.
> 
>  mm/filemap.c |   22 +++++++++++++++++++++-
>  1 file changed, 21 insertions(+), 1 deletion(-)
> 
> --- 4.5-rc6/mm/filemap.c	2016-02-28 09:04:38.816707844 -0800
> +++ linux/mm/filemap.c	2016-02-28 19:45:23.406263928 -0800
> @@ -195,6 +195,27 @@ void __delete_from_page_cache(struct pag
>  	else
>  		cleancache_invalidate_page(mapping, page);
>  
> +	VM_BUG_ON_PAGE(page_mapped(page), page);
> +	if (!IS_ENABLED(CONFIG_DEBUG_VM) && WARN_ON(page_mapped(page))) {
> +		int mapcount;
> +
> +		dump_page(page, "still mapped when deleted");
> +		add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
> +
> +		mapcount = page_mapcount(page);
> +		if (mapping_exiting(mapping) &&
> +		    page_count(page) >= mapcount + 2) {
> +			/*
> +			 * All vmas have already been torn down, so it's
> +			 * a good bet that actually the page is unmapped,
> +			 * and we'd prefer not to leak it: if we're wrong,
> +			 * some other bad page check should catch it later.
> +			 */
> +			page_mapcount_reset(page);
> +			atomic_sub(mapcount, &page->_count);
> +		}
> +	}
> +
>  	page_cache_tree_delete(mapping, page, shadow);
>  
>  	page->mapping = NULL;
> @@ -205,7 +226,6 @@ void __delete_from_page_cache(struct pag
>  		__dec_zone_page_state(page, NR_FILE_PAGES);
>  	if (PageSwapBacked(page))
>  		__dec_zone_page_state(page, NR_SHMEM);
> -	VM_BUG_ON_PAGE(page_mapped(page), page);
>  
>  	/*
>  	 * At this point page must be either written or cleaned by truncate.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
