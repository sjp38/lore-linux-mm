Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id A39DE6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 13:04:25 -0400 (EDT)
Received: by mail-yk0-f171.google.com with SMTP id 79so2170291ykr.16
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 10:04:25 -0700 (PDT)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id u26si9527705yhf.138.2014.09.23.10.04.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 10:04:24 -0700 (PDT)
Received: by mail-yh0-f45.google.com with SMTP id a41so1926256yho.18
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 10:04:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <542125F1.3080607@redhat.com>
References: <1411410865-3603-1-git-send-email-andreslc@google.com>
	<1411422882-16245-1-git-send-email-andreslc@google.com>
	<542125F1.3080607@redhat.com>
Date: Tue, 23 Sep 2014 10:04:24 -0700
Message-ID: <CAJu=L58L4XrACYieQuM412TJuJoD+QYBb=qOcN1MtwdVAPzn2Q@mail.gmail.com>
Subject: Re: [PATCH v4] kvm: Fix page ageing bugs
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andres Lagar-Cavilla <andreslc@gooogle.com>

On Tue, Sep 23, 2014 at 12:49 AM, Paolo Bonzini <pbonzini@redhat.com> wrote:
> Il 22/09/2014 23:54, Andres Lagar-Cavilla ha scritto:
>> @@ -1406,32 +1406,24 @@ static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp,
>>       struct rmap_iterator uninitialized_var(iter);
>>       int young = 0;
>>
>> -     /*
>> -      * In case of absence of EPT Access and Dirty Bits supports,
>> -      * emulate the accessed bit for EPT, by checking if this page has
>> -      * an EPT mapping, and clearing it if it does. On the next access,
>> -      * a new EPT mapping will be established.
>> -      * This has some overhead, but not as much as the cost of swapping
>> -      * out actively used pages or breaking up actively used hugepages.
>> -      */
>> -     if (!shadow_accessed_mask) {
>> -             young = kvm_unmap_rmapp(kvm, rmapp, slot, data);
>> -             goto out;
>> -     }
>> +     BUG_ON(!shadow_accessed_mask);
>>
>>       for (sptep = rmap_get_first(*rmapp, &iter); sptep;
>>            sptep = rmap_get_next(&iter)) {
>> +             struct kvm_mmu_page *sp;
>> +             gfn_t gfn;
>>               BUG_ON(!is_shadow_present_pte(*sptep));
>> +             /* From spte to gfn. */
>> +             sp = page_header(__pa(sptep));
>> +             gfn = kvm_mmu_page_get_gfn(sp, sptep - sp->spt);
>>
>>               if (*sptep & shadow_accessed_mask) {
>>                       young = 1;
>>                       clear_bit((ffs(shadow_accessed_mask) - 1),
>>                                (unsigned long *)sptep);
>>               }
>> +             trace_kvm_age_page(gfn, slot, young);
>
> Yesterday I couldn't think of a way to avoid the
> page_header/kvm_mmu_page_get_gfn on every iteration, but it's actually
> not hard.  Instead of passing hva as datum, you can pass (unsigned long)
> &start.  Then you can add PAGE_SIZE to it at the end of every call to
> kvm_age_rmapp, and keep the old tracing logic.

I'm not sure. The addition is not always by PAGE_SIZE, since it
depends on the current level we are iterating at in the outer
kvm_handle_hva_range(). IOW, could be PMD_SIZE or even PUD_SIZE, and
is_large_pte() enough to tell?

This is probably worth a general fix, I can see all the callbacks
benefiting from knowing the gfn (passed down by
kvm_handle_hva_range()) without any additional computation, and adding
that to a tracing call if they don't already.

Even passing the level down to the callback would help by cutting down
to one arithmetic op (subtract rmapp from slot rmap base pointer for
that level)

Andres
>
>
> Paolo



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
