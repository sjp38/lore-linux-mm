Message-ID: <48F110AA.50609@redhat.com>
Date: Sat, 11 Oct 2008 16:46:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
References: <200810081655.06698.nickpiggin@yahoo.com.au>	<20081008185401.D958.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<20081010151701.e9e50bdb.akpm@linux-foundation.org>	<20081010152540.79ed64cb.akpm@linux-foundation.org>	<20081010153346.e25b90f7.akpm@linux-foundation.org>	<48EFEC68.6000705@redhat.com>	<20081010184217.f689f493.akpm@linux-foundation.org>	<48F00737.1080707@redhat.com> <20081010192125.9a54cc22.akpm@linux-foundation.org>
In-Reply-To: <20081010192125.9a54cc22.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> then I get the below.  Can we think of a plausible-sounding changelog for ?

Does this sound reasonable?

Moving referenced pages back to the head of the active list
creates a huge scalability problem, because by the time a
large memory system finally runs out of free memory, every
single page in the system will have been referenced.

Not only do we not have the time to scan every single page
on the active list, but since they have will all have the
referenced bit set, that bit conveys no useful information.

A more scalable solution is to just move every page that
hits the end of the active list to the inactive list.

We clear the referenced bit off of mapped pages, which
need just one reference to be moved back onto the active
list.

Unmapped pages will be moved back to the active list after
two references (see mark_page_accessed).  We preserve the
PG_referenced flag on unmapped pages to preserve accesses
that were made while the page was on the active list.

> @@ -1103,13 +1107,20 @@ static void shrink_active_list(unsigned 
>  	 * to the inactive list.  This helps balance scan pressure between
>  	 * file and anonymous pages in get_scan_ratio.
>   	 */
> +
> +	/*
> +	 * Count referenced pages from currently used mappings as
> +	 * rotated, even though they are moved to the inactive list.
> +	 * This helps balance scan pressure between file and anonymous
> +	 * pages in get_scan_ratio.
> +	 */
>  	zone->recent_rotated[!!file] += pgmoved;

You might want to remove the obsoleted comment :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
