Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7926B0072
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 12:22:50 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id w62so1698157wes.27
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 09:22:50 -0800 (PST)
Received: from mail-we0-x235.google.com (mail-we0-x235.google.com [2a00:1450:400c:c03::235])
        by mx.google.com with ESMTPS id lr5si10298981wjb.138.2014.01.13.09.22.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 09:22:49 -0800 (PST)
Received: by mail-we0-f181.google.com with SMTP id u56so4539243wes.40
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 09:22:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1389632555-7039-3-git-send-email-wroberts@tresys.com>
References: <1389632555-7039-1-git-send-email-wroberts@tresys.com>
	<1389632555-7039-3-git-send-email-wroberts@tresys.com>
Date: Mon, 13 Jan 2014 12:22:41 -0500
Message-ID: <CAFftDdogmn6MTMG1kYxEq91jhRxO9xjyMWmPjJiJGsiov25_rA@mail.gmail.com>
Subject: Re: [RFC][PATCH v3 3/3] audit: Audit proc cmdline value
From: William Roberts <bill.c.roberts@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Richard Guy Briggs <rgb@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, akpm@linux-foundation.org, Stephen Smalley <sds@tycho.nsa.gov>
Cc: William Roberts <wroberts@tresys.com>

On Mon, Jan 13, 2014 at 12:02 PM, William Roberts
<bill.c.roberts@gmail.com> wrote:
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
>
> Example denial prior to patch (Ubuntu):
> CALL msg=3Daudit(1387828084.070:361): arch=3Dc000003e syscall=3D82 succes=
s=3Dyes exit=3D0 a0=3D4184bf a1=3D418547 a2=3D0 a3=3D0 items=3D0 ppid=3D1 p=
id=3D1329 auid=3D4294967295 uid=3D0 gid=3D0 euid=3D0 suid=3D0 fsuid=3D0 egi=
d=3D0 sgid=3D0 fsgid=3D0 ses=3D4294967295 tty=3D(none) comm=3D"console-kit-=
dae" exe=3D"/usr/sbin/console-kit-daemon" subj=3Dsystem_u:system_r:consolek=
it_t:s0-s0:c0.c255 key=3D(null)
>
> After Patches (Ubuntu):
> type=3DSYSCALL msg=3Daudit(1387828084.070:361): arch=3Dc000003e syscall=
=3D82 success=3Dyes exit=3D0 a0=3D4184bf a1=3D418547 a2=3D0 a3=3D0 items=3D=
0 ppid=3D1 pid=3D1329 auid=3D4294967295 uid=3D0 gid=3D0 euid=3D0 suid=3D0 f=
suid=3D0 egid=3D0 sgid=3D0 fsgid=3D0 ses=3D4294967295 tty=3D(none) comm=3D"=
console-kit-dae" exe=3D"/usr/sbin/console-kit-daemon" subj=3Dsystem_u:syste=
m_r:consolekit_t:s0-s0:c0.c255 key=3D(null) cmdline=3D"/usr/lib/dbus-1.0/db=
us-daemon-launch-helper"
>
> Example denial prior to patch (Android):
> type=3D1300 msg=3Daudit(248323.940:247): arch=3D40000028 syscall=3D54 per=
=3D840000 success=3Dyes exit=3D0 a0=3D39 a1=3D540b a2=3D2 a3=3D750eecec ite=
ms=3D0 ppid=3D224 pid=3D1858 auid=3D4294967295 uid=3D1002 gid=3D1002 euid=
=3D1002 suid=3D1002 fsuid=3D1002 egid=3D1002 sgid=3D1002 fsgid=3D1002 tty=
=3D(none) ses=3D4294967295 comm=3D"bt_hc_worker" exe=3D"/system/bin/app_pro=
cess" subj=3Du:r:bluetooth:s0 key=3D(null)
>
> After Patches (Android):
> type=3D1300 msg=3Daudit(248323.940:247): arch=3D40000028 syscall=3D54 per=
=3D840000 success=3Dyes exit=3D0 a0=3D39 a1=3D540b a2=3D2 a3=3D750eecec ite=
ms=3D0 ppid=3D224 pid=3D1858 auid=3D4294967295 uid=3D1002 gid=3D1002 euid=
=3D1002 suid=3D1002 fsuid=3D1002 egid=3D1002 sgid=3D1002 fsgid=3D1002 tty=
=3D(none) ses=3D4294967295 comm=3D"bt_hc_worker" exe=3D"/system/bin/app_pro=
cess" subj=3Du:r:bluetooth:s0 key=3D(null) cmdline=3D"com.android.bluetooth=
"
>
> Signed-off-by: William Roberts <wroberts@tresys.com>
> ---
>  kernel/audit.h   |    1 +
>  kernel/auditsc.c |   43 +++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 44 insertions(+)
>
> diff --git a/kernel/audit.h b/kernel/audit.h
> index b779642..bd6211f 100644
> --- a/kernel/audit.h
> +++ b/kernel/audit.h
> @@ -202,6 +202,7 @@ struct audit_context {
>                 } execve;
>         };
>         int fds[2];
> +       char *cmdline;
>
>  #if AUDIT_DEBUG
>         int                 put_count;
> diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> index 90594c9..08bdbec 100644
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -842,6 +842,12 @@ static inline struct audit_context *audit_get_contex=
t(struct task_struct *tsk,
>         return context;
>  }
>
> +static inline void audit_cmdline_free(struct audit_context *context)
> +{
> +       kfree(context->cmdline);
> +       context->cmdline =3D NULL;
> +}
> +
>  static inline void audit_free_names(struct audit_context *context)
>  {
>         struct audit_names *n, *next;
> @@ -955,6 +961,7 @@ static inline void audit_free_context(struct audit_co=
ntext *context)
>         audit_free_aux(context);
>         kfree(context->filterkey);
>         kfree(context->sockaddr);
> +       audit_cmdline_free(context);
>         kfree(context);
>  }
>
> @@ -1271,6 +1278,41 @@ static void show_special(struct audit_context *con=
text, int *call_panic)
>         audit_log_end(ab);
>  }
>
> +static void audit_log_cmdline(struct audit_buffer *ab, struct task_struc=
t *tsk,
> +                        struct audit_context *context)
> +{
> +       int res;
> +       char *buf;
> +       char *msg =3D "(null)";
> +       audit_log_format(ab, " cmdline=3D");
> +
> +       /* Not  cached */
> +       if (!context->cmdline) {
> +               buf =3D kmalloc(PATH_MAX, GFP_KERNEL);
> +               if (!buf)
> +                       goto out;
> +               res =3D get_cmdline(tsk, buf, PATH_MAX);
> +               if (res =3D=3D 0) {
> +                       kfree(buf);
> +                       goto out;
> +               }
> +               /*
> +                * Ensure NULL terminated but don't clobber the end
> +                * unless the buffer is full. Worst case you end up
> +                * with 2 null bytes ending it. By doing it this way
> +                * one avoids additional branching. One checking if the
> +                * end is null and another to check if their should be
> +                * an increment before setting the null byte.
> +                */
> +               res -=3D res =3D=3D PATH_MAX;
> +               buf[res] =3D '\0';
> +               context->cmdline =3D buf;
> +       }
> +       msg =3D context->cmdline;
> +out:
> +       audit_log_untrustedstring(ab, msg);
> +}
> +
>  static void audit_log_exit(struct audit_context *context, struct task_st=
ruct *tsk)
>  {
>         int i, call_panic =3D 0;
> @@ -1303,6 +1345,7 @@ static void audit_log_exit(struct audit_context *co=
ntext, struct task_struct *ts
>
>         audit_log_task_info(ab, tsk);
>         audit_log_key(ab, context->filterkey);
> +       audit_log_cmdline(ab, tsk, context);
>         audit_log_end(ab);
>
>         for (aux =3D context->aux; aux; aux =3D aux->next) {
> --
> 1.7.9.5
>

Incorrect patch version v3, should be v2. Sorry for the confusion. Ill
resend the proper subj.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
