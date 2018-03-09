Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACE86B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 13:17:18 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id q4so3455366ioh.4
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 10:17:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l123sor1243697itl.128.2018.03.09.10.17.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 10:17:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180305143625.vtrfvsbw7loxngaj@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com> <739eecf573b6342fc41c4f89d7f64eb8c183e312.1520017438.git.andreyknvl@google.com>
 <20180305143625.vtrfvsbw7loxngaj@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 9 Mar 2018 19:17:14 +0100
Message-ID: <CAAeHK+xd1g0Jqvz+KT9=Cb4PmXWMHS0t+FWqSBhFEHmC1DBkPQ@mail.gmail.com>
Subject: Re: [RFC PATCH 06/14] khwasan: enable top byte ignore for the kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Mon, Mar 5, 2018 at 3:36 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Mar 02, 2018 at 08:44:25PM +0100, Andrey Konovalov wrote:
>> KHWASAN uses the Top Byte Ignore feature of arm64 CPUs to store a pointer
>> tag in the top byte of each pointer. This commit enables the TCR_TBI1 bit,
>> which enables Top Byte Ignore for the kernel, when KHWASAN is used.
>> ---
>>  arch/arm64/include/asm/pgtable-hwdef.h | 1 +
>>  arch/arm64/mm/proc.S                   | 8 +++++++-
>>  2 files changed, 8 insertions(+), 1 deletion(-)
>
> Before it's safe to do this, I also think you'll need to fix up at
> least:
>
> * virt_to_phys()

I've already got some issues with it (the jbd2 patch), so I'll look into this.

>
> * access_ok()

This is used for accessing user addresses, and they are not tagged. Am
I missing something?

>
> ... and potentially others which assume that bits [63:56] of kernel
> addresses are 0xff. For example, bits of the fault handling logic might
> need fixups.

I'll look into this as well.

>
> Thanks,
> Mark.
