Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8FE8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 17:32:26 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id t17so5846295ywc.23
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 14:32:26 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id b185si2318734ywc.169.2019.01.17.14.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 Jan 2019 14:32:23 -0800 (PST)
Date: Thu, 17 Jan 2019 14:31:53 -0800
In-Reply-To: <B8C39C5A-A669-4F80-9BAE-7C11A4379ECF@gmail.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com> <20190117003259.23141-7-rick.p.edgecombe@intel.com> <CALCETrUMAsXoZogEJg7ssv0CO56vzBV2C7VotmWcwNM7iH9Wqw@mail.gmail.com> <CALCETrXQ6uxzB3JvO14sEyMA21RcWCbwicL4nUdPBG8KAunxwg@mail.gmail.com> <B8C39C5A-A669-4F80-9BAE-7C11A4379ECF@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 06/17] x86/alternative: use temporary mm for text poking
From: hpa@zytor.com
Message-ID: <7E4A4400-0A2E-4393-B22C-DBD708610BB5@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity <linux-integrity@vger.kernel.org>, LSM List <linux-security-module@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>

On January 17, 2019 1:43:54 PM PST, Nadav Amit <nadav=2Eamit@gmail=2Ecom> w=
rote:
>> On Jan 17, 2019, at 12:47 PM, Andy Lutomirski <luto@kernel=2Eorg>
>wrote:
>>=20
>> On Thu, Jan 17, 2019 at 12:27 PM Andy Lutomirski <luto@kernel=2Eorg>
>wrote:
>>> On Wed, Jan 16, 2019 at 4:33 PM Rick Edgecombe
>>> <rick=2Ep=2Eedgecombe@intel=2Ecom> wrote:
>>>> From: Nadav Amit <namit@vmware=2Ecom>
>>>>=20
>>>> text_poke() can potentially compromise the security as it sets
>temporary
>>>> PTEs in the fixmap=2E These PTEs might be used to rewrite the kernel
>code
>>>> from other cores accidentally or maliciously, if an attacker gains
>the
>>>> ability to write onto kernel memory=2E
>>>=20
>>> i think this may be sufficient, but barely=2E
>>>=20
>>>> +       pte_clear(poking_mm, poking_addr, ptep);
>>>> +
>>>> +       /*
>>>> +        * __flush_tlb_one_user() performs a redundant TLB flush
>when PTI is on,
>>>> +        * as it also flushes the corresponding "user" address
>spaces, which
>>>> +        * does not exist=2E
>>>> +        *
>>>> +        * Poking, however, is already very inefficient since it
>does not try to
>>>> +        * batch updates, so we ignore this problem for the time
>being=2E
>>>> +        *
>>>> +        * Since the PTEs do not exist in other kernel
>address-spaces, we do
>>>> +        * not use __flush_tlb_one_kernel(), which when PTI is on
>would cause
>>>> +        * more unwarranted TLB flushes=2E
>>>> +        *
>>>> +        * There is a slight anomaly here: the PTE is a
>supervisor-only and
>>>> +        * (potentially) global and we use __flush_tlb_one_user()
>but this
>>>> +        * should be fine=2E
>>>> +        */
>>>> +       __flush_tlb_one_user(poking_addr);
>>>> +       if (cross_page_boundary) {
>>>> +               pte_clear(poking_mm, poking_addr + PAGE_SIZE, ptep
>+ 1);
>>>> +               __flush_tlb_one_user(poking_addr + PAGE_SIZE);
>>>> +       }
>>>=20
>>> In principle, another CPU could still have the old translation=2E=20
>Your
>>> mutex probably makes this impossible, but it makes me nervous=2E
>>> Ideally you'd use flush_tlb_mm_range(), but I guess you can't do
>that
>>> with IRQs off=2E  Hmm=2E  I think you should add an inc_mm_tlb_gen()
>here=2E
>>> Arguably, if you did that, you could omit the flushes, but maybe
>>> that's silly=2E
>>>=20
>>> If we start getting new users of use_temporary_mm(), we should give
>>> some serious thought to the SMP semantics=2E
>>>=20
>>> Also, you're using PAGE_KERNEL=2E  Please tell me that the global bit
>>> isn't set in there=2E
>>=20
>> Much better solution: do unuse_temporary_mm() and *then*
>> flush_tlb_mm_range()=2E  This is entirely non-sketchy and should be
>just
>> about optimal, too=2E
>
>This solution sounds nice and clean=2E The fact the global-bit was set
>didn=E2=80=99t
>matter before (since __flush_tlb_one_user would get rid of it no matter
>what), but would matter now, so I=E2=80=99ll change it too=2E
>
>Thanks!
>
>Nadav

You can just disable the global bit at the top level, obviously=2E

This approach also should make it far easier to do batching if desired=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E
