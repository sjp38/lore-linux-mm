Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE936B003B
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 12:25:46 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id e51so3225959eek.0
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 09:25:45 -0800 (PST)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id k3si33342853eep.246.2014.02.11.09.25.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 09:25:44 -0800 (PST)
Received: by mail-wi0-f173.google.com with SMTP id hn9so4835369wib.0
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 09:25:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140211163629.GM18807@madcap2.tricolour.ca>
References: <1391710528-23481-1-git-send-email-wroberts@tresys.com>
	<1391710528-23481-3-git-send-email-wroberts@tresys.com>
	<20140211163629.GM18807@madcap2.tricolour.ca>
Date: Tue, 11 Feb 2014 09:25:44 -0800
Message-ID: <CAFftDdrxZtSpQi5zugwkcbfRhvbsyL9y=51x8PwqryhtE+2x4g@mail.gmail.com>
Subject: Re: [PATCH v5 3/3] audit: Audit proc/<pid>/cmdline aka proctitle
From: William Roberts <bill.c.roberts@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Guy Briggs <rgb@redhat.com>
Cc: "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, akpm@linux-foundation.org, Stephen Smalley <sds@tycho.nsa.gov>, William Roberts <wroberts@tresys.com>

On Tue, Feb 11, 2014 at 8:36 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> On 14/02/06, William Roberts wrote:
>> During an audit event, cache and print the value of the process's
>> proctitle value (proc/<pid>/cmdline). This is useful in situations
>> where processes are started via fork'd virtual machines where the
>> comm field is incorrect. Often times, setting the comm field still
>> is insufficient as the comm width is not very wide and most
>> virtual machine "package names" do not fit. Also, during execution,
>> many threads have their comm field set as well. By tying it back to
>> the global cmdline value for the process, audit records will be more
>> complete in systems with these properties. An example of where this
>> is useful and applicable is in the realm of Android. With Android,
>> their is no fork/exec for VM instances. The bare, preloaded Dalvik
>> VM listens for a fork and specialize request. When this request comes
>> in, the VM forks, and the loads the specific application (specializing).
>> This was done to take advantage of COW and to not require a load of
>> basic packages by the VM on very app spawn. When this spawn occurs,
>> the package name is set via setproctitle() and shows up in procfs.
>> Many of these package names are longer then 16 bytes, the historical
>> width of task->comm. Having the cmdline in the audit records will
>> couple the application back to the record directly. Also, on my
>> Debian development box, some audit records were more useful then
>> what was printed under comm.
>>
>> The cached proctitle is tied to the life-cycle of the audit_context
>> structure and is built on demand.
>>
>> Proctitle is controllable by userspace, and thus should not be trusted.
>> It is meant as an aid to assist in debugging. The proctitle event is
>> emitted during syscall audits, and can be filtered with auditctl.
>>
>> Example:
>> type=3DAVC msg=3Daudit(1391217013.924:386): avc:  denied  { getattr } fo=
r  pid=3D1971 comm=3D"mkdir" name=3D"/" dev=3D"selinuxfs" ino=3D1 scontext=
=3Dsystem_u:system_r:consolekit_t:s0-s0:c0.c255 tcontext=3Dsystem_u:object_=
r:security_t:s0 tclass=3Dfilesystem
>> type=3DSYSCALL msg=3Daudit(1391217013.924:386): arch=3Dc000003e syscall=
=3D137 success=3Dyes exit=3D0 a0=3D7f019dfc8bd7 a1=3D7fffa6aed2c0 a2=3Dffff=
fffffff4bd25 a3=3D7fffa6aed050 items=3D0 ppid=3D1967 pid=3D1971 auid=3D4294=
967295 uid=3D0 gid=3D0 euid=3D0 suid=3D0 fsuid=3D0 egid=3D0 sgid=3D0 fsgid=
=3D0 tty=3D(none) ses=3D4294967295 comm=3D"mkdir" exe=3D"/bin/mkdir" subj=
=3Dsystem_u:system_r:consolekit_t:s0-s0:c0.c255 key=3D(null)
>> type=3DUNKNOWN[1327] msg=3Daudit(1391217013.924:386):  proctitle=3D6D6B6=
46972002D70002F7661722F72756E2F636F6E736F6C65
>>
>> Signed-off-by: William Roberts <wroberts@tresys.com>
>
> Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
>
> Though, I would prefer to see the size of the proctitle copy buffer
> dynamically allocated based on the size of the original rather than
> pinned at 128.

Not as good as it originally seems as this could be a whole page,
which would result in 2*PAGE_SIZE if hex escaped back to
userspace. A tuneable interface could be added in the future if its needed.

