Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id CEF9F6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 19:56:08 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id l18so1123422wgh.11
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:56:08 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id bv8si1778441wjb.146.2014.01.14.16.56.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 16:56:07 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id hm2so1528362wib.10
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 16:56:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAFftDdpSm=LyWBaMJban+0ZTxR0iS-rvuLELA9Xj936XjL4zLA@mail.gmail.com>
References: <1389022230-24664-1-git-send-email-wroberts@tresys.com>
	<1389022230-24664-3-git-send-email-wroberts@tresys.com>
	<20140114224523.GF23577@madcap2.tricolour.ca>
	<CAFftDdpSm=LyWBaMJban+0ZTxR0iS-rvuLELA9Xj936XjL4zLA@mail.gmail.com>
Date: Tue, 14 Jan 2014 19:56:07 -0500
Message-ID: <CAFftDdq=X54MeGFjRg5=45pfhVOik2NPqju5Zqyzu79tGTC1yg@mail.gmail.com>
Subject: Re: [RFC][PATCH 3/3] audit: Audit proc cmdline value
From: William Roberts <bill.c.roberts@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Guy Briggs <rgb@redhat.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>, William Roberts <wroberts@tresys.com>, akpm@linux-foundation.org, "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

This bounced LKML, re-sending. My phone sent it as HTML

