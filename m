Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 245E46B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 10:11:28 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g11-v6so817149edi.8
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 07:11:28 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0123.outbound.protection.outlook.com. [104.47.2.123])
        by mx.google.com with ESMTPS id n61-v6si2164924edc.86.2018.08.02.07.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Aug 2018 07:11:26 -0700 (PDT)
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
References: <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
 <20180629110709.GA17859@arm.com>
 <CAAeHK+wHd8B2nhat-Z2Y2=s4NVobPG7vjr2CynjFhqPTwQRepQ@mail.gmail.com>
 <20180703173608.GF27243@arm.com>
 <CAAeHK+wTcH+2hgm_BTkLLdn1GkjBtkhQ=vPWZCncJ6KenqgKpg@mail.gmail.com>
 <CAAeHK+xc1E64tXEEHoXqOuUNZ7E_kVyho3_mNZTCc+LTGHYFdA@mail.gmail.com>
 <20180801163538.GA10800@arm.com>
 <CACT4Y+aZtph5qDsLzTDEgpQRz4_Vtg1DD-cB18qooi6D0bexDg@mail.gmail.com>
 <20180802111031.yx3x6y5d5q6drq52@armageddon.cambridge.arm.com>
 <CACT4Y+b0gkSQHUG67MbYZUTA_aZWs7EmJ2eUzOEPWdt9==ysdg@mail.gmail.com>
 <20180802135201.qjweapbskllthvhu@armageddon.cambridge.arm.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <da873a0d-3c75-0a00-974e-824f1eb49de6@virtuozzo.com>
Date: Thu, 2 Aug 2018 17:11:18 +0300
MIME-Version: 1.0
In-Reply-To: <20180802135201.qjweapbskllthvhu@armageddon.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Paul Lawrence <paullawrence@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-sparse@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Dave Martin <Dave.Martin@arm.com>, Evgeniy Stepanov <eugenis@google.com>, Arnd Bergmann <arnd@arndb.de>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Andrey Konovalov <andreyknvl@google.com>, Lee Smith <Lee.Smith@arm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Kostya Serebryany <kcc@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Nick Desaulniers <ndesaulniers@google.com>, LKML <linux-kernel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

On 08/02/2018 04:52 PM, Catalin Marinas wrote:
> 
>> If somebody has a practical idea how to detect these statically, let's
>> do it. Otherwise let's go with the traditional solution to this --
>> dynamic testing. The patch series show that the problem is not a
>> disaster and we won't need to change just every line of kernel code.
> 
> It's indeed not a disaster but we had to do this exercise to find out
> whether there are better ways of detecting where untagging is necessary.
> 
> If you want to enable khwasan in "production" and since enabling it
> could potentially change the behaviour of existing code paths, the
> run-time validation space doubles as we'd need to get the same code
> coverage with and without the feature being enabled. I wouldn't say it's
> a blocker for khwasan, more like something to be aware of.
> 
> The awareness is a bit of a problem as the normal programmer would have
> to pay more attention to conversions between pointer and long. Given
> that this is an arm64-only feature, we have a risk of khwasan-triggered
> bugs being introduced in generic code in the future (hence the
> suggestion of some static checker, if possible).
 
I don't see how we can implement such checker. There is no simple rule which defines when we need
to remove the tag and when we can leave it in place.
The cast to long have nothing to do with the need to remove the tag. If pointers compared for sorting objects,
or lock ordering, than having tags is fine and it doesn't matter whether pointers compared as 'unsigned long'
or as 'void *'.
If developer needs to check whether the pointer is in linear mapping, than tag has to be removed.
But again, it doesn't matter if pointer is 'unsigned long' or 'void *'. Either way, the tag has to go away.
