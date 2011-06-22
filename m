Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1C10D900185
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:19:55 -0400 (EDT)
Received: by mail-wy0-f179.google.com with SMTP id 40so575758wyb.10
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 04:19:54 -0700 (PDT)
Message-ID: <4E01CFD2.6000404@ravellosystems.com>
Date: Wed, 22 Jun 2011 14:19:46 +0300
From: Izik Eidus <izik.eidus@ravellosystems.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com> <201106212132.39311.nai.xia@gmail.com> <4E01C752.10405@redhat.com> <4E01CC77.10607@ravellosystems.com> <4E01CDAD.3070202@redhat.com>
In-Reply-To: <4E01CDAD.3070202@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: nai.xia@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On 6/22/2011 2:10 PM, Avi Kivity wrote:
> On 06/22/2011 02:05 PM, Izik Eidus wrote:
>>>> +    spte = rmap_next(kvm, rmapp, NULL);
>>>> +    while (spte) {
>>>> +        int _dirty;
>>>> +        u64 _spte = *spte;
>>>> +        BUG_ON(!(_spte&  PT_PRESENT_MASK));
>>>> +        _dirty = _spte&  PT_DIRTY_MASK;
>>>> +        if (_dirty) {
>>>> +            dirty = 1;
>>>> +            clear_bit(PT_DIRTY_SHIFT, (unsigned long *)spte);
>>>> +        }
>>>
>>> Racy.  Also, needs a tlb flush eventually.
>> +
>>
>> Hi, one of the issues is that the whole point of this patch is not do 
>> tlb flush eventually,
>> But I see your point, because other users will not expect such 
>> behavior, so maybe there is need into a parameter
>> flush_tlb=?, or add another mmu notifier call?
>>
>
> If you don't flush the tlb, a subsequent write will not see that 
> spte.d is clear and the write will happen.  So you'll see the page as 
> clean even though it's dirty.  That's not acceptable.
>

Yes, but this is exactly what we want from this use case:
Right now ksm calculate the page hash to see if it was changed, the idea 
behind this patch is to use the dirty bit instead,
however the guest might not really like the fact that we will flush its 
tlb over and over again, specially in periodically scan like ksm does.

So what we say here is: it is better to have little junk in the unstable 
tree that get flushed eventualy anyway, instead of make the guest slower....
this race is something that does not reflect accurate of ksm anyway due 
to the full memcmp that we will eventualy perform...

Ofcurse we trust that in most cases, beacuse it take ksm to get into a 
random virtual address in real systems few minutes, there will be 
already tlb flush performed.

What you think about having 2 calls: one that does the expected behivor 
and does flush the tlb, and one that clearly say it doesnt flush the tlb
and expline its use case for ksm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
