Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] Page table sharing
Date: Tue, 19 Feb 2002 02:23:35 +0100
References: <Pine.LNX.4.33.0202181631120.24405-100000@home.transmeta.com>
In-Reply-To: <Pine.LNX.4.33.0202181631120.24405-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E16cz0J-0000yQ-00@starship.berlin>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, Rik van Riel <riel@conectiva.com.br>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On February 19, 2002 01:56 am, Linus Torvalds wrote:
> On Tue, 19 Feb 2002, Daniel Phillips wrote:
> >
> > Thanks, here it is again.  This time I left the gratuitous whitespace
> > cleanup in as the route of least resistance ;-)
> 
> Daniel, there's something wrong in the locking.
> 
> I can see _no_ reason to have "page_table_share_lock". What is the point
> of that one?

Before I put it in I was getting a weird error trying to run UML on a
native kernel with page table sharing.  After it was solid.  That's emprical, 
but...

> Whenever we end up touching the pmd counts, we already hold the local
> mm->page_table_lock. That means that we are always guaranteed to have a
> count of at least one when we start out on it.

Yes, good observation, I was looking at it inversely: when we have a
count of one then we must have exclusion from the mm->page_table_lock.

> [...]
>
> In short, I do not believe that that lock is needed. And if it isn't
> needed, it is _incorrect_. Locking that doesn't buy you anything is not
> just a performance overhead, it's bad thinking.

It would be very nice if the lock isn't needed.  OK, it's going to take some
time to ponder over your post properly.  In the mean time, there is exclusion 
that's clearly missing elsewhere and needs to go it, i.e., in the read fault 
path.
 
-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
