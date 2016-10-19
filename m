Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0406B0260
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:33:28 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o68so22938210qkf.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:33:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r126si24926892qkf.286.2016.10.19.10.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:33:27 -0700 (PDT)
Date: Wed, 19 Oct 2016 13:33:25 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: x32 is broken in 4.9-rc1 due to "x86/signal: Add SA_{X32,IA32}_ABI
 sa_flags"
In-Reply-To: <alpine.LRH.2.02.1610191311010.24555@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1610191329500.29288@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1610191311010.24555@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="185206533-1321940004-1476898405=:29288"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: 0x7f454c46@gmail.com, oleg@redhat.com, linux-mm@kvack.org, gorcunov@openvz.org, xemul@virtuozzo.com, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--185206533-1321940004-1476898405=:29288
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT



On Wed, 19 Oct 2016, Mikulas Patocka wrote:

> Hi
> 
> In the kernel 4.9-rc1, the x32 support is seriously broken, a x32 process 
> is killed with SIGKILL after returning from any signal handler.

I should have said they are killed with SIGSEGV, not SIGKILL.

> I use Debian sid x64-64 distribution with x32 architecture added from 
> debian-ports.
> 
> I bisected the bug and found out that it is caused by the patch 
> 6846351052e685c2d1428e80ead2d7ca3d7ed913 ("x86/signal: Add 
> SA_{X32,IA32}_ABI sa_flags").
> 
> example (strace of a process after receiving the SIGWINCH signal):
> 
> epoll_wait(10, 0xef6890, 32, -1)        = -1 EINTR (Interrupted system call)
> --- SIGWINCH {si_signo=SIGWINCH, si_code=SI_USER, si_pid=1772, si_uid=0} ---
> poll([{fd=4, events=POLLOUT}], 1, 0)    = 1 ([{fd=4, revents=POLLOUT}])
> write(4, "\0", 1)                       = 1
> rt_sigreturn({mask=[INT QUIT ILL TRAP BUS KILL SEGV USR2 PIPE ALRM STKFLT TSTP TTOU URG XCPU XFSZ VTALRM IO PWR SYS RTMIN]}) = 0
> --- SIGSEGV {si_signo=SIGSEGV, si_code=SI_KERNEL, si_addr=NULL} ---
> +++ killed by SIGSEGV +++
> Neopravniny poistup do pamiti (SIGSEGV)
> 
> Mikulas

BTW. when I take core dump of the killed x32 process, it shows:

ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              CORE (Core file)
  Machine:                           Intel 80386
				^^^^^^^^^^^^^^^^^^^

So, the kernel somehow thinks that it is i386 process, not x32 process. A 
core dump of a real x32 process shows "Class: ELF32, Machine: Advanced 
Micro Devices X86-64".

Mikulas
--185206533-1321940004-1476898405=:29288--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
