Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 037A66B01CD
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 09:04:51 -0400 (EDT)
Subject: Re: Probable Bug (or configuration error) in kmemleak
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com>
References: <AANLkTimb7rP0rS0OU8nan5uNEhHx_kEYL99ImZ3c8o0D@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Jun 2010 14:00:58 +0100
Message-ID: <1276866058.28780.48.camel@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sankar P <sankar.curiosity@gmail.com>
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>, rnagarajan@novell.com, teheo@novell.com, Pekka Enberg <penberg@cs.helsinki.fi>, Luis Rodriguez <Luis.Rodriguez@atheros.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2010-06-18 at 09:11 +0100, Sankar P wrote:
> On Thu, Jun 17, 2010 at 11:06 PM, Luis R. Rodriguez
> <lrodriguez@atheros.com> wrote:
> > On Thu, Jun 17, 2010 at 02:21:56AM -0700, Sankar P wrote:
> >> Hi,
> >>
> >> I wanted to detect memory leaks in one of my kernel modules. So I
> >> built Linus' tree  with the following config options enabled (on top
> >> of make defconfig)
> >>
> >> CONFIG_DEBUG_KMEMLEAK=y
> >> CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE=400
> >> CONFIG_DEBUG_KMEMLEAK_TEST=y
> >>
> >> If I boot with this kernel, debugfs is automatically mounted. But I do
> >> not have the file:
> >>
> >> /sys/kernel/debug/kmemleak
> >>
> >> created at all. There are other files like kprobes in the mounted
> >> /sys/kernel/debug directory btw. So I am not able to detect any of the
> >> memory leaks. Is there anything I am doing wrong or missing (or) is
> >> this a bug in kmemleak ?
> >>
> >> Please let me know your suggestions to fix this and get memory leaks
> >> reporting working. Thanks.
> >>
> >> The full .config file is also attached with this mail. Sorry for the
> >> attachment, I did not want to paste 5k lines in the mail. Sorry if it
> >> is wrong.
> >
> >
> > This is odd.. Do you see this message on your kernel ring buffer?
> >
> > Failed to create the debugfs kmemleak file
> >
> 
> I dont see such an error in the dmesg output. But I got another
> interesting error:
> 
> [    0.000000] kmemleak: Early log buffer exceeded, please increase
> DEBUG_KMEMLEAK_EARLY_LOG_SIZE
> [    0.000000] kmemleak: Kernel memory leak detector disabled

You would need to increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE. The default of
400 seems ok for me but it may not work with some other kernel
configurations (that's a static array for logging memory allocations
before the kmemleak is fully initialised and can start tracking them).

> But after that also, I see some other lines like:
> 
> [    0.511641] kmemleak: vmalloc(64) = f7857000
> [    0.511645] kmemleak: vmalloc(64) = f785a000

This is because you compiler the test module into the kernel
(DEBUG_KMEMLEAK_TEST). It's not kmemleak printing this but it's testing
module (which leaks memory on purpose).

> The variable  DEBUG_KMEMLEAK_EARLY_LOG_SIZE was set to 400 by default.
> I changed it to 4000 and then 40000 (may be should try < 32567 ?) but
> still I get the same error message and the file
> /sys/kernel/debug/kmem* is never created at all.

This shouldn't usually happen with values greater than 2000. From your
kernel log, the version seems to be 2.6.32. Do you have the same
problems with 2.6.35-rc3?

Your .config seems to refer to the 2.6.35-rc3 kernel - are you checking
the right image?

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
