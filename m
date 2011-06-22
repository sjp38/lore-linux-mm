Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id AA91590016F
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:05:39 -0400 (EDT)
Received: by wye20 with SMTP id 20so691350wye.11
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 04:05:36 -0700 (PDT)
Message-ID: <4E01CC77.10607@ravellosystems.com>
Date: Wed, 22 Jun 2011 14:05:27 +0300
From: Izik Eidus <izik.eidus@ravellosystems.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com> <201106212132.39311.nai.xia@gmail.com> <4E01C752.10405@redhat.com>
In-Reply-To: <4E01C752.10405@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: nai.xia@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On 6/22/2011 1:43 PM, Avi Kivity wrote:
> On 06/21/2011 04:32 PM, Nai Xia wrote:
>> Introduced kvm_mmu_notifier_test_and_clear_dirty(), 
>> kvm_mmu_notifier_dirty_update()
>> and their mmu_notifier interfaces to support KSM dirty bit tracking, 
>> which brings
>> significant performance gain in volatile pages scanning in KSM.
>> Currently, kvm_mmu_notifier_dirty_update() returns 0 if and only if 
>> intel EPT is
>> enabled to indicate that the dirty bits of underlying sptes are not 
>> updated by
>> hardware.
>>
>
>
> Can you quantify the performance gains?
>
>> +int kvm_test_and_clear_dirty_rmapp(struct kvm *kvm, unsigned long 
>> *rmapp,
>> +                   unsigned long data)
>> +{
>> +    u64 *spte;
>> +    int dirty = 0;
>> +
>> +    if (!shadow_dirty_mask) {
>> +        WARN(1, "KVM: do NOT try to test dirty bit in EPT\n");
>> +        goto out;
>> +    }
>> +
>> +    spte = rmap_next(kvm, rmapp, NULL);
>> +    while (spte) {
>> +        int _dirty;
>> +        u64 _spte = *spte;
>> +        BUG_ON(!(_spte&  PT_PRESENT_MASK));
>> +        _dirty = _spte&  PT_DIRTY_MASK;
>> +        if (_dirty) {
>> +            dirty = 1;
>> +            clear_bit(PT_DIRTY_SHIFT, (unsigned long *)spte);
>> +        }
>
> Racy.  Also, needs a tlb flush eventually.

Hi, one of the issues is that the whole point of this patch is not do 
tlb flush eventually,
But I see your point, because other users will not expect such behavior, 
so maybe there is need into a parameter
flush_tlb=?, or add another mmu notifier call?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
