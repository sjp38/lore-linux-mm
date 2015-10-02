Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7601A82F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 03:25:26 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so20314860wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 00:25:25 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id l10si11851290wjr.34.2015.10.02.00.25.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 00:25:25 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so20093866wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 00:25:24 -0700 (PDT)
Date: Fri, 2 Oct 2015 09:25:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
Message-ID: <20151002072522.GC30354@dhcp22.suse.cz>
References: <560D59F7.4070002@roeck-us.net>
 <20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Guenter Roeck <linux@roeck-us.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Thu 01-10-15 13:49:04, Andrew Morton wrote:
[...]
> mpage_readpage() is getting the __GFP_HIGHMEM from mapping_gfp_mask()
> and that got passed all the way into kmem_cache_alloc() to allocate a
> bio.  slab goes BUG if asked for highmem.
> 
> A fix would be to mask off __GFP_HIGHMEM right there in
> mpage_readpage().

Yes, this is an obvious bug in the patch. It should only make the gfp
mask more restrictive.

> But I think the patch needs a bit of a rethink.  mapping_gfp_mask() is
> the mask for allocating a file's pagecache.  It isn't designed for
> allocation of memory for IO structures, file metadata, etc.
>
> Now, we could redefine mapping_gfp_mask()'s purpose (or formalize
> stuff which has been sneaking in anyway).  Treat mapping_gfp_mask() as
> a constraint mask - instead of it being "use this gfp for this
> mapping", it becomes "don't use these gfp flags for this mapping".
> 
> Hence something like:
> 
> gfp_t mapping_gfp_constraint(struct address_space *mapping, gfp_t gfp_in)
> {
> 	return mapping_gfp_mask(mapping) & gfp_in;
> }
> 
> So instead of doing this:
> 
> @@ -370,12 +371,13 @@ mpage_readpages(struct address_space *ma
>  		prefetchw(&page->flags);
>  		list_del(&page->lru);
>  		if (!add_to_page_cache_lru(page, mapping,
> -					page->index, GFP_KERNEL)) {
> +					page->index,
> +					gfp)) {
> 
> Michal's patch will do:
> 
> @@ -370,12 +371,13 @@ mpage_readpages(struct address_space *ma
>  		prefetchw(&page->flags);
>  		list_del(&page->lru);
>  		if (!add_to_page_cache_lru(page, mapping,
> -				page->index, GFP_KERNEL)) {
> +				page->index,
> +				mapping_gfp_constraint(mapping, GFP_KERNEL))) {
> 
> ie: use mapping_gfp_mask() to strip out any GFP flags which the
> filesystem doesn't want used.  If the filesystem has *added* flags to
> mapping_gfp_mask() then obviously this won't work and we'll need two
> fields in the address_space or something.
> 
> Meanwhile I'll drop "mm, fs: obey gfp_mapping for add_to_page_cache()",
> thanks for the report.

mapping_gfp_mask is used at many places so I think it would be better to
fix this particular place (others seem to be correct). It would make the
stable backport much easier. We can build a more sane API on top. What
do you think?

Here is the respin of the original patch. I will post another one which
will add mapping_gfp_constraint on top. It will surely be less error
prone.
---
