Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9FB016B008C
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:53:50 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id r5so547115qcx.18
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:53:50 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 4si497207qat.146.2014.03.04.19.53.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:53:50 -0800 (PST)
Message-ID: <53169FC5.4080006@oracle.com>
Date: Tue, 04 Mar 2014 22:53:41 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at mm/huge_memory.c:2785!
References: <530F3F0A.5040304@oracle.com>	<20140227150313.3BA27E0098@blue.fi.intel.com> <CAA_GA1c02iSmkmCLHFkrK4b4W+JppZ4CSMUJ-Wn1rCs-c=dV6g@mail.gmail.com>
In-Reply-To: <CAA_GA1c02iSmkmCLHFkrK4b4W+JppZ4CSMUJ-Wn1rCs-c=dV6g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 03/04/2014 10:16 PM, Bob Liu wrote:
> On Thu, Feb 27, 2014 at 11:03 PM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
>> Sasha Levin wrote:
>>> Hi all,
>>>
>>> While fuzzing with trinity inside a KVM tools guest running latest -next kernel I've stumbled on the
>>> following spew:
>>>
>>> [ 1428.146261] kernel BUG at mm/huge_memory.c:2785!
>>
>> Hm, interesting.
>>
>> It seems we either failed to split huge page on vma split or it
>> materialized from under us. I don't see how it can happen:
>>
>>    - it seems we do the right thing with vma_adjust_trans_huge() in
>>      __split_vma();
>>    - we hold ->mmap_sem all the way from vm_munmap(). At least I don't see
>>      a place where we could drop it;
>>
>
> Enable CONFIG_DEBUG_VM may show some useful information, at least we
> can confirm weather rwsem_is_locked(&tlb->mm->mmap_sem) before
> split_huge_page_pmd().

I have CONFIG_DEBUG_VM enabled and that code you're talking is not triggering, so mmap_sem
is locked.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
