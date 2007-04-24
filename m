Message-ID: <462D5A2E.5060908@yahoo.com.au>
Date: Tue, 24 Apr 2007 11:15:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au> <462C2DC7.5070709@redhat.com> <462C2F33.8090508@redhat.com> <462C7A6F.9030905@redhat.com> <462C88B1.8080906@yahoo.com.au> <462C8B0A.8060801@redhat.com> <462C8BFF.2050405@yahoo.com.au> <462C8E1D.8000706@redhat.com>
In-Reply-To: <462C8E1D.8000706@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Use TLB batching for MADV_FREE.  Adds another 10-15% extra performance
> to the MySQL sysbench results on my quad core system.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> 
> Nick Piggin wrote:
> 
>>> 3) because of this, we can treat any such accesses as
>>>    happening simultaneously with the MADV_FREE and
>>>    as illegal, aka undefined behaviour territory and
>>>    we do not need to worry about them
>>
>>
>> Yes, but I'm wondering if it is legal in all architectures.
> 
> 
> It's similar to trying to access memory during an munmap.
> 
> You may be able to for a short time, but it'll come back to
> haunt you.

The question is whether the architecture specific tlb
flushing code will break or not.


>>> 4) because we flush the tlb before releasing the page
>>>    table lock, other CPUs cannot remove this page from
>>>    the address space - they will block on the page
>>>    table lock before looking at this pte
>>
>>
>> We don't when the ptl is split.
> 
> 
> Even then we do.  Each invocation of zap_pte_range() only touches
> one page table page, and it flushes the TLB before releasing the
> page table lock.

What kernel are you looking at? -rc7 and rc6-mm1 don't, AFAIKS.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
