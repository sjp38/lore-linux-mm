From: volodya@mindspring.com
Date: Thu, 15 Jun 2000 04:58:44 -0400 (EDT)
Reply-To: volodya@mindspring.com
Subject: Re: shrink_mmap bug in 2.2?
In-Reply-To: <200006150116.SAA41023@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.20.0006150456210.19446-100000@node2.localnet.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Neil Schemenauer <nascheme@enme.ucalgary.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 14 Jun 2000, Kanoj Sarcar wrote:

> > 
> > This code looks strange to me (possibly because I don't
> > understand it):
> > 
> >     /*
> >      * Is it a page swap page? If so, we want to
> >      * drop it if it is no longer used, even if it
> >      * were to be marked referenced..
> >      */
> >     if (PageSwapCache(page)) {
> >             if (referenced && swap_count(page->offset) != 1)
> >                     continue;
> >             delete_from_swap_cache(page);
> >             return 1;
> >     }       
> 
> Aren't you misreading the logic here? It is
> 
> 	referenced && swap_count(page->offset) != 1)
> 	          ^^^^
> and not
> 
> 	referenced || swap_count(page->offset) != 1)
>                  ^^^^^
> 
> So delete_from_swap_cache will only ever be called on a page
> with swap_count(page->offset) == 1.
> 

This evades me. We delete when the condition is false. So if referenced is
0  if will not happen and we delete the page..

                                 Vladimir Dergachev
> Kanoj
> 
> > 
> > Can pages be deleted from the swap cache if swap_count is not
> > one?  If not, then I think this code is wrong.  It should be:
> > 
> >     if (PageSwapCache(page)) {
> >             if (swap_count(page->offset) != 1)
> >                     continue;
> >             delete_from_swap_cache(page);
> >             return 1;
> >     }       
> >  
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
