Date: Wed, 13 Jan 1999 20:07:21 -0700 (MST)
From: Colin Plumb <colin@nyx.net>
Message-Id: <199901140307.UAA25835@nyx10.nyx.net>
Subject: Re: Why don't shared anonymous mappings work?
Sender: owner-linux-mm@kvack.org
To: blah@kvack.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ben LaHaise wrote:
> On Wed, 13 Jan 1999, Colin Plumb wrote:
> 
>> Um, I just thought of another problem with shared anonymous pages.
>> It's similar to the zero-page issue you raised, but it's no longer
>> a single special case.
>> 
>> Copy-on-write and shared mappings.  Let's say that process 1 has a COW
>> copy of page X.  Then the page is shared (via mmap /proc/1/mem or some
>> such) with process 2.  Now process A writes to the page.
> 
> Shared mappings *cannot* be COW.  The mmap(/proc/<pid>/mem) was killed for
> good reasons, and if it's truely nescessary, I suggest that mmap enforce
> that the mapping is of the same (or compatible in the case of files)
> nature.  Anything less overcomplicates things needlessly, leading to a
> Mach like vm system.

Um, okay, how about a more plausible scenario.  Processes 1 and 2
share a page X.  Process 1 forks.

Doesn't this lead to the hairy Mach-like situation?

>> It *is* possible to link PTE entries together in a singly-linked list
>> where a pointer to another PTE is distinguishable from a pointer to
>> a disk block or a valid PTE.  I have thought of using this to update
>> more PTEs when a page is swapped in, as the swapper-in would traverse
>> the list to find the page at the end, swap it in if necessary, and
>> copy the mapping to all the entries it traversed.
> 
> Been there, done it, got the t-shirt.  Creating actual lists for ptes is a
> Bad Idea (tm), as I learned in my original pte_list patch.  It doubles the
> size of the page tables and is *slow*.  Plus, as Linus pointed out a long
> time ago, we've got the information already -- and there's an easy way to
> get it for the anonymous case too (it just requires a wee bit 'o
> bookkeeping on anonymous vmas).  I'm in the process of updating the patch
> now that things are stablizing, so stay tuned...

Um, I think you fail to understand.  I was talking about a linked list
*without* allocating extra space.  The idea is that I don't know of a
processor that requires more than 2 bits (M68K) to mark a PTE as invalid;
the user gets the rest.  Currently the user bits in the invalid PTE
encodings point to swap pages.  You could steal one bit and point to
either a word in memory or a swap page.

Because memory does not fill the entire virtual address space and has
alignment contraints, the number of bits needed for the pointer leaves
room for the invalid flag bit(s) and the memory/swap pointer-type bit.

I am quite aware that enlaring all of the PTEs in the system is a cost to
be avoided if at all possible.
-- 
	-Colin
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
