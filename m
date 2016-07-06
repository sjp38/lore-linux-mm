Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 265476B025E
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 18:25:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so709110pfa.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 15:25:45 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id k4si414876paz.154.2016.07.06.15.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jul 2016 15:25:43 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id dx3so117623pab.2
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 15:25:43 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 0/9] mm: Hardened usercopy
Date: Wed,  6 Jul 2016 15:25:19 -0700
Message-Id: <1467843928-29351-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Hi,

This is a start of the mainline port of PAX_USERCOPY[1]. After I started
writing tests (now in lkdtm in -next) for Casey's earlier port[2], I
kept tweaking things further and further until I ended up with a whole
new patch series. To that end, I took Rik's feedback and made a number
of other changes and clean-ups as well.

Based on my understanding, PAX_USERCOPY was designed to catch a few
classes of flaws around the use of copy_to_user()/copy_from_user(). These
changes don't touch get_user() and put_user(), since these operate on
constant sized lengths, and tend to be much less vulnerable. There
are effectively three distinct protections in the whole series,
each of which I've given a separate CONFIG, though this patch set is
only the first of the three intended protections. (Generally speaking,
PAX_USERCOPY covers what I'm calling CONFIG_HARDENED_USERCOPY (this) and
CONFIG_HARDENED_USERCOPY_WHITELIST (future), and PAX_USERCOPY_SLABS covers
CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC (future).)

This series, which adds CONFIG_HARDENED_USERCOPY, checks that objects
being copied to/from userspace meet certain criteria:
- if address is a heap object, the size must not exceed the object's
  allocated size. (This will catch all kinds of heap overflow flaws.)
- if address range is in the current process stack, it must be within the
  current stack frame (if such checking is possible) or at least entirely
  within the current process's stack. (This could catch large lengths that
  would have extended beyond the current process stack, or overflows if
  their length extends back into the original stack.)
- if the address range is part of kernel data, rodata, or bss, allow it.
- if address range is page-allocated, that it doesn't span multiple
  allocations.
- if address is within the kernel text, reject it.
- everything else is accepted

The patches in the series are:
- The core copy_to/from_user() checks, without the slab object checks:
	1- mm: Hardened usercopy
- Per-arch enablement of the protection:
	2- x86/uaccess: Enable hardened usercopy
	3- ARM: uaccess: Enable hardened usercopy
	4- arm64/uaccess: Enable hardened usercopy
	5- ia64/uaccess: Enable hardened usercopy
	6- powerpc/uaccess: Enable hardened usercopy
	7- sparc/uaccess: Enable hardened usercopy
- The heap allocator implementation of object size checking:
	8- mm: SLAB hardened usercopy support
	9- mm: SLUB hardened usercopy support

Some notes:

- This is expected to apply on top of -next which contains fixes for the
  position of _etext on both arm and arm64.

- I couldn't detect a measurable performance change with these features
  enabled. Kernel build times were unchanged, hackbench was unchanged,
  etc. I think we could flip this to "on by default" at some point.

- The SLOB support extracted from grsecurity seems entirely broken. I
  have no idea what's going on there, I spent my time testing SLAB and
  SLUB. Having someone else look at SLOB would be nice, but this series
  doesn't depend on it.

Additional features that would be nice, but aren't blocking this series:

- Needs more architecture support for stack frame checking (only x86 now).


Thanks!

-Kees

[1] https://grsecurity.net/download.php "grsecurity - test kernel patch"
[2] http://www.openwall.com/lists/kernel-hardening/2016/05/19/5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
