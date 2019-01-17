Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6858F8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 16:43:59 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id m3so8356312pfj.14
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 13:43:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p2sor4166185pgn.83.2019.01.17.13.43.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 13:43:58 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 06/17] x86/alternative: use temporary mm for text poking
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <CALCETrXQ6uxzB3JvO14sEyMA21RcWCbwicL4nUdPBG8KAunxwg@mail.gmail.com>
Date: Thu, 17 Jan 2019 13:43:54 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <B8C39C5A-A669-4F80-9BAE-7C11A4379ECF@gmail.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
 <20190117003259.23141-7-rick.p.edgecombe@intel.com>
 <CALCETrUMAsXoZogEJg7ssv0CO56vzBV2C7VotmWcwNM7iH9Wqw@mail.gmail.com>
 <CALCETrXQ6uxzB3JvO14sEyMA21RcWCbwicL4nUdPBG8KAunxwg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity <linux-integrity@vger.kernel.org>, LSM List <linux-security-module@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>

> On Jan 17, 2019, at 12:47 PM, Andy Lutomirski <luto@kernel.org> wrote:
>=20
> On Thu, Jan 17, 2019 at 12:27 PM Andy Lutomirski <luto@kernel.org> =
wrote:
>> On Wed, Jan 16, 2019 at 4:33 PM Rick Edgecombe
>> <rick.p.edgecombe@intel.com> wrote:
>>> From: Nadav Amit <namit@vmware.com>
>>>=20
>>> text_poke() can potentially compromise the security as it sets =
temporary
>>> PTEs in the fixmap. These PTEs might be used to rewrite the kernel =
code
>>> from other cores accidentally or maliciously, if an attacker gains =
the
>>> ability to write onto kernel memory.
>>=20
>> i think this may be sufficient, but barely.
>>=20
>>> +       pte_clear(poking_mm, poking_addr, ptep);
>>> +
>>> +       /*
>>> +        * __flush_tlb_one_user() performs a redundant TLB flush =
when PTI is on,
>>> +        * as it also flushes the corresponding "user" address =
spaces, which
>>> +        * does not exist.
>>> +        *
>>> +        * Poking, however, is already very inefficient since it =
does not try to
>>> +        * batch updates, so we ignore this problem for the time =
being.
>>> +        *
>>> +        * Since the PTEs do not exist in other kernel =
address-spaces, we do
>>> +        * not use __flush_tlb_one_kernel(), which when PTI is on =
would cause
>>> +        * more unwarranted TLB flushes.
>>> +        *
>>> +        * There is a slight anomaly here: the PTE is a =
supervisor-only and
>>> +        * (potentially) global and we use __flush_tlb_one_user() =
but this
>>> +        * should be fine.
>>> +        */
>>> +       __flush_tlb_one_user(poking_addr);
>>> +       if (cross_page_boundary) {
>>> +               pte_clear(poking_mm, poking_addr + PAGE_SIZE, ptep + =
1);
>>> +               __flush_tlb_one_user(poking_addr + PAGE_SIZE);
>>> +       }
>>=20
>> In principle, another CPU could still have the old translation.  Your
>> mutex probably makes this impossible, but it makes me nervous.
>> Ideally you'd use flush_tlb_mm_range(), but I guess you can't do that
>> with IRQs off.  Hmm.  I think you should add an inc_mm_tlb_gen() =
here.
>> Arguably, if you did that, you could omit the flushes, but maybe
>> that's silly.
>>=20
>> If we start getting new users of use_temporary_mm(), we should give
>> some serious thought to the SMP semantics.
>>=20
>> Also, you're using PAGE_KERNEL.  Please tell me that the global bit
>> isn't set in there.
>=20
> Much better solution: do unuse_temporary_mm() and *then*
> flush_tlb_mm_range().  This is entirely non-sketchy and should be just
> about optimal, too.

This solution sounds nice and clean. The fact the global-bit was set =
didn=E2=80=99t
matter before (since __flush_tlb_one_user would get rid of it no matter
what), but would matter now, so I=E2=80=99ll change it too.

Thanks!

Nadav
