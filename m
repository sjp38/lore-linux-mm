From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200001140113.RAA62584@google.engr.sgi.com>
Subject: Re: [RFC] 2.3.39 zone balancing
Date: Thu, 13 Jan 2000 17:13:05 -0800 (PST)
In-Reply-To: <Pine.LNX.4.21.0001140128510.3816-100000@alpha.random> from "Andrea Arcangeli" at Jan 14, 2000 01:33:54 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@chiara.csoma.elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> On Thu, 13 Jan 2000, Linus Torvalds wrote:
> 
> >Basically, my argument is that there is no way "swap_out()" can really
> >target any special zone, except by avoiding to do the final stage in a
> >long sequence of stages that it has already done. I think that's just
> >completely wasteful - doing all the work, and then at the last minute
> >deciding to not use the work after all. Especially as we don't really have
> >any good reason to believe that it's the right thing in the first place.
> 
> The only problem in what you are suggesting is that you may end swapping
> out also the wrong pages. Suppose you want to allocate 4k of DMA
> memory. Why should the machine swapout lots of mbytes of data while it
> could only swapout 4k? And after each swapout we have to restart from the
> vma because to swapout we have to drop the pagetable lock and so the
> mappings can be changed from under us.

Yes, I am worried about this a little too. Specially, when you are
hunting for a dma page, and the machine happens to have gigs of
highmem and regular pages, chances are that you will end up stealing
a lot of pages unneccesarily.

But as Linus points out, recovering from that is not that costly
(the page will be in the swapcache mostly, its just the cost of 
the page fault).

What about stealing the page only if the corresponding zone is
also running unbalanced?

Kanoj

> 
> >So that's why I think the page table walker should be completely
> >zone-blind, and just not care. It's likely to be more "balanced" that way
> >anyway.
> 
> The swapout will be definitely more balanced but we may end doing not
> necesary swapouts.
> 
> Andrea
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.nl.linux.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
