Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id B44EE6B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:01:49 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id r15so1219118ead.27
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:01:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w5si4577013eef.172.2014.02.06.15.01.47
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 15:01:48 -0800 (PST)
From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH v5 3/3] audit: Audit proc/<pid>/cmdline aka proctitle
Date: Thu, 06 Feb 2014 18:01:39 -0500
Message-ID: <4258851.7s7uqWZHxJ@x2>
In-Reply-To: <1391710528-23481-3-git-send-email-wroberts@tresys.com>
References: <1391710528-23481-1-git-send-email-wroberts@tresys.com> <1391710528-23481-3-git-send-email-wroberts@tresys.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-audit@redhat.com
Cc: William Roberts <bill.c.roberts@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov, William Roberts <wroberts@tresys.com>

On Thursday, February 06, 2014 10:15:28 AM William Roberts wrote:
> During an audit event, cache and print the value of the process's
> proctitle value (proc/<pid>/cmdline). This is useful in situations
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
> The cached proctitle is tied to the life-cycle of the audit_context
> structure and is built on demand.
> 
> Proctitle is controllable by userspace, and thus should not be trusted.
> It is meant as an aid to assist in debugging. The proctitle event is
> emitted during syscall audits, and can be filtered with auditctl.

Ack  wrt record format and contents.

-Steve