On Tue, Jan 14, 2014 at 7:50 PM, William Roberts
<bill.c.roberts@gmail.com> wrote:
> The race was non existent. I had the VMA locked. I switched to this to keep
> the code that gets the cmdline value almost unchanged to try and reduce
> bugs. I can still author a patch on top of this later to optimize. However
> the buffer is smaller. Before it was page size, now its path max....iirc is
> smaller.
>
> On Jan 14, 2014 5:45 PM, "Richard Guy Briggs" <rgb@redhat.com> wrote:
>>
>> On 14/01/06, William Roberts wrote:
>> > During an audit event, cache and print the value of the process's
>> > cmdline value (proc/<pid>/cmdline). This is useful in situations
>> > where processes are started via fork'd virtual machines where the
>> > comm field is incorrect. Often times, setting the comm field still
>> > is insufficient as the comm width is not very wide and most
>> > virtual machine "package names" do not fit. Also, during execution,
>> > many threads have their comm field set as well. By tying it back to
>> > the global cmdline value for the process, audit records will be more
>> > complete in systems with these properties. An example of where this
>> > is useful and applicable is in the realm of Android. With Android,
>> > their is no fork/exec for VM instances. The bare, preloaded Dalvik
>> > VM listens for a fork and specialize request. When this request comes
>> > in, the VM forks, and the loads the specific application (specializing).
>> > This was done to take advantage of COW and to not require a load of
>> > basic packages by the VM on very app spawn. When this spawn occurs,
>> > the package name is set via setproctitle() and shows up in procfs.
>> > Many of these package names are longer then 16 bytes, the historical
>> > width of task->comm. Having the cmdline in the audit records will
>> > couple the application back to the record directly. Also, on my
>> > Debian development box, some audit records were more useful then
>> > what was printed under comm.
>>
>> So...  What happenned to allocating only what you need instead of the
>> full 4k buffer?  Your test results showed promise with only 64 or 128
>> bytes allocated.  I recall seeing some discussion about a race between
>> testing for the size needed and actually filling the buffer, but was
>> hoping that would be worked on rather than reverting back to the full
>> 4k.
>>
>> > The cached cmdline is tied to the life-cycle of the audit_context
>> > structure and is built on demand.
>> >
>> > Example denial prior to patch (Ubuntu):
>> > CALL msg=audit(1387828084.070:361): arch=c000003e syscall=82 success=yes
>> > exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329 auid=4294967295
>> > uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 ses=4294967295
>> > tty=(none) comm="console-kit-dae" exe="/usr/sbin/console-kit-daemon"
>> > subj=system_u:system_r:consolekit_t:s0-s0:c0.c255 key=(null)
>> >
>> > After Patches (Ubuntu):
>> > type=SYSCALL msg=audit(1387828084.070:361): arch=c000003e syscall=82
>> > success=yes exit=0 a0=4184bf a1=418547 a2=0 a3=0 items=0 ppid=1 pid=1329
>> > auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0
>> > ses=4294967295 tty=(none) comm="console-kit-dae"
>> > exe="/usr/sbin/console-kit-daemon"
>> > subj=system_u:system_r:consolekit_t:s0-s0:c0.c255
>> > cmdline="/usr/lib/dbus-1.0/dbus-daemon-launch-helper" key=(null)
>> >
>> > Example denial prior to patch (Android):
>> > type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000
>> > success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858
>> > auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002
>> > sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker"
>> > exe="/system/bin/app_process" subj=u:r:bluetooth:s0 key=(null)
>> >
>> > After Patches (Android):
>> > type=1300 msg=audit(248323.940:247): arch=40000028 syscall=54 per=840000
>> > success=yes exit=0 a0=39 a1=540b a2=2 a3=750eecec items=0 ppid=224 pid=1858
>> > auid=4294967295 uid=1002 gid=1002 euid=1002 suid=1002 fsuid=1002 egid=1002
>> > sgid=1002 fsgid=1002 tty=(none) ses=4294967295 comm="bt_hc_worker"
>> > exe="/system/bin/app_process" cmdline="com.android.bluetooth"
>> > subj=u:r:bluetooth:s0 key=(null)
>> >
>> > Signed-off-by: William Roberts <wroberts@tresys.com>
>> > ---
>> >  kernel/audit.h   |    1 +
>> >  kernel/auditsc.c |   32 ++++++++++++++++++++++++++++++++
>> >  2 files changed, 33 insertions(+)
>> >
>> > diff --git a/kernel/audit.h b/kernel/audit.h
>> > index b779642..bd6211f 100644
>> > --- a/kernel/audit.h
>> > +++ b/kernel/audit.h
>> > @@ -202,6 +202,7 @@ struct audit_context {
>> >               } execve;
>> >       };
>> >       int fds[2];
>> > +     char *cmdline;
>> >
>> >  #if AUDIT_DEBUG
>> >       int                 put_count;
>> > diff --git a/kernel/auditsc.c b/kernel/auditsc.c
>> > index 90594c9..a4c2003 100644
>> > --- a/kernel/auditsc.c
>> > +++ b/kernel/auditsc.c
>> > @@ -842,6 +842,12 @@ static inline struct audit_context
>> > *audit_get_context(struct task_struct *tsk,
>> >       return context;
>> >  }
>> >
>> > +static inline void audit_cmdline_free(struct audit_context *context)
>> > +{
>> > +     kfree(context->cmdline);
>> > +     context->cmdline = NULL;
>> > +}
>> > +
>> >  static inline void audit_free_names(struct audit_context *context)
>> >  {
>> >       struct audit_names *n, *next;
>> > @@ -955,6 +961,7 @@ static inline void audit_free_context(struct
>> > audit_context *context)
>> >       audit_free_aux(context);
>> >       kfree(context->filterkey);
>> >       kfree(context->sockaddr);
>> > +     audit_cmdline_free(context);
>> >       kfree(context);
>> >  }
>> >
>> > @@ -1271,6 +1278,30 @@ static void show_special(struct audit_context
>> > *context, int *call_panic)
>> >       audit_log_end(ab);
>> >  }
>> >
>> > +static void audit_log_cmdline(struct audit_buffer *ab, struct
>> > task_struct *tsk,
>> > +                      struct audit_context *context)
>> > +{
>> > +     int res;
>> > +     char *buf;
>> > +     char *msg = "(null)";
>> > +     audit_log_format(ab, " cmdline=");
>> > +
>> > +     /* Not  cached */
>> > +     if (!context->cmdline) {
>> > +             buf = kmalloc(PATH_MAX, GFP_KERNEL);
>> > +             if (!buf)
>> > +                     goto out;
>> > +             res = get_cmdline(tsk, buf, PATH_MAX);
>> > +             /* Ensure NULL terminated */
>> > +             if (buf[res-1] != '\0')
>> > +                     buf[res-1] = '\0';
>> > +             context->cmdline = buf;
>> > +     }
>> > +     msg = context->cmdline;
>> > +out:
>> > +     audit_log_untrustedstring(ab, msg);
>> > +}
>> > +
>> >  static void audit_log_exit(struct audit_context *context, struct
>> > task_struct *tsk)
>> >  {
>> >       int i, call_panic = 0;
>> > @@ -1302,6 +1333,7 @@ static void audit_log_exit(struct audit_context
>> > *context, struct task_struct *ts
>> >                        context->name_count);
>> >
>> >       audit_log_task_info(ab, tsk);
>> > +     audit_log_cmdline(ab, tsk, context);
>> >       audit_log_key(ab, context->filterkey);
>> >       audit_log_end(ab);
>> >
>> > --
>> > 1.7.9.5
>> >
>> > --
>> > Linux-audit mailing list
>> > Linux-audit@redhat.com
>> > https://www.redhat.com/mailman/listinfo/linux-audit
>>
>> - RGB
>>
>> --
>> Richard Guy Briggs <rbriggs@redhat.com>
>> Senior Software Engineer, Kernel Security, AMER ENG Base Operating
>> Systems, Red Hat
>> Remote, Ottawa, Canada
>> Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545



-- 
Respectfully,

William C Roberts

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
