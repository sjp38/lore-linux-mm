Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8896F6B0038
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 14:33:19 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g19so7329387wrb.4
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 11:33:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g16si4108507wmg.76.2017.04.06.11.33.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 11:33:17 -0700 (PDT)
Date: Thu, 6 Apr 2017 20:33:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] fault-inject: support systematic fault injection
Message-ID: <20170406183314.GB5504@dhcp22.suse.cz>
References: <20170328130128.101773-1-dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328130128.101773-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: akinobu.mita@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

[Let's add linux-api - please always cc this list when adding/modifying
user visible interfaces]

On Tue 28-03-17 15:01:28, Dmitry Vyukov wrote:
> Add /proc/self/task/<current-tid>/fail-nth file that allows failing
> 0-th, 1-st, 2-nd and so on calls systematically.
> Excerpt from the added documentation:

I didn't really get to read through details here but it just feels wrong
to add this debugging only feature into proc. It also smells like one
off thing as well.
 
> ===
> Write to this file of integer N makes N-th call in the current task fail
> (N is 0-based). Read from this file returns a single char 'Y' or 'N'
> that says if the fault setup with a previous write to this file was
> injected or not, and disables the fault if it wasn't yet injected.
> Note that this file enables all types of faults (slab, futex, etc).
> This setting takes precedence over all other generic settings like
> probability, interval, times, etc. But per-capability settings
> (e.g. fail_futex/ignore-private) take precedence over it.
> This feature is intended for systematic testing of faults in a single
> system call. See an example below.
> ===
> 
> Why adding new setting:
> 1. Existing settings are global rather than per-task.
>    So parallel testing is not possible.
> 2. attr->interval is close but it depends on attr->count
>    which is non reset to 0, so interval does not work as expected.
> 3. Trying to model this with existing settings requires manipulations
>    of all of probability, interval, times, space, task-filter and
>    unexposed count and per-task make-it-fail files.
> 4. Existing settings are per-failure-type, and the set of failure
>    types is potentially expanding.
> 5. make-it-fail can't be changed by unprivileged user and aggressive
>    stress testing better be done from an unprivileged user.
>    Similarly, this would require opening the debugfs files to the
>    unprivileged user, as he would need to reopen at least times file
>    (not possible to pre-open before dropping privs).
> 
> The proposed interface solves all of the above (see the example).
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> 
> ---
> We want to integrate this into syzkaller fuzzer.
> A prototype has found 10 bugs in kernel in first day of usage:
> https://groups.google.com/forum/#!searchin/syzkaller/%22FAULT_INJECTION%22%7Csort:relevance
> 
> Changes since v1:
>  - change file name from /sys/kernel/debug/fail_once
>    to /proc/self/task/<current-tid>/fail-nth as per
>    Akinobu suggestion
> 
> ---
>  Documentation/fault-injection/fault-injection.txt | 78 +++++++++++++++++++++++
>  fs/proc/base.c                                    | 52 +++++++++++++++
>  include/linux/sched.h                             |  1 +
>  kernel/fork.c                                     |  4 ++
>  lib/fault-inject.c                                |  7 ++
>  5 files changed, 142 insertions(+)
> 
> diff --git a/Documentation/fault-injection/fault-injection.txt b/Documentation/fault-injection/fault-injection.txt
> index 415484f3d59a..192d8cbcc5f9 100644
> --- a/Documentation/fault-injection/fault-injection.txt
> +++ b/Documentation/fault-injection/fault-injection.txt
> @@ -134,6 +134,22 @@ use the boot option:
>  	fail_futex=
>  	mmc_core.fail_request=<interval>,<probability>,<space>,<times>
>  
> +o proc entries
> +
> +- /proc/self/task/<current-tid>/fail-nth:
> +
> +	Write to this file of integer N makes N-th call in the current task fail
> +	(N is 0-based). Read from this file returns a single char 'Y' or 'N'
> +	that says if the fault setup with a previous write to this file was
> +	injected or not, and disables the fault if it wasn't yet injected.
> +	Note that this file enables all types of faults (slab, futex, etc).
> +	This setting takes precedence over all other generic debugfs settings
> +	like probability, interval, times, etc. But per-capability settings
> +	(e.g. fail_futex/ignore-private) take precedence over it.
> +
> +	This feature is intended for systematic testing of faults in a single
> +	system call. See an example below.
> +
>  How to add new fault injection capability
>  -----------------------------------------
>  
> @@ -278,3 +294,65 @@ allocation failure.
>  	# env FAILCMD_TYPE=fail_page_alloc \
>  		./tools/testing/fault-injection/failcmd.sh --times=100 \
>                  -- make -C tools/testing/selftests/ run_tests
> +
> +Systematic faults using fail-nth
> +---------------------------------
> +
> +The following code systematically faults 0-th, 1-st, 2-nd and so on
> +capabilities in the socketpair() system call.
> +
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <sys/socket.h>
> +#include <sys/syscall.h>
> +#include <fcntl.h>
> +#include <unistd.h>
> +#include <string.h>
> +#include <stdlib.h>
> +#include <stdio.h>
> +#include <errno.h>
> +
> +int main()
> +{
> +	int i, err, res, fail_nth, fds[2];
> +	char buf[128];
> +
> +	system("echo N > /sys/kernel/debug/failslab/ignore-gfp-wait");
> +	sprintf(buf, "/proc/self/task/%ld/fail-nth", syscall(SYS_gettid));
> +	fail_nth = open(buf, O_RDWR);
> +	for (i = 0;; i++) {
> +		sprintf(buf, "%d", i);
> +		write(fail_nth, buf, strlen(buf));
> +		res = socketpair(AF_LOCAL, SOCK_STREAM, 0, fds);
> +		err = errno;
> +		read(fail_nth, buf, 1);
> +		if (res == 0) {
> +			close(fds[0]);
> +			close(fds[1]);
> +		}
> +		printf("%d-th fault %c: res=%d/%d\n", i, buf[0], res, err);
> +		if (buf[0] != 'Y')
> +			break;
> +	}
> +	return 0;
> +}
> +
> +An example output:
> +
> +0-th fault Y: res=-1/23
> +1-th fault Y: res=-1/23
> +2-th fault Y: res=-1/23
> +3-th fault Y: res=-1/12
> +4-th fault Y: res=-1/12
> +5-th fault Y: res=-1/23
> +6-th fault Y: res=-1/23
> +7-th fault Y: res=-1/23
> +8-th fault Y: res=-1/12
> +9-th fault Y: res=-1/12
> +10-th fault Y: res=-1/12
> +11-th fault Y: res=-1/12
> +12-th fault Y: res=-1/12
> +13-th fault Y: res=-1/12
> +14-th fault Y: res=-1/12
> +15-th fault Y: res=-1/12
> +16-th fault N: res=0/12
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 6e8655845830..66001172249b 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1353,6 +1353,53 @@ static const struct file_operations proc_fault_inject_operations = {
>  	.write		= proc_fault_inject_write,
>  	.llseek		= generic_file_llseek,
>  };
> +
> +static ssize_t proc_fail_nth_write(struct file *file, const char __user *buf,
> +				   size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task;
> +	int err, n;
> +
> +	task = get_proc_task(file_inode(file));
> +	if (!task)
> +		return -ESRCH;
> +	put_task_struct(task);
> +	if (task != current)
> +		return -EPERM;
> +	err = kstrtoint_from_user(buf, count, 10, &n);
> +	if (err)
> +		return err;
> +	if (n < 0 || n == INT_MAX)
> +		return -EINVAL;
> +	current->fail_nth = n + 1;
> +	return len;
> +}
> +
> +static ssize_t proc_fail_nth_read(struct file *file, char __user *buf,
> +				  size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task;
> +	int err;
> +
> +	task = get_proc_task(file_inode(file));
> +	if (!task)
> +		return -ESRCH;
> +	put_task_struct(task);
> +	if (task != current)
> +		return -EPERM;
> +	if (count < 1)
> +		return -EINVAL;
> +	err = put_user((char)(current->fail_nth ? 'N' : 'Y'), buf);
> +	if (err)
> +		return err;
> +	current->fail_nth = 0;
> +	return 1;
> +}
> +
> +static const struct file_operations proc_fail_nth_operations = {
> +	.read		= proc_fail_nth_read,
> +	.write		= proc_fail_nth_write,
> +};
>  #endif
>  
>  
> @@ -3296,6 +3343,11 @@ static const struct pid_entry tid_base_stuff[] = {
>  #endif
>  #ifdef CONFIG_FAULT_INJECTION
>  	REG("make-it-fail", S_IRUGO|S_IWUSR, proc_fault_inject_operations),
> +	/*
> +	 * Operations on the file check that the task is current,
> +	 * so we create it with 0666 to support testing under unprivileged user.
> +	 */
> +	REG("fail-nth", 0666, proc_fail_nth_operations),
>  #endif
>  #ifdef CONFIG_TASK_IO_ACCOUNTING
>  	ONE("io",	S_IRUSR, proc_tid_io_accounting),
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 543e0ea82684..7b50221fea51 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1897,6 +1897,7 @@ struct task_struct {
>  #endif
>  #ifdef CONFIG_FAULT_INJECTION
>  	int make_it_fail;
> +	int fail_nth;
>  #endif
>  	/*
>  	 * when (nr_dirtied >= nr_dirtied_pause), it's time to call
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 61284d8122fa..869c97a0a930 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -545,6 +545,10 @@ static struct task_struct *dup_task_struct(struct task_struct *orig, int node)
>  
>  	kcov_task_init(tsk);
>  
> +#ifdef CONFIG_FAULT_INJECTION
> +	tsk->fail_nth = 0;
> +#endif
> +
>  	return tsk;
>  
>  free_stack:
> diff --git a/lib/fault-inject.c b/lib/fault-inject.c
> index 6a823a53e357..d6516ba64d33 100644
> --- a/lib/fault-inject.c
> +++ b/lib/fault-inject.c
> @@ -107,6 +107,12 @@ static inline bool fail_stacktrace(struct fault_attr *attr)
>  
>  bool should_fail(struct fault_attr *attr, ssize_t size)
>  {
> +	if (in_task() && current->fail_nth) {
> +		if (--current->fail_nth == 0)
> +			goto fail;
> +		return false;
> +	}
> +
>  	/* No need to check any other properties if the probability is 0 */
>  	if (attr->probability == 0)
>  		return false;
> @@ -134,6 +140,7 @@ bool should_fail(struct fault_attr *attr, ssize_t size)
>  	if (!fail_stacktrace(attr))
>  		return false;
>  
> +fail:
>  	fail_dump(attr);
>  
>  	if (atomic_read(&attr->times) != -1)
> -- 
> 2.12.2.564.g063fe858b8-goog
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
