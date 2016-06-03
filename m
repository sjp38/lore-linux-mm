Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D73146B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 22:56:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id p194so95964237iod.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 19:56:50 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id t18si4178830itb.78.2016.06.02.19.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 19:56:50 -0700 (PDT)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 2 Jun 2016 20:56:49 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] powerpc/mm/radix: Implement tlb mmu gather flush efficiently
In-Reply-To: <20160602131250.e4d43401e7eade277bc4476a@linux-foundation.org>
References: <1464860389-29019-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1464860389-29019-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160602131250.e4d43401e7eade277bc4476a@linux-foundation.org>
Date: Fri, 03 Jun 2016 08:26:43 +0530
Message-ID: <87porzvv2s.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu,  2 Jun 2016 15:09:49 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> Now that we track page size in mmu_gather, we can use address based
>> tlbie format when doing a tlb_flush(). We don't do this if we are
>> invalidating the full address space.
>> 
>> ...
>>
>>  void radix__tlb_flush(struct mmu_gather *tlb)
>>  {
>> +	int psize = 0;
>>  	struct mm_struct *mm = tlb->mm;
>> -	radix__flush_tlb_mm(mm);
>> +	int page_size = tlb->page_size;
>> +
>> +	psize = radix_get_mmu_psize(page_size);
>> +	if (psize == -1)
>> +		/* unknown page size */
>> +		goto flush_mm;
>> +
>> +	if (!tlb->fullmm && !tlb->need_flush_all)
>> +		radix__flush_tlb_range_psize(mm, tlb->start, tlb->end, psize);
>> +	else
>> +flush_mm:
>> +		radix__flush_tlb_mm(mm);
>
> That's kinda ugly.  What about
>
> void radix__tlb_flush(struct mmu_gather *tlb)
> {
> 	int psize = 0;
> 	struct mm_struct *mm = tlb->mm;
> 	int page_size = tlb->page_size;
>
> 	psize = radix_get_mmu_psize(page_size);
>
> 	if (psize != -1 && !tlb->fullmm && !tlb->need_flush_all)
> 		radix__flush_tlb_range_psize(mm, tlb->start, tlb->end, psize);
> 	else
> 		radix__flush_tlb_mm(mm);
> }
>
> ?
>
> We lost the comment, but that can be neatly addressed by documenting
> radix_get_mmu_psize() (of course!).  Please send along a comment to do
> this and I'll add it in.


I will update the patch. But this patch (Patch 4) need to go through
powerpc tree because radix__flush_tlb_range_psize is not yet upstream.
As I mentioned in the previous thread, if you can take patch 1 to patch 3 that
will enable wider testing w.r.t other archs and ppc64 related changes can
go later via powerpc tree ?

>
> --- a/arch/powerpc/mm/tlb-radix.c~powerpc-mm-radix-implement-tlb-mmu-gather-flush-efficiently-fix
> +++ a/arch/powerpc/mm/tlb-radix.c
> @@ -265,13 +265,9 @@ void radix__tlb_flush(struct mmu_gather
>  	int page_size = tlb->page_size;
>
>  	psize = radix_get_mmu_psize(page_size);
> -	if (psize == -1)
> -		/* unknown page size */
> -		goto flush_mm;
>
> -	if (!tlb->fullmm && !tlb->need_flush_all)
> +	if (psize != -1 && !tlb->fullmm && !tlb->need_flush_all)
>  		radix__flush_tlb_range_psize(mm, tlb->start, tlb->end, psize);
>  	else
> -flush_mm:
>  		radix__flush_tlb_mm(mm);
>  }
> _
>
> I'll await feedback from the other PPC developers before doing anything
> further on this patchset.
>
> hm, no ppc mailing lists were cc'ed.  Regrettable.

I missed that. I can resend the series again adding ppc-devel to cc: ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
