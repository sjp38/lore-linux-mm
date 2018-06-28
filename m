Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7F76B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 20:04:43 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v13-v6so3368686wmc.1
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:04:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w81-v6sor1731557wmw.26.2018.06.27.17.04.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 17:04:42 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1530018818.git.andreyknvl@google.com> <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
In-Reply-To: <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
From: Kostya Serebryany <kcc@google.com>
Date: Wed, 27 Jun 2018 17:04:28 -0700
Message-ID: <CAN=P9pivApAo76Kjc0TUDE0kvJn0pET=47xU6e=ioZV2VqO0Rg@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, will.deacon@arm.com, cl@linux.com, mark.rutland@arm.com, Nick Desaulniers <ndesaulniers@google.com>, marc.zyngier@arm.com, dave.martin@arm.com, ard.biesheuvel@linaro.org, ebiederm@xmission.com, mingo@kernel.org, Paul Lawrence <paullawrence@google.com>, geert@linux-m68k.org, arnd@arndb.de, kirill.shutemov@linux.intel.com, Greg KH <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, rppt@linux.vnet.ibm.com, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, cpandya@codeaurora.org, Vishwath Mohan <vishwath@google.com>

On Wed, Jun 27, 2018 at 4:08 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 26 Jun 2018 15:15:10 +0200 Andrey Konovalov <andreyknvl@google.com> wrote:
>
> > This patchset adds a new mode to KASAN [1], which is called KHWASAN
> > (Kernel HardWare assisted Address SANitizer).
> >
> > The plan is to implement HWASan [2] for the kernel with the incentive,
> > that it's going to have comparable to KASAN performance, but in the same
> > time consume much less memory, trading that off for somewhat imprecise
> > bug detection and being supported only for arm64.
>
> Why do we consider this to be a worthwhile change?
>
> Is KASAN's memory consumption actually a significant problem?  Some
> data regarding that would be very useful.

On mobile, ASAN's and KASAN's memory usage is a significant problem.
Not sure if I can find scientific evidence of that.
CC-ing Vishwath Mohan who deals with KASAN on Android to provide
anecdotal evidence.

There are several other benefits too:
* HWASAN more reliably detects non-linear-buffer-overflows compared to
ASAN (same for kernel-HWASAN vs kernel-ASAN)
* Same for detecting use-after-free (since HWASAN doesn't rely on quarantine).
* Much easier to implement stack-use-after-return detection (which
IIRC KASAN doesn't have yet, because in KASAN it's too hard)

> If it is a large problem then we still have that problem on x86, so the
> problem remains largely unsolved?

The problem is more significant on mobile devices than on desktop/server.
I'd love to have [K]HWASAN on x86_64 as well, but it's less trivial since x86_64
doesn't have an analog of aarch64's top-byte-ignore hardware feature.


>
> > ====== Benchmarks
> >
> > The following numbers were collected on Odroid C2 board. Both KASAN and
> > KHWASAN were used in inline instrumentation mode.
> >
> > Boot time [1]:
> > * ~1.7 sec for clean kernel
> > * ~5.0 sec for KASAN
> > * ~5.0 sec for KHWASAN
> >
> > Slab memory usage after boot [2]:
> > * ~40 kb for clean kernel
> > * ~105 kb + 1/8th shadow ~= 118 kb for KASAN
> > * ~47 kb + 1/16th shadow ~= 50 kb for KHWASAN
> >
> > Network performance [3]:
> > * 8.33 Gbits/sec for clean kernel
> > * 3.17 Gbits/sec for KASAN
> > * 2.85 Gbits/sec for KHWASAN
> >
> > Note, that KHWASAN (compared to KASAN) doesn't require quarantine.
> >
> > [1] Time before the ext4 driver is initialized.
> > [2] Measured as `cat /proc/meminfo | grep Slab`.
> > [3] Measured as `iperf -s & iperf -c 127.0.0.1 -t 30`.
>
> The above doesn't actually demonstrate the whole point of the
> patchset: to reduce KASAN's very high memory consumption?
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20180627160800.3dc7f9ee41c0badbf7342520%40linux-foundation.org.
> For more options, visit https://groups.google.com/d/optout.
