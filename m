Date: Mon, 6 Nov 2000 09:23:38 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
In-Reply-To: <20001106150539.A19112@redhat.com>
Message-ID: <Pine.LNX.4.10.10011060912120.7955-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 6 Nov 2000, Stephen C. Tweedie wrote:
> 
> > > -		map = follow_page(ptr);
> > > +		map = follow_page(ptr, datain);
> > 
> > Here you should _first_ follow_page and do handle_mm_fault _only_ if the pte is
> > not ok.
> 
> Agreed --- I'll push that as a performace diff to Linus once the
> essential bug-fixes are in.

I would _really_ want to see follow_page() just cleaned up altogether.

We should NOT have code that messes with combinations of
"handle_mm_fault()" and "follow_page()" at all.

We should just change the page followers (do_no_page() and friends) to
return the "struct page" directly, instead of returning an "int". Then
we'd have something on the order of

struct page * follow_page(struct mm_struct *mm, struct vm_area_struct * vma,
        unsigned long address, int write_access)
{
	pgd_t *pgd;
	pmd_t *pmd;

	pgd = pgd_offset(mm, address);
	pmd = pmd_alloc(pgd, address);

	if (pmd) {
		pte_t * pte = pte_alloc(pmd, address);
		if (pte) {
			struct page * page = handle_pte_fault(mm, vma, address, write_access, pte);
			if (page)
				return page;
		}
	}
	return NULL;
}

and just a simple

int handle_pte_fault(struct mm_struct *mm, ...
{
	struct page * page = follow_page(..);
	if (!IS_ERR(page)) {
		page_cache_release(page);	/* it's in the page tables */
		return 1;
	}
	return PTR_ERR(page);
}

and you' dbe done with it. 

Yes, I realize that we need to do the min_flt/maj_flt stuff too, and that
we'd need to tweak the return codes for sigbus/oom instead of having the
current 0 == SIGBUS, -1 == OOM magic, but that would actually clean things
up and would allow us to return proper errors on page faults (like
indicating whether it was due to ENOMEM or due to EIO or due to some other
reason like EPERM that we couldn't handle the page fault).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
