Message-ID: <41E5C3E6.90906@yahoo.com.au>
Date: Thu, 13 Jan 2005 11:42:14 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: page table lock patch V15 [0/7]: overview
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain> <Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org> <Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0412011545060.5721@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501041129030.805@schroedinger.engr.sgi.com> <Pine.LNX.4.58.0501041137410.805@schroedinger.engr.sgi.com> <m1652ddljp.fsf@muc.de> <Pine.LNX.4.58.0501110937450.32744@schroedinger.engr.sgi.com> <41E4BCBE.2010001@yahoo.com.au> <20050112014235.7095dcf4.akpm@osdl.org> <Pine.LNX.4.58.0501120833060.10380@schroedinger.engr.sgi.com> <20050112104326.69b99298.akpm@osdl.org> <41E5AFE6.6000509@yahoo.com.au> <20050112153033.6e2e4c6e.akpm@osdl.org> <41E5B7AD.40304@yahoo.com.au> <Pine.LNX.4.58.0501121552170.12669@schroedinger.engr.sgi.com> <41E5BC60.3090309@yahoo.com.au> <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501121611590.12872@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, ak@muc.de, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 13 Jan 2005, Nick Piggin wrote:
> 
> 
>>>Pointer operations and word size operations are atomic. So this is mostly
>>>okay.
>>>
>>>The issue arises on architectures that have a large pte size than the
>>>wordsize. This is only on i386 PAE mode and S/390. S/390 falls back to
>>>the page table lock  for these operations. PAE mode should do the same and
>>>not use atomic ops if they cannot be made to work in a reasonable manner.
>>>
>>
>>Yep well you should be OK then. Your implementation has the advantage
>>that it only instantiates previously clear ptes... hmm, no I'm wrong,
>>your ptep_set_access_flags path modifies an existing pte. I think this
>>can cause subtle races in copy_page_range, and maybe other places,
>>can't it?
> 
> 
> ptep_set_access_flags is only used after acquiring the page_table_lock and
> does not clear a pte. That is safe. The only critical thing is if a pte
> would be cleared while holding the page_table_lock. That used to occur in
> the swapper code but we modified that.
> 

I mean what used to be the ptep_set_access_flags path. Where you are
now modifying a pte without the ptl. However after a second look, it
seems like that won't be a problem.

> There is still an issue as Hugh rightly observed. One cannot rely on a
> read of a pte/pud/pmd being atomic if the pte is > word size. This occurs
> for all higher levels in handle_mm_fault. Thus we would need to either
> acuire the page_table_lock for some architectures or provide primitives
> get_pgd, get_pud etc that take the page_table_lock on PAE mode. ARGH.
> 

Yes I know. I would say that having arch-definable accessors for the
page tables wouldn't be a bad idea anyway, and the flexibility may
come in handy for other things.

It would be a big, annoying patch though :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
