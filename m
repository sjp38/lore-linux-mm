Message-ID: <419353D5.2080902@yahoo.com.au>
Date: Thu, 11 Nov 2004 22:58:13 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: follow_page()
References: <20041111024015.7c50c13d.akpm@osdl.org>	 <1100170570.2646.27.camel@laptop.fenrus.org>	 <20041111030634.1d06a7c1.akpm@osdl.org> <1100171453.2646.29.camel@laptop.fenrus.org>
In-Reply-To: <1100171453.2646.29.camel@laptop.fenrus.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Arjan van de Ven wrote:
>>>most likely it's because the intent to write to it is given.
>>>It's cheaper for the OS to mark a pagetable dirty than it's for the CPU
>>>to do so (example, on a Pentium 4 it can easily take the cpu 2000 to
>>>4000 cycles to flip the dirty bit on the PTE). So if you KNOW you're
>>>going to write to it (and thus the intent parameter) you can save a big
>>>chunk of those cycles.
>>
>>But it's racy.  writeback can write-and-clean the page before we've
>>modified its contents.  Whether the page contents are altered via disk DMA
>>or a memset or whatever, we can lose the data.  Except callers are
>>correctly dirtying the page after modifying it anyway.
> 
> 
> so in the race case you get the hit of those 4000 cycles... still optimizes the non-race case 
> (so I'd agree that nothing should depend on this function dirtying it; it's a pre-dirty that's an
> optimisation)
> 

Only it doesn't mark the pte dirty, does it?

                 if (pfn_valid(pfn)) {
                         page = pfn_to_page(pfn);
                         if (write && !pte_dirty(pte) && !PageDirty(page))
                                 set_page_dirty(page);
                         mark_page_accessed(page);
                         return page;
                 }

So the CPU will still need to flip the dirty bit on the next write anyway.

It must be some leftover cruft to try to ensure the dirty bit doesn't get lost,
because it's going out of its way not to set the page dirty if the pte is dirty.

Kill it..?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
