Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB076B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 12:55:34 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h3so421573igd.14
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 09:55:34 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id qr10si2258773igb.42.2014.09.16.09.55.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 09:55:33 -0700 (PDT)
Received: by mail-ig0-f179.google.com with SMTP id r10so429033igi.0
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 09:55:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJu=L5_w+u6komiZB6RE1+9H5MiL+8RJBy_GYO6CmjqkhaG5Zg@mail.gmail.com>
References: <1410811885-17267-1-git-send-email-andreslc@google.com>
	<54184078.4070505@redhat.com>
	<CAJu=L5_w+u6komiZB6RE1+9H5MiL+8RJBy_GYO6CmjqkhaG5Zg@mail.gmail.com>
Date: Tue, 16 Sep 2014 09:55:32 -0700
Message-ID: <CAJu=L597w-DNGV_7t9k36eh9R=JgnkUHFKwXUL2WVaMmEW5FNw@mail.gmail.com>
Subject: Re: [PATCH] kvm: Faults which trigger IO release the mmap_sem
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 16, 2014 at 9:52 AM, Andres Lagar-Cavilla
<andreslc@google.com> wrote:

Apologies to all. Resend as lists rejected my gmail-formatted version.
Now on plain text. Won't happen again.

> On Tue, Sep 16, 2014 at 6:51 AM, Paolo Bonzini <pbonzini@redhat.com> wrote:
>>
>> Il 15/09/2014 22:11, Andres Lagar-Cavilla ha scritto:
>> > +     if (!locked) {
>> > +             BUG_ON(npages != -EBUSY);
>>
>> VM_BUG_ON perhaps?
>
> Sure.
>
>>
>> > @@ -1177,9 +1210,15 @@ static int hva_to_pfn_slow(unsigned long addr,
>> > bool *async, bool write_fault,
>> >               npages = get_user_page_nowait(current, current->mm,
>> >                                             addr, write_fault, page);
>> >               up_read(&current->mm->mmap_sem);
>> > -     } else
>> > -             npages = get_user_pages_fast(addr, 1, write_fault,
>> > -                                          page);
>> > +     } else {
>> > +             /*
>> > +              * By now we have tried gup_fast, and possible async_pf,
>> > and we
>> > +              * are certainly not atomic. Time to retry the gup,
>> > allowing
>> > +              * mmap semaphore to be relinquished in the case of IO.
>> > +              */
>> > +             npages = kvm_get_user_page_retry(current, current->mm,
>> > addr,
>> > +                                              write_fault, page);
>>
>> This is a separate logical change.  Was this:
>>
>>         down_read(&mm->mmap_sem);
>>         npages = get_user_pages(NULL, mm, addr, 1, 1, 0, NULL, NULL);
>>         up_read(&mm->mmap_sem);
>>
>> the intention rather than get_user_pages_fast?
>
>
> Nope. The intention was to pass FAULT_FLAG_RETRY to the vma fault handler
> (without _NOWAIT). And once you do that, if you come back without holding
> the mmap sem, you need to call yet again.
>
> By that point in the call chain I felt comfortable dropping the _fast. All
> paths that get there have already tried _fast (and some have tried _NOWAIT).
>
>>
>> I think a first patch should introduce kvm_get_user_page_retry ("Retry a
>> fault after a gup with FOLL_NOWAIT.") and the second would add
>> FOLL_TRIED ("This properly relinquishes mmap semaphore if the
>> filemap/swap has to wait on page lock (and retries the gup to completion
>> after that").
>
>
> That's not what FOLL_TRIED does. The relinquishing of mmap semaphore is done
> by this patch minus the FOLL_TRIED bits. FOLL_TRIED will let the fault
> handler (e.g. filemap) know that we've been there and waited on the IO
> already, so in the common case we won't need to redo the IO.
>
> Have a look at how FAULT_FLAG_TRIED is used in e.g. arch/x86/mm/fault.c.
>
>>
>>
>> Apart from this, the patch looks good.  The mm/ parts are minimal, so I
>> think it's best to merge it through the KVM tree with someone's Acked-by.
>
>
> Thanks!
> Andres
>
>>
>>
>> Paolo
>
>
>
>
> --
> Andres Lagar-Cavilla | Google Cloud Platform | andreslc@google.com |
> 647-778-4380



-- 
Andres Lagar-Cavilla | Google Cloud Platform | andreslc@google.com |
647-778-4380

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
