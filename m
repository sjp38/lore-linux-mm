Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id BFFA26B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 22:28:43 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so2076928wgb.26
        for <linux-mm@kvack.org>; Sun, 29 Apr 2012 19:28:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335681937-3715-13-git-send-email-levinsasha928@gmail.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
	<1335681937-3715-13-git-send-email-levinsasha928@gmail.com>
Date: Sun, 29 Apr 2012 22:28:41 -0400
Message-ID: <CACLa4ps4Cw82abKS+-qUruMwPa-s_yGkBbAh42uT2GiWmjXV-w@mail.gmail.com>
Subject: Re: [PATCH 13/14] security,sysctl: remove proc input checks out of
 sysctl handlers
From: Eric Paris <eparis@parisplace.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, ebiederm@xmission.com, akpm@linux-foundation.org, tglx@linutronix.de, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

NAK - You moved the check to see if someone has permission to make a
change AFTER the change was made.  The original semantics were
correct.  You must do the capable check, then update the value, then
do the other calculations with the new value.  You can't do the
permission check after you already made the changes.

-Eric

On Sun, Apr 29, 2012 at 2:45 AM, Sasha Levin <levinsasha928@gmail.com> wrot=
e:
> Simplify sysctl handler by removing user input checks and using the callb=
ack
> provided by the sysctl table.
>
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
> =A0include/linux/security.h | =A0 =A03 +--
> =A0kernel/sysctl.c =A0 =A0 =A0 =A0 =A0| =A0 =A03 ++-
> =A0security/min_addr.c =A0 =A0 =A0| =A0 11 +++--------
> =A03 files changed, 6 insertions(+), 11 deletions(-)
>
> diff --git a/include/linux/security.h b/include/linux/security.h
> index ab0e091..3d3445c 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -147,8 +147,7 @@ struct request_sock;
> =A0#define LSM_UNSAFE_NO_NEW_PRIVS =A0 =A0 =A0 =A08
>
> =A0#ifdef CONFIG_MMU
> -extern int mmap_min_addr_handler(struct ctl_table *table, int write,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void __u=
ser *buffer, size_t *lenp, loff_t *ppos);
> +extern int mmap_min_addr_handler(void);
> =A0#endif
>
> =A0/* security_inode_init_security callback function to write xattrs */
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index f9ce79b..2104452 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1317,7 +1317,8 @@ static struct ctl_table vm_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =A0 =A0 =A0 =A0 =A0 =3D &dac_mmap_mi=
n_addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.maxlen =A0 =A0 =A0 =A0 =3D sizeof(unsigne=
d long),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D mmap_min_addr_handler=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D proc_doulongvec_minma=
x,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .callback =A0 =A0 =A0 =3D mmap_min_addr_han=
dler,
> =A0 =A0 =A0 =A0},
> =A0#endif
> =A0#ifdef CONFIG_NUMA
> diff --git a/security/min_addr.c b/security/min_addr.c
> index f728728..3e5a41c 100644
> --- a/security/min_addr.c
> +++ b/security/min_addr.c
> @@ -28,19 +28,14 @@ static void update_mmap_min_addr(void)
> =A0* sysctl handler which just sets dac_mmap_min_addr =3D the new value a=
nd then
> =A0* calls update_mmap_min_addr() so non MAP_FIXED hints get rounded prop=
erly
> =A0*/
> -int mmap_min_addr_handler(struct ctl_table *table, int write,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void __user *buffer, si=
ze_t *lenp, loff_t *ppos)
> +int mmap_min_addr_handler(void)
> =A0{
> - =A0 =A0 =A0 int ret;
> -
> - =A0 =A0 =A0 if (write && !capable(CAP_SYS_RAWIO))
> + =A0 =A0 =A0 if (!capable(CAP_SYS_RAWIO))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
>
> - =A0 =A0 =A0 ret =3D proc_doulongvec_minmax(table, write, buffer, lenp, =
ppos);
> -
> =A0 =A0 =A0 =A0update_mmap_min_addr();
>
> - =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 return 0;
> =A0}
>
> =A0static int __init init_mmap_min_addr(void)
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
