Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 39C0A6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:50:14 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id y10so1138003wgg.20
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:50:13 -0800 (PST)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id q4si2071308wij.24.2014.01.14.16.50.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 16:50:13 -0800 (PST)
Received: by mail-wi0-f175.google.com with SMTP id hr1so1536675wib.14
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:50:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140114224523.GF23577@madcap2.tricolour.ca>
References: <1389022230-24664-1-git-send-email-wroberts@tresys.com>
	<1389022230-24664-3-git-send-email-wroberts@tresys.com>
	<20140114224523.GF23577@madcap2.tricolour.ca>
Date: Tue, 14 Jan 2014 19:50:13 -0500
Message-ID: <CAFftDdpSm=LyWBaMJban+0ZTxR0iS-rvuLELA9Xj936XjL4zLA@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/3] audit: Audit proc cmdline value
From: William Roberts <bill.c.roberts@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bea41fe0b4d8304eff7b1b4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Guy Briggs <rgb@redhat.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>, William Roberts <wroberts@tresys.com>, akpm@linux-foundation.org, linux-audit@redhat.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org

--047d7bea41fe0b4d8304eff7b1b4
Content-Type: text/plain; charset=ISO-8859-1

The race was non existent. I had the VMA locked. I switched to this to keep
the code that gets the cmdline value almost unchanged to try and reduce
bugs. I can still author a patch on top of this later to optimize. However
the buffer is smaller. Before it was page size, now its path max....iirc is
smaller.
On Jan 14, 2014 5:45 PM, "Richard Guy Briggs" <rgb@redhat.com> wrote:

