Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D8F346B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 11:44:14 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m199so1068690lfe.3
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 08:44:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s195sor33241lfs.57.2017.09.22.08.44.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Sep 2017 08:44:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170920230634.31572-1-guro@fb.com>
References: <20170914224431.GA9735@castle> <20170920230634.31572-1-guro@fb.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Fri, 22 Sep 2017 18:44:12 +0300
Message-ID: <CALYGNiMOPMrY1+kN=vC4nyD3OG1T1VWSNVTROvPvH2Tchk0z_g@mail.gmail.com>
Subject: Re: [RESEND] proc, coredump: add CoreDumping flag to /proc/pid/status
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, kernel-team@fb.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>

On Thu, Sep 21, 2017 at 2:06 AM, Roman Gushchin <guro@fb.com> wrote:
> Right now there is no convenient way to check if a process is being
> coredumped at the moment.
>
> It might be necessary to recognize such state to prevent killing
> the process and getting a broken coredump.
> Writing a large core might take significant time, and the process
> is unresponsive during it, so it might be killed by timeout,
> if another process is monitoring and killing/restarting
> hanging tasks.
>
> To provide an ability to detect if a process is in the state of
> being coreduped, we can expose a boolean CoreDumping flag
> in /proc/pid/status.

Makes sense.

Maybe print this line only when task actually makes dump?
And probably expose pid of coredump helper.

Add Oleg into CC.

>
> Example:
> $ cat core.sh
>   #!/bin/sh
>
>   echo "|/usr/bin/sleep 10" > /proc/sys/kernel/core_pattern
>   sleep 1000 &
>   PID=$!
>
>   cat /proc/$PID/status | grep CoreDumping
>   kill -ABRT $PID
>   sleep 1
>   cat /proc/$PID/status | grep CoreDumping
>
> $ ./core.sh
>   CoreDumping:  0
>   CoreDumping:  1
>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: kernel-team@fb.com
> Cc: linux-kernel@vger.kernel.org
> ---
>  fs/proc/array.c | 6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/fs/proc/array.c b/fs/proc/array.c
> index 88c355574aa0..fc4a0aa7f487 100644
> --- a/fs/proc/array.c
> +++ b/fs/proc/array.c
> @@ -369,6 +369,11 @@ static void task_cpus_allowed(struct seq_file *m, struct task_struct *task)
>                    cpumask_pr_args(&task->cpus_allowed));
>  }
>
> +static inline void task_core_dumping(struct seq_file *m, struct mm_struct *mm)
> +{
> +       seq_printf(m, "CoreDumping:\t%d\n", !!mm->core_state);
> +}
> +
>  int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
>                         struct pid *pid, struct task_struct *task)
>  {
> @@ -379,6 +384,7 @@ int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
>
>         if (mm) {
>                 task_mem(m, mm);
> +               task_core_dumping(m, mm);
>                 mmput(mm);
>         }
>         task_sig(m, task);
> --
> 2.13.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
