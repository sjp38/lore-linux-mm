Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2422E6B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 22:41:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so136362181wmz.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 19:41:23 -0700 (PDT)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id bx10si11140805wjb.45.2016.08.03.19.41.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 19:41:21 -0700 (PDT)
Received: by mail-wm0-x22b.google.com with SMTP id o80so360568136wme.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 19:41:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160803233913.32511-1-jason@lakedaemon.net>
References: <20160728204730.27453-1-jason@lakedaemon.net> <20160803233913.32511-1-jason@lakedaemon.net>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 3 Aug 2016 19:41:20 -0700
Message-ID: <CAGXu5jK4j2=gFVd_=Spn1e_ke8_5xiWyBgKYf+NYyG5FuFDbdw@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] char/random: Simplify random address requests
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: Michael Ellerman <mpe@ellerman.id.au>, "Roberts, William C" <william.c.roberts@intel.com>, Yann Droneaud <ydroneaud@opteya.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening <kernel-hardening@lists.openwall.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Nick Kralevich <nnk@google.com>, Jeffrey Vander Stoep <jeffv@google.com>, Daniel Cashman <dcashman@android.com>

On Wed, Aug 3, 2016 at 4:39 PM, Jason Cooper <jason@lakedaemon.net> wrote:
> Two previous attempts have been made to rework this API.  The first can be
> found at:
>
>   https://lkml.kernel.org/r/cover.1390770607.git.ydroneaud@opteya.com
>
> The second at:
>
>   https://lkml.kernel.org/r/1469471141-25669-1-git-send-email-william.c.roberts@intel.com
>
> Previous versions of this series can been seen at:
>
> RFC:  https://lkml.kernel.org/r/20160726030201.6775-1-jason@lakedaemon.net
>  v1:  https://lkml.kernel.org/r/20160728204730.27453-1-jason@lakedaemon.net
>  v2:  https://lkml.kernel.org/r/20160730154244.403-1-jason@lakedaemon.net
>
> In addition to incorporating ideas from these two previous efforts, this series
> adds several desirable features.  First, we take the range as an argument
> directly, which removes math both before the call and inside the function.
> Second, we return the start address on error.  All callers fell back to the
> start address on error, so we remove the need to check for errors.  Third, we
> cap range to prevent overflow.  Last, we use kerneldoc to describe the new
> function.
>
> If possible, I'd like to request Acks from the various subsystems so that we
> can merge this as one bisectable branch.
>
> Changes from v2:
>  - s/randomize_addr/randomize_page/ (Kees Cook)
>  - PAGE_ALIGN(start) if it wasn't (Kees Cook, Michael Ellerman)
>
> Changes from v1:
>  - Explicitly mention page_aligned start assumption (Yann Droneaud)
>  - pick random pages vice random addresses (Yann Droneaud)
>  - catch range=0 last
>  - Add Ack for arm64 (Will Deacon)
>
> Jason Cooper (7):
>   random: Simplify API for random address requests
>   x86: Use simpler API for random address requests
>   ARM: Use simpler API for random address requests
>   arm64: Use simpler API for random address requests
>   tile: Use simpler API for random address requests
>   unicore32: Use simpler API for random address requests
>   random: Remove unused randomize_range()
>
>  arch/arm/kernel/process.c       |  3 +--
>  arch/arm64/kernel/process.c     |  8 ++------
>  arch/tile/mm/mmap.c             |  3 +--
>  arch/unicore32/kernel/process.c |  3 +--
>  arch/x86/kernel/process.c       |  3 +--
>  arch/x86/kernel/sys_x86_64.c    |  5 +----
>  drivers/char/random.c           | 36 +++++++++++++++++++++++++-----------
>  include/linux/random.h          |  2 +-
>  8 files changed, 33 insertions(+), 30 deletions(-)

This looks great! Thanks for the v3. :)

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

-- 
Kees Cook
Brillo & Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
