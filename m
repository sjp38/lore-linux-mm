Date: 13 Jan 2005 04:18:07 +0100
Date: Thu, 13 Jan 2005 04:18:07 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: page table lock patch V15 [0/7]: overview
Message-ID: <20050113031807.GA97340@muc.de>
References: <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org> <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com> <20050112104326.69b99298.akpm@osdl.org> <41E5AFE6.6000509@yahoo.com.au> <20050112153033.6e2e4c6e.akpm@osdl.org> <41E5B7AD.40304@yahoo.com.au> <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com> <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

> There is still an issue as Hugh rightly observed. One cannot rely on a
> read of a pte/pud/pmd being atomic if the pte is > word size. This occurs
> for all higher levels in handle_mm_fault. Thus we would need to either
> acuire the page_table_lock for some architectures or provide primitives
> get_pgd, get_pud etc that take the page_table_lock on PAE mode. ARGH.
> 

Alternatively you can use a lazy load, checking for changes. 
(untested) 

pte_t read_pte(volatile pte_t *pte) 
{ 
	pte_t n;
	do { 
		n.pte_low = pte->pte_low;
		rmb();
		n.pte_high = pte->pte_high;
		rmb();
	} while (n.pte_low != pte->pte_low); 
	return pte; 	
} 

No atomic operations, I bet it's actually faster than the cmpxchg8.
There is a small risk for livelock, but not much worse than with an
ordinary spinlock.

Not that I get it what you want it for exactly - the content
of the pte could change any time when you don't hold page_table_lock, right?

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
