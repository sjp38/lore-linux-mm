Date: Fri, 19 Jan 2001 12:37:10 +0100 (CET)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: <mingo@elte.hu>
Subject: Re: [RFC] 2-pointer PTE chaining idea
In-Reply-To: <Pine.LNX.4.31.0101181253540.31432-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.30.0101191220360.1802-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jan 2001, Rik van Riel wrote:

> The pte chain entries will look like this:
>
> struct pte_chain {
> 	struct pte_chain * next;
> 	struct pte_t * pte;
> };

why not just use a 'shadow' pagetable for every pagetable. The 'shadow'
pagetable has the same physical structure but has soft data. So for every
pte one has 32 bits (well, sizeof(pte_t) bytes) worth of extra
information.

the most obvious implementation would be to use an order-2 allocation, but
that is problematic on low memory systems (which we are trying to optimize
...). BUT, maybe it's not all that problematic, since we have reverse ptes
already :-) [catch-22]

a variation of this scheme that avoids the order-2 allocation is to use an
explicit (not implicit), per-pagetable pointer, by (ab)using the
pagetable's page->mapping or page->list pointer. This way the 'soft' part
of the pagetable can be allocated anywhere, and can be found via
page->list.next. [and the soft table points to the hardware table via
page->list.next as well] (The pagetable's page->list is an unused field.)

traversing the pte list (chain) of alias mappings goes like this:

 pte_t * get_next_pte(pte_t *pte)
 {
	soft_table = (mem_map + MAP_NR(pte))->list.next;
	next_pte = soft_table + ((pte & ~PAGE_MASK) >> PTE_SHIFT);
 }

it's fast, O(1) and has a 1-pointer overhead per pte and uses PAGE_SIZE
allocations only. Important: there is no extra allocation overhead while
establishing mappings. It works on every architecture, because the
allocation 'mirrors' that of the real pagetable's allocation.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
