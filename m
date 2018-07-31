Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E90D6B000C
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 12:03:39 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f91-v6so11592266plb.10
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:03:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b69-v6sor2038421plb.139.2018.07.31.09.03.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 09:03:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <01000164f0fd5abc-df9ea911-9701-498c-adce-9f833e6df3ed-000000@email.amazonses.com>
References: <cover.1530018818.git.andreyknvl@google.com> <a2a93370d43ec85b02abaf8d007a15b464212221.1530018818.git.andreyknvl@google.com>
 <09cb5553-d84a-0e62-5174-315c14b88833@arm.com> <CAAeHK+yC3XRPoTByhH1QPrX45pG3QY_2Q4gz=dfDgxfzu1Fyfw@mail.gmail.com>
 <8240d4f9-c8df-cfe9-119d-6e933f8b13df@virtuozzo.com> <CACT4Y+Y=61VwwETQP3FwAN16ompSNJOCyDCG6Ew1Bm5f_Fe1Lw@mail.gmail.com>
 <01000164f0fd5abc-df9ea911-9701-498c-adce-9f833e6df3ed-000000@email.amazonses.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 31 Jul 2018 18:03:16 +0200
Message-ID: <CACT4Y+b6_d6b5Q4oScXuoXhsnkJPG+UZ1QxqPPGuM4_aU3n4mA@mail.gmail.com>
Subject: Re: [PATCH v4 13/17] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrey Konovalov <andreyknvl@google.com>, vincenzo.frascino@arm.com, Alexander Potapenko <glider@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Tue, Jul 31, 2018 at 5:38 PM, Christopher Lameter <cl@linux.com> wrote:
> On Tue, 31 Jul 2018, Dmitry Vyukov wrote:
>
>> > Actually you should do this for SLAB_TYPESAFE_BY_RCU slabs. Usually they are with ->ctors but there
>> > are few without constructors.
>> > We can't reinitialize or even retag them. The latter will definitely cause false-positive use-after-free reports.
>>
>> Somewhat offtopic, but I can't understand how SLAB_TYPESAFE_BY_RCU
>> slabs can be useful without ctors or at least memset(0). Objects in
>> such slabs need to be type-stable, but I can't understand how it's
>> possible to establish type stability without a ctor... Are these bugs?
>> Or I am missing something subtle? What would be a canonical usage of
>> SLAB_TYPESAFE_BY_RCU slab without a ctor?
>
> True that sounds fishy. Would someone post a list of SLAB_TYPESAFE_BY_RCU
> slabs without ctors?

https://elixir.bootlin.com/linux/latest/source/fs/jbd2/journal.c#L2395
https://elixir.bootlin.com/linux/latest/source/fs/kernfs/mount.c#L415
https://elixir.bootlin.com/linux/latest/source/net/netfilter/nf_conntrack_core.c#L2065
https://elixir.bootlin.com/linux/latest/source/drivers/gpu/drm/i915/i915_gem.c#L5501
https://elixir.bootlin.com/linux/latest/source/drivers/gpu/drm/i915/selftests/mock_gem_device.c#L212
https://elixir.bootlin.com/linux/latest/source/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c#L1131

Also these in proto structs:
https://elixir.bootlin.com/linux/latest/source/net/dccp/ipv4.c#L959
https://elixir.bootlin.com/linux/latest/source/net/dccp/ipv6.c#L1048
https://elixir.bootlin.com/linux/latest/source/net/ipv4/tcp_ipv4.c#L2461
https://elixir.bootlin.com/linux/latest/source/net/ipv6/tcp_ipv6.c#L1980
https://elixir.bootlin.com/linux/latest/source/net/llc/af_llc.c#L145
https://elixir.bootlin.com/linux/latest/source/net/smc/af_smc.c#L105

They later created in net/core/sock.c without ctor.
