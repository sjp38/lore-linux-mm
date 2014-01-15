Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id 456B56B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 07:40:41 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id 8so941394qea.33
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 04:40:41 -0800 (PST)
Received: from mail-oa0-x235.google.com (mail-oa0-x235.google.com [2607:f8b0:4003:c02::235])
        by mx.google.com with ESMTPS id q18si5269877qeu.82.2014.01.15.04.40.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 04:40:40 -0800 (PST)
Received: by mail-oa0-f53.google.com with SMTP id i7so1133273oag.12
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 04:40:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1389022230-24664-3-git-send-email-wroberts@tresys.com>
References: <1389022230-24664-1-git-send-email-wroberts@tresys.com> <1389022230-24664-3-git-send-email-wroberts@tresys.com>
From: Paul Davies C <pauldaviesc@gmail.com>
Date: Wed, 15 Jan 2014 18:10:19 +0530
Message-ID: <CAA80vrAZFvrWGhsY+zpVC4cC0f0XtMWpz5QuRwwrNG8=kGCOcQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/3] audit: Audit proc cmdline value
Content-Type: multipart/alternative; boundary=14dae94ed90dc9c88d04f0019d57
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <bill.c.roberts@gmail.com>
Cc: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov

--14dae94ed90dc9c88d04f0019d57
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Jan 6, 2014 at 9:00 PM, William Roberts <bill.c.roberts@gmail.com>wrote:

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
>
Another important advantage of having the cmdline in the audit log is that
it gives us an idea about the switches , that may have been used along with
a command.

Also consider that we ran *bash example.sh* , if it were to create an audit
event, then audit log will have *comm="bash"* and *exe="/bin/bash"*. If  we
where to add cmdline in audit log then it will have
cmdline="bashexample.sh", which is obviously more helpful.



