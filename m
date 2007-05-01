Date: Tue, 1 May 2007 15:31:02 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22 -mm merge plans: mm-more-rmap-checking
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705011458060.16979@blonde.wat.veritas.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Apr 2007, Andrew Morton wrote:
>... 
>  mm-more-rmap-checking.patch
>...
> 
> Misc MM things.  Will merge.

Would Nick mind very much if I ask you to drop this one?
You did CC me ages ago, but I've only just run across it.
It's a small matter, but I'd prefer it dropped for now.

>> Re-introduce rmap verification patches that Hugh removed when he removed
>> PG_map_lock. PG_map_lock actually isn't needed to synchronise access to
>> anonymous pages, because PG_locked and PTL together already do.
>> 
>> These checks were important in discovering and fixing a rare rmap corruption
>> in SLES9.

It introduces some silly checks which were never in mainline,
nor so far as I can tell in SLES9: I'm thinking of those
+	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
There are few callsites for these rmap functions, I don't think
they need to be checking their arguments in that way.

It also changes the inline page_dup_rmap (a single atomic increment)
into a bugchecking out-of-line function: do we really want to slow
down fork in that way, for 2.6.22 to fix a rare corruption in SLES9?

What I really like about the patch is Nick's observation that my
	/* else checking page index and mapping is racy */
is no longer true: a change we made to the do_swap_page sequence
some while ago has indeed cured that raciness, and I'm happy to
reintroduce the check on mapping and index in page_add_anon_rmap,
and his BUG_ON(!PageLocked(page)) there (despite BUG_ONs falling
out of fashion very recently).

That becomes more important when I send the patches to free up
PG_swapcache, using a PAGE_MAPPING_SWAP bit instead: so I was
planning to include that part of Nick's patch in that series.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
