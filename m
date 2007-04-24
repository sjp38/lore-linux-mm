Message-ID: <462D643C.5020709@redhat.com>
Date: Mon, 23 Apr 2007 21:58:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au> <462C2DC7.5070709@redhat.com> <462C2F33.8090508@redhat.com> <462C7A6F.9030905@redhat.com> <462C88B1.8080906@yahoo.com.au> <462C8B0A.8060801@redhat.com> <462C8BFF.2050405@yahoo.com.au> <462C8E1D.8000706@redhat.com> <462D5A2E.5060908@yahoo.com.au>
In-Reply-To: <462D5A2E.5060908@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------040707040500040700090600"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040707040500040700090600
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

This should fix the MADV_FREE code for PPC's hashed tlb.

Signed-off-by: Rik van Riel <riel@redhat.com>
---

Nick Piggin wrote:
>> Nick Piggin wrote:
>>
>>>> 3) because of this, we can treat any such accesses as
>>>>    happening simultaneously with the MADV_FREE and
>>>>    as illegal, aka undefined behaviour territory and
>>>>    we do not need to worry about them
>>>
>>>
>>> Yes, but I'm wondering if it is legal in all architectures.
>>
>>
>> It's similar to trying to access memory during an munmap.
>>
>> You may be able to for a short time, but it'll come back to
>> haunt you.
> 
> The question is whether the architecture specific tlb
> flushing code will break or not.

I guess we'll need to call tlb_remove_tlb_entry() inside the
MADV_FREE code to keep powerpc happy.

Thanks for pointing this one out.

>> Even then we do.  Each invocation of zap_pte_range() only touches
>> one page table page, and it flushes the TLB before releasing the
>> page table lock.
> 
> What kernel are you looking at? -rc7 and rc6-mm1 don't, AFAIKS.

Oh dear.  I see it now...

The tlb end things inside zap_pte_range() are actually
noops and the actual tlb flush only happens inside
zap_page_range().

I guess the fact that munmap gets the mmap_sem for
writing should save us, though...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--------------040707040500040700090600
Content-Type: text/x-patch;
 name="linux-2.6-madv-ppcfix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-madv-ppcfix.patch"

--- linux-2.6.20.x86_64/mm/memory.c.noppc	2007-04-23 21:50:09.000000000 -0400
+++ linux-2.6.20.x86_64/mm/memory.c	2007-04-23 21:48:59.000000000 -0400
@@ -679,6 +679,7 @@ static unsigned long zap_pte_range(struc
 					}
 					ptep_test_and_clear_dirty(vma, addr, pte);
 					ptep_test_and_clear_young(vma, addr, pte);
+					tlb_remove_tlb_entry(tlb, pte, addr);
 					SetPageLazyFree(page);
 					if (PageActive(page))
 						deactivate_tail_page(page);

--------------040707040500040700090600--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