> The cached cmdline is tied to the life-cycle of the audit_context
> structure and is built on demand.
>
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
>  kernel/auditsc.c |   32 ++++++++++++++++++++++++++++++++
>  2 files changed, 33 insertions(+)
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
> index 90594c9..a4c2003 100644
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -842,6 +842,12 @@ static inline struct audit_context
> *audit_get_context(struct task_struct *tsk,
>         return context;
>  }
>
> +static inline void audit_cmdline_free(struct audit_context *context)
> +{
> +       kfree(context->cmdline);
> +       context->cmdline = NULL;
> +}
> +
>  static inline void audit_free_names(struct audit_context *context)
>  {
>         struct audit_names *n, *next;
> @@ -955,6 +961,7 @@ static inline void audit_free_context(struct
> audit_context *context)
>         audit_free_aux(context);
>         kfree(context->filterkey);
>         kfree(context->sockaddr);
> +       audit_cmdline_free(context);
>         kfree(context);
>  }
>
> @@ -1271,6 +1278,30 @@ static void show_special(struct audit_context
> *context, int *call_panic)
>         audit_log_end(ab);
>  }
>
> +static void audit_log_cmdline(struct audit_buffer *ab, struct task_struct
> *tsk,
> +                        struct audit_context *context)
> +{
> +       int res;
> +       char *buf;
> +       char *msg = "(null)";
> +       audit_log_format(ab, " cmdline=");
> +
> +       /* Not  cached */
> +       if (!context->cmdline) {
> +               buf = kmalloc(PATH_MAX, GFP_KERNEL);
> +               if (!buf)
> +                       goto out;
> +               res = get_cmdline(tsk, buf, PATH_MAX);
> +               /* Ensure NULL terminated */
> +               if (buf[res-1] != '\0')
> +                       buf[res-1] = '\0';
> +               context->cmdline = buf;
> +       }
> +       msg = context->cmdline;
> +out:
> +       audit_log_untrustedstring(ab, msg);
> +}
> +
>  static void audit_log_exit(struct audit_context *context, struct
> task_struct *tsk)
>  {
>         int i, call_panic = 0;
> @@ -1302,6 +1333,7 @@ static void audit_log_exit(struct audit_context
> *context, struct task_struct *ts
>                          context->name_count);
>
>         audit_log_task_info(ab, tsk);
> +       audit_log_cmdline(ab, tsk, context);
>         audit_log_key(ab, context->filterkey);
>         audit_log_end(ab);
>
> --
> 1.7.9.5
>
> --
> Linux-audit mailing list
> Linux-audit@redhat.com
> https://www.redhat.com/mailman/listinfo/linux-audit
>



-- 
*Regards,*
*Paul Davies C*
vivafoss.blogspot.com

--14dae94ed90dc9c88d04f0019d57
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><br><div class=3D"gmail=
_quote">On Mon, Jan 6, 2014 at 9:00 PM, William Roberts <span dir=3D"ltr">&=
lt;<a href=3D"mailto:bill.c.roberts@gmail.com" target=3D"_blank">bill.c.rob=
erts@gmail.com</a>&gt;</span> wrote:<br>

<blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-=
left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;p=
adding-left:1ex">During an audit event, cache and print the value of the pr=
ocess&#39;s<br>


cmdline value (proc/&lt;pid&gt;/cmdline). This is useful in situations<br>
where processes are started via fork&#39;d virtual machines where the<br>
comm field is incorrect. Often times, setting the comm field still<br>
is insufficient as the comm width is not very wide and most<br>
virtual machine &quot;package names&quot; do not fit. Also, during executio=
n,<br>
many threads have their comm field set as well. By tying it back to<br>
the global cmdline value for the process, audit records will be more<br>
complete in systems with these properties. An example of where this<br>
is useful and applicable is in the realm of Android. With Android,<br>
their is no fork/exec for VM instances. The bare, preloaded Dalvik<br>
VM listens for a fork and specialize request. When this request comes<br>
in, the VM forks, and the loads the specific application (specializing).<br=
>
This was done to take advantage of COW and to not require a load of<br>
basic packages by the VM on very app spawn. When this spawn occurs,<br>
the package name is set via setproctitle() and shows up in procfs.<br>
Many of these package names are longer then 16 bytes, the historical<br>
width of task-&gt;comm. Having the cmdline in the audit records will<br>
couple the application back to the record directly. Also, on my<br>
Debian development box, some audit records were more useful then<br>
what was printed under comm.<br>
<br></blockquote><div><br></div><div>Another important advantage of having =
the cmdline in the audit log is that it gives us an idea about the switches=
 , that may have been used along with a command.=A0</div><div><br></div>

<div>Also consider that we ran *bash example.sh* , if it were to create an =
audit event, then audit log will have *comm=3D&quot;bash&quot;* and *exe=3D=
&quot;/bin/bash&quot;*. If =A0we where to add cmdline in audit log then it =
will have cmdline=3D&quot;bashexample.sh&quot;, which is obviously more hel=
pful.</div>

<div><br></div><div>=A0</div><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,2=
04);border-left-style:solid;padding-left:1ex">
The cached cmdline is tied to the life-cycle of the audit_context<br>
structure and is built on demand.<br>
<br>
Example denial prior to patch (Ubuntu):<br>
CALL msg=3Daudit(1387828084.070:361): arch=3Dc000003e syscall=3D82 success=
=3Dyes exit=3D0 a0=3D4184bf a1=3D418547 a2=3D0 a3=3D0 items=3D0 ppid=3D1 pi=
d=3D1329 auid=3D4294967295 uid=3D0 gid=3D0 euid=3D0 suid=3D0 fsuid=3D0 egid=
=3D0 sgid=3D0 fsgid=3D0 ses=3D4294967295 tty=3D(none) comm=3D&quot;console-=
kit-dae&quot; exe=3D&quot;/usr/sbin/console-kit-daemon&quot; subj=3Dsystem_=
u:system_r:consolekit_t:s0-s0:c0.c255 key=3D(null)<br>


