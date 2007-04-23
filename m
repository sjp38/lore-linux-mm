Message-ID: <462C8E1D.8000706@redhat.com>
Date: Mon, 23 Apr 2007 06:44:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au> <462C2DC7.5070709@redhat.com> <462C2F33.8090508@redhat.com> <462C7A6F.9030905@redhat.com> <462C88B1.8080906@yahoo.com.au> <462C8B0A.8060801@redhat.com> <462C8BFF.2050405@yahoo.com.au>
In-Reply-To: <462C8BFF.2050405@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------090202030605030100060308"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090202030605030100060308
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Use TLB batching for MADV_FREE.  Adds another 10-15% extra performance
to the MySQL sysbench results on my quad core system.

Signed-off-by: Rik van Riel <riel@redhat.com>
---

Nick Piggin wrote:

>> 3) because of this, we can treat any such accesses as
>>    happening simultaneously with the MADV_FREE and
>>    as illegal, aka undefined behaviour territory and
>>    we do not need to worry about them
> 
> Yes, but I'm wondering if it is legal in all architectures.

It's similar to trying to access memory during an munmap.

You may be able to for a short time, but it'll come back to
haunt you.

>> 4) because we flush the tlb before releasing the page
>>    table lock, other CPUs cannot remove this page from
>>    the address space - they will block on the page
>>    table lock before looking at this pte
> 
> We don't when the ptl is split.

Even then we do.  Each invocation of zap_pte_range() only touches
one page table page, and it flushes the TLB before releasing the
page table lock.

> What the tlb flush used to be able to assume is that the page
> has been removed from the pagetables when they are put in the
> tlb flush batch.

All the tlb flush code seems to assume is that the tlb entries
should be invalidated.

> I'm not saying there is any bugs, but just suggesting there
> might be.

Jakub found a potential bug, in that I did not use an atomic
operation to clear the page table entries.  I've attached a
new patch which simply uses ptep_test_and_clear_dirty/young
to get rid of the dirty and accessed bits.

It uses the same atomic accesses we use elsewhere in the VM
and the code is a line shorter than before.

Andrew, please use this one.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--------------090202030605030100060308
Content-Type: text/x-patch;
 name="linux-2.6-madv_free-lazytlb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6-madv_free-lazytlb.patch"

--- linux-2.6.20.x86_64/mm/memory.c.orig	2007-04-23 02:48:36.000000000 -0400
+++ linux-2.6.20.x86_64/mm/memory.c	2007-04-23 02:54:42.000000000 -0400
@@ -677,11 +677,14 @@ static unsigned long zap_pte_range(struc
 						remove_exclusive_swap_page(page);
 						unlock_page(page);
 					}
-					ptep_clear_flush_dirty(vma, addr, pte);
-					ptep_clear_flush_young(vma, addr, pte);
+					ptep_test_and_clear_dirty(vma, addr, pte);
+					ptep_test_and_clear_young(vma, addr, pte);
 					SetPageLazyFree(page);
 					if (PageActive(page))
 						deactivate_tail_page(page);
+					/* tlb_remove_page frees it again */
+					get_page(page);
+					tlb_remove_page(tlb, page);
 					continue;
 				}
 			}

--------------090202030605030100060308--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
