Message-ID: <4365E1B4.4050409@yahoo.com.au>
Date: Mon, 31 Oct 2005 20:19:48 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: munmap extremely slow even with untouched mapping.
References: <20051028013738.GA19727@attica.americas.sgi.com> <43620138.6060707@yahoo.com.au> <Pine.LNX.4.61.0510281557440.3229@goblin.wat.veritas.com> <43644C22.8050501@yahoo.com.au> <Pine.LNX.4.61.0510301631360.2848@goblin.wat.veritas.com> <4365DF9A.5040101@yahoo.com.au>
In-Reply-To: <4365DF9A.5040101@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> The address based work estimate for unmapping (for lockbreak) is and
> always was horribly inefficient for sparse mappings. The problem is most
> simply explained with an example:
> 
> If we find a pgd is clear, we still have to call into unmap_page_range
> PGDIR_SIZE / ZAP_BLOCK_SIZE times, each time checking the clear pgd, in
> order to progress the working address to the next pgd.
> 
> The fundamental way to solve the problem is to keep track of the end address
> we've processed and pass it back to the higher layers.
> 
> From: Robin Holt <holt@sgi.com>
> 
> Modification to completely get away from address based work estimate and
> instead use an abstract count, with a very small cost for empty entries as
> opposed to present pages.
> 
> On 2.6.14-git2, ppc64, and CONFIG_PREEMPT=y, mapping and unmapping 1TB of
> virtual address space takes 1.69s; with the following patch applied, this
> operation can be done 1000 times in less than 0.01s
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 

Note that I think this patch will cripple our nice page table folding
in the unmap path, due to no longer using the 'next' from p??_addr_end,
even if the compiler is very smart.

I haven't confirmed this by looking at assembly, however I'd be almost
sure this is the case. Possibly a followup patch would be in order so
as to restore this, but I couldn't think of a really nice way to do it.

Basically we only want to return the return of the next level
zap_p??_range in the case that it returns with zap_work < 0.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
