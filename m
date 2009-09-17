Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 364A46B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 02:59:36 -0400 (EDT)
Received: by qyk32 with SMTP id 32so14878qyk.14
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:59:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090917114509.a9eb9f2c.kamezawa.hiroyu@jp.fujitsu.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
	 <1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
	 <20090917114138.e14a1183.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090917114509.a9eb9f2c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 17 Sep 2009 14:59:35 +0800
Message-ID: <2375c9f90909162359m14ec7640m88ddd7ba54d6e793@mail.gmail.com>
Subject: Re: [PATCH 3/3][mmotm] updateing size of kcore
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 17, 2009 at 10:45 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> After memory hotplug (or other events in future), kcore size
> can be modified.
>
> To update inode->i_size, we have to know inode/dentry but we
> can't get it from inside /proc directly.
> But considerinyg memory hotplug, kcore image is updated only when
> it's opened. Then, updating inode->i_size at open() is enough.
>
> Cc: WANG Cong <xiyou.wangcong@gmail.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


This patch looks fine.

However, I am thinking if kcore is the only file under /proc whose size
is changed dynamically? If no, that probably means we need to change
generic proc code.

Thanks!

> ---
> =C2=A0fs/proc/kcore.c | =C2=A0 =C2=A05 +++++
> =C2=A01 file changed, 5 insertions(+)
>
> Index: mmotm-2.6.31-Sep14/fs/proc/kcore.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Sep14.orig/fs/proc/kcore.c
> +++ mmotm-2.6.31-Sep14/fs/proc/kcore.c
> @@ -546,6 +546,11 @@ static int open_kcore(struct inode *inod
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EPERM;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (kcore_need_update)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kcore_update_ram()=
;
> + =C2=A0 =C2=A0 =C2=A0 if (i_size_read(inode) !=3D proc_root_kcore->size)=
 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_lock(&inode->i_m=
utex);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 i_size_write(inode, pr=
oc_root_kcore->size);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&inode->i=
_mutex);
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0}
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
