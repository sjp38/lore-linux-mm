Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C0A536B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 15:55:56 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so210268528pab.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 12:55:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sp3si24584076pbc.195.2015.11.09.12.55.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 12:55:55 -0800 (PST)
Date: Mon, 9 Nov 2015 12:55:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ptrace: use fsuid, fsgid, effective creds for fs access
 checks
Message-Id: <20151109125554.43e6a711e59d1b8bf99cdeb1@linux-foundation.org>
In-Reply-To: <1446984516-1784-1-git-send-email-jann@thejh.net>
References: <1446984516-1784-1-git-send-email-jann@thejh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Joe Perches <joe@perches.com>, Thomas Gleixner <tglx@linutronix.de>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, linux-api@vger.kernel.org, security@kernel.org, Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@google.com>

On Sun,  8 Nov 2015 13:08:36 +0100 Jann Horn <jann@thejh.net> wrote:

> By checking the effective credentials instead of the real UID /
> permitted capabilities, ensure that the calling process actually
> intended to use its credentials.
> 
> To ensure that all ptrace checks use the correct caller
> credentials (e.g. in case out-of-tree code or newly added code
> omits the PTRACE_MODE_*CREDS flag), use two new flags and
> require one of them to be set.
> 
> The problem was that when a privileged task had temporarily dropped
> its privileges, e.g. by calling setreuid(0, user_uid), with the
> intent to perform following syscalls with the credentials of
> a user, it still passed ptrace access checks that the user would
> not be able to pass.
> 
> While an attacker should not be able to convince the privileged
> task to perform a ptrace() syscall, this is a problem because the
> ptrace access check is reused for things in procfs.
> 
> In particular, the following somewhat interesting procfs entries
> only rely on ptrace access checks:
> 
>  /proc/$pid/stat - uses the check for determining whether pointers
>      should be visible, useful for bypassing ASLR
>  /proc/$pid/maps - also useful for bypassing ASLR
>  /proc/$pid/cwd - useful for gaining access to restricted
>      directories that contain files with lax permissions, e.g. in
>      this scenario:
>      lrwxrwxrwx root root /proc/13020/cwd -> /root/foobar
>      drwx------ root root /root
>      drwxr-xr-x root root /root/foobar
>      -rw-r--r-- root root /root/foobar/secret
> 
> Therefore, on a system where a root-owned mode 6755 binary
> changes its effective credentials as described and then dumps a
> user-specified file, this could be used by an attacker to reveal
> the memory layout of root's processes or reveal the contents of
> files he is not allowed to access (through /proc/$pid/cwd).

I'll await reviewer input on this one.  Meanwhile, a bunch of
minor(ish) things...

> --- a/fs/proc/array.c
> +++ b/fs/proc/array.c
> @@ -395,7 +395,8 @@ static int do_task_stat(struct seq_file *m, struct pid_namespace *ns,
>  
>  	state = *get_task_state(task);
>  	vsize = eip = esp = 0;
> -	permitted = ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_NOAUDIT);
> +	permitted = ptrace_may_access(task,
> +		PTRACE_MODE_READ | PTRACE_MODE_NOAUDIT | PTRACE_MODE_FSCREDS);

There's lots of ugliness in the patch to do with fitting code into 80 cols. 
Can we do

#define PTRACE_foo (PTRACE_MODE_READ|PTRACE_MODE_FSCREDS)

to avoid all that?

> --- a/include/linux/ptrace.h
> +++ b/include/linux/ptrace.h
> @@ -57,7 +57,22 @@ extern void exit_ptrace(struct task_struct *tracer, struct list_head *dead);
>  #define PTRACE_MODE_READ	0x01
>  #define PTRACE_MODE_ATTACH	0x02
>  #define PTRACE_MODE_NOAUDIT	0x04
> -/* Returns true on success, false on denial. */
> +#define PTRACE_MODE_FSCREDS 0x08
> +#define PTRACE_MODE_REALCREDS 0x10
> +/**
> + * ptrace_may_access - check whether the caller is permitted to access
> + * a target task.
> + * @task: target task
> + * @mode: selects type of access and caller credentials
> + *
> + * Returns true on success, false on denial.
> + *
> + * One of the flags PTRACE_MODE_FSCREDS and PTRACE_MODE_REALCREDS must
> + * be set in @mode to specify whether the access was requested through
> + * a filesystem syscall (should use effective capabilities and fsuid
> + * of the caller) or through an explicit syscall such as
> + * process_vm_writev or ptrace (and should use the real credentials).
> + */
>  extern bool ptrace_may_access(struct task_struct *task, unsigned int mode);

It is unconventional to put the kernedoc in the header - people have
been trained to look for it in the .c file.

> +++ b/kernel/ptrace.c
> @@ -219,6 +219,13 @@ static int ptrace_has_cap(struct user_namespace *ns, unsigned int mode)
>  static int __ptrace_may_access(struct task_struct *task, unsigned int mode)
>  {
>  	const struct cred *cred = current_cred(), *tcred;
> +	kuid_t caller_uid;
> +	kgid_t caller_gid;
> +
> +	if (!(mode & PTRACE_MODE_FSCREDS) != !(mode & PTRACE_MODE_REALCREDS)) {

So setting either one of these and not the other is an error.  How
come?

> +		WARN(1, "denying ptrace access check without PTRACE_MODE_*CREDS\n");

This warning cannot be triggered by malicious userspace, I trust?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
