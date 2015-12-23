Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 869A582F64
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 15:18:48 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id ba1so80576539obb.3
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 12:18:48 -0800 (PST)
Received: from muru.com (muru.com. [72.249.23.125])
        by mx.google.com with ESMTP id gb5si31263080obb.87.2015.12.23.12.18.47
        for <linux-mm@kvack.org>;
        Wed, 23 Dec 2015 12:18:47 -0800 (PST)
Date: Wed, 23 Dec 2015 12:18:44 -0800
From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH v2] ARM: mm: flip priority of CONFIG_DEBUG_RODATA
Message-ID: <20151223201843.GQ2793@atomide.com>
References: <20151202202725.GA794@www.outflux.net>
 <20151223195129.GP2793@atomide.com>
 <20151223200132.GW8644@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151223200132.GW8644@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Nicolas Pitre <nico@linaro.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel-hardening@lists.openwall.com, linux-arm-kernel@lists.infradead.org, Laura Abbott <labbott@fedoraproject.org>

* Russell King - ARM Linux <linux@arm.linux.org.uk> [151223 12:01]:
> On Wed, Dec 23, 2015 at 11:51:29AM -0800, Tony Lindgren wrote:
> > Also all omap3 boards are now oopsing in Linux next if PM is enabled:
> 
> I'm not sure that's entirely true.  My LDP3430 works fine with this
> change in place, and that has CONFIG_PM=y.  See my nightly build/boot
> results, which includes an attempt to enter hibernation.  Remember
> that last night's results are from my tree plus arm-soc's for-next.

Right but you don't have any deeper idle states enabled for your
old ldp, see the script below. It may not work properly on your ldp
because of the old silicon revision of the SoC..

> Maybe there's some other change in linux-next which, when combined
> with this change, is provoking it?

Well it seems to be the new default Kconfig options selected by
default as Geert is saying?

And it seems to require off mode enabled for idle to hit it, retention
idle does not seem to trigger it.

Regards,

Tony


8< -------------------------
#!/bin/bash

uarts=$(find /sys/class/tty/tty[SO]*/device/power/ -type d)
for uart in $uarts; do
	echo 3000 > $uart/autosuspend_delay_ms 2>&1
done

uarts=$(find /sys/class/tty/tty[SO]*/power/ -type d 2>/dev/null)
for uart in $uarts; do
	echo enabled > $uart/wakeup 2>&1
	echo auto > $uart/control 2>&1
done

echo 1 > /sys/kernel/debug/pm_debug/enable_off_mode

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
