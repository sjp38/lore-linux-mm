Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id CC02E6B0035
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 03:20:46 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so8151254pad.41
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 00:20:46 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id x1si24997518pdn.12.2014.09.24.00.20.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 00:20:45 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id eu11so6504930pac.10
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 00:20:45 -0700 (PDT)
Message-ID: <542270BA.4090708@gmail.com>
Date: Wed, 24 Sep 2014 15:20:26 +0800
From: Wanpeng Li <kernellwp@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4] kvm: Fix page ageing bugs
References: <1411410865-3603-1-git-send-email-andreslc@google.com> <1411422882-16245-1-git-send-email-andreslc@google.com> <20140924022729.GA2889@kernel> <54226CEB.9080504@redhat.com>
In-Reply-To: <54226CEB.9080504@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, Wanpeng Li <wanpeng.li@linux.intel.com>, Andres Lagar-Cavilla <andreslc@google.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Paolo,
ao? 9/24/14, 3:04 PM, Paolo Bonzini a??e??:
> Il 24/09/2014 04:27, Wanpeng Li ha scritto:
>> Hi Andres,
>> On Mon, Sep 22, 2014 at 02:54:42PM -0700, Andres Lagar-Cavilla wrote:
>>> 1. We were calling clear_flush_young_notify in unmap_one, but we are
>>> within an mmu notifier invalidate range scope. The spte exists no more
>>> (due to range_start) and the accessed bit info has already been
>>> propagated (due to kvm_pfn_set_accessed). Simply call
>>> clear_flush_young.
>>>
>>> 2. We clear_flush_young on a primary MMU PMD, but this may be mapped
>>> as a collection of PTEs by the secondary MMU (e.g. during log-dirty).
>>> This required expanding the interface of the clear_flush_young mmu
>>> notifier, so a lot of code has been trivially touched.
>>>
>>> 3. In the absence of shadow_accessed_mask (e.g. EPT A bit), we emulate
>>> the access bit by blowing the spte. This requires proper synchronizing
>>> with MMU notifier consumers, like every other removal of spte's does.
>>>
>> [...]
>>> ---
>>> +	BUG_ON(!shadow_accessed_mask);
>>>
>>> 	for (sptep = rmap_get_first(*rmapp, &iter); sptep;
>>> 	     sptep = rmap_get_next(&iter)) {
>>> +		struct kvm_mmu_page *sp;
>>> +		gfn_t gfn;
>>> 		BUG_ON(!is_shadow_present_pte(*sptep));
>>> +		/* From spte to gfn. */
>>> +		sp = page_header(__pa(sptep));
>>> +		gfn = kvm_mmu_page_get_gfn(sp, sptep - sp->spt);
>>>
>>> 		if (*sptep & shadow_accessed_mask) {
>>> 			young = 1;
>>> 			clear_bit((ffs(shadow_accessed_mask) - 1),
>>> 				 (unsigned long *)sptep);
>>> 		}
>>> +		trace_kvm_age_page(gfn, slot, young);
>> IIUC, all the rmapps in this for loop are against the same gfn which
>> results in the above trace point dump the message duplicated.
> You're right; Andres's patch "[PATCH] kvm/x86/mmu: Pass gfn and level to
> rmapp callback" helps avoiding that.

 From Andres's patch "[PATCH] kvm/x86/mmu: Pass gfn and level to rmapp 
callback"

@@ -1410,25 +1421,20 @@ static int kvm_age_rmapp(struct kvm *kvm, 
unsigned long *rmapp,

for (sptep = rmap_get_first(*rmapp, &iter); sptep;
sptep = rmap_get_next(&iter)) {
- struct kvm_mmu_page *sp;
- gfn_t gfn;
BUG_ON(!is_shadow_present_pte(*sptep));
- /* From spte to gfn. */
- sp = page_header(__pa(sptep));
- gfn = kvm_mmu_page_get_gfn(sp, sptep - sp->spt);
-
if (*sptep & shadow_accessed_mask) {
young = 1;
clear_bit((ffs(shadow_accessed_mask) - 1),
(unsigned long *)sptep);
}
- trace_kvm_age_page(gfn, slot, young);
+ trace_kvm_age_page(gfn, level, slot, young);
}
return young;
}


This trace point still dup duplicated message for the same gfn in the 
for loop.

Regards,
Wanpeng Li

>
> Paolo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
