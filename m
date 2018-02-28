Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BCD1A6B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 01:11:27 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y20so915652pfm.1
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 22:11:27 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50092.outbound.protection.outlook.com. [40.107.5.92])
        by mx.google.com with ESMTPS id c65si718009pfa.93.2018.02.27.22.11.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Feb 2018 22:11:26 -0800 (PST)
Date: Tue, 27 Feb 2018 22:11:04 -0800
From: Andrei Vagin <avagin@virtuozzo.com>
Subject: Re: [PATCH v5 0/4] vm: add a syscall to map a process memory into a
 pipe
Message-ID: <20180228061103.GA8608@outlook.office365.com>
References: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180220164406.3ec34509376f16841dc66e34@linux-foundation.org>
 <3122ec5a-7f73-f6b4-33ea-8c10ef32e5b0@virtuozzo.com>
 <20180227021818.GA31386@altlinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <20180227021818.GA31386@altlinux.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Dmitry V. Levin" <ldv@altlinux.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, gdb@sourceware.org, devel@lists.open-mpi.org, rr-dev@mozilla.org, Arnd Bergmann <arnd@arndb.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>

On Tue, Feb 27, 2018 at 05:18:18AM +0300, Dmitry V. Levin wrote:
> On Mon, Feb 26, 2018 at 12:02:25PM +0300, Pavel Emelyanov wrote:
> > On 02/21/2018 03:44 AM, Andrew Morton wrote:
> > > On Tue,  9 Jan 2018 08:30:49 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > > 
> > >> This patches introduces new process_vmsplice system call that combines
> > >> functionality of process_vm_read and vmsplice.
> > > 
> > > All seems fairly strightforward.  The big question is: do we know that
> > > people will actually use this, and get sufficient value from it to
> > > justify its addition?
> > 
> > Yes, that's what bothers us a lot too :) I've tried to start with finding out if anyone 
> > used the sys_read/write_process_vm() calls, but failed :( Does anybody know how popular
> > these syscalls are?
> 
> Well, process_vm_readv itself is quite popular, it's used by debuggers nowadays,
> see e.g.
> $ strace -qq -esignal=none -eprocess_vm_readv strace -qq -o/dev/null cat /dev/null

For this case, there is no advantage from process_vmsplice().

But it can significantly optimize a process of generating a core file.
In this case, we need to read a process memory and save content into a
file. process_vmsplice() allows to do this more optimal than
process_vm_readv(), because it doesn't copy data into a userspace.

Here is a part of strace how gdb saves memory content into a core file:

10593 open("/proc/10193/mem", O_RDONLY|O_CLOEXEC) = 17
10593 pread64(17, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 1048576, 140009356111872) = 1048576
10593 close(17)                         = 0
10593 write(16, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 4096) = 4096
10593 write(16, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 1044480) = 1044480
10593 open("/proc/10193/mem", O_RDONLY|O_CLOEXEC) = 17
10593 pread64(17, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 1048576, 140009357160448) = 1048576
10593 close(17)                         = 0
10593 write(16, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 4096) = 4096
10593 write(16, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 1044480) = 1044480
10593 open("/proc/10193/mem", O_RDONLY|O_CLOEXEC) = 17
10593 pread64(17, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 1048576, 140009358209024) = 1048576
10593 close(17)                         = 0
10593 write(16, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 4096) = 4096
10593 write(16, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 1044480) = 1044480
10593 open("/proc/10193/mem", O_RDONLY|O_CLOEXEC) = 17
10593 pread64(17, "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"..., 1048576, 140009359257600) = 1048576
10593 close(17)

It is strange that process_vm_readv() isn't used and that
/proc/10193/mem is opened many times.

BTW: "strace -fo strace-gdb.log gdb -p PID" doesn't work properly.

Thanks,
Andrei

> 
> 
> -- 
> ldv


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
