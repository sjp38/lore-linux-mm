From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200006151656.JAA19085@google.engr.sgi.com>
Subject: Re: shrink_mmap bug in 2.2?
Date: Thu, 15 Jun 2000 09:56:43 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.20.0006150456210.19446-100000@node2.localnet.net> from "volodya@mindspring.com" at Jun 15, 2000 04:58:44 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: volodya@mindspring.com
Cc: Neil Schemenauer <nascheme@enme.ucalgary.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> 
> On Wed, 14 Jun 2000, Kanoj Sarcar wrote:
> 
> > > 
> > > This code looks strange to me (possibly because I don't
> > > understand it):
> > > 
> > >     /*
> > >      * Is it a page swap page? If so, we want to
> > >      * drop it if it is no longer used, even if it
> > >      * were to be marked referenced..
> > >      */
> > >     if (PageSwapCache(page)) {
> > >             if (referenced && swap_count(page->offset) != 1)
> > >                     continue;
> > >             delete_from_swap_cache(page);
> > >             return 1;
> > >     }       
> > 
> > Aren't you misreading the logic here? It is
> > 
> > 	referenced && swap_count(page->offset) != 1)
> > 	          ^^^^
> > and not
> > 
> > 	referenced || swap_count(page->offset) != 1)
> >                  ^^^^^
> > 
> > So delete_from_swap_cache will only ever be called on a page
> > with swap_count(page->offset) == 1.
> > 
> 
> This evades me. We delete when the condition is false. So if referenced is
> 0  if will not happen and we delete the page..

Oh okay, I was confused myself. 

Looking at 2.4.0-test1, I think the code is now,

                /*
                 * Is it a page swap page? If so, we want to
                 * drop it if it is no longer used, even if it
                 * were to be marked referenced..
                 */
                if (PageSwapCache(page)) {
                        spin_unlock(&pagecache_lock);
                        __delete_from_swap_cache(page);
                        goto made_inode_progress;
                }


So, the code that Neil posted is a little older. In any case, the
logic there is this: if the page has been referenced, it is evidently
not a good decision to steal it, since due to time-locality of reference,
it is going to be accessed soon again, and we do not want to incur a 
swapin at that point (if we steal the page and reuse it for another
purpose, thereby loosing the current contents). 

Even if the page has been referenced, the contents of the page are
already on the swap, so if the swap_count of the page is 1, it is 
due to being in the swapcache itself (no user process has a reference 
to the page or the corresponding swap handle). Good candidate to be
stolen.

If the page has not been referenced, it is a good candidate for stealing.
Since the contents are already on swap, it does not matter how many
user processes have references to the swap handle, they will incur a
swapin cost when they access the corresponding user virtual address.
At this point, the page must go out of the swapcache, since it is
potentially going to be used for another purpose.

Another thing to note is that this code is executed on a page which
has no user reference count to the page, since all such references
have been converted to references to the corresponding swap handle.

Kanoj

> 
>                                  Vladimir Dergachev
> > Kanoj
> > 
> > > 
> > > Can pages be deleted from the swap cache if swap_count is not
> > > one?  If not, then I think this code is wrong.  It should be:
> > > 
> > >     if (PageSwapCache(page)) {
> > >             if (swap_count(page->offset) != 1)
> > >                     continue;
> > >             delete_from_swap_cache(page);
> > >             return 1;
> > >     }       
> > >  
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux.eu.org/Linux-MM/
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
