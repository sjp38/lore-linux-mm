From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200006150116.SAA41023@google.engr.sgi.com>
Subject: Re: shrink_mmap bug in 2.2?
Date: Wed, 14 Jun 2000 18:16:10 -0700 (PDT)
In-Reply-To: <20000614185034.A2505@acs.ucalgary.ca> from "Neil Schemenauer" at Jun 14, 2000 06:50:34 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> This code looks strange to me (possibly because I don't
> understand it):
> 
>     /*
>      * Is it a page swap page? If so, we want to
>      * drop it if it is no longer used, even if it
>      * were to be marked referenced..
>      */
>     if (PageSwapCache(page)) {
>             if (referenced && swap_count(page->offset) != 1)
>                     continue;
>             delete_from_swap_cache(page);
>             return 1;
>     }       

Aren't you misreading the logic here? It is

	referenced && swap_count(page->offset) != 1)
	          ^^^^
and not

	referenced || swap_count(page->offset) != 1)
                 ^^^^^

So delete_from_swap_cache will only ever be called on a page
with swap_count(page->offset) == 1.

Kanoj

> 
> Can pages be deleted from the swap cache if swap_count is not
> one?  If not, then I think this code is wrong.  It should be:
> 
>     if (PageSwapCache(page)) {
>             if (swap_count(page->offset) != 1)
>                     continue;
>             delete_from_swap_cache(page);
>             return 1;
>     }       
>  
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
