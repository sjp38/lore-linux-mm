Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CB6A68D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 18:52:14 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p1HNqBXh004965
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:52:11 -0800
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by kpbe17.cbf.corp.google.com with ESMTP id p1HNq9T0000602
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:52:09 -0800
Received: by pvf33 with SMTP id 33so400288pvf.1
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:52:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4D5C7F00.2050802@cn.fujitsu.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7F00.2050802@cn.fujitsu.com>
From: Paul Menage <menage@google.com>
Date: Thu, 17 Feb 2011 15:51:47 -0800
Message-ID: <AANLkTiki=aXr3KMXwrnnTrLC2Wt1F0eG8sVdXWiZrVFa@mail.gmail.com>
Subject: Re: [PATCH 4/4] cpuset: Hold callback_mutex in cpuset_clone()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

On Wed, Feb 16, 2011 at 5:50 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> Chaning cpuset->mems/cpuset->cpus should be protected under
> callback_mutex.
>
> cpuset_clone() doesn't follow this rule. It's ok because it's
> called when creating and initializing a cgroup, but we'd better
> hold the lock to avoid subtil break in the future.
>
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: Paul Menage <menage@google.com>

Patch title should be s/cpuset_clone/cpuset_post_clone/

> ---
> =A0kernel/cpuset.c | =A0 =A02 ++
> =A01 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 1e18d26..445573b 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1840,8 +1840,10 @@ static void cpuset_post_clone(struct cgroup_subsys=
 *ss,
> =A0 =A0 =A0 =A0cs =3D cgroup_cs(cgroup);
> =A0 =A0 =A0 =A0parent_cs =3D cgroup_cs(parent);
>
> + =A0 =A0 =A0 mutex_lock(&callback_mutex);
> =A0 =A0 =A0 =A0cs->mems_allowed =3D parent_cs->mems_allowed;
> =A0 =A0 =A0 =A0cpumask_copy(cs->cpus_allowed, parent_cs->cpus_allowed);
> + =A0 =A0 =A0 mutex_unlock(&callback_mutex);
> =A0 =A0 =A0 =A0return;
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
