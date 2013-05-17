Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 07F6A6B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 09:27:19 -0400 (EDT)
Date: Fri, 17 May 2013 14:27:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFCv2][PATCH 2/5] make 'struct page' and swp_entry_t variants
 of swapcache_free().
Message-ID: <20130517132711.GL11497@suse.de>
References: <20130516203427.E3386936@viggo.jf.intel.com>
 <20130516203429.5293EA57@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130516203429.5293EA57@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tim.c.chen@linux.intel.com

On Thu, May 16, 2013 at 01:34:29PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> swapcache_free() takes two arguments:
> 
> 	void swapcache_free(swp_entry_t entry, struct page *page)
> 
> Most of its callers (5/7) are from error handling paths haven't even
> instantiated a page, so they pass page=NULL.  Both of the callers
> that call in with a 'struct page' create and pass in a temporary
> swp_entry_t.
> 
> Now that we are deferring clearing page_private() until after
> swapcache_free() has been called, we can just create a variant
> that takes a 'struct page' and does the temporary variable in
> the helper.
> 
> That leaves all the other callers doing
> 
> 	swapcache_free(entry, NULL)
> 
> so create another helper for them that makes it clear that they
> need only pass in a swp_entry_t.
> 
> One downside here is that delete_from_swap_cache() now does
> an extra swap_address_space() call.  But, those are pretty
> cheap (just some array index arithmetic).
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
