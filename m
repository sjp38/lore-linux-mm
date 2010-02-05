Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E60D06B0047
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 11:30:52 -0500 (EST)
Received: by pxi5 with SMTP id 5so4458098pxi.12
        for <linux-mm@kvack.org>; Fri, 05 Feb 2010 08:30:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 6 Feb 2010 01:30:49 +0900
Message-ID: <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
	cgroup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Hi, Kame.

On Fri, Feb 5, 2010 at 9:39 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Please take this patch in different context with recent discussion.
> This is a quick-fix for a terrible bug.
>
> This patch itself is against mmotm but can be easily applied to mainline =
or
> stable tree, I think. (But I don't CC stable tree until I get ack.)
>
> =3D=3D
> Now, oom-killer kills process's chidlren at first. But this means
> a child in other cgroup can be killed. But it's not checked now.
>
> This patch fixes that.
>
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =C2=A0mm/oom_kill.c | =C2=A0 =C2=A03 +++
> =C2=A01 file changed, 3 insertions(+)
>
> Index: mmotm-2.6.33-Feb03/mm/oom_kill.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.33-Feb03.orig/mm/oom_kill.c
> +++ mmotm-2.6.33-Feb03/mm/oom_kill.c
> @@ -459,6 +459,9 @@ static int oom_kill_process(struct task_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry(c, &p->children, sibling) =
{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (c->mm =3D=3D p=
->mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Children may be in =
other cgroup */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mem && !task_in_me=
m_cgroup(c, mem))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 continue;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!oom_kill_task=
(c))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> --

I am worried about latency of OOM at worst case.
I mean that task_in_mem_cgroup calls task_lock of child.
We have used task_lock in many place.
Some place task_lock hold and then other locks.
For example, exit_fs held task_lock and try to hold write_lock of fs->lock.
If child already hold task_lock and wait to write_lock of fs->lock, OOM lat=
ency
is dependent of fs->lock.

I am not sure how many usecase is also dependent of other locks.
If it is not as is, we can't make sure in future.

So How about try_task_in_mem_cgroup?
If we can't hold task_lock, let's continue next child.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
