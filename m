Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 803B16B05FE
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 12:43:04 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n2so8763175oig.12
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 09:43:04 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h124si8405100oia.353.2017.07.15.09.43.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 09:43:03 -0700 (PDT)
Received: from mail-vk0-f41.google.com (mail-vk0-f41.google.com [209.85.213.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E735E238F2
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 16:43:02 +0000 (UTC)
Received: by mail-vk0-f41.google.com with SMTP id f68so56382076vkg.2
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 09:43:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170714200624.GA22585@rkaganb.sw.ru>
References: <cover.1495990440.git.luto@kernel.org> <7d369dab491071edc02d39e2fa2b218a3be401f2.1495990440.git.luto@kernel.org>
 <20170714200624.GA22585@rkaganb.sw.ru>
From: Andy Lutomirski <luto@kernel.org>
Date: Sat, 15 Jul 2017 09:42:41 -0700
Message-ID: <CALCETrXjE1htOUCgbwAm-ECXY3cGFd6S95tDFo2E9PDQt2Z2mw@mail.gmail.com>
Subject: Re: [PATCH v4 8/8] x86,kvm: Teach KVM's VMX code that CR3 isn't a constant
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Kagan <rkagan@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm list <kvm@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Fri, Jul 14, 2017 at 1:06 PM, Roman Kagan <rkagan@virtuozzo.com> wrote:
> On Sun, May 28, 2017 at 10:00:17AM -0700, Andy Lutomirski wrote:
>> When PCID is enabled, CR3's PCID bits can change during context
>> switches, so KVM won't be able to treat CR3 as a per-mm constant any
>> more.
>>
>> I structured this like the existing CR4 handling.  Under ordinary
>> circumstances (PCID disabled or if the current PCID and the value
>> that's already in the VMCS match), then we won't do an extra VMCS
>> write, and we'll never do an extra direct CR3 read.  The overhead
>> should be minimal.
>>
>> I disallowed using the new helper in non-atomic context because
>> PCID support will cause CR3 to stop being constant in non-atomic
>> process context.
>>
>> (Frankly, it also scares me a bit that KVM ever treated CR3 as
>> constant, but it looks like it was okay before.)
>>
>> Cc: Paolo Bonzini <pbonzini@redhat.com>
>> Cc: Radim Kr=C4=8Dm=C3=A1=C5=99 <rkrcmar@redhat.com>
>> Cc: kvm@vger.kernel.org
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> Cc: Nadav Amit <namit@vmware.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Arjan van de Ven <arjan@linux.intel.com>
>> Signed-off-by: Andy Lutomirski <luto@kernel.org>
>> ---
>>  arch/x86/include/asm/mmu_context.h | 19 +++++++++++++++++++
>>  arch/x86/kvm/vmx.c                 | 21 ++++++++++++++++++---
>>  2 files changed, 37 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/m=
mu_context.h
>> index 187c39470a0b..f20d7ea47095 100644
>> --- a/arch/x86/include/asm/mmu_context.h
>> +++ b/arch/x86/include/asm/mmu_context.h
>> @@ -266,4 +266,23 @@ static inline bool arch_vma_access_permitted(struct=
 vm_area_struct *vma,
>>       return __pkru_allows_pkey(vma_pkey(vma), write);
>>  }
>>
>> +
>> +/*
>> + * This can be used from process context to figure out what the value o=
f
>> + * CR3 is without needing to do a (slow) read_cr3().
>> + *
>> + * It's intended to be used for code like KVM that sneakily changes CR3
>> + * and needs to restore it.  It needs to be used very carefully.
>> + */
>> +static inline unsigned long __get_current_cr3_fast(void)
>> +{
>> +     unsigned long cr3 =3D __pa(this_cpu_read(cpu_tlbstate.loaded_mm)->=
pgd);
>> +
>> +     /* For now, be very restrictive about when this can be called. */
>> +     VM_WARN_ON(in_nmi() || !in_atomic());
>
> With the following config (from Fedora26 + olddefconfig)
>
>   $ grep PREEMPT .config
>   CONFIG_PREEMPT_NOTIFIERS=3Dy
>   # CONFIG_PREEMPT_NONE is not set
>   CONFIG_PREEMPT_VOLUNTARY=3Dy
>   # CONFIG_PREEMPT is not set
>
> I hit this warning on !in_atomic() on every vm entry.  Shouldn't this be
> preemptible() instead?

Ugh, I hate in_atomic() and its willingness to return the sort-of-wrong ans=
wer.

Want to send a patch?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
