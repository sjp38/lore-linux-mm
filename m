Date: Wed, 02 Apr 2003 15:56:33 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-ID: <80300000.1049320593@baldur.austin.ibm.com>
In-Reply-To: <20030402132939.647c74a6.akpm@digeo.com>
References: <8910000.1049303582@baldur.austin.ibm.com>
 <20030402132939.647c74a6.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, April 02, 2003 13:29:39 -0800 Andrew Morton
<akpm@digeo.com> wrote:

> I am unable to convince myself that this is correct.  It's playing with
> pmd and pte pages which can be freed, reallocated and filled with random
> stuff. I really don't see how that can work, but am willing to be taught.
> 
> Because we hold i_shared_sem we know that the pgd layer is stable and that
> the mm's aren't going away.

The sequence is the following:

1.  take a copy of the reference to the page (the pgd or pmd entry)
2.  validate the copy
3.  establish a pointer into the page
4.  pull the data from the page (pmd or pte entry)
5.  validate the original reference again
6.  use the data

This guarantees that the data is from a page that's still valid, since the
pgd or pmd entry are cleared when the page is released.  We're helped by
the fact that for an invalid page we can simply return failure.

> Is it not possible to take each mm's page_table_lock?  There's a ranking
> problem with pte_chain_lock(), but that can presumably be resolved by
> doing a trylock on the page_table_lock and if that fails, restart the
> whole operation.

It is possible, but would be much more painful.

> But then again, why is it not possible to just do:
> 
> 	list_for_each_entry(vma, &mapping->i_mmap, shared) {
> 		if (!pte_chain)
> 			pte_chain = pte_chain_alloc(GFP_KERNEL);
> 		spin_lock(&mm->page_table_lock);
> 		pte = find_pte(vma, page, NULL);
> 		if (pte)
> 			pte_chain = page_add_rmap(page, pte, pte_chain);
> 		spin_unlock(&mm->page_table_lock);
> 	}
> 
> 	pte_chain_free(pte_chain);
> 	up(&mapping->i_shared_sem);
> 
> ?

Because the page is in transition from !PageAnon to PageAnon.  We have to
hold the pte_chain lock during the entire transition in case someone else
tries to do something like page_remove_rmap, which would break.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
