Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AEBF6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 08:39:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so18055402pff.7
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:39:34 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k7si5811514pgp.676.2017.09.26.05.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 05:39:32 -0700 (PDT)
Date: Tue, 26 Sep 2017 13:39:01 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RESEND] proc, coredump: add CoreDumping flag to /proc/pid/status
Message-ID: <20170926123901.GA26395@castle.DHCP.thefacebook.com>
References: <20170914224431.GA9735@castle>
 <20170920230634.31572-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170920230634.31572-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

Hi, Andrew!

As there are no objections, can you, please, pick this patch?

Thank you!

On Wed, Sep 20, 2017 at 04:06:34PM -0700, Roman Gushchin wrote:
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
>   CoreDumping:	0
>   CoreDumping:	1
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
>  		   cpumask_pr_args(&task->cpus_allowed));
>  }
>  
> +static inline void task_core_dumping(struct seq_file *m, struct mm_struct *mm)
> +{
> +	seq_printf(m, "CoreDumping:\t%d\n", !!mm->core_state);
> +}
> +
>  int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
>  			struct pid *pid, struct task_struct *task)
>  {
> @@ -379,6 +384,7 @@ int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
>  
>  	if (mm) {
>  		task_mem(m, mm);
> +		task_core_dumping(m, mm);
>  		mmput(mm);
>  	}
>  	task_sig(m, task);
> -- 
> 2.13.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
