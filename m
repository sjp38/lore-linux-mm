Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id F24FE900185
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:39:47 -0400 (EDT)
Received: by wwf4 with SMTP id 4so807334wwf.35
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 04:39:44 -0700 (PDT)
Message-ID: <4E01D477.70808@ravellosystems.com>
Date: Wed, 22 Jun 2011 14:39:35 +0300
From: Izik Eidus <izik.eidus@ravellosystems.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com> <4E01D0E3.9080508@redhat.com> <4E01D1C8.2050707@redhat.com> <201106221933.37691.nai.xia@gmail.com>
In-Reply-To: <201106221933.37691.nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nai.xia@gmail.com
Cc: Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On 6/22/2011 2:33 PM, Nai Xia wrote:
> On Wednesday 22 June 2011 19:28:08 Avi Kivity wrote:
>> On 06/22/2011 02:24 PM, Avi Kivity wrote:
>>> On 06/22/2011 02:19 PM, Izik Eidus wrote:
>>>> On 6/22/2011 2:10 PM, Avi Kivity wrote:
>>>>> On 06/22/2011 02:05 PM, Izik Eidus wrote:
>>>>>>>> +    spte = rmap_next(kvm, rmapp, NULL);
>>>>>>>> +    while (spte) {
>>>>>>>> +        int _dirty;
>>>>>>>> +        u64 _spte = *spte;
>>>>>>>> +        BUG_ON(!(_spte&   PT_PRESENT_MASK));
>>>>>>>> +        _dirty = _spte&   PT_DIRTY_MASK;
>>>>>>>> +        if (_dirty) {
>>>>>>>> +            dirty = 1;
>>>>>>>> +            clear_bit(PT_DIRTY_SHIFT, (unsigned long *)spte);
>>>>>>>> +        }
>>>>>>> Racy.  Also, needs a tlb flush eventually.
>>>>>> +
>>>>>>
>>>>>> Hi, one of the issues is that the whole point of this patch is not
>>>>>> do tlb flush eventually,
>>>>>> But I see your point, because other users will not expect such
>>>>>> behavior, so maybe there is need into a parameter
>>>>>> flush_tlb=?, or add another mmu notifier call?
>>>>>>
>>>>> If you don't flush the tlb, a subsequent write will not see that
>>>>> spte.d is clear and the write will happen.  So you'll see the page
>>>>> as clean even though it's dirty.  That's not acceptable.
>>>>>
>>>> Yes, but this is exactly what we want from this use case:
>>>> Right now ksm calculate the page hash to see if it was changed, the
>>>> idea behind this patch is to use the dirty bit instead,
>>>> however the guest might not really like the fact that we will flush
>>>> its tlb over and over again, specially in periodically scan like ksm
>>>> does.
>>> I see.
>> Actually, this is dangerous.  If we use the dirty bit for other things,
>> we will get data corruption.
> Yeah,yeah, I actually clarified in a reply letter to Chris about his similar
> concern that we are currently the _only_ user. :)
> We can add the flushing when someone else should rely on this bit.
>

I suggest to add the flushing when someone else will use it as well

Btw I don`t think this whole optimization is worth for kvm guests in 
case that tlb flush must be perform,
in machine with alot of cpus, it much better ksm will burn one cpu 
usage, instead of slowering all the others...
So while this patch will really make ksm look faster, the whole system 
will be slower...

So in case you don`t want to add the flushing when someone else will 
rely on it,
it will be better to use the dirty tick just for userspace applications 
and not for kvm guests..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
