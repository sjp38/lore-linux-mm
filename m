Date: Thu, 13 Jan 2000 15:29:51 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <Pine.LNX.4.10.10001140040040.6274-100000@chiara.csoma.elte.hu>
Message-ID: <Pine.LNX.4.10.10001131524580.2250-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Fri, 14 Jan 2000, Ingo Molnar wrote:
> 
> so why cant swap_out (conceptually) accept a 'zones under pressure'
> bitmask as an input, and calculate zones from the physical address it sees
> in the page table.

Because swap_out() is going to look at the page tables _anyway_.

Basically, my argument is that there is no way "swap_out()" can really
target any special zone, except by avoiding to do the final stage in a
long sequence of stages that it has already done. I think that's just
completely wasteful - doing all the work, and then at the last minute
deciding to not use the work after all. Especially as we don't really have
any good reason to believe that it's the right thing in the first place.

I suspect we're much better off just having a simple "age the page tables"
thing that doesn't care abotu zones at all, and when a page table entry
has been aged enough, it gets pushed into the page/swap cache. It's
reasonably cheap to fault it in again, and because we use aging on the
page tables we've selected a page that isn't supposed to be very active
anyway.

So that's why I think the page table walker should be completely
zone-blind, and just not care. It's likely to be more "balanced" that way
anyway.

The "shrink_mmap()" stage is another matter entirely. shrink_mmap() has
complete control over which zone it looks at, and can do a good (perfect)
job of balancing the amount of work it does to how much it wants to
accomplish.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
