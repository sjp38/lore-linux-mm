Date: Fri, 19 Jan 2001 16:08:11 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [RFC] 2-pointer PTE chaining idea
Message-ID: <Pine.LNX.4.31.0101181253540.31432-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: davem@redhat.com, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

Hi,

I think I have come up with an idea that would allow us to
do pte-chaining with an overhead of just 2 pointers (8 bytes
on x86) per pte ...

This idea depends on the fact that each page table is only
used by one mm_struct, which is probably a safe assumption
since shared page tables are a big can of worms on some
architectures (shared TLB entries on machines with virtually
indexed caches, etc.).


	Basics:

The pte chain entries will look like this:

struct pte_chain {
	struct pte_chain * next;
	struct pte_t * pte;
};

... where *next points to the next pte_chain entry in the list
of pte_chains for this page and *pte points directly to the
page table entry that maps this page.

>From the pte_chain pointer, refill_inactive_scan can directly
do test_and_clear_referenced(pte) to implement the page aging.

In order to find the vma and the mm_struct each pte belongs to,
we can use the ->mapping and ->index fields in the page_struct
of the page table, with the ->mapping pointing to the mm_struct
and the ->index containing the offset within the mm_struct, so
we can support non-aligned or even page-sized VMAs ... this means
walking 2 or 3 pointers extra when unmapping a page, but the page
scanning is really cheap.


	Allocation trick / overhead:

In order to avoid failing allocations for pte_chain structs and
nasty things like that, we can simply unmap a pte whenever we run
out of reverse mapping space or when an allocation fails.


	DIRTY trick you don't want to read:

We could reduce the overhead further by using the dirty trick of
having a set of 2^16 struct pte_chains per N pages of physical
memory.

This way we can remove the *next pointer and turn that into an
array offset for this smaller local array, shaving off 2 bytes
in the struct pte_chain. It also means that we don't need to
have a pointer in the page_struct, but can subdivide the word
that's currently taken by page->age and put a starting array
offset into 16 bits out of this word.

	(as I said .. DIRTY, please ignore)


Would this main idea (with the 2-pointer struct pte_chain) work
for pte chaining and do everything we want ?

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
