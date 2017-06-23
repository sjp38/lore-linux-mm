Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 767776B0365
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 11:28:28 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id a80so27459442oic.8
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:28:28 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u35si1935430otb.226.2017.06.23.08.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 08:28:27 -0700 (PDT)
Received: from mail-vk0-f50.google.com (mail-vk0-f50.google.com [209.85.213.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B3D7522B6E
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 15:28:26 +0000 (UTC)
Received: by mail-vk0-f50.google.com with SMTP id r126so7262898vkg.0
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:28:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170623115026.qqy5mpyihymocaet@pd.tnic>
References: <cover.1498022414.git.luto@kernel.org> <57c1d18b1c11f9bc9a3bcf8bdee38033415e1a13.1498022414.git.luto@kernel.org>
 <20170623115026.qqy5mpyihymocaet@pd.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 23 Jun 2017 08:28:05 -0700
Message-ID: <CALCETrU3AcncCUZacmtdPDAptbWjp+RTQpeBokbspp2e395o7A@mail.gmail.com>
Subject: Re: [PATCH v3 10/11] x86/mm: Enable CR4.PCIDE on supported systems
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Fri, Jun 23, 2017 at 4:50 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Tue, Jun 20, 2017 at 10:22:16PM -0700, Andy Lutomirski wrote:
>> We can use PCID if the CPU has PCID and PGE and we're not on Xen.
>>
>> By itself, this has no effect.  The next patch will start using
>> PCID.
>>
>> Cc: Juergen Gross <jgross@suse.com>
>> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
>> Signed-off-by: Andy Lutomirski <luto@kernel.org>
>> ---
>>  arch/x86/include/asm/tlbflush.h |  8 ++++++++
>>  arch/x86/kernel/cpu/common.c    | 15 +++++++++++++++
>>  arch/x86/xen/enlighten_pv.c     |  6 ++++++
>>  3 files changed, 29 insertions(+)
>>
>> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
>> index 87b13e51e867..57b305e13c4c 100644
>> --- a/arch/x86/include/asm/tlbflush.h
>> +++ b/arch/x86/include/asm/tlbflush.h
>> @@ -243,6 +243,14 @@ static inline void __flush_tlb_all(void)
>>               __flush_tlb_global();
>>       else
>>               __flush_tlb();
>> +
>> +     /*
>> +      * Note: if we somehow had PCID but not PGE, then this wouldn't work --
>> +      * we'd end up flushing kernel translations for the current ASID but
>> +      * we might fail to flush kernel translations for other cached ASIDs.
>> +      *
>> +      * To avoid this issue, we force PCID off if PGE is off.
>> +      */
>>  }
>>
>>  static inline void __flush_tlb_one(unsigned long addr)
>> diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
>> index 904485e7b230..01caf66b270f 100644
>> --- a/arch/x86/kernel/cpu/common.c
>> +++ b/arch/x86/kernel/cpu/common.c
>> @@ -1143,6 +1143,21 @@ static void identify_cpu(struct cpuinfo_x86 *c)
>>       setup_smep(c);
>>       setup_smap(c);
>>
>> +     /* Set up PCID */
>> +     if (cpu_has(c, X86_FEATURE_PCID)) {
>> +             if (cpu_has(c, X86_FEATURE_PGE)) {
>
> What are we protecting ourselves here against? Funny virtualization guests?
>
> Because PGE should be ubiquitous by now. Or have you heard something?

Yes, funny VM guests.  I've been known to throw weird options at qemu
myself, and I prefer when the system works.  In this particular case,
I think the failure mode would be stale kernel TLB entries, and that
would be really annoying.

>
>> +                     cr4_set_bits(X86_CR4_PCIDE);
>> +             } else {
>> +                     /*
>> +                      * flush_tlb_all(), as currently implemented, won't
>> +                      * work if PCID is on but PGE is not.  Since that
>> +                      * combination doesn't exist on real hardware, there's
>> +                      * no reason to try to fully support it.
>> +                      */
>> +                     clear_cpu_cap(c, X86_FEATURE_PCID);
>> +             }
>> +     }
>
> This whole in setup_pcid() I guess, like the rest of the features.

Done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
