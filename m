Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 424B36B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 09:37:47 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j7-v6so1769660oib.19
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 06:37:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u143-v6sor1918750oif.239.2018.06.21.06.37.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 06:37:45 -0700 (PDT)
MIME-Version: 1.0
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com> <CAGXu5jLt8Zv-p=9J590WFppc3O6LWrAVdi-xtU7r_8f4j0XeRg@mail.gmail.com>
In-Reply-To: <CAGXu5jLt8Zv-p=9J590WFppc3O6LWrAVdi-xtU7r_8f4j0XeRg@mail.gmail.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 21 Jun 2018 15:37:33 +0200
Message-ID: <CAG48ez2uuQkSS9DLz6j5HbpuxaHMyAVYGMM+xoZEo51N=sHmdg@mail.gmail.com>
Subject: Re: [PATCH 0/3] KASLR feature to randomize each loadable module
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, rick.p.edgecombe@intel.com
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, kristen.c.accardi@intel.com, Dave Hansen <dave.hansen@intel.com>, arjan.van.de.ven@intel.com

On Thu, Jun 21, 2018 at 12:34 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Wed, Jun 20, 2018 at 3:09 PM, Rick Edgecombe
> <rick.p.edgecombe@intel.com> wrote:
> > This patch changes the module loading KASLR algorithm to randomize the position
> > of each module text section allocation with at least 18 bits of entropy in the
> > typical case. It used on x86_64 only for now.
>
> Very cool! Thanks for sending the series. :)
>
> > Today the RANDOMIZE_BASE feature randomizes the base address where the module
> > allocations begin with 10 bits of entropy. From here, a highly deterministic
> > algorithm allocates space for the modules as they are loaded and un-loaded. If
> > an attacker can predict the order and identities for modules that will be
> > loaded, then a single text address leak can give the attacker access to the
>
> nit: "text address" -> "module text address"
>
> > So the defensive strength of this algorithm in typical usage (<800 modules) for
> > x86_64 should be at least 18 bits, even if an address from the random area
> > leaks.
>
> And most systems have <200 modules, really. I have 113 on a desktop
> right now, 63 on a server. So this looks like a trivial win.

But note that the eBPF JIT also uses module_alloc(). Every time a BPF
program (this includes seccomp filters!) is JIT-compiled by the
kernel, another module_alloc() allocation is made. For example, on my
desktop machine, I have a bunch of seccomp-sandboxed processes thanks
to Chrome. If I enable the net.core.bpf_jit_enable sysctl and open a
few Chrome tabs, BPF JIT allocations start showing up between modules:

# grep -C1 bpf_jit_binary_alloc /proc/vmallocinfo | cut -d' ' -f 2-
  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
  12288 bpf_jit_binary_alloc+0x32/0x90 pages=2 vmalloc N0=2
  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
--
  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
  12288 bpf_jit_binary_alloc+0x32/0x90 pages=2 vmalloc N0=2
  36864 load_module+0x1326/0x2ab0 pages=8 vmalloc N0=8
--
  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
  12288 bpf_jit_binary_alloc+0x32/0x90 pages=2 vmalloc N0=2
  40960 load_module+0x1326/0x2ab0 pages=9 vmalloc N0=9
--
  20480 load_module+0x1326/0x2ab0 pages=4 vmalloc N0=4
  12288 bpf_jit_binary_alloc+0x32/0x90 pages=2 vmalloc N0=2
 253952 load_module+0x1326/0x2ab0 pages=61 vmalloc N0=61

If you use Chrome with Site Isolation, you have a few dozen open tabs,
and the BPF JIT is enabled, reaching a few hundred allocations might
not be that hard.

Also: What's the impact on memory usage? Is this going to increase the
number of pagetables that need to be allocated by the kernel per
module_alloc() by 4K or 8K or so?

> > As for fragmentation, this algorithm reduces the average number of modules that
> > can be loaded without an allocation failure by about 6% (~17000 to ~16000)
> > (p<0.05). It can also reduce the largest module executable section that can be
> > loaded by half to ~500MB in the worst case.
>
> Given that we only have 8312 tristate Kconfig items, I think 16000
> will remain just fine. And even large modules (i915) are under 2MB...
>
> > The new __vmalloc_node_try_addr function uses the existing function
> > __vmalloc_node_range, in order to introduce this algorithm with the least
> > invasive change. The side effect is that each time there is a collision when
> > trying to allocate in the random area a TLB flush will be triggered. There is
> > a more complex, more efficient implementation that can be used instead if
> > there is interest in improving performance.
>
> The only time when module loading speed is noticeable, I would think,
> would be boot time. Have you done any boot time delta analysis? I
> wouldn't expect it to change hardly at all, but it's probably a good
> idea to actually test it. :)

If you have a forking server that applies seccomp filters on each
fork, or something like that, you might care about those TLB flushes.

> Also: can this be generalized for use on other KASLRed architectures?
> For example, I know the arm64 module randomization is pretty similar
> to x86.
>
> -Kees
>
> --
> Kees Cook
> Pixel Security
