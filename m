Date: Sun, 17 Feb 2002 22:16:48 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] Page table sharing
In-Reply-To: <E16cX9a-0000D9-00@starship.berlin>
Message-ID: <Pine.LNX.4.21.0202172133520.10152-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, dmccr@us.ibm.com, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Robert Love <rml@tech9.net>, Rik van Riel <riel@conectiva.com.br>, mingo@redhat.co, Andrew Morton <akpm@zip.com.au>, manfred@colorfullife.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Sun, 17 Feb 2002, Daniel Phillips wrote:
> 
> Note that we have to hold the page_table_share_lock until we're finished
> copying in the ptes, otherwise the source could go away.  This can turn
> into a lock on the page table itself eventually, so whatever contention
> there might be will be eliminated.
> 
> Fixing up copy_page_range to bring the pmd populate inside the 
> mm->page_table_lock is trivial, I won't go into it here.  With that plus
> changes as above, I think it's tight.  Though I would not bet my life on
> it ;-)

Sorry, I didn't really try to follow your preceding discussion of
zap_page_range.  (I suspect you need to step back and think again if it
gets that messy; but that may be unfair, I haven't thought it through).

You need your "page_table_share_lock" (better, per-page-table spinlock)
much more than you seem to realize.  If mm1 and mm2 share a page table,
mm1->page_table_lock and mm2->page_table_lock give no protection against
each other.  Consider copy_page_range from mm1 or __pte_alloc in mm1
while try_to_swap_out is acting on shared page table in mm2.  In fact,
I think even the read faults are vulnerable to races (mm1 and mm2
bringing page in at the same time so double-counting it), since your
__pte_alloc doesn't regard a read fault as reason to break the share.

I'm also surprised that your copy_page_range appears to be setting
write protect on each pte, including expensive pte_page, VALID_PAGE
stuff on each.  You avoid actually copying pte and incrementing counts,
but I'd expect you to want to avoid the whole scan: invalidating entry
for the page table itself, to force fault if needed.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
