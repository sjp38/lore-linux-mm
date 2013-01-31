Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 4BB866B0011
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 16:50:44 -0500 (EST)
Date: Thu, 31 Jan 2013 13:50:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/3 v2]swap: make each swap partition have one
 address_space
Message-Id: <20130131135042.ae633246.akpm@linux-foundation.org>
In-Reply-To: <20130124102414.GA10025@kernel.org>
References: <20130122022951.GB12293@kernel.org>
	<20130123061645.GF2723@blaptop>
	<20130123073655.GA31672@kernel.org>
	<20130123080420.GI2723@blaptop>
	<1358991596.3351.9.camel@kernel>
	<20130124022241.GB22654@blaptop>
	<20130124024311.GA26602@kernel.org>
	<20130124051910.GD22654@blaptop>
	<20130124102414.GA10025@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, linux-mm@kvack.org, hughd@google.com, riel@redhat.com

On Thu, 24 Jan 2013 18:24:14 +0800
Shaohua Li <shli@kernel.org> wrote:

> Subject: mm: add memory barrier to prevent SwapCache bit and page private out of order
> 
> page_mapping() checks SwapCache bit first and then read page private. Adding
> memory barrier so page private has correct value before SwapCache bit set.
> 
> In some cases, page_mapping() isn't called with page locked. Without doing
> this, we might get a wrong swap address space with SwapCache bit set. Though I
> didn't found a problem with this so far (such code typically only checks if the
> page has mapping or the mapping can be dirty or migrated), this is too subtle
> and error-prone, so we want to avoid it.
> 
> ...
>
> --- linux.orig/mm/swap_state.c	2013-01-22 10:12:33.514490665 +0800
> +++ linux/mm/swap_state.c	2013-01-24 18:08:05.149390977 +0800
> @@ -89,6 +89,7 @@ static int __add_to_swap_cache(struct pa
>  
>  	page_cache_get(page);
>  	set_page_private(page, entry.val);
> +	smp_wmb();
>  	SetPageSwapCache(page);

SetPageSwapCache() uses set_bit() and arch/x86/include/asm/bitops.h
says "This function is atomic and may not be reordered".  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
