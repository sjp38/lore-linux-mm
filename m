Date: Mon, 18 Feb 2002 17:53:50 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <E16czQ1-0000yf-00@starship.berlin>
Message-ID: <Pine.LNX.4.33.0202181749110.24597-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Hugh Dickins <hugh@veritas.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, Rik van Riel <riel@conectiva.com.br>, mingo@redhat.com, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>


On Tue, 19 Feb 2002, Daniel Phillips wrote:
>
> Somebody might read fault, changing an entry when we're in the middle of
> copying it and might might do a duplicated read fault.

You're confusing the mm->mmap_sem with the page_table_lock.

The mm semaphore is really a read-write semaphore, and yes, there can be
multiple faulters active at the same time readin gin pages.

But the page_table_lock is 100% exclusive, and while you hold the
page_table_lock there is absolutely _not_ going to be any concurrent page
faulting.

(NOTE! Sure, there might be another mm that has the same pmd shared, but
that one is going to do an unshare before it actually touches anything in
the pmd, so it's NOT going to change the values in the original pmd).

So I'm personally convinced that the locking shouldn't be needed at all,
if you just make sure that you do things in the right order (that, of
course, might need some memory barriers, which had better be implied by
the atomic dec-and-test anyway).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
