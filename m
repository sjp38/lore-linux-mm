Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 511586B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 14:14:36 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u68so5139858oia.0
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 11:14:36 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q35si503475otd.36.2018.03.09.11.14.35
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 11:14:35 -0800 (PST)
Date: Fri, 9 Mar 2018 19:14:23 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 06/14] khwasan: enable top byte ignore for the kernel
Message-ID: <20180309191422.yediylbb4uwriy4e@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <739eecf573b6342fc41c4f89d7f64eb8c183e312.1520017438.git.andreyknvl@google.com>
 <20180305143625.vtrfvsbw7loxngaj@lakrids.cambridge.arm.com>
 <b5f203ba-1f2f-d56e-9acf-6f269677f175@arm.com>
 <CAAeHK+yvG8Xc3PXBNM6Q6bqg8iNYJTRw+kx=R1Pqj6JG0ZkAkw@mail.gmail.com>
 <0377a2e1-ccc2-51bf-26b9-978eb685cdce@arm.com>
 <CAAeHK+zyGQtNxap6N5s11MWrQS-Y_uA7TRQnh5oP=HWZjPytsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+zyGQtNxap6N5s11MWrQS-Y_uA7TRQnh5oP=HWZjPytsw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 09, 2018 at 07:42:19PM +0100, Andrey Konovalov wrote:
> On Fri, Mar 9, 2018 at 7:32 PM, Marc Zyngier <marc.zyngier@arm.com> wrote:
> > Well, that's not quite how it works. KVM is an integral part of the
> > kernel, and I don't really want to have to deal with regression (not to
> > mention that KVM is an essential tool in our testing infrastructure).
> >
> > You could try and exclude KVM from the instrumentation (which we already
> > have for invasive things such as KASAN), but I'm afraid that having a
> > debugging option that conflicts with another essential part of the
> > kernel is not an option.
> 
> Hm, KHWASAN instruments the very same parts of the kernel that KASAN
> does (it reuses the same flag).

Sure, but KASAN doesn't fiddle with the tag in pointers, and the KVM hyp
code relies on EL1/EL2 pointers having a fixed offset from each other
(implicitly relying on addr[63:56] being zero).

We have two aliases of the kernel in two disjoint address spaces:

TTBR0                   TTBR1

                        -SS-KKKK--------    EL1 kernel mappings

----KKKK--------                            EL2 hyp mappings

To convert between the two, we just flip a few high bits of the address.
See kern_hyp_va() in <asm/kvm_mmu.h>.


The EL1 mappings have the KASAN shadow, and kernel. The EL2 mappings
just have the kernel. So long as we don't instrument EL2 code with
KASAN, it's fine for EL1 code to be instrumented.

However, with KHASAN, pointers generated by EL1 will have some arbitrary
tag, and more work needs to be done to convert an address to its EL2
alias.

Thanks,
Mark.