> On 14/01/06, William Roberts wrote:
> > During an audit event, cache and print the value of the process's
> > cmdline value (proc/<pid>/cmdline). This is useful in situations
> > where processes are started via fork'd virtual machines where the
> > comm field is incorrect. Often times, setting the comm field still
> > is insufficient as the comm width is not very wide and most
> > virtual machine "package names" do not fit. Also, during execution,
> > many threads have their comm field set as well. By tying it back to
> > the global cmdline value for the process, audit records will be more
> > complete in systems with these properties. An example of where this
> > is useful and applicable is in the realm of Android. With Android,
> > their is no fork/exec for VM instances. The bare, preloaded Dalvik
> > VM listens for a fork and specialize request. When this request comes
> > in, the VM forks, and the loads the specific application (specializing).
> > This was done to take advantage of COW and to not require a load of
> > basic packages by the VM on very app spawn. When this spawn occurs,
> > the package name is set via setproctitle() and shows up in procfs.
> > Many of these package names are longer then 16 bytes, the historical
> > width of task->comm. Having the cmdline in the audit records will
> > couple the application back to the record directly. Also, on my
> > Debian development box, some audit records were more useful then
> > what was printed under comm.
>
> So...  What happenned to allocating only what you need instead of the
> full 4k buffer?  Your test results showed promise with only 64 or 128
> bytes allocated.  I recall seeing some discussion about a race between
> testing for the size needed and actually filling the buffer, but was
> hoping that would be worked on rather than reverting back to the full
> 4k.
>
> > The cached cmdline is tied to the life-cycle of the audit_context
> > structure and is built on demand.
> >
> > Example denial prior to patch (Ubuntu):
> > CALL msg=audit(1387828084.070:361): arch=c000003e syscall=82 success=yes
> exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329
> auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0
> ses=4294967295 tty=(none) comm="console-kit-dae"
> exe="/usr/sbin/console-kit-daemon"
> subj=system_u:system_r:consolekit_t:s0-s0:c0.c255 key=(null)
> >
> > After Patches (Ubuntu):
> > type=SYSCALL msg=audit(1387828084.070:361): arch=c000003e syscall=82
> success=yes exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329
> auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0
> ses=4294967295 tty=(none) comm="console-kit-dae"
> exe="/usr/sbin/console-kit-daemon"
> subj=system_u:system_r:consolekit_t:s0-s0:c0.c255
> cmdline="/usr/lib/dbus-1.0/dbus-daemon-launch-helper" key=(null)
> >
> > Example denial prior to patch (Android):
> > type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000
> success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858
> auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002
> sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker"
> exe="/system/bin/app_process" subj=u:r:bluetooth:s0 key=(null)
> >
> > After Patches (Android):
> > type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000
> success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858
> auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002
> sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker"
> exe="/system/bin/app_process" cmdline="com.android.bluetooth"
> subj=u:r:bluetooth:s0 key=(null)
> >
> > Signed-off-by: William Roberts <wroberts@tresys.com>
> > ---
> >  kernel/audit.h   |    1 +
> >  kernel/auditsc.c |   32 ++++++++++++++++++++++++++++++++
> >  2 files changed, 33 insertions(+)
> >
> > diff --git a/kernel/audit.h b/kernel/audit.h
> > index b779642..bd6211f 100644
> > --- a/kernel/audit.h
> > +++ b/kernel/audit.h
> > @@ -202,6 +202,7 @@ struct audit_context {
> >               } execve;
> >       };
> >       int fds[2];
> > +     char *cmdline;
> >
> >  #if AUDIT_DEBUG
> >       int                 put_count;
> > diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> > index 90594c9..a4c2003 100644
> > --- a/kernel/auditsc.c
> > +++ b/kernel/auditsc.c
> > @@ -842,6 +842,12 @@ static inline struct audit_context
> *audit_get_context(struct task_struct *tsk,
> >       return context;
> >  }
> >
> > +static inline void audit_cmdline_free(struct audit_context *context)
> > +{
> > +     kfree(context->cmdline);
> > +     context->cmdline = NULL;
> > +}
> > +
> >  static inline void audit_free_names(struct audit_context *context)
> >  {
> >       struct audit_names *n, *next;
> > @@ -955,6 +961,7 @@ static inline void audit_free_context(struct
> audit_context *context)
> >       audit_free_aux(context);
> >       kfree(context->filterkey);
> >       kfree(context->sockaddr);
> > +     audit_cmdline_free(context);
> >       kfree(context);
> >  }
> >
> > @@ -1271,6 +1278,30 @@ static void show_special(struct audit_context
> *context, int *call_panic)
> >       audit_log_end(ab);
> >  }
> >
> > +static void audit_log_cmdline(struct audit_buffer *ab, struct
> task_struct *tsk,
> > +                      struct audit_context *context)
> > +{
> > +     int res;
> > +     char *buf;
> > +     char *msg = "(null)";
> > +     audit_log_format(ab, " cmdline=");
> > +
> > +     /* Not  cached */
> > +     if (!context->cmdline) {
> > +             buf = kmalloc(PATH_MAX, GFP_KERNEL);
> > +             if (!buf)
> > +                     goto out;
> > +             res = get_cmdline(tsk, buf, PATH_MAX);
> > +             /* Ensure NULL terminated */
> > +             if (buf[res-1] != '\0')
> > +                     buf[res-1] = '\0';
> > +             context->cmdline = buf;
> > +     }
> > +     msg = context->cmdline;
> > +out:
> > +     audit_log_untrustedstring(ab, msg);
> > +}
> > +
> >  static void audit_log_exit(struct audit_context *context, struct
> task_struct *tsk)
> >  {
> >       int i, call_panic = 0;
> > @@ -1302,6 +1333,7 @@ static void audit_log_exit(struct audit_context
> *context, struct task_struct *ts
> >                        context->name_count);
> >
> >       audit_log_task_info(ab, tsk);
> > +     audit_log_cmdline(ab, tsk, context);
> >       audit_log_key(ab, context->filterkey);
> >       audit_log_end(ab);
> >
> > --
> > 1.7.9.5
> >
> > --
> > Linux-audit mailing list
> > Linux-audit@redhat.com
> > https://www.redhat.com/mailman/listinfo/linux-audit
>
> - RGB
>
> --
> Richard Guy Briggs <rbriggs@redhat.com>
> Senior Software Engineer, Kernel Security, AMER ENG Base Operating
> Systems, Red Hat
> Remote, Ottawa, Canada
> Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
>

--047d7bea41fe0b4d8304eff7b1b4
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr">The race was non existent. I had the VMA locked. I switched =
to this to keep the code that gets the cmdline value almost unchanged to tr=
y and reduce bugs. I can still author a patch on top of this later to optim=
ize. However the buffer is smaller. Before it was page size, now its path m=
ax....iirc is smaller.</p>

<div class=3D"gmail_quote">On Jan 14, 2014 5:45 PM, &quot;Richard Guy Brigg=
s&quot; &lt;<a href=3D"mailto:rgb@redhat.com">rgb@redhat.com</a>&gt; wrote:=
<br type=3D"attribution"><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
On 14/01/06, William Roberts wrote:<br>
&gt; During an audit event, cache and print the value of the process&#39;s<=
br>
&gt; cmdline value (proc/&lt;pid&gt;/cmdline). This is useful in situations=
<br>
&gt; where processes are started via fork&#39;d virtual machines where the<=
br>
&gt; comm field is incorrect. Often times, setting the comm field still<br>
&gt; is insufficient as the comm width is not very wide and most<br>
&gt; virtual machine &quot;package names&quot; do not fit. Also, during exe=
cution,<br>
&gt; many threads have their comm field set as well. By tying it back to<br=
>
&gt; the global cmdline value for the process, audit records will be more<b=
r>
&gt; complete in systems with these properties. An example of where this<br=
>
&gt; is useful and applicable is in the realm of Android. With Android,<br>
&gt; their is no fork/exec for VM instances. The bare, preloaded Dalvik<br>
&gt; VM listens for a fork and specialize request. When this request comes<=
br>
&gt; in, the VM forks, and the loads the specific application (specializing=
).<br>
&gt; This was done to take advantage of COW and to not require a load of<br=
>
&gt; basic packages by the VM on very app spawn. When this spawn occurs,<br=
>
&gt; the package name is set via setproctitle() and shows up in procfs.<br>
&gt; Many of these package names are longer then 16 bytes, the historical<b=
r>
&gt; width of task-&gt;comm. Having the cmdline in the audit records will<b=
r>
&gt; couple the application back to the record directly. Also, on my<br>
&gt; Debian development box, some audit records were more useful then<br>
&gt; what was printed under comm.<br>
<br>
So... =A0What happenned to allocating only what you need instead of the<br>
full 4k buffer? =A0Your test results showed promise with only 64 or 128<br>
bytes allocated. =A0I recall seeing some discussion about a race between<br=
>
testing for the size needed and actually filling the buffer, but was<br>
hoping that would be worked on rather than reverting back to the full<br>
4k.<br>
<br>
&gt; The cached cmdline is tied to the life-cycle of the audit_context<br>
&gt; structure and is built on demand.<br>
&gt;<br>
&gt; Example denial prior to patch (Ubuntu):<br>
&gt; CALL msg=3Daudit(1387828084.070:361): arch=3Dc000003e syscall=3D82 suc=
cess=3Dyes exit=3D0 a0=3D4184bf a1=3D418547 a2=3D0 a3=3D0 items=3D0 ppid=3D=
1 pid=3D1329 auid=3D4294967295 uid=3D0 gid=3D0 euid=3D0 suid=3D0 fsuid=3D0 =
egid=3D0 sgid=3D0 fsgid=3D0 ses=3D4294967295 tty=3D(none) comm=3D&quot;cons=
ole-kit-dae&quot; exe=3D&quot;/usr/sbin/console-kit-daemon&quot; subj=3Dsys=
tem_u:system_r:consolekit_t:s0-s0:c0.c255 key=3D(null)<br>

&gt;<br>
&gt; After Patches (Ubuntu):<br>
&gt; type=3DSYSCALL msg=3Daudit(1387828084.070:361): arch=3Dc000003e syscal=
l=3D82 success=3Dyes exit=3D0 a0=3D4184bf a1=3D418547 a2=3D0 a3=3D0 items=
=3D0 ppid=3D1 pid=3D1329 auid=3D4294967295 uid=3D0 gid=3D0 euid=3D0 suid=3D=
0 fsuid=3D0 egid=3D0 sgid=3D0 fsgid=3D0 ses=3D4294967295 tty=3D(none) comm=
=3D&quot;console-kit-dae&quot; exe=3D&quot;/usr/sbin/console-kit-daemon&quo=
t; subj=3Dsystem_u:system_r:consolekit_t:s0-s0:c0.c255 cmdline=3D&quot;/usr=
/lib/dbus-1.0/dbus-daemon-launch-helper&quot; key=3D(null)<br>

&gt;<br>
&gt; Example denial prior to patch (Android):<br>
&gt; type=3D1300 msg=3Daudit(248323.940:247): arch=3D40000028 syscall=3D54 =
per=3D840000 success=3Dyes exit=3D0 a0=3D39 a1=3D540b a2=3D2 a3=3D750eecec =
items=3D0 ppid=3D224 pid=3D1858 auid=3D4294967295 uid=3D1002 gid=3D1002 eui=
d=3D1002 suid=3D1002 fsuid=3D1002 egid=3D1002 sgid=3D1002 fsgid=3D1002 tty=
=3D(none) ses=3D4294967295 comm=3D&quot;bt_hc_worker&quot; exe=3D&quot;/sys=
tem/bin/app_process&quot; subj=3Du:r:bluetooth:s0 key=3D(null)<br>

&gt;<br>
&gt; After Patches (Android):<br>
&gt; type=3D1300 msg=3Daudit(248323.940:247): arch=3D40000028 syscall=3D54 =
per=3D840000 success=3Dyes exit=3D0 a0=3D39 a1=3D540b a2=3D2 a3=3D750eecec =
items=3D0 ppid=3D224 pid=3D1858 auid=3D4294967295 uid=3D1002 gid=3D1002 eui=
d=3D1002 suid=3D1002 fsuid=3D1002 egid=3D1002 sgid=3D1002 fsgid=3D1002 tty=
=3D(none) ses=3D4294967295 comm=3D&quot;bt_hc_worker&quot; exe=3D&quot;/sys=
tem/bin/app_process&quot; cmdline=3D&quot;com.android.bluetooth&quot; subj=
=3Du:r:bluetooth:s0 key=3D(null)<br>

&gt;<br>
&gt; Signed-off-by: William Roberts &lt;<a href=3D"mailto:wroberts@tresys.c=
om">wroberts@tresys.com</a>&gt;<br>
&gt; ---<br>
&gt; =A0kernel/audit.h =A0 | =A0 =A01 +<br>
&gt; =A0kernel/auditsc.c | =A0 32 ++++++++++++++++++++++++++++++++<br>
&gt; =A02 files changed, 33 insertions(+)<br>
&gt;<br>
&gt; diff --git a/kernel/audit.h b/kernel/audit.h<br>
&gt; index b779642..bd6211f 100644<br>
&gt; --- a/kernel/audit.h<br>
&gt; +++ b/kernel/audit.h<br>
&gt; @@ -202,6 +202,7 @@ struct audit_context {<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 } execve;<br>
&gt; =A0 =A0 =A0 };<br>
&gt; =A0 =A0 =A0 int fds[2];<br>
&gt; + =A0 =A0 char *cmdline;<br>
&gt;<br>
&gt; =A0#if AUDIT_DEBUG<br>
&gt; =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_count;<br>
&gt; diff --git a/kernel/auditsc.c b/kernel/auditsc.c<br>
&gt; index 90594c9..a4c2003 100644<br>
&gt; --- a/kernel/auditsc.c<br>
&gt; +++ b/kernel/auditsc.c<br>
&gt; @@ -842,6 +842,12 @@ static inline struct audit_context *audit_get_con=
text(struct task_struct *tsk,<br>
&gt; =A0 =A0 =A0 return context;<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static inline void audit_cmdline_free(struct audit_context *context)<=
br>
&gt; +{<br>
&gt; + =A0 =A0 kfree(context-&gt;cmdline);<br>
&gt; + =A0 =A0 context-&gt;cmdline =3D NULL;<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static inline void audit_free_names(struct audit_context *context)<=
br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 struct audit_names *n, *next;<br>
&gt; @@ -955,6 +961,7 @@ static inline void audit_free_context(struct audit=
_context *context)<br>
&gt; =A0 =A0 =A0 audit_free_aux(context);<br>
&gt; =A0 =A0 =A0 kfree(context-&gt;filterkey);<br>
&gt; =A0 =A0 =A0 kfree(context-&gt;sockaddr);<br>
&gt; + =A0 =A0 audit_cmdline_free(context);<br>
&gt; =A0 =A0 =A0 kfree(context);<br>
&gt; =A0}<br>
&gt;<br>
&gt; @@ -1271,6 +1278,30 @@ static void show_special(struct audit_context *=
context, int *call_panic)<br>
&gt; =A0 =A0 =A0 audit_log_end(ab);<br>
&gt; =A0}<br>
&gt;<br>
&gt; +static void audit_log_cmdline(struct audit_buffer *ab, struct task_st=
ruct *tsk,<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct audit_context *con=
text)<br>
&gt; +{<br>
&gt; + =A0 =A0 int res;<br>
&gt; + =A0 =A0 char *buf;<br>
&gt; + =A0 =A0 char *msg =3D &quot;(null)&quot;;<br>
&gt; + =A0 =A0 audit_log_format(ab, &quot; cmdline=3D&quot;);<br>
&gt; +<br>
&gt; + =A0 =A0 /* Not =A0cached */<br>
&gt; + =A0 =A0 if (!context-&gt;cmdline) {<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 buf =3D kmalloc(PATH_MAX, GFP_KERNEL);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (!buf)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 res =3D get_cmdline(tsk, buf, PATH_MAX);<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 /* Ensure NULL terminated */<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 if (buf[res-1] !=3D &#39;\0&#39;)<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf[res-1] =3D &#39;\0&#39;;=
<br>
&gt; + =A0 =A0 =A0 =A0 =A0 =A0 context-&gt;cmdline =3D buf;<br>
&gt; + =A0 =A0 }<br>
&gt; + =A0 =A0 msg =3D context-&gt;cmdline;<br>
&gt; +out:<br>
&gt; + =A0 =A0 audit_log_untrustedstring(ab, msg);<br>
&gt; +}<br>
&gt; +<br>
&gt; =A0static void audit_log_exit(struct audit_context *context, struct ta=
sk_struct *tsk)<br>
&gt; =A0{<br>
&gt; =A0 =A0 =A0 int i, call_panic =3D 0;<br>
&gt; @@ -1302,6 +1333,7 @@ static void audit_log_exit(struct audit_context =
*context, struct task_struct *ts<br>
&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0context-&gt;name_count)=
;<br>
&gt;<br>
&gt; =A0 =A0 =A0 audit_log_task_info(ab, tsk);<br>
&gt; + =A0 =A0 audit_log_cmdline(ab, tsk, context);<br>
&gt; =A0 =A0 =A0 audit_log_key(ab, context-&gt;filterkey);<br>
&gt; =A0 =A0 =A0 audit_log_end(ab);<br>
&gt;<br>
&gt; --<br>
&gt; 1.7.9.5<br>
&gt;<br>
&gt; --<br>
&gt; Linux-audit mailing list<br>
&gt; <a href=3D"mailto:Linux-audit@redhat.com">Linux-audit@redhat.com</a><b=
r>
&gt; <a href=3D"https://www.redhat.com/mailman/listinfo/linux-audit" target=
=3D"_blank">https://www.redhat.com/mailman/listinfo/linux-audit</a><br>
<br>
- RGB<br>
<br>
--<br>
Richard Guy Briggs &lt;<a href=3D"mailto:rbriggs@redhat.com">rbriggs@redhat=
.com</a>&gt;<br>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems,=
 Red Hat<br>
Remote, Ottawa, Canada<br>
Voice: <a href=3D"tel:%2B1.647.777.2635" value=3D"+16477772635">+1.647.777.=
2635</a>, Internal: (81) 32635, Alt: <a href=3D"tel:%2B1.613.693.0684x3545"=
 value=3D"+16136930684">+1.613.693.0684x3545</a><br>
</blockquote></div>

--047d7bea41fe0b4d8304eff7b1b4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