> Example:
> type=AVC msg=audit(1391217013.924:386): avc:  denied  { getattr } for 
> pid=1971 comm="mkdir" name="/" dev="selinuxfs" ino=1
> scontext=system_u:system_r:consolekit_t:s0-s0:c0.c255
> tcontext=system_u:object_r:security_t:s0 tclass=filesystem type=SYSCALL
> msg=audit(1391217013.924:386): arch=c000003e syscall=137 success=yes exit=0
> a0=7f019dfc8bd7 a1=7fffa6aed2c0 a2=fffffffffff4bd25 a3=7fffa6aed050 items=0
> ppid=1967 pid=1971 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0
> sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="mkdir" exe="/bin/mkdir"
> subj=system_u:system_r:consolekit_t:s0-s0:c0.c255 key=(null)
> type=UNKNOWN[1327] msg=audit(1391217013.924:386): 
> proctitle=6D6B646972002D70002F7661722F72756E2F636F6E736F6C65
> 
> Signed-off-by: William Roberts <wroberts@tresys.com>
> ---
>  include/uapi/linux/audit.h |    1 +
>  kernel/audit.h             |    6 ++++
>  kernel/auditsc.c           |   67
> ++++++++++++++++++++++++++++++++++++++++++++ 3 files changed, 74
> insertions(+)
> 
> diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
> index 2d48fe1..4315ee9 100644
> --- a/include/uapi/linux/audit.h
> +++ b/include/uapi/linux/audit.h
> @@ -109,6 +109,7 @@
>  #define AUDIT_NETFILTER_PKT	1324	/* Packets traversing netfilter chains 
*/
>  #define AUDIT_NETFILTER_CFG	1325	/* Netfilter chain modifications */
>  #define AUDIT_SECCOMP		1326	/* Secure Computing event */
> +#define AUDIT_PROCTITLE		1327	/* Proctitle emit event */
> 
>  #define AUDIT_AVC		1400	/* SE Linux avc denial or grant */
>  #define AUDIT_SELINUX_ERR	1401	/* Internal SE Linux Errors */
> diff --git a/kernel/audit.h b/kernel/audit.h
> index 57cc64d..38c967d 100644
> --- a/kernel/audit.h
> +++ b/kernel/audit.h
> @@ -106,6 +106,11 @@ struct audit_names {
>  	bool			should_free;
>  };
> 
> +struct audit_proctitle {
> +	int	len;	/* length of the cmdline field. */
> +	char	*value;	/* the cmdline field */
> +};
> +
>  /* The per-task audit context. */
>  struct audit_context {
>  	int		    dummy;	/* must be the first element */
> @@ -202,6 +207,7 @@ struct audit_context {
>  		} execve;
>  	};
>  	int fds[2];
> +	struct audit_proctitle proctitle;
> 
>  #if AUDIT_DEBUG
>  	int		    put_count;
> diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> index 10176cd..e342eb0 100644
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -68,6 +68,7 @@
>  #include <linux/capability.h>
>  #include <linux/fs_struct.h>
>  #include <linux/compat.h>
> +#include <linux/ctype.h>
> 
>  #include "audit.h"
> 
> @@ -79,6 +80,9 @@
>  /* no execve audit message should be longer than this (userspace limits) */
> #define MAX_EXECVE_AUDIT_LEN 7500
> 
> +/* max length to print of cmdline/proctitle value during audit */
> +#define MAX_PROCTITLE_AUDIT_LEN 128
> +
>  /* number of audit rules */
>  int audit_n_rules;
> 
> @@ -842,6 +846,13 @@ static inline struct audit_context
> *audit_get_context(struct task_struct *tsk, return context;
>  }
> 
> +static inline void audit_proctitle_free(struct audit_context *context)
> +{
> +	kfree(context->proctitle.value);
> +	context->proctitle.value = NULL;
> +	context->proctitle.len = 0;
> +}
> +
>  static inline void audit_free_names(struct audit_context *context)
>  {
>  	struct audit_names *n, *next;
> @@ -955,6 +966,7 @@ static inline void audit_free_context(struct
> audit_context *context) audit_free_aux(context);
>  	kfree(context->filterkey);
>  	kfree(context->sockaddr);
> +	audit_proctitle_free(context);
>  	kfree(context);
>  }
> 
> @@ -1271,6 +1283,59 @@ static void show_special(struct audit_context
> *context, int *call_panic) audit_log_end(ab);
>  }
> 
> +static inline int audit_proctitle_rtrim(char *proctitle, int len)
> +{
> +	char *end = proctitle + len - 1;
> +	while (end > proctitle && !isprint(*end))
> +		end--;
> +
> +	/* catch the case where proctitle is only 1 non-print character */
> +	len = end - proctitle + 1;
> +	len -= isprint(proctitle[len-1]) == 0;
> +	return len;
> +}
> +
> +static void audit_log_proctitle(struct task_struct *tsk,
> +			 struct audit_context *context)
> +{
> +	int res;
> +	char *buf;
> +	char *msg = "(null)";
> +	int len = strlen(msg);
> +	struct audit_buffer *ab;
> +
> +	ab = audit_log_start(context, GFP_KERNEL, AUDIT_PROCTITLE);
> +	if (!ab)
> +		return;	/* audit_panic or being filtered */
> +
> +	audit_log_format(ab, "proctitle=");
> +
> +	/* Not  cached */
> +	if (!context->proctitle.value) {
> +		buf = kmalloc(MAX_PROCTITLE_AUDIT_LEN, GFP_KERNEL);
> +		if (!buf)
> +			goto out;
> +		/* Historically called this from procfs naming */
> +		res = get_cmdline(tsk, buf, MAX_PROCTITLE_AUDIT_LEN);
> +		if (res == 0) {
> +			kfree(buf);
> +			goto out;
> +		}
> +		res = audit_proctitle_rtrim(buf, res);
> +		if (res == 0) {
> +			kfree(buf);
> +			goto out;
> +		}
> +		context->proctitle.value = buf;
> +		context->proctitle.len = res;
> +	}
> +	msg = context->proctitle.value;
> +	len = context->proctitle.len;
> +out:
> +	audit_log_n_untrustedstring(ab, msg, len);
> +	audit_log_end(ab);
> +}
> +
>  static void audit_log_exit(struct audit_context *context, struct
> task_struct *tsk) {
>  	int i, call_panic = 0;
> @@ -1388,6 +1453,8 @@ static void audit_log_exit(struct audit_context
> *context, struct task_struct *ts audit_log_name(context, n, NULL, i++,
> &call_panic);
>  	}
> 
> +	audit_log_proctitle(tsk, context);
> +
>  	/* Send end of event record to help user space know we are finished */
>  	ab = audit_log_start(context, GFP_KERNEL, AUDIT_EOE);
>  	if (ab)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
