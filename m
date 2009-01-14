Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEED6B006A
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 13:08:35 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id n0EI7Q2m029800
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 05:07:26 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0EI5f2H1495122
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 05:05:42 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0EI4dA3006143
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 05:04:40 +1100
Date: Wed, 14 Jan 2009 23:34:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC v12][PATCH 01/14] Create syscalls: sys_checkpoint,
	sys_restart
Message-ID: <20090114180441.GD21516@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu> <1230542187-10434-2-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1230542187-10434-2-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Mike Waychison <mikew@google.com>
List-ID: <linux-mm.kvack.org>

* Oren Laadan <orenl@cs.columbia.edu> [2008-12-29 04:16:14]:

> Create trivial sys_checkpoint and sys_restore system calls. They will
> enable to checkpoint and restart an entire container, to and from a
> checkpoint image file descriptor.
> 
> The syscalls take a file descriptor (for the image file) and flags as
> arguments. For sys_checkpoint the first argument identifies the target
> container; for sys_restart it will identify the checkpoint image.
> 
> A checkpoint, much like a process coredump, dumps the state of multiple
> processes at once, including the state of the container. The checkpoint
> image is written to (and read from) the file descriptor directly from
> the kernel. This way the data is generated and then pushed out naturally
> as resources and tasks are scanned to save their state. This is the
> approach taken by, e.g., Zap and OpenVZ.
> 
> By using a return value and not a file descriptor, we can distinguish
> between a return from checkpoint, a return from restart (in case of a
> checkpoint that includes self, i.e. a task checkpointing its own
> container, or itself), and an error condition, in a manner analogous
> to a fork() call.
> 
> We don't use copyin()/copyout() because it requires holding the entire

              ^^^^^^^^^^^^^^^^^^^ Do you mean get_user_pages(),
copy_to/from_user()?

> image in user space, and does not make sense for restart.  Also, we
> don't use a pipe, pseudo-fs file and the like, because they work by
> generating data on demand as the user pulls it (unless the entire
> image is buffered in the kernel) and would require more complex logic.
> They also would significantly complicate checkpoint that includes self.
> 
> Changelog[v5]:
>   - Config is 'def_bool n' by default
> 
> Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
> Acked-by: Serge Hallyn <serue@us.ibm.com>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
>  arch/x86/include/asm/unistd_32.h   |    2 +
>  arch/x86/kernel/syscall_table_32.S |    2 +
>  checkpoint/Kconfig                 |   11 +++++++++
>  checkpoint/Makefile                |    5 ++++
>  checkpoint/sys.c                   |   41 ++++++++++++++++++++++++++++++++++++
>  include/linux/syscalls.h           |    2 +
>  init/Kconfig                       |    2 +
>  kernel/sys_ni.c                    |    4 +++
>  8 files changed, 69 insertions(+), 0 deletions(-)
>  create mode 100644 checkpoint/Kconfig
>  create mode 100644 checkpoint/Makefile
>  create mode 100644 checkpoint/sys.c
> 
> diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
> index f2bba78..a5f9e09 100644
> --- a/arch/x86/include/asm/unistd_32.h
> +++ b/arch/x86/include/asm/unistd_32.h
> @@ -338,6 +338,8 @@
>  #define __NR_dup3		330
>  #define __NR_pipe2		331
>  #define __NR_inotify_init1	332
> +#define __NR_checkpoint		333
                           ^^^ extra tab
> +#define __NR_restart		334

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
