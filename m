Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 982B26B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:54:40 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id t10so1150585eei.40
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 13:54:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l44si10293272eem.145.2014.01.15.13.54.39
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 13:54:39 -0800 (PST)
From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH v3 3/3] audit: Audit proc cmdline value
Date: Wed, 15 Jan 2014 16:54:31 -0500
Message-ID: <3556794.adKRynleHP@x2>
In-Reply-To: <1389808934-4446-3-git-send-email-wroberts@tresys.com>
References: <1389808934-4446-1-git-send-email-wroberts@tresys.com> <1389808934-4446-3-git-send-email-wroberts@tresys.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-audit@redhat.com
Cc: William Roberts <bill.c.roberts@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov, William Roberts <wroberts@tresys.com>

On Wednesday, January 15, 2014 01:02:14 PM William Roberts wrote:
> During an audit event, cache and print the value of the process's
> cmdline value (proc/<pid>/cmdline). This is useful in situations
> where processes are started via fork'd virtual machines where the
> comm field is incorrect. Often times, setting the comm field still
> is insufficient as the comm width is not very wide and most
> virtual machine "package names" do not fit. Also, during execution,
> many threads have their comm field set as well. By tying it back to
> the global cmdline value for the process, audit records will be more
> complete in systems with these properties. An example of where this
> is useful and applicable is in the realm of Android. With Android,
> their is no fork/exec for VM instances. The bare, preloaded Dalvik
> VM listens for a fork and specialize request. When this request comes
> in, the VM forks, and the loads the specific application (specializing).
> This was done to take advantage of COW and to not require a load of
> basic packages by the VM on very app spawn. When this spawn occurs,
> the package name is set via setproctitle() and shows up in procfs.
> Many of these package names are longer then 16 bytes, the historical
> width of task->comm. Having the cmdline in the audit records will
> couple the application back to the record directly. Also, on my
> Debian development box, some audit records were more useful then
> what was printed under comm.
> 
> The cached cmdline is tied to the life-cycle of the audit_context
> structure and is built on demand.

I don't think its a good idea to do this for a number of reasons.
1) don't we have a record type for command line and its arguments? Shouldn't 
we use that auxiliary record if we do this?
2) we don't want each and every syscall record to grow huge(r). Remember the 
command line can be virtually unlimited in length. Adding this will consume 
disk space and we will be able to keep less records than we currently do.
3) User space will now have to parse this field, too. If everything is in 1 
field, how can you tell the command from its arguments considering the command 
name could have spaces in it. What if the arguments have spaces in them?

Its far better to fix cmd to be bigger than 16 characters than add all this 
extra information that is not needed in the audit logs.

-Steve


> Example denial prior to patch (Ubuntu):
> CALL msg=audit(1387828084.070:361): arch=c000003e syscall=82 success=yes
> exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329
> auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0
> ses=4294967295 tty=(none) comm="console-kit-dae"
> exe="/usr/sbin/console-kit-daemon"
> subj=system_u:system_r:consolekit_t:s0-s0:c0.c255 key=(null)
> 
> After Patches (Ubuntu):
> type=SYSCALL msg=audit(1387828084.070:361): arch=c000003e syscall=82
> success=yes exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329
> auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0
> ses=4294967295 tty=(none) comm="console-kit-dae"
> exe="/usr/sbin/console-kit-daemon"
> subj=system_u:system_r:consolekit_t:s0-s0:c0.c255
> cmdline="/usr/lib/dbus-1.0/dbus-daemon-launch-helper" key=(null)
> 
> Example denial prior to patch (Android):
> type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000
> success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858
> auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002
> sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker"
> exe="/system/bin/app_process" subj=u:r:bluetooth:s0 key=(null)
> 
> After Patches (Android):
> type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000
> success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858
> auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002
> sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker"
> exe="/system/bin/app_process" cmdline="com.android.bluetooth"
> subj=u:r:bluetooth:s0 key=(null)
> 
> Signed-off-by: William Roberts <wroberts@tresys.com>
> ---
>  kernel/audit.h   |    1 +
>  kernel/auditsc.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 47 insertions(+)
> 
> diff --git a/kernel/audit.h b/kernel/audit.h
> index b779642..bd6211f 100644
> --- a/kernel/audit.h
> +++ b/kernel/audit.h
> @@ -202,6 +202,7 @@ struct audit_context {
>  		} execve;
>  	};
>  	int fds[2];
> +	char *cmdline;
> 
>  #if AUDIT_DEBUG
>  	int		    put_count;
> diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> index 90594c9..cadee2b 100644
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -79,6 +79,9 @@
>  /* no execve audit message should be longer than this (userspace limits) */
> #define MAX_EXECVE_AUDIT_LEN 7500
> 
> +/* max length to print of cmdline value during audit */
> +#define MAX_CMDLINE_AUDIT_LEN 128
> +
>  /* number of audit rules */
>  int audit_n_rules;
> 
> @@ -842,6 +845,12 @@ static inline struct audit_context
> *audit_get_context(struct task_struct *tsk, return context;
>  }
> 
> +static inline void audit_cmdline_free(struct audit_context *context)
> +{
> +	kfree(context->cmdline);
> +	context->cmdline = NULL;
> +}
> +
>  static inline void audit_free_names(struct audit_context *context)
>  {
>  	struct audit_names *n, *next;
> @@ -955,6 +964,7 @@ static inline void audit_free_context(struct
> audit_context *context) audit_free_aux(context);
>  	kfree(context->filterkey);
>  	kfree(context->sockaddr);
> +	audit_cmdline_free(context);
>  	kfree(context);
>  }
> 
> @@ -1271,6 +1281,41 @@ static void show_special(struct audit_context
> *context, int *call_panic) audit_log_end(ab);
>  }
> 
> +static void audit_log_cmdline(struct audit_buffer *ab, struct task_struct
> *tsk, +			 struct audit_context *context)
> +{
> +	int res;
> +	char *buf;
> +	char *msg = "(null)";
> +	audit_log_format(ab, " cmdline=");
> +
> +	/* Not  cached */
> +	if (!context->cmdline) {
> +		buf = kmalloc(MAX_CMDLINE_AUDIT_LEN, GFP_KERNEL);
> +		if (!buf)
> +			goto out;
> +		res = get_cmdline(tsk, buf, MAX_CMDLINE_AUDIT_LEN);
> +		if (res == 0) {
> +			kfree(buf);
> +			goto out;
> +		}
> +		/*
> +		 * Ensure NULL terminated but don't clobber the end
> +		 * unless the buffer is full. Worst case you end up
> +		 * with 2 null bytes ending it. By doing it this way
> +		 * one avoids additional branching. One checking if the
> +		 * end is null and another to check if their should be
> +		 * an increment before setting the null byte.
> +		 */
> +		res -= res == PATH_MAX;
> +		buf[res] = '\0';
> +		context->cmdline = buf;
> +	}
> +	msg = context->cmdline;
> +out:
> +	audit_log_untrustedstring(ab, msg);
> +}
> +
>  static void audit_log_exit(struct audit_context *context, struct
> task_struct *tsk) {
>  	int i, call_panic = 0;
> @@ -1303,6 +1348,7 @@ static void audit_log_exit(struct audit_context
> *context, struct task_struct *ts
> 
>  	audit_log_task_info(ab, tsk);
>  	audit_log_key(ab, context->filterkey);
> +	audit_log_cmdline(ab, tsk, context);
>  	audit_log_end(ab);
> 
>  	for (aux = context->aux; aux; aux = aux->next) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