<br>
After Patches (Ubuntu):<br>
type=3DSYSCALL msg=3Daudit(1387828084.070:361): arch=3Dc000003e syscall=3D8=
2 success=3Dyes exit=3D0 a0=3D4184bf a1=3D418547 a2=3D0 a3=3D0 items=3D0 pp=
id=3D1 pid=3D1329 auid=3D4294967295 uid=3D0 gid=3D0 euid=3D0 suid=3D0 fsuid=
=3D0 egid=3D0 sgid=3D0 fsgid=3D0 ses=3D4294967295 tty=3D(none) comm=3D&quot=
;console-kit-dae&quot; exe=3D&quot;/usr/sbin/console-kit-daemon&quot; subj=
=3Dsystem_u:system_r:consolekit_t:s0-s0:c0.c255 cmdline=3D&quot;/usr/lib/db=
us-1.0/dbus-daemon-launch-helper&quot; key=3D(null)<br>


<br>
Example denial prior to patch (Android):<br>
type=3D1300 msg=3Daudit(248323.940:247): arch=3D40000028 syscall=3D54 per=
=3D840000 success=3Dyes exit=3D0 a0=3D39 a1=3D540b a2=3D2 a3=3D750eecec ite=
ms=3D0 ppid=3D224 pid=3D1858 auid=3D4294967295 uid=3D1002 gid=3D1002 euid=
=3D1002 suid=3D1002 fsuid=3D1002 egid=3D1002 sgid=3D1002 fsgid=3D1002 tty=
=3D(none) ses=3D4294967295 comm=3D&quot;bt_hc_worker&quot; exe=3D&quot;/sys=
tem/bin/app_process&quot; subj=3Du:r:bluetooth:s0 key=3D(null)<br>


<br>
After Patches (Android):<br>
type=3D1300 msg=3Daudit(248323.940:247): arch=3D40000028 syscall=3D54 per=
=3D840000 success=3Dyes exit=3D0 a0=3D39 a1=3D540b a2=3D2 a3=3D750eecec ite=
ms=3D0 ppid=3D224 pid=3D1858 auid=3D4294967295 uid=3D1002 gid=3D1002 euid=
=3D1002 suid=3D1002 fsuid=3D1002 egid=3D1002 sgid=3D1002 fsgid=3D1002 tty=
=3D(none) ses=3D4294967295 comm=3D&quot;bt_hc_worker&quot; exe=3D&quot;/sys=
tem/bin/app_process&quot; cmdline=3D&quot;com.android.bluetooth&quot; subj=
=3Du:r:bluetooth:s0 key=3D(null)<br>


