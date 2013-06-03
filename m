Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 7BF356B0037
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 11:55:10 -0400 (EDT)
Message-ID: <51ACBC5C.9020701@sr71.net>
Date: Mon, 03 Jun 2013 08:55:08 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [v4][PATCH 2/6] mm: swap: make 'struct page' and swp_entry_t
 variants of swapcache_free().
References: <20130531183855.44DDF928@viggo.jf.intel.com> <20130531183858.3C8C10C7@viggo.jf.intel.com> <20130603061320.GA2795@blaptop>
In-Reply-To: <20130603061320.GA2795@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 06/02/2013 11:13 PM, Minchan Kim wrote:
> I lost from this description.
> 
> Old behavior
> 
> delete_from_swap_cache
>         swap_address_space
>         __delete_from_swap_cache
>                 swap_address_space
> 
> 
> New behavior
> 
> delete_from_swap_cache
>         __delete_from_swap_cache
>                 swap_address_space
>                 
> So you removes a swap_address_space, not adding a extra call.
> Am I missing something?

I think I got the page->swp_entry_t lookup confused with the
page->swap_address_space lookup when I was writing the description.  The
bit that you missed is that I _added_ a page_mapping() call, which calls
swap_address_space() internally:

Old behavior:

delete_from_swap_cache
        swap_address_space
        __delete_from_swap_cache
                swap_address_space

New behavior:

delete_from_swap_cache
	page_mapping
		swap_address_space
        __delete_from_swap_cache
                swap_address_space

--

New description (last paragraph changed).  Andrew, I'll resend the
series since there are a few of these cleanups.

From: Dave Hansen <dave.hansen@linux.intel.com>

swapcache_free() takes two arguments:

	void swapcache_free(swp_entry_t entry, struct page *page)

Most of its callers (5/7) are from error handling paths haven't even
instantiated a page, so they pass page=NULL.  Both of the callers
that call in with a 'struct page' create and pass in a temporary
swp_entry_t.

Now that we are deferring clearing page_private() until after
swapcache_free() has been called, we can just create a variant
that takes a 'struct page' and does the temporary variable in
the helper.

That leaves all the other callers doing

	swapcache_free(entry, NULL)

so create another helper for them that makes it clear that they
need only pass in a swp_entry_t.

One downside here is that delete_from_swap_cache() now calls
swap_address_space() via page_mapping() instead of calling
swap_address_space() directly.  In doing so, it removes one more
case of the swap cache code being special-cased, which is a good
thing in my book.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
