Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84A436B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 05:31:58 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k200so93986185lfg.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 02:31:58 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id uu10si23424343wjc.123.2016.04.25.02.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 02:31:56 -0700 (PDT)
Received: by mail-wm0-f54.google.com with SMTP id u206so117189717wme.1
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 02:31:56 -0700 (PDT)
Date: Mon, 25 Apr 2016 11:31:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + procfs-expose-umask-in-proc-pid-status.patch added to -mm tree
Message-ID: <20160425093155.GD23933@dhcp22.suse.cz>
References: <571a8f8c.6RbLc3Gh9b0xGfe6%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <571a8f8c.6RbLc3Gh9b0xGfe6%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: rjones@redhat.com, jmarchan@redhat.com, keescook@chromium.org, koct9i@gmail.com, pierre@spotify.com, tytso@mit.edu, mm-commits@vger.kernel.org, linux-mm@kvack.org

Just a formal note from me here.

On Fri 22-04-16 13:54:36, Andrew Morton wrote:
> From: "Richard W.M. Jones" <rjones@redhat.com>
> Subject: procfs: expose umask in /proc/<PID>/status
> 
> It's not possible to read the process umask without also modifying it,
> which is what umask(2) does.  A library cannot read umask safely,
> especially if the main program might be multithreaded.
> 
> Add a new status line ("Umask") in /proc/<PID>/status.  It contains
> the file mode creation mask (umask) in octal.  It is only shown for
> tasks which have task->fs.
> 
> This patch is adapted from one originally written by Pierre Carrier.
> 
> 
> The use case is that we have endless trouble with people setting weird
> umask() values (usually on the grounds of "security"), and then everything
> breaking.  I'm on the hook to fix these.  We'd like to add debugging to
> our program so we can dump out the umask in debug reports.
> 
> Previous versions of the patch used a syscall so you could only read your
> own umask.  That's all I need.  However there was quite a lot of push-back
> from those, so this new version exports it in /proc.
> 
> See:
> 

lkmlo.org links tend to be rather unstable from my experience. Please
try to use lkml.kernel.org/[rg]/$msg_id as much as possible

> https://lkml.org/lkml/2016/4/13/704 [umask2]

http://lkml.kernel.org/r/1460574336-18930-1-git-send-email-rjones@redhat.com

> https://lkml.org/lkml/2016/4/13/487 [getumask]

http://lkml.kernel.org/r/1460547786-16766-1-git-send-email-rjones@redhat.com

> Signed-off-by: Richard W.M. Jones <rjones@redhat.com>
> Acked-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Acked-by: Jerome Marchand <jmarchan@redhat.com>
> Acked-by: Kees Cook <keescook@chromium.org>
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Pierre Carrier <pierre@spotify.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  Documentation/filesystems/proc.txt |    1 +
>  fs/proc/array.c                    |   20 +++++++++++++++++++-
>  2 files changed, 20 insertions(+), 1 deletion(-)
> 
> diff -puN Documentation/filesystems/proc.txt~procfs-expose-umask-in-proc-pid-status Documentation/filesystems/proc.txt
> --- a/Documentation/filesystems/proc.txt~procfs-expose-umask-in-proc-pid-status
> +++ a/Documentation/filesystems/proc.txt
> @@ -225,6 +225,7 @@ Table 1-2: Contents of the status files
>   TracerPid                   PID of process tracing this process (0 if not)
>   Uid                         Real, effective, saved set, and  file system UIDs
>   Gid                         Real, effective, saved set, and  file system GIDs
> + Umask                       file mode creation mask
>   FDSize                      number of file descriptor slots currently allocated
>   Groups                      supplementary group list
>   NStgid                      descendant namespace thread group ID hierarchy
> diff -puN fs/proc/array.c~procfs-expose-umask-in-proc-pid-status fs/proc/array.c
> --- a/fs/proc/array.c~procfs-expose-umask-in-proc-pid-status
> +++ a/fs/proc/array.c
> @@ -83,6 +83,7 @@
>  #include <linux/tracehook.h>
>  #include <linux/string_helpers.h>
>  #include <linux/user_namespace.h>
> +#include <linux/fs_struct.h>
>  
>  #include <asm/pgtable.h>
>  #include <asm/processor.h>
> @@ -139,12 +140,25 @@ static inline const char *get_task_state
>  	return task_state_array[fls(state)];
>  }
>  
> +static inline int get_task_umask(struct task_struct *tsk)
> +{
> +	struct fs_struct *fs;
> +	int umask = -ENOENT;
> +
> +	task_lock(tsk);
> +	fs = tsk->fs;
> +	if (fs)
> +		umask = fs->umask;
> +	task_unlock(tsk);
> +	return umask;
> +}
> +
>  static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
>  				struct pid *pid, struct task_struct *p)
>  {
>  	struct user_namespace *user_ns = seq_user_ns(m);
>  	struct group_info *group_info;
> -	int g;
> +	int g, umask;
>  	struct task_struct *tracer;
>  	const struct cred *cred;
>  	pid_t ppid, tpid = 0, tgid, ngid;
> @@ -162,6 +176,10 @@ static inline void task_state(struct seq
>  	ngid = task_numa_group_id(p);
>  	cred = get_task_cred(p);
>  
> +	umask = get_task_umask(p);
> +	if (umask >= 0)
> +		seq_printf(m, "Umask:\t%#04o\n", umask);
> +
>  	task_lock(p);
>  	if (p->files)
>  		max_fds = files_fdtable(p->files)->max_fds;
> _
> 
> Patches currently in -mm which might be from rjones@redhat.com are
> 
> procfs-expose-umask-in-proc-pid-status.patch

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
