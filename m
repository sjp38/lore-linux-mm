Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 387B5900185
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:28:19 -0400 (EDT)
Message-ID: <4E01D1C8.2050707@redhat.com>
Date: Wed, 22 Jun 2011 14:28:08 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com> <201106212132.39311.nai.xia@gmail.com> <4E01C752.10405@redhat.com> <4E01CC77.10607@ravellosystems.com> <4E01CDAD.3070202@redhat.com> <4E01CFD2.6000404@ravellosystems.com> <4E01D0E3.9080508@redhat.com>
In-Reply-To: <4E01D0E3.9080508@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Izik Eidus <izik.eidus@ravellosystems.com>
Cc: nai.xia@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On 06/22/2011 02:24 PM, Avi Kivity wrote:
> On 06/22/2011 02:19 PM, Izik Eidus wrote:
>> On 6/22/2011 2:10 PM, Avi Kivity wrote:
>>> On 06/22/2011 02:05 PM, Izik Eidus wrote:
>>>>>> +    spte = rmap_next(kvm, rmapp, NULL);
>>>>>> +    while (spte) {
>>>>>> +        int _dirty;
>>>>>> +        u64 _spte = *spte;
>>>>>> +        BUG_ON(!(_spte&  PT_PRESENT_MASK));
>>>>>> +        _dirty = _spte&  PT_DIRTY_MASK;
>>>>>> +        if (_dirty) {
>>>>>> +            dirty = 1;
>>>>>> +            clear_bit(PT_DIRTY_SHIFT, (unsigned long *)spte);
>>>>>> +        }
>>>>>
>>>>> Racy.  Also, needs a tlb flush eventually.
>>>> +
>>>>
>>>> Hi, one of the issues is that the whole point of this patch is not 
>>>> do tlb flush eventually,
>>>> But I see your point, because other users will not expect such 
>>>> behavior, so maybe there is need into a parameter
>>>> flush_tlb=?, or add another mmu notifier call?
>>>>
>>>
>>> If you don't flush the tlb, a subsequent write will not see that 
>>> spte.d is clear and the write will happen.  So you'll see the page 
>>> as clean even though it's dirty.  That's not acceptable.
>>>
>>
>> Yes, but this is exactly what we want from this use case:
>> Right now ksm calculate the page hash to see if it was changed, the 
>> idea behind this patch is to use the dirty bit instead,
>> however the guest might not really like the fact that we will flush 
>> its tlb over and over again, specially in periodically scan like ksm 
>> does.
>
> I see.

Actually, this is dangerous.  If we use the dirty bit for other things, 
we will get data corruption.

For example we might want to map clean host pages as writeable-clean in 
the spte on a read fault so that we don't get a page fault when they get 
eventually written.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
