Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8A8796B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 02:02:39 -0400 (EDT)
Received: by qyk40 with SMTP id 40so4831322qyk.8
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:02:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090917114404.d87b155d.kamezawa.hiroyu@jp.fujitsu.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
	 <1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
	 <20090917114138.e14a1183.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090917114404.d87b155d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 17 Sep 2009 14:02:39 +0800
Message-ID: <2375c9f90909162302m1fb89414o4f72b6b36e7cbb06@mail.gmail.com>
Subject: Re: [PATCH 2/3][mmotm] showing size of kcore
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 17, 2009 at 10:44 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, size of /proc/kcore which can be read by 'ls -l' is 0.
> But it's not correct value.
>
> This is a patch for showing size of /proc/kcore as following.
>
> On x86-64, ls -l shows
> =C2=A0... root root 140737486266368 2009-09-17 10:29 /proc/kcore
> Then, 7FFFFFFE02000. This comes from vmalloc area's size.
> (*) This shows "core" size, not =C2=A0memory size.
>
> This patch shows the size by updating "size" field in struct proc_dir_ent=
ry.
> Later, lookup routine will create inode and fill inode->i_size based
> on this value. Then, this has a problem.
>
> =C2=A0- Once inode is cached, inode->i_size will never be updated.
>
> Then, this patch is not memory-hotplug-aware.
>
> To update inode->i_size, we have to know dentry or inode.
> But there is no way to lookup them by inside kernel. Hmmm....
> Next patch will try it.
>
> Cc: WANG Cong <xiyou.wangcong@gmail.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =C2=A0fs/proc/kcore.c | =C2=A0 =C2=A06 +++++-
> =C2=A01 file changed, 5 insertions(+), 1 deletion(-)
>
> Index: mmotm-2.6.31-Sep14/fs/proc/kcore.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.31-Sep14.orig/fs/proc/kcore.c
> +++ mmotm-2.6.31-Sep14/fs/proc/kcore.c
> @@ -107,6 +107,8 @@ static void free_kclist_ents(struct list
> =C2=A0*/
> =C2=A0static void __kcore_update_ram(struct list_head *list)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 int nphdr;
> + =C2=A0 =C2=A0 =C2=A0 size_t size;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct kcore_list *tmp, *pos;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LIST_HEAD(garbage);
>
> @@ -124,6 +126,7 @@ static void __kcore_update_ram(struct li
> =C2=A0 =C2=A0 =C2=A0 =C2=A0write_unlock(&kclist_lock);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_kclist_ents(&garbage);
> + =C2=A0 =C2=A0 =C2=A0 proc_root_kcore->size =3D get_kcore_size(&nphdr, &=
size);


This makes me to think if we will have some race condition here?
Two processes can open kcore at the same time...

> =C2=A0}
>
>
> @@ -429,7 +432,8 @@ read_kcore(struct file *file, char __use
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long start;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0read_lock(&kclist_lock);
> - =C2=A0 =C2=A0 =C2=A0 proc_root_kcore->size =3D size =3D get_kcore_size(=
&nphdr, &elf_buflen);
> + =C2=A0 =C2=A0 =C2=A0 size =3D get_kcore_size(&nphdr, &elf_buflen);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (buflen =3D=3D 0 || *fpos >=3D size) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0read_unlock(&kclis=
t_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
