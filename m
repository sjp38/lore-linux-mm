Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6E66B0003
	for <linux-mm@kvack.org>; Sun,  4 Mar 2018 06:44:46 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r15so9495694wrr.16
        for <linux-mm@kvack.org>; Sun, 04 Mar 2018 03:44:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o15sor483018wrg.19.2018.03.04.03.44.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Mar 2018 03:44:44 -0800 (PST)
Date: Sun, 4 Mar 2018 12:44:39 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH 00/14] khwasan: kernel hardware assisted address
 sanitizer
Message-ID: <20180304114439.zxksut65mefrpc7w@gmail.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <CAMuHMdX-3uFCagtnR5fuuU9wPJZ41D45pGi-gst7vtc0VT7zmA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdX-3uFCagtnR5fuuU9wPJZ41D45pGi-gst7vtc0VT7zmA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux MM <linux-mm@kvack.org>, linux-kbuild <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>


* Geert Uytterhoeven <geert@linux-m68k.org> wrote:

> Hi Andrey,
> 
> On Fri, Mar 2, 2018 at 8:44 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> > This patchset adds a new mode to KASAN, which is called KHWASAN (Kernel
> > HardWare assisted Address SANitizer). There's still some work to do and
> > there are a few TODOs in the code, so I'm publishing this as a RFC to
> > collect some initial feedback.
> >
> > The plan is to implement HWASan [1] for the kernel with the incentive,
> > that it's going to have comparable performance, but in the same time
> > consume much less memory, trading that off for somewhat imprecise bug
> > detection and being supported only for arm64.
> >
> > The overall idea of the approach used by KHWASAN is the following:
> >
> > 1. By using the Top Byte Ignore arm64 CPU feature, we can store pointer
> >    tags in the top byte of each kernel pointer.
> 
> And for how long will this be OK?

Firstly it's not for production kernels, it's a hardware accelerator for an 
intrusive debug feature, so it shouldn't really matter, right?

Secondly, if the top byte is lost and the other 56 bits can still be used that 
gives a virtual memory space of up to 65,536 TB, which should be enough for a few 
years in the arm64 space, right?

> Remembering:
>   - AmigaBasic,
>   - MacOS,
>   - Emacs,
>   - ...
> They all tried to use the same trick, and did regret...
> (AmigaBasic never survived this failure).

The 64-bit address space is really a lot larger, and it's a debug-info feature in 
any case.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
