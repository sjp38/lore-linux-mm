From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910151843.LAA14256@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
Date: Fri, 15 Oct 1999 11:43:31 -0700 (PDT)
In-Reply-To: <380771D1.25616711@colorfullife.com> from "Manfred Spraul" at Oct 15, 99 08:26:25 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: torvalds@transmeta.com, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> Kanoj Sarcar wrote:
> > If you wanted to be more careful, you
> > could define the swapout prototype as swapout(start, end, flags, file).
> > That *should* be enough for most future 2.3/2.4 driver.
> 
> "file" can go away if you do not call "get_file()" before releasing the
> locking.

Absolutely ... you would need to do a get_file() in try_to_swap_out,
then a fput() after return from the swapout() method. I was just
focusing attention on the vma-does-not-have-to-exist point.

> > 
> > This works for filemap_swapout, but you can not expect every regular Joe
> > driver writer to adhere to this rule.
> The result is not a rare lock-up, but it will lock-up nearly
> immediately. Even Joe would notice that.
> [I know this is ugly]

Oh, the lockup will hapen only if Joe tests his driver under huge 
memory demand conditions, that too, if a page stealer decides to 
victimize the vma Joe set up. Entirely missable during driver
developement, imo. Even if Joe hits the scenario, it would be cruel
for us to ask him to understand how swapping works; its enough for
him to have to worry about MP issues ...

> 
> > And here's one more. Before invoking swapout(), and before loosing the
> > vmlist_lock in try_to_swap_out, the vma might be marked with a flag
> > that indicates that swapout() is looking at the vma.
> Or: use a multiple reader - single writer semaphore with "starve writer"
> policy.
> IMO that's cleaner than a semaphore with an attached waitqueue for
> do_munmap().
> 

Explain ... who are the readers, and who are the writers? I think if you 
are talking about a semaphore lock being held thru out swapout() in the
try_to_swap_out path, you are reduced to the same deadlock I just pointed 
out. I was talking more about a monitor like approach here.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
