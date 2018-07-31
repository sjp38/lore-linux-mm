Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6277F6B000A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 11:21:38 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 136-v6so3049881itw.5
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 08:21:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 185-v6sor4625332ioy.49.2018.07.31.08.21.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 08:21:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8240d4f9-c8df-cfe9-119d-6e933f8b13df@virtuozzo.com>
References: <cover.1530018818.git.andreyknvl@google.com> <a2a93370d43ec85b02abaf8d007a15b464212221.1530018818.git.andreyknvl@google.com>
 <09cb5553-d84a-0e62-5174-315c14b88833@arm.com> <CAAeHK+yC3XRPoTByhH1QPrX45pG3QY_2Q4gz=dfDgxfzu1Fyfw@mail.gmail.com>
 <8240d4f9-c8df-cfe9-119d-6e933f8b13df@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 31 Jul 2018 17:21:35 +0200
Message-ID: <CAAeHK+wUu4c5MwknrJkw=22y5cWuZNsyd+-QJ3v0Z48Xj-Hqng@mail.gmail.com>
Subject: Re: [PATCH v4 13/17] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: vincenzo.frascino@arm.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Mark Brand <markbrand@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Tue, Jul 31, 2018 at 4:50 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
> On 07/31/2018 04:05 PM, Andrey Konovalov wrote:
>> We can assign tags to objects with constructors when a slab is
>> allocated and call constructors once as usual. The downside is that
>> such object would always have the same tag when it is reallocated, so
>> we won't catch use-after-frees.
>
> Actually you should do this for SLAB_TYPESAFE_BY_RCU slabs. Usually they are with ->ctors but there
> are few without constructors.
> We can't reinitialize or even retag them. The latter will definitely cause false-positive use-after-free reports.
>
> As for non-SLAB_TYPESAFE_BY_RCU caches with constructors, it's probably ok to reinitialize and retag such objects.
> I don't see how could any code rely on the current ->ctor() behavior in non-SLAB_TYPESAFE_BY_RCU case,
> unless it does something extremely stupid or weird.
> But let's not do it now. If you care, you cand do it later, with a separate patch, so we could just revert
> it if anything goes wrong.

OK, will do it then when there's either a constructor or the slab is
SLAB_TYPESAFE_BY_RCU.
