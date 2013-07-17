Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id AA8E36B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 18:13:06 -0400 (EDT)
Date: Wed, 17 Jul 2013 15:13:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/4 v6]swap: fix races exposed by swap discard
Message-Id: <20130717151304.7afcc7b0c68fa91ce7b12012@linux-foundation.org>
In-Reply-To: <20130715204354.GC7925@kernel.org>
References: <20130715204354.GC7925@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com

On Tue, 16 Jul 2013 04:43:54 +0800 Shaohua Li <shli@kernel.org> wrote:

> Last patch can expose races, according to Hugh:
> 
> swapoff was sometimes failing with "Cannot allocate memory", coming from
> try_to_unuse()'s -ENOMEM: it needs to allow for swap_duplicate() failing on a
> free entry temporarily SWAP_MAP_BAD while being discarded.
> 
> We should use ACCESS_ONCE() there, and whenever accessing swap_map locklessly;
> but rather than peppering it throughout try_to_unuse(), just declare *swap_map
> with volatile.
> 
> try_to_unuse() is accustomed to *swap_map going down racily, but not
> necessarily to it jumping up from 0 to SWAP_MAP_BAD: we'll be safer to prevent
> that transition once SWP_WRITEOK is switched off, when it's a waste of time to
> issue discards anyway (swapon can do a whole discard).
> 
> Another issue is:
> 
> In swapin_readahead(), read_swap_cache_async() can read a bad swap entry,
> because we don't check if readahead swap entry is bad. This doesn't break
> anything but such swapin page is wasteful and can only be freed at page
> reclaim. We should avoid read such swap entry. And in discard, we mark swap
> entry SWAP_MAP_BAD and then switch it to normal when discard is finished. If
> readahead reads such swap entry, we have the same issue, so we much check if
> swap entry is bad too.
> 
> Thanks Hugh to inspire swapin_readahead could use bad swap entry.

Oh geeze.  How is anyone supposed to maintain this code :(

>
> ...
>
> @@ -1275,7 +1276,7 @@ int try_to_unuse(unsigned int type, bool
>  {
>  	struct swap_info_struct *si = swap_info[type];
>  	struct mm_struct *start_mm;
> -	unsigned char *swap_map;
> +	volatile unsigned char *swap_map;	/* ACCESS_ONCE throughout */

Again, it would take an unreasonable effort for anyone else to
understand why this is being done.  Please document your code with
sufficient detail to permit a reasonably experienced kernel developer
to understand it.


>  	unsigned char swcount;
>  	struct page *page;
>  	swp_entry_t entry;
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
