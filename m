Date: Wed, 2 Apr 2003 13:29:39 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-Id: <20030402132939.647c74a6.akpm@digeo.com>
In-Reply-To: <8910000.1049303582@baldur.austin.ibm.com>
References: <8910000.1049303582@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> 
> I came up with a scheme for accessing the page tables in page_convert_anon
> that should work without requiring locks.  Hugh has looked at it and agrees
> it addresses the problems he found.  Anyway, here's the patch.
> 

I am unable to convince myself that this is correct.  It's playing with pmd
and pte pages which can be freed, reallocated and filled with random stuff.
I really don't see how that can work, but am willing to be taught.

Because we hold i_shared_sem we know that the pgd layer is stable and that
the mm's aren't going away.

Is it not possible to take each mm's page_table_lock?  There's a ranking
problem with pte_chain_lock(), but that can presumably be resolved by doing a
trylock on the page_table_lock and if that fails, restart the whole operation.

But then again, why is it not possible to just do:

	list_for_each_entry(vma, &mapping->i_mmap, shared) {
		if (!pte_chain)
			pte_chain = pte_chain_alloc(GFP_KERNEL);
		spin_lock(&mm->page_table_lock);
		pte = find_pte(vma, page, NULL);
		if (pte)
			pte_chain = page_add_rmap(page, pte, pte_chain);
		spin_unlock(&mm->page_table_lock);
	}

	pte_chain_free(pte_chain);
	up(&mapping->i_shared_sem);

?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
