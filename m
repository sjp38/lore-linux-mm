Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 85F986B0085
	for <linux-mm@kvack.org>; Tue, 27 Jan 2009 12:20:37 -0500 (EST)
Message-ID: <497F424A.7060202@oracle.com>
Date: Tue, 27 Jan 2009 09:20:10 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC v13][PATCH 01/14] Create syscalls: sys_checkpoint, sys_restart
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1233076092-8660-2-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1233076092-8660-2-git-send-email-orenl@cs.columbia.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Oren Laadan wrote:
> Changelog[v5]:
>   - Config is 'def_bool n' by default

That's true by default; it doesn't have to be written/typed.


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
> +#define __NR_restart		334
>  
>  #ifdef __KERNEL__
>  
> diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
> index d44395f..5543136 100644
> --- a/arch/x86/kernel/syscall_table_32.S
> +++ b/arch/x86/kernel/syscall_table_32.S
> @@ -332,3 +332,5 @@ ENTRY(sys_call_table)
>  	.long sys_dup3			/* 330 */
>  	.long sys_pipe2
>  	.long sys_inotify_init1
> +	.long sys_checkpoint
> +	.long sys_restart

> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> new file mode 100644
> index 0000000..375129c
> --- /dev/null
> +++ b/checkpoint/sys.c
> @@ -0,0 +1,41 @@
> +/*
> + *  Generic container checkpoint-restart
> + *
> + *  Copyright (C) 2008 Oren Laadan
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +

#include <linux/syscalls.h>

and then use the new syscall definition macros.
See SYSCALL_DEFINE* in kernel/*.c (current git tree) for examples.

> +#include <linux/sched.h>
> +#include <linux/kernel.h>
> +
> +/**
> + * sys_checkpoint - checkpoint a container
> + * @pid: pid of the container init(1) process
> + * @fd: file to which dump the checkpoint image
> + * @flags: checkpoint operation flags
> + *
> + * Returns positive identifier on success, 0 when returning from restart
> + * or negative value on error
> + */
> +asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
> +{
> +	pr_debug("sys_checkpoint not implemented yet\n");
> +	return -ENOSYS;
> +}
> +/**
> + * sys_restart - restart a container
> + * @crid: checkpoint image identifier
> + * @fd: file from which read the checkpoint image
> + * @flags: restart operation flags
> + *
> + * Returns negative value on error, or otherwise returns in the realm
> + * of the original checkpoint
> + */
> +asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
> +{
> +	pr_debug("sys_restart not implemented yet\n");
> +	return -ENOSYS;
> +}
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 04fb47b..9750393 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -621,6 +621,8 @@ asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
>  asmlinkage long sys_eventfd(unsigned int count);
>  asmlinkage long sys_eventfd2(unsigned int count, int flags);
>  asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
> +asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
> +asmlinkage long sys_restart(int crid, int fd, unsigned long flags);
>  
>  int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
>  
> diff --git a/init/Kconfig b/init/Kconfig
> index f763762..57364fe 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -814,6 +814,8 @@ config MARKERS
>  
>  source "arch/Kconfig"
>  
> +source "checkpoint/Kconfig"
> +
>  endmenu		# General setup
>  
>  config HAVE_GENERIC_DMA_COHERENT
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index e14a232..fcd65cc 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -174,3 +174,7 @@ cond_syscall(compat_sys_timerfd_settime);
>  cond_syscall(compat_sys_timerfd_gettime);
>  cond_syscall(sys_eventfd);
>  cond_syscall(sys_eventfd2);
> +
> +/* checkpoint/restart */
> +cond_syscall(sys_checkpoint);
> +cond_syscall(sys_restart);


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
