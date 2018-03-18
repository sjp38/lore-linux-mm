Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0C036B0003
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 10:22:51 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id g203so2286191qkb.3
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 07:22:51 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0043.outbound.protection.outlook.com. [104.47.33.43])
        by mx.google.com with ESMTPS id v1si3550728qtg.211.2018.03.18.07.22.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 18 Mar 2018 07:22:50 -0700 (PDT)
Date: Sun, 18 Mar 2018 17:22:30 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH v16 06/13] task_isolation: userspace hard isolation from
 kernel
Message-ID: <20180318142230.7vcvayiktypqqy7s@yury-thinkpad>
References: <1509728692-10460-1-git-send-email-cmetcalf@mellanox.com>
 <1509728692-10460-7-git-send-email-cmetcalf@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509728692-10460-7-git-send-email-cmetcalf@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Chris,

On Fri, Nov 03, 2017 at 01:04:45PM -0400, Chris Metcalf wrote:
> The existing nohz_full mode is designed as a "soft" isolation mode
> that makes tradeoffs to minimize userspace interruptions while
> still attempting to avoid overheads in the kernel entry/exit path,
> to provide 100% kernel semantics, etc.
> 
> However, some applications require a "hard" commitment from the
> kernel to avoid interruptions, in particular userspace device driver
> style applications, such as high-speed networking code.
> 
> This change introduces a framework to allow applications
> to elect to have the "hard" semantics as needed, specifying
> prctl(PR_TASK_ISOLATION, PR_TASK_ISOLATION_ENABLE) to do so.
> 
> The kernel must be built with the new TASK_ISOLATION Kconfig flag
> to enable this mode, and the kernel booted with an appropriate
> "nohz_full=CPULIST isolcpus=CPULIST" boot argument to enable
> nohz_full and isolcpus.  The "task_isolation" state is then indicated
> by setting a new task struct field, task_isolation_flag, to the
> value passed by prctl(), and also setting a TIF_TASK_ISOLATION
> bit in the thread_info flags.  When the kernel is returning to
> userspace from the prctl() call and sees TIF_TASK_ISOLATION set,
> it calls the new task_isolation_start() routine to arrange for
> the task to avoid being interrupted in the future.
> 
> With interrupts disabled, task_isolation_start() ensures that kernel
> subsystems that might cause a future interrupt are quiesced.  If it
> doesn't succeed, it adjusts the syscall return value to indicate that
> fact, and userspace can retry as desired.  In addition to stopping
> the scheduler tick, the code takes any actions that might avoid
> a future interrupt to the core, such as a worker thread being
> scheduled that could be quiesced now (e.g. the vmstat worker)
> or a future IPI to the core to clean up some state that could be
> cleaned up now (e.g. the mm lru per-cpu cache).
> 
> Once the task has returned to userspace after issuing the prctl(),
> if it enters the kernel again via system call, page fault, or any
> other exception or irq, the kernel will kill it with SIGKILL.
> In addition to sending a signal, the code supports a kernel
> command-line "task_isolation_debug" flag which causes a stack
> backtrace to be generated whenever a task loses isolation.
> 
> To allow the state to be entered and exited, the syscall checking
> test ignores the prctl(PR_TASK_ISOLATION) syscall so that we can
> clear the bit again later, and ignores exit/exit_group to allow
> exiting the task without a pointless signal being delivered.
> 
> The prctl() API allows for specifying a signal number to use instead
> of the default SIGKILL, to allow for catching the notification
> signal; for example, in a production environment, it might be
> helpful to log information to the application logging mechanism
> before exiting.  Or, the signal handler might choose to reset the
> program counter back to the code segment intended to be run isolated
> via prctl() to continue execution.
> 
> In a number of cases we can tell on a remote cpu that we are
> going to be interrupting the cpu, e.g. via an IPI or a TLB flush.
> In that case we generate the diagnostic (and optional stack dump)
> on the remote core to be able to deliver better diagnostics.
> If the interrupt is not something caught by Linux (e.g. a
> hypervisor interrupt) we can also request a reschedule IPI to
> be sent to the remote core so it can be sure to generate a
> signal to notify the process.
> 
> Separate patches that follow provide these changes for x86, tile,
> arm, and arm64.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@mellanox.com>
> ---
>  Documentation/admin-guide/kernel-parameters.txt |   6 +
>  include/linux/isolation.h                       | 175 +++++++++++
>  include/linux/sched.h                           |   4 +
>  include/uapi/linux/prctl.h                      |   6 +
>  init/Kconfig                                    |  28 ++
>  kernel/Makefile                                 |   1 +
>  kernel/context_tracking.c                       |   2 +
>  kernel/isolation.c                              | 402 ++++++++++++++++++++++++
>  kernel/signal.c                                 |   2 +
>  kernel/sys.c                                    |   6 +
>  10 files changed, 631 insertions(+)
>  create mode 100644 include/linux/isolation.h
>  create mode 100644 kernel/isolation.c
 
[...]

> + * This routine is called from syscall entry, prevents most syscalls
> + * from executing, and if needed raises a signal to notify the process.
> + *
> + * Note that we have to stop isolation before we even print a message
> + * here, since otherwise we might end up reporting an interrupt due to
> + * kicking the printk handling code, rather than reporting the true
> + * cause of interrupt here.
> + */
> +int task_isolation_syscall(int syscall)
> +{

All callers of this function call it like this:
        if (work & _TIF_TASK_ISOLATION) {
                if (task_isolation_syscall(regs->syscallno) ==
                                -1)
                        return -1;
        }

Would it make sense to move check of _TIF_TASK_ISOLATION flag inside
the function?

> +	struct task_struct *task = current;
> +
> +	if (is_acceptable_syscall(syscall)) {
> +		stop_isolation(task);
> +		return 0;
> +	}
> +
> +	send_isolation_signal(task);
> +
> +	pr_warn("%s/%d (cpu %d): task_isolation lost due to syscall %d\n",
> +		task->comm, task->pid, smp_processor_id(), syscall);
> +	debug_dump_stack();
> +
> +	syscall_set_return_value(task, current_pt_regs(), -ERESTARTNOINTR, -1);
> +	return -1;
> +}

Yury
