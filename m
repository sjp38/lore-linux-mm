Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 557C76B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:33:47 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id u207-v6so742534ywg.0
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:33:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6-v6sor848199ybm.70.2018.06.20.15.33.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 15:33:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 20 Jun 2018 15:33:44 -0700
Message-ID: <CAGXu5jLt8Zv-p=9J590WFppc3O6LWrAVdi-xtU7r_8f4j0XeRg@mail.gmail.com>
Subject: Re: [PATCH 0/3] KASLR feature to randomize each loadable module
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, kristen Accardi <kristen.c.accardi@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Van De Ven, Arjan" <arjan.van.de.ven@intel.com>

On Wed, Jun 20, 2018 at 3:09 PM, Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
> This patch changes the module loading KASLR algorithm to randomize the position
> of each module text section allocation with at least 18 bits of entropy in the
> typical case. It used on x86_64 only for now.

Very cool! Thanks for sending the series. :)

> Today the RANDOMIZE_BASE feature randomizes the base address where the module
> allocations begin with 10 bits of entropy. From here, a highly deterministic
> algorithm allocates space for the modules as they are loaded and un-loaded. If
> an attacker can predict the order and identities for modules that will be
> loaded, then a single text address leak can give the attacker access to the

nit: "text address" -> "module text address"

> So the defensive strength of this algorithm in typical usage (<800 modules) for
> x86_64 should be at least 18 bits, even if an address from the random area
> leaks.

And most systems have <200 modules, really. I have 113 on a desktop
right now, 63 on a server. So this looks like a trivial win.

> As for fragmentation, this algorithm reduces the average number of modules that
> can be loaded without an allocation failure by about 6% (~17000 to ~16000)
> (p<0.05). It can also reduce the largest module executable section that can be
> loaded by half to ~500MB in the worst case.

Given that we only have 8312 tristate Kconfig items, I think 16000
will remain just fine. And even large modules (i915) are under 2MB...

> The new __vmalloc_node_try_addr function uses the existing function
> __vmalloc_node_range, in order to introduce this algorithm with the least
> invasive change. The side effect is that each time there is a collision when
> trying to allocate in the random area a TLB flush will be triggered. There is
> a more complex, more efficient implementation that can be used instead if
> there is interest in improving performance.

The only time when module loading speed is noticeable, I would think,
would be boot time. Have you done any boot time delta analysis? I
wouldn't expect it to change hardly at all, but it's probably a good
idea to actually test it. :)

Also: can this be generalized for use on other KASLRed architectures?
For example, I know the arm64 module randomization is pretty similar
to x86.

-Kees

-- 
Kees Cook
Pixel Security
