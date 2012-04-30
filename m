Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 8CEFA6B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 22:32:45 -0400 (EDT)
Received: by wgbds1 with SMTP id ds1so2173694wgb.2
        for <linux-mm@kvack.org>; Sun, 29 Apr 2012 19:32:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335681937-3715-3-git-send-email-levinsasha928@gmail.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
	<1335681937-3715-3-git-send-email-levinsasha928@gmail.com>
Date: Sun, 29 Apr 2012 22:32:43 -0400
Message-ID: <CACLa4ptMy0GkS=XSGVOPx4Ba2HN+N2EyK50BARr2xaOXfvDqcg@mail.gmail.com>
Subject: Re: [PATCH 03/14] sched rt,sysctl: remove proc input checks out of
 sysctl handlers
From: Eric Paris <eparis@parisplace.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, ebiederm@xmission.com, akpm@linux-foundation.org, tglx@linutronix.de, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

NAK

old_period =3D sysctl_sched_rt_period;

Doesn't make any sense in the callback, since you already updated
sysctl_sched_rt_period.

I'll leave the remainder of the series as an exercise for the reader.
But I get the feeling this isn't the only place where you are doing
things after the proc_dointvec() which must be done before.

-Eric

On Sun, Apr 29, 2012 at 2:45 AM, Sasha Levin <levinsasha928@gmail.com> wrot=
e:
> Simplify sysctl handler by removing user input checks and using the callb=
ack
> provided by the sysctl table.
>
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
> =A0include/linux/sched.h | =A0 =A04 +---
> =A0kernel/sched/core.c =A0 | =A0 25 ++++++++++---------------
> =A0kernel/sysctl.c =A0 =A0 =A0 | =A0 =A06 ++++--
> =A03 files changed, 15 insertions(+), 20 deletions(-)
>
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 722da9a..9509d80 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -2152,9 +2152,7 @@ static inline unsigned int get_sysctl_timer_migrati=
on(void)
> =A0extern unsigned int sysctl_sched_rt_period;
> =A0extern int sysctl_sched_rt_runtime;
>
> -int sched_rt_handler(struct ctl_table *table, int write,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 void __user *buffer, size_t *lenp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 loff_t *ppos);
> +int sched_rt_handler(void);
>
> =A0#ifdef CONFIG_SCHED_AUTOGROUP
> =A0extern unsigned int sysctl_sched_autogroup_enabled;
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 477b998..ca4a806 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -7573,9 +7573,7 @@ static int sched_rt_global_constraints(void)
> =A0}
> =A0#endif /* CONFIG_RT_GROUP_SCHED */
>
> -int sched_rt_handler(struct ctl_table *table, int write,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 void __user *buffer, size_t *lenp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 loff_t *ppos)
> +int sched_rt_handler(void)
> =A0{
> =A0 =A0 =A0 =A0int ret;
> =A0 =A0 =A0 =A0int old_period, old_runtime;
> @@ -7585,19 +7583,16 @@ int sched_rt_handler(struct ctl_table *table, int=
 write,
> =A0 =A0 =A0 =A0old_period =3D sysctl_sched_rt_period;
> =A0 =A0 =A0 =A0old_runtime =3D sysctl_sched_rt_runtime;
>
> - =A0 =A0 =A0 ret =3D proc_dointvec(table, write, buffer, lenp, ppos);
> -
> - =A0 =A0 =A0 if (!ret && write) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D sched_rt_global_constraints();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysctl_sched_rt_period =3D =
old_period;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysctl_sched_rt_runtime =3D=
 old_runtime;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 def_rt_bandwidth.rt_runtime=
 =3D global_rt_runtime();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 def_rt_bandwidth.rt_period =
=3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ns_to_ktime=
(global_rt_period());
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 ret =3D sched_rt_global_constraints();
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysctl_sched_rt_period =3D old_period;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysctl_sched_rt_runtime =3D old_runtime;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 def_rt_bandwidth.rt_runtime =3D global_rt_r=
untime();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 def_rt_bandwidth.rt_period =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ns_to_ktime(global_rt_perio=
d());
> =A0 =A0 =A0 =A0}
> +
> =A0 =A0 =A0 =A0mutex_unlock(&mutex);
>
> =A0 =A0 =A0 =A0return ret;
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 23f1ac6..fad9ff6 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -347,14 +347,16 @@ static struct ctl_table kern_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =A0 =A0 =A0 =A0 =A0 =3D &sysctl_sche=
d_rt_period,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.maxlen =A0 =A0 =A0 =A0 =3D sizeof(unsigne=
d int),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D sched_rt_handler,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D proc_dointvec,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .callback =A0 =A0 =A0 =3D sched_rt_handler,
> =A0 =A0 =A0 =A0},
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "sched_rt_runtim=
e_us",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =A0 =A0 =A0 =A0 =A0 =3D &sysctl_sche=
d_rt_runtime,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.maxlen =A0 =A0 =A0 =A0 =3D sizeof(int),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D sched_rt_handler,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D proc_dointvec,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .callback =A0 =A0 =A0 =3D sched_rt_handler,
> =A0 =A0 =A0 =A0},
> =A0#ifdef CONFIG_SCHED_AUTOGROUP
> =A0 =A0 =A0 =A0{
> --
> 1.7.8.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
