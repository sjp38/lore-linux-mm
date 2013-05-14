Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 345046B00AF
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:55:42 -0400 (EDT)
Date: Tue, 14 May 2013 15:55:37 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH 1/7] defer clearing of page_private() for swap cache
 pages
Message-ID: <20130514145537.GS11497@suse.de>
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
 <20130507211955.7DF88A4F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130507211955.7DF88A4F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tim.c.chen@linux.intel.com

On Tue, May 07, 2013 at 02:19:55PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> There are only two callers of swapcache_free() which actually
> pass in a non-NULL 'struct page'.  Both of them
> (__remove_mapping and delete_from_swap_cache())  create a
> temporary on-stack 'swp_entry_t' and set entry.val to
> page_private().
> 
> They need to do this since __delete_from_swap_cache() does
> set_page_private(page, 0) and destroys the information.
> 
> However, I'd like to batch a few of these operations on several
> pages together in a new version of __remove_mapping(), and I
> would prefer not to have to allocate temporary storage for
> each page.  The code is pretty ugly, and it's a bit silly
> to create these on-stack 'swp_entry_t's when it is so easy to
> just keep the information around in 'struct page'.
> 
> There should not be any danger in doing this since we are
> absolutely on the path of freeing these page.  There is no
> turning back, and no other rerferences can be obtained
> after it comes out of the radix tree.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

On it's own, this patch looks like it has a lot missing but when
combined with patch 2, it starts making sense so

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
