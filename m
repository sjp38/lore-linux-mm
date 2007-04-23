Message-ID: <462C8BFF.2050405@yahoo.com.au>
Date: Mon, 23 Apr 2007 20:35:43 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au> <462C2DC7.5070709@redhat.com> <462C2F33.8090508@redhat.com> <462C7A6F.9030905@redhat.com> <462C88B1.8080906@yahoo.com.au> <462C8B0A.8060801@redhat.com>
In-Reply-To: <462C8B0A.8060801@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Nick Piggin wrote:
> 
>>> It looks like the tlb flushes (and IPIs) from zap_pte_range()
>>> could have been the problem.  They're gone now.
>>
>>
>> I guess it is a good idea to batch these things. But can you
>> do that on all architectures? What happens if your tlb flush
>> happens after another thread already accesses it again, or
>> after it subsequently gets removed from the address space via
>> another CPU?
> 
> 
> I have thought about this a lot tonight, and have come to the conclusion
> that they are ok.
> 
> The reason is simple:
> 
> 1) we do the TLB flush before we return from the
>    madvise(MADV_FREE) syscall.
> 
> 2) anything that accessess the pages between the start
>    and end of the MADV_FREE procedure does not know in
>    which order we go through the pages, so it could hit
>    a page either before or after we get to processing
>    it
> 
> 3) because of this, we can treat any such accesses as
>    happening simultaneously with the MADV_FREE and
>    as illegal, aka undefined behaviour territory and
>    we do not need to worry about them

Yes, but I'm wondering if it is legal in all architectures.

> 
> 4) because we flush the tlb before releasing the page
>    table lock, other CPUs cannot remove this page from
>    the address space - they will block on the page
>    table lock before looking at this pte

We don't when the ptl is split.

What the tlb flush used to be able to assume is that the page
has been removed from the pagetables when they are put in the
tlb flush batch.

I'm not saying there is any bugs, but just suggesting there
might be.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