<br>
Signed-off-by: William Roberts &lt;<a href=3D"mailto:wroberts@tresys.com">w=
roberts@tresys.com</a>&gt;<br>
---<br>
=A0kernel/audit.h =A0 | =A0 =A01 +<br>
=A0kernel/auditsc.c | =A0 32 ++++++++++++++++++++++++++++++++<br>
=A02 files changed, 33 insertions(+)<br>
<br>
diff --git a/kernel/audit.h b/kernel/audit.h<br>
index b779642..bd6211f 100644<br>
--- a/kernel/audit.h<br>
+++ b/kernel/audit.h<br>
@@ -202,6 +202,7 @@ struct audit_context {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } execve;<br>
=A0 =A0 =A0 =A0 };<br>
=A0 =A0 =A0 =A0 int fds[2];<br>
+ =A0 =A0 =A0 char *cmdline;<br>
<br>
=A0#if AUDIT_DEBUG<br>
=A0 =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_count;<br>
diff --git a/kernel/auditsc.c b/kernel/auditsc.c<br>
index 90594c9..a4c2003 100644<br>
--- a/kernel/auditsc.c<br>
+++ b/kernel/auditsc.c<br>
@@ -842,6 +842,12 @@ static inline struct audit_context *audit_get_context(=
struct task_struct *tsk,<br>
=A0 =A0 =A0 =A0 return context;<br>
=A0}<br>
<br>
+static inline void audit_cmdline_free(struct audit_context *context)<br>
+{<br>
+ =A0 =A0 =A0 kfree(context-&gt;cmdline);<br>
+ =A0 =A0 =A0 context-&gt;cmdline =3D NULL;<br>
+}<br>
+<br>
=A0static inline void audit_free_names(struct audit_context *context)<br>
=A0{<br>
=A0 =A0 =A0 =A0 struct audit_names *n, *next;<br>
@@ -955,6 +961,7 @@ static inline void audit_free_context(struct audit_cont=
ext *context)<br>
=A0 =A0 =A0 =A0 audit_free_aux(context);<br>
=A0 =A0 =A0 =A0 kfree(context-&gt;filterkey);<br>
=A0 =A0 =A0 =A0 kfree(context-&gt;sockaddr);<br>
+ =A0 =A0 =A0 audit_cmdline_free(context);<br>
=A0 =A0 =A0 =A0 kfree(context);<br>
=A0}<br>
<br>
@@ -1271,6 +1278,30 @@ static void show_special(struct audit_context *conte=
xt, int *call_panic)<br>
=A0 =A0 =A0 =A0 audit_log_end(ab);<br>
=A0}<br>
<br>
+static void audit_log_cmdline(struct audit_buffer *ab, struct task_struct =
*tsk,<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct audit_context *cont=
ext)<br>
+{<br>
+ =A0 =A0 =A0 int res;<br>
+ =A0 =A0 =A0 char *buf;<br>
+ =A0 =A0 =A0 char *msg =3D &quot;(null)&quot;;<br>
+ =A0 =A0 =A0 audit_log_format(ab, &quot; cmdline=3D&quot;);<br>
+<br>
+ =A0 =A0 =A0 /* Not =A0cached */<br>
+ =A0 =A0 =A0 if (!context-&gt;cmdline) {<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf =3D kmalloc(PATH_MAX, GFP_KERNEL);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!buf)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 res =3D get_cmdline(tsk, buf, PATH_MAX);<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Ensure NULL terminated */<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (buf[res-1] !=3D &#39;\0&#39;)<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf[res-1] =3D &#39;\0&#39;;<=
br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 context-&gt;cmdline =3D buf;<br>
+ =A0 =A0 =A0 }<br>
+ =A0 =A0 =A0 msg =3D context-&gt;cmdline;<br>
+out:<br>
+ =A0 =A0 =A0 audit_log_untrustedstring(ab, msg);<br>
+}<br>
+<br>
=A0static void audit_log_exit(struct audit_context *context, struct task_st=
ruct *tsk)<br>
=A0{<br>
=A0 =A0 =A0 =A0 int i, call_panic =3D 0;<br>
@@ -1302,6 +1333,7 @@ static void audit_log_exit(struct audit_context *cont=
ext, struct task_struct *ts<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0context-&gt;name_count);=
<br>
<br>
=A0 =A0 =A0 =A0 audit_log_task_info(ab, tsk);<br>
+ =A0 =A0 =A0 audit_log_cmdline(ab, tsk, context);<br>
=A0 =A0 =A0 =A0 audit_log_key(ab, context-&gt;filterkey);<br>
=A0 =A0 =A0 =A0 audit_log_end(ab);<br>
<span class=3D""><font color=3D"#888888"><br>
--<br>
1.7.9.5<br>
<br>
--<br>
Linux-audit mailing list<br>
<a href=3D"mailto:Linux-audit@redhat.com">Linux-audit@redhat.com</a><br>
<a href=3D"https://www.redhat.com/mailman/listinfo/linux-audit" target=3D"_=
blank">https://www.redhat.com/mailman/listinfo/linux-audit</a><br>
</font></span></blockquote></div><br><br clear=3D"all"><div><br></div>-- <b=
r><div><font face=3D"&#39;arial narrow&#39;, sans-serif" color=3D"#C0C0C0">=
<b>Regards,</b></font></div><div><font face=3D"&#39;arial narrow&#39;, sans=
-serif" color=3D"#C0C0C0"><b>Paul Davies C</b></font></div>

<a href=3D"http://vivafoss.blogspot.com" target=3D"_blank">vivafoss.blogspo=
t.com</a>
</div></div>

--14dae94ed90dc9c88d04f0019d57--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