>
>> ---
>>  include/uapi/linux/audit.h |    1 +
>>  kernel/audit.h             |    6 ++++
>>  kernel/auditsc.c           |   67 +++++++++++++++++++++++++++++++++++++=
+++++++
>>  3 files changed, 74 insertions(+)
>>
>> diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
>> index 2d48fe1..4315ee9 100644
>> --- a/include/uapi/linux/audit.h
>> +++ b/include/uapi/linux/audit.h
>> @@ -109,6 +109,7 @@
>>  #define AUDIT_NETFILTER_PKT  1324    /* Packets traversing netfilter ch=
ains */
>>  #define AUDIT_NETFILTER_CFG  1325    /* Netfilter chain modifications *=
/
>>  #define AUDIT_SECCOMP                1326    /* Secure Computing event =
*/
>> +#define AUDIT_PROCTITLE              1327    /* Proctitle emit event */
>>
>>  #define AUDIT_AVC            1400    /* SE Linux avc denial or grant */
>>  #define AUDIT_SELINUX_ERR    1401    /* Internal SE Linux Errors */
>> diff --git a/kernel/audit.h b/kernel/audit.h
>> index 57cc64d..38c967d 100644
>> --- a/kernel/audit.h
>> +++ b/kernel/audit.h
>> @@ -106,6 +106,11 @@ struct audit_names {
>>       bool                    should_free;
>>  };
>>
>> +struct audit_proctitle {
>> +     int     len;    /* length of the cmdline field. */
>> +     char    *value; /* the cmdline field */
>> +};
>> +
>>  /* The per-task audit context. */
>>  struct audit_context {
>>       int                 dummy;      /* must be the first element */
>> @@ -202,6 +207,7 @@ struct audit_context {
>>               } execve;
>>       };
>>       int fds[2];
>> +     struct audit_proctitle proctitle;
>>
>>  #if AUDIT_DEBUG
>>       int                 put_count;
>> diff --git a/kernel/auditsc.c b/kernel/auditsc.c
>> index 10176cd..e342eb0 100644
>> --- a/kernel/auditsc.c
>> +++ b/kernel/auditsc.c
>> @@ -68,6 +68,7 @@
>>  #include <linux/capability.h>
>>  #include <linux/fs_struct.h>
>>  #include <linux/compat.h>
>> +#include <linux/ctype.h>
>>
>>  #include "audit.h"
>>
>> @@ -79,6 +80,9 @@
>>  /* no execve audit message should be longer than this (userspace limits=
) */
>>  #define MAX_EXECVE_AUDIT_LEN 7500
>>
>> +/* max length to print of cmdline/proctitle value during audit */
>> +#define MAX_PROCTITLE_AUDIT_LEN 128
>> +
>>  /* number of audit rules */
>>  int audit_n_rules;
>>
>> @@ -842,6 +846,13 @@ static inline struct audit_context *audit_get_conte=
xt(struct task_struct *tsk,
>>       return context;
>>  }
>>
>> +static inline void audit_proctitle_free(struct audit_context *context)
>> +{
>> +     kfree(context->proctitle.value);
>> +     context->proctitle.value =3D NULL;
>> +     context->proctitle.len =3D 0;
>> +}
>> +
>>  static inline void audit_free_names(struct audit_context *context)
>>  {
>>       struct audit_names *n, *next;
>> @@ -955,6 +966,7 @@ static inline void audit_free_context(struct audit_c=
ontext *context)
>>       audit_free_aux(context);
>>       kfree(context->filterkey);
>>       kfree(context->sockaddr);
>> +     audit_proctitle_free(context);
>>       kfree(context);
>>  }
>>
>> @@ -1271,6 +1283,59 @@ static void show_special(struct audit_context *co=
ntext, int *call_panic)
>>       audit_log_end(ab);
>>  }
>>
>> +static inline int audit_proctitle_rtrim(char *proctitle, int len)
>> +{
>> +     char *end =3D proctitle + len - 1;
>> +     while (end > proctitle && !isprint(*end))
>> +             end--;
>> +
>> +     /* catch the case where proctitle is only 1 non-print character */
>> +     len =3D end - proctitle + 1;
>> +     len -=3D isprint(proctitle[len-1]) =3D=3D 0;
>> +     return len;
>> +}
>> +
>> +static void audit_log_proctitle(struct task_struct *tsk,
>> +                      struct audit_context *context)
>> +{
>> +     int res;
>> +     char *buf;
>> +     char *msg =3D "(null)";
>> +     int len =3D strlen(msg);
>> +     struct audit_buffer *ab;
>> +
>> +     ab =3D audit_log_start(context, GFP_KERNEL, AUDIT_PROCTITLE);
>> +     if (!ab)
>> +             return; /* audit_panic or being filtered */
>> +
>> +     audit_log_format(ab, "proctitle=3D");
>> +
>> +     /* Not  cached */
>> +     if (!context->proctitle.value) {
>> +             buf =3D kmalloc(MAX_PROCTITLE_AUDIT_LEN, GFP_KERNEL);
>> +             if (!buf)
>> +                     goto out;
>> +             /* Historically called this from procfs naming */
>> +             res =3D get_cmdline(tsk, buf, MAX_PROCTITLE_AUDIT_LEN);
>> +             if (res =3D=3D 0) {
>> +                     kfree(buf);
>> +                     goto out;
>> +             }
>> +             res =3D audit_proctitle_rtrim(buf, res);
>> +             if (res =3D=3D 0) {
>> +                     kfree(buf);
>> +                     goto out;
>> +             }
>> +             context->proctitle.value =3D buf;
>> +             context->proctitle.len =3D res;
>> +     }
>> +     msg =3D context->proctitle.value;
>> +     len =3D context->proctitle.len;
>> +out:
>> +     audit_log_n_untrustedstring(ab, msg, len);
>> +     audit_log_end(ab);
>> +}
>> +
>>  static void audit_log_exit(struct audit_context *context, struct task_s=
truct *tsk)
>>  {
>>       int i, call_panic =3D 0;
>> @@ -1388,6 +1453,8 @@ static void audit_log_exit(struct audit_context *c=
ontext, struct task_struct *ts
>>               audit_log_name(context, n, NULL, i++, &call_panic);
>>       }
>>
>> +     audit_log_proctitle(tsk, context);
>> +
>>       /* Send end of event record to help user space know we are finishe=
d */
>>       ab =3D audit_log_start(context, GFP_KERNEL, AUDIT_EOE);
>>       if (ab)
>> --
>> 1.7.9.5
>>
>
> - RGB
>
> --
> Richard Guy Briggs <rbriggs@redhat.com>
> Senior Software Engineer, Kernel Security, AMER ENG Base Operating System=
s, Red Hat
> Remote, Ottawa, Canada
> Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545



--=20
Respectfully,

William C Roberts

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
