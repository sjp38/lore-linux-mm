Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id D24706B0135
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 21:41:51 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so5338026pbc.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 18:41:51 -0800 (PST)
Date: Fri, 17 Feb 2012 18:41:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: move buffer_heads_over_limit check up
In-Reply-To: <20120217161142.a3ffa135.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1202171823350.25244@eggly.anvils>
References: <alpine.LSU.2.00.1202171557040.1286@eggly.anvils> <20120217161142.a3ffa135.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Konstantin Khelbnikov <khlebnikov@openvz.org>

On Fri, 17 Feb 2012, Andrew Morton wrote:
> 
> I don't think there's a lot of point in trying to micro-optimise the
> buffer_heads_over_limit==true case, either.  But I suppose that
> pointlessly locking 1000000 anon pages is indeed pointless.  Hopefully
> there _is_ a point in micro-optimising the actual test for
> buffer_heads_over_limit==true.  So...

That's fine, yes, and thanks for putting this in.  I just want to
exonerate Mel: it's not a fix to his useful work on buffer_heads_over_limit,
but I don't think he'll mind terribly that you've named it thus.

If it's a fix to anything, it's to my 3.3 free_hot_cold_page_list-ification
of shrink_active_list(), which was silly to leave the buffer_heads business
down there in move_active_pages_to_lru().

And the only reason I'm concerned to get it in, is that it's in an area
which I then trample over in the per-memcg per-zone locking series (as
is Hillf's rearrangement around update_isolated_counts()), so it's
convenient for me to have both of those in the base, instead of
having to put them in a prologue.

If I were to worry about the buffer_heads_over_limit situation itself,
I might worry about the unevictable pages which we never scan.

Hugh

> 
> --- a/mm/vmscan.c~mm-vmscan-forcibly-scan-highmem-if-there-are-too-many-buffer_heads-pinning-highmem-fix-fix
> +++ a/mm/vmscan.c
> @@ -1723,11 +1723,12 @@ static void shrink_active_list(unsigned 
>  			continue;
>  		}
>  
> -		if (buffer_heads_over_limit &&
> -		    page_has_private(page) && trylock_page(page)) {
> -			if (page_has_private(page))
> -				try_to_release_page(page, 0);
> -			unlock_page(page);
> +		if (unlikely(buffer_heads_over_limit)) {
> +			if (page_has_private(page) && trylock_page(page)) {
> +				if (page_has_private(page))
> +					try_to_release_page(page, 0);
> +				unlock_page(page);
> +			}
>  		}
>  
>  		if (page_referenced(page, 0, mz->mem_cgroup, &vm_flags)) {
> _

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
