Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3A2C6B0261
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 18:11:59 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f27so1954358wra.9
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 15:11:59 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m5si1569811wme.22.2017.11.01.15.11.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 15:11:58 -0700 (PDT)
Date: Wed, 1 Nov 2017 23:11:53 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm
 page tables
In-Reply-To: <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1711012258590.1942@nanos>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com> <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com> <alpine.DEB.2.20.1711012225400.1942@nanos>
 <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Wed, 1 Nov 2017, Dave Hansen wrote:

> On 11/01/2017 02:28 PM, Thomas Gleixner wrote:
> > On Wed, 1 Nov 2017, Andy Lutomirski wrote:
> >> The vsyscall page is _PAGE_USER and lives in init_mm via the fixmap.
> > 
> > Groan, forgot about that abomination, but still there is no point in having
> > it marked PAGE_USER in the init_mm at all, kaiser or not.
> 
> So shouldn't this patch effectively make the vsyscall page unusable?
> Any idea why that didn't show up in any of the x86 selftests?

vsyscall is the legacy mechanism. Halfways modern userspace does not need
it at all.

The default for it is EMULATE except you set it to NATIVE either via
Kconfig or on the kernel command line. Distros ship it with EMULATE set.
The emulation does not use the fixmap, it traps the access and emulates it.

But that aside. The point is that the fixmap exists in the init_mm and if
vsyscall is enabled then its also established in the process mappings.

So this can be done as a general correctness change:

  - Prevent USER mappings in init_mm

  - Make sure the fixmap gets the USER bit in the process mapping when
    vsyscall is in native mode.

We can avoid the latter by just removing the native vsyscall support and only
support emulation and none. It's about time to kill that stuff anyway.

Thanks,

	tglx



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
