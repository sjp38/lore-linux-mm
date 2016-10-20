Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0AF6B0253
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 23:14:01 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n3so21514769lfn.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 20:14:01 -0700 (PDT)
Received: from tartarus.angband.pl (tartarus.angband.pl. [2a03:9300:10::8])
        by mx.google.com with ESMTPS id 64si5253530lfs.73.2016.10.19.20.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 20:13:59 -0700 (PDT)
Date: Thu, 20 Oct 2016 05:13:54 +0200
From: Adam Borowski <kilobyte@angband.pl>
Subject: Re: x32 is broken in 4.9-rc1 due to "x86/signal: Add
 SA_{X32,IA32}_ABI sa_flags"
Message-ID: <20161020031354.GA9074@angband.pl>
References: <alpine.LRH.2.02.1610191311010.24555@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1610191329500.29288@file01.intranet.prod.int.rdu2.redhat.com>
 <CAJwJo6Z8ZWPqNfT6t-i8GW1MKxQrKDUagQqnZ+0+697=MyVeGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJwJo6Z8ZWPqNfT6t-i8GW1MKxQrKDUagQqnZ+0+697=MyVeGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <0x7f454c46@gmail.com>
Cc: Mikulas Patocka <mpatocka@redhat.com>, Dmitry Safonov <dsafonov@virtuozzo.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, open list <linux-kernel@vger.kernel.org>

On Thu, Oct 20, 2016 at 01:02:59AM +0300, Dmitry Safonov wrote:
> 2016-10-19 20:33 GMT+03:00 Mikulas Patocka <mpatocka@redhat.com>:
> > On Wed, 19 Oct 2016, Mikulas Patocka wrote:
> >> In the kernel 4.9-rc1, the x32 support is seriously broken, a x32 process
> >> is killed with SIGKILL after returning from any signal handler.
> >
> > I should have said they are killed with SIGSEGV, not SIGKILL.
> >
> >> I use Debian sid x64-64 distribution with x32 architecture added from
> >> debian-ports.
> >>
> >> I bisected the bug and found out that it is caused by the patch
> >> 6846351052e685c2d1428e80ead2d7ca3d7ed913 ("x86/signal: Add
> >> SA_{X32,IA32}_ABI sa_flags").
> >
> > So, the kernel somehow thinks that it is i386 process, not x32 process. A
> > core dump of a real x32 process shows "Class: ELF32, Machine: Advanced
> > Micro Devices X86-64".
> 
> could you give attached patch a shot?
> In about 10 hours I'll be at work and will have debian-x32 install,
> but for now, I can't test it.
> Thanks again on catching that.
> 

> From a546f8da1d12676fe79c746d859eb1e17aa4c331 Mon Sep 17 00:00:00 2001
> From: Dmitry Safonov <0x7f454c46@gmail.com>
> Date: Thu, 20 Oct 2016 00:53:08 +0300
> Subject: [PATCH] x86/signal: set SA_X32_ABI flag for x32 programs
> 
> For x32 programs cs register is __USER_CS, so it returns here
> unconditionally - remove this check completely here.
> 
> Fixes: commit 6846351052e6 ("x86/signal: Add SA_{X32,IA32}_ABI sa_flags")
> 
> Reported-by: Mikulas Patocka <mpatocka@redhat.com>
> Signed-off-by: Dmitry Safonov <0x7f454c46@gmail.com>
> ---
>  arch/x86/kernel/signal_compat.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/arch/x86/kernel/signal_compat.c b/arch/x86/kernel/signal_compat.c
> index 40df33753bae..ec1f756f9dc9 100644
> --- a/arch/x86/kernel/signal_compat.c
> +++ b/arch/x86/kernel/signal_compat.c
> @@ -105,9 +105,6 @@ void sigaction_compat_abi(struct k_sigaction *act, struct k_sigaction *oact)
>  	/* Don't let flags to be set from userspace */
>  	act->sa.sa_flags &= ~(SA_IA32_ABI | SA_X32_ABI);
>  
> -	if (user_64bit_mode(current_pt_regs()))
> -		return;
> -
>  	if (in_ia32_syscall())
>  		act->sa.sa_flags |= SA_IA32_ABI;
>  	if (in_x32_syscall())
> -- 
> 2.10.0

Works for me.  Tested on general operation, a few by-hand checks and several
random package builds.

It'd be nice to check glibc's testsuite as well as it had recent regressions
caused by kernel changes on x32 (like https://bugs.debian.org/841240) but as
gcc-6 in sid is broken right now (fails to build kernel, glibc:amd64, etc),
I didn't bother that much.

Tested-by: Adam Borowski <kilobyte@angband.pl>

-- 
A MAP07 (Dead Simple) raspberry tincture recipe: 0.5l 95% alcohol, 1kg
raspberries, 0.4kg sugar; put into a big jar for 1 month.  Filter out and
throw away the fruits (can dump them into a cake, etc), let the drink age
at least 3-6 months.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
