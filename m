Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GeHlC-0003xs-S4
	for linux-mm@kvack.org; Sun, 29 Oct 2006 22:00:02 +0100
Received: from ool-18b86566.dyn.optonline.net ([24.184.101.102])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sun, 29 Oct 2006 22:00:02 +0100
Received: from giri by ool-18b86566.dyn.optonline.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Sun, 29 Oct 2006 22:00:02 +0100
From: Giridhar Pemmasani <giri@lmc.cs.sunysb.edu>
Subject: Re: Slab panic on 2.6.19-rc3-git5 (-git4 was OK)
Date: Sun, 29 Oct 2006 15:53:12 -0500
Message-ID: <ei34bo$dhr$1@sea.gmane.org>
References: <454442DC.9050703@google.com> <20061029000513.de5af713.akpm@osdl.org> <454471C3.2020005@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:

> Andrew Morton wrote:
>> --- a/mm/vmalloc.c~__vmalloc_area_node-fix
>> +++ a/mm/vmalloc.c
>> @@ -428,7 +428,8 @@ void *__vmalloc_area_node(struct vm_stru
>>  area->nr_pages = nr_pages;
>>  /* Please note that the recursion is strictly bounded. */
>>  if (array_size > PAGE_SIZE) {
>> -            pages = __vmalloc_node(array_size, gfp_mask, PAGE_KERNEL, node);
>> +            pages = __vmalloc_node(array_size, gfp_mask & ~__GFP_HIGHMEM,
>> +                                    PAGE_KERNEL, node);
>>  area->flags |= VM_VPAGES;
>>  } else {
>>  pages = kmalloc_node(array_size,
> 
> Don't you actually *want* the page array to be allocated from highmem? So
> the gfp mask here should be just for whether we're allowed to sleep /
> reclaim (ie gfp_mask & ~(__GFP_DMA|__GFP_DMA32) | (__GFP_HIGHMEM))?
> 
> Slab allocations should be (gfp_mask &
> ~(__GFP_DMA|__GFP_DMA32|__GFP_HIGHMEM)), which you could mask in
> __get_vm_area_node
> 

Since gfp_mask there would also have GFP_ZERO, we need to mask off that too.
How about my earlier suggestion of masking off flags in __get_vm_area_node
with GFP_LEVEL_MASK?

Giri

PS: I am not sure if this mail gets to all recipients in the original
thread - I am not subscribed to lkml and I haven't found a way to reply to
all people and the group.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
