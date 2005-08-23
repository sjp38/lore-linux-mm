Date: Tue, 23 Aug 2005 19:29:43 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFT][PATCH 0/2] pagefault scalability alternative
In-Reply-To: <Pine.LNX.4.62.0508230909120.16321@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0508231832340.10612@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508221448480.8933@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0508230822300.5224@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508230909120.16321@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Aug 2005, Christoph Lameter wrote:
> On Tue, 23 Aug 2005, Hugh Dickins wrote:
> 
> > > The basic idea is to have a spinlock per page table entry it seems.
> > A spinlock per page table, not a spinlock per page table entry.
> 
> Thats a spinlock per pmd? Calling it per page table is a bit confusing 
> since page table may refer to the whole tree. Could you develop 
> a clearer way of referring to these locks that is not page_table_lock or 
> ptl?

Sorry to confuse.  I'm used to using "page table" for the leaf (or
rather, the twig above the pages themselves), may be hard to retrain
myself now.  Martin suggests "page table page", that's fine by me.

And, quite aside from getting confused between the different levels,
there's the confusion that C arrays introduce: when we write "pte",
sometimes we're thinking of a single page table entry, and sometimes
of the contiguous array of them, the "page table page".

You suggest I mean spinlock per pmd: I'd say it's a spinlock
per pmd entry.  Oh well, let the code speak for itself.
Every PMD_SIZE bytes of userspace gets its own spinlock
(and "PMD_SIZE" argues for your nomenclature not mine).

> Atomicity can be guaranteed to some degree by using the present bit. 
> For an update the present bit is first switched off. When a 
> new value is written, it is first written in the piece of the entry that 
> does not contain the pte bit which keeps the entry "not present". Last the 
> word with the present bit is written.

Exactly.  And many of the tests (e.g. in the _alloc functions) are testing
present, and need no change.  But the p?d_none_or_clear_bad tests would be
in danger of advancing to the "bad" test, and getting it wrong, if we
assemble "none" from two parts: need just to test the one with present in.

(But this would go wrong if we did it for pte_none, I think,
because the swap entry gets stored in the upper part when PAE.)

> This means that if any p?d entry has been found to not contain the present 
> bit then a lock must be taken and then the entry must be reread to get a 
> consistent value.

That's indeed what happens in the _alloc functions, pmd_alloc etc.
In the others, the lookups which don't wish to allocate, they just
give up on seeing p?d_none, no need to reread, if there's a race
we're happy to lose it in those contexts.

> Here are the results of the performance test. In summary these show that
> the performance of both our approaches are equivalent.

Many thanks for getting those done.  Interesting: or perhaps not -
boringly similar!  They fit with what I see on the 32-bit and 64-bit
2*HT*Xeons I have here, sometimes one does better, sometimes the other.

I'd rather been expecting the bigger machines to show some advantage
to your patch, yet not a decisive advantage.  Perhaps, on the bigger
ones neither can presently scale to, that will become apparent later;
or maybe I was just preparing myself for some disappointment.

> I would prefer your 
> patches over mine since they have a broader scope and may accellerate 
> other aspects of vm operations.

That is very generous of you, especially after all the effort you've
put into posting and reposting yours down the months: thank you.

But I do agree that mine covers more bases: no doubt similar tests on
the shared file pages would degenerate quickly from other contention
(e.g. the pagecache Nick is playing in), but we can expect that as
such issues get dealt with, the narrowed and split locking would
give the same advantage to those as to the anonymous.

I still fear that your pte xchging, with its parallel set of locking
rules, would tie our hands down the road, and might have to be backed
out later even if brought in.  But it's certainly not ruled out: it
will be interesting to see if it gives any boost on top of the split.

I do consistently see a small advantage to CONFIG_SPLIT_PTLOCK N
over Y when not multithreading, and little visible advantage at 4.
Not particularly anxious to offer it as a config option to the user:
I wonder whether to tie it to CONFIG_NR_CPUS, enable split ptlock at
4 or at 8 (would need to get good regular test coverage of both).

By the way, a little detail in pft.c: I think there's one too many
zeroes where wall.tv_nsec is converted for printing - hence the
remarkable trend that Wall time is always X.0Ys.  But that does
not invalidate our conclusions.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
