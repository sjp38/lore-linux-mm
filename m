Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E64186B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 05:41:29 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so7795552wme.4
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 02:41:29 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id q8si34724916wjq.171.2016.11.08.02.41.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 02:41:28 -0800 (PST)
Date: Tue, 8 Nov 2016 10:41:12 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] mm: only enable sys_pkey* when ARCH_HAS_PKEYS
Message-ID: <20161108104112.GM1041@n2100.armlinux.org.uk>
References: <1477958904-9903-1-git-send-email-mark.rutland@arm.com>
 <c716d515-409f-4092-73d2-1a81db6c1ba3@linux.intel.com>
 <20161104234459.GA18760@remoulade>
 <20161108093042.GC3528@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161108093042.GC3528@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Thomas Gleixner <tglx@linutronix.de>, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org

On Tue, Nov 08, 2016 at 10:30:42AM +0100, Heiko Carstens wrote:
> Two architectures (arm, mips) have wired them up and thus allocated system
> call numbers, even though they don't have ARCH_HAS_PKEYS set. Which seems a
> bit pointless.

I don't think it's pointless at all.  First, read the LWN article for
the userspace side of the interface: https://lwn.net/Articles/689395/

>From reading this, it seems (at least to me) that these pkey syscalls
are going to be the application level API - which means applications
are probably going to want to make these calls.

Sure, they'll have to go through glibc, and glibc can provide stubs,
but the problem with that is if we do get hardware pkey support (eg,
due to pressure to increase security) then we're going to end up
needing both kernel changes and glibc changes to add the calls.

Since one of the design goals of pkeys is to allow them to work when
there is no underlying hardware support, I see no reason not to wire
them up in architecture syscall tables today, so that we have a cross-
architecture kernel version where the pkey syscalls become available.
glibc (and other libcs) don't then have to mess around with per-
architecture recording of which kernel version the pkey syscalls were
added.

Not wiring up the syscalls doesn't really gain anything: the code
present when !ARCH_HAS_PKEYS will still be part of the kernel image,
it just won't be callable.

So, on balance, I've decided to wire them up on ARM, even though the
hardware doesn't support them, to avoid unnecessary pain in userspace
from the ARM side of things.

Obviously what other architectures do is their own business.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
