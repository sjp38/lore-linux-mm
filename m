Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 51A778D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 18:46:46 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p1HNkgoq031008
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:46:42 -0800
Received: from pwi14 (pwi14.prod.google.com [10.241.219.14])
	by hpaq11.eem.corp.google.com with ESMTP id p1HNkdXQ024509
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:46:41 -0800
Received: by pwi14 with SMTP id 14so19012pwi.0
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:46:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4D5C7EBF.2070603@cn.fujitsu.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7EBF.2070603@cn.fujitsu.com>
From: Paul Menage <menage@google.com>
Date: Thu, 17 Feb 2011 15:46:19 -0800
Message-ID: <AANLkTimRH=LVRLnajbtL3a8FwKkbEfLspAHXXeQLUY8=@mail.gmail.com>
Subject: Re: [PATCH 2/4] cpuset: Remove unneeded NODEMASK_ALLOC() in cpuset_attch()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

On Wed, Feb 16, 2011 at 5:49 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> oldcs->mems_allowed is not modified during cpuset_attch(), so
> we don't have to copy it to a buffer allocated by NODEMASK_ALLOC().
> Just pass it to cpuset_migrate_mm().
>
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

I'd be inclined to skip this one - we're already allocating one
nodemask, so one more isn't really any extra complexity, and we're
doing horrendously complicated stuff in cpuset_migrate_mm() that's
much more likely to fail in low-memory situations.

It's true that mems_allowed can't change during the call to
cpuset_attach(), but that's due to the fact that both cgroup_attach()
and the cpuset.mems write paths take cgroup_mutex. I might prefer to
leave the allocated nodemask here and wrap callback_mutex around the
places in cpuset_attach() where we're reading from a cpuset's
mems_allowed - that would remove the implicit synchronization via
cgroup_mutex and leave the code a little more understandable.

> ---
> =A0kernel/cpuset.c | =A0 =A07 ++-----
> =A01 files changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index f13ff2e..70c9ca2 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1438,10 +1438,9 @@ static void cpuset_attach(struct cgroup_subsys *ss=
, struct cgroup *cont,
> =A0 =A0 =A0 =A0struct mm_struct *mm;
> =A0 =A0 =A0 =A0struct cpuset *cs =3D cgroup_cs(cont);
> =A0 =A0 =A0 =A0struct cpuset *oldcs =3D cgroup_cs(oldcont);
> - =A0 =A0 =A0 NODEMASK_ALLOC(nodemask_t, from, GFP_KERNEL);
> =A0 =A0 =A0 =A0NODEMASK_ALLOC(nodemask_t, to, GFP_KERNEL);
>
> - =A0 =A0 =A0 if (from =3D=3D NULL || to =3D=3D NULL)
> + =A0 =A0 =A0 if (to =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto alloc_fail;
>
> =A0 =A0 =A0 =A0if (cs =3D=3D &top_cpuset) {
> @@ -1463,18 +1462,16 @@ static void cpuset_attach(struct cgroup_subsys *s=
s, struct cgroup *cont,
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* change mm; only needs to be done once even if threadgro=
up */
> - =A0 =A0 =A0 *from =3D oldcs->mems_allowed;
> =A0 =A0 =A0 =A0*to =3D cs->mems_allowed;
> =A0 =A0 =A0 =A0mm =3D get_task_mm(tsk);
> =A0 =A0 =A0 =A0if (mm) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mpol_rebind_mm(mm, to);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (is_memory_migrate(cs))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpuset_migrate_mm(mm, from,=
 to);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpuset_migrate_mm(mm, &oldc=
s->mems_allowed, to);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mmput(mm);
> =A0 =A0 =A0 =A0}
>
> =A0alloc_fail:
> - =A0 =A0 =A0 NODEMASK_FREE(from);
> =A0 =A0 =A0 =A0NODEMASK_FREE(to);
> =A0}
>
> --
> 1.7.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
