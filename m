Date: Wed, 03 Dec 2003 21:38:54 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: memory hotremove prototype, take 3
Message-ID: <152440000.1070516333@[10.10.2.4]>
In-Reply-To: <20031204035842.72C9A7007A@sv1.valinux.co.jp>
References: <20031201034155.11B387007A@sv1.valinux.co.jp><187360000.1070480461@flay> <20031204035842.72C9A7007A@sv1.valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I used the discontigmem code because this is what we have now.
> My hacks such as zone_active[] will go away when the memory hot add
> code (on which Goto-san is working on) is ready.

Understand that, but it'd be much cleaner (and more likely to get 
accepted) doing it the other way.
 
>> Have you looked at Daniel's CONFIG_NONLINEAR stuff? That provides a much
>> cleaner abstraction for getting rid of discontiguous memory in the non
>> truly-NUMA case, and should work really well for doing mem hot add / remove
>> as well.
> 
> Thanks for pointing out.  I looked at the patch.
> It should be doable to make my patch work with the CONFIG_NONLINEAR
> code.  For my code to work, basically the following functionarities
> are necessary:
> 1. disabling alloc_page from hot-removing area
> and
> 2. enumerating pages in use in hot-removing area.
> 
> My target is somewhat NUMA-ish and fairly large.  So I'm not sure if
> CONFIG_NONLINEAR fits, but CONFIG_NUMA isn't perfect either.

If your target is NUMA, then you really, really need CONFIG_NONLINEAR.
We don't support multiple pgdats per node, nor do I wish to, as it'll
make an unholy mess ;-). With CONFIG_NONLINEAR, the discontiguities
within a node are buried down further, so we have much less complexity
to deal with from the main VM. The abstraction also keeps the poor
VM engineers trying to read / write the code saner via simplicity ;-)

WRT generic discontigmem support (not NUMA), doing that via pgdats
should really go away, as there's no real difference between the 
chunks of physical memory as far as the page allocator is concerned.
The plan is to use Daniel's nonlinear stuff to replace that, and keep
the pgdats strictly for NUMA. Same would apply to hotpluggable zones - 
I'd hate to end up with 512 pgdats of stuff that are really all the
same memory types underneath.

The real issue you have is the mapping of the struct pages - if we can
acheive a non-contig mapping of the mem_map / lmem_map array, we should
be able to take memory on and offline reasonably easy. If you're willing
for a first implementation to pre-allocate the struct page array for 
every possible virtual address, it makes life a lot easier.

Adding the other layer of indirection for access the struct page array
should fix up most of that, and is very easily abstracted out via the
pfn_to_page macros and friends. I ripped out all the direct references
to mem_map indexing already in 2.6, so it should all be nicely 
abstracted out.

>> PS. What's this bit of the patch for?
>> 
>>  void *vmalloc(unsigned long size)
>>  {
>> +#ifdef CONFIG_MEMHOTPLUGTEST
>> +       return __vmalloc(size, GFP_KERNEL, PAGE_KERNEL);
>> +#else
>>         return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL);
>> +#endif
>>  }
> 
> This is necessary because kernel memory cannot be swapped out.
> Only highmem can be hot removed, though it doesn't need to be highmem.
> We can define another zone attribute such as GFP_HOTPLUGGABLE.

You could just lock the pages, I'd think? I don't see at a glance
exactly what you were using this for, but would that work?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
