Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1AFB36B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 01:26:35 -0400 (EDT)
Received: by yxn35 with SMTP id 35so4255742yxn.14
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 22:26:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1315369399-3073-4-git-send-email-glommer@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-4-git-send-email-glommer@parallels.com>
From: Paul Menage <paul@paulmenage.org>
Date: Tue, 6 Sep 2011 22:26:13 -0700
Message-ID: <CALdu-PCeZLnF-3zx=NU6paC41Hp+_VTN-mTt6RvXbCu7Kdk-mQ@mail.gmail.com>
Subject: Re: [PATCH v2 3/9] socket: initial cgroup code.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Tue, Sep 6, 2011 at 9:23 PM, Glauber Costa <glommer@parallels.com> wrote=
:
> We aim to control the amount of kernel memory pinned at any
> time by tcp sockets. To lay the foundations for this work,
> this patch adds a pointer to the kmem_cgroup to the socket
> structure.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> ---
> =A0include/linux/kmem_cgroup.h | =A0 29 +++++++++++++++++++++++++++++
> =A0include/net/sock.h =A0 =A0 =A0 =A0 =A0| =A0 =A02 ++
> =A0net/core/sock.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 ++---
> =A03 files changed, 33 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/kmem_cgroup.h b/include/linux/kmem_cgroup.h
> index 0e4a74b..77076d8 100644
> --- a/include/linux/kmem_cgroup.h
> +++ b/include/linux/kmem_cgroup.h
> @@ -49,5 +49,34 @@ static inline struct kmem_cgroup *kcg_from_task(struct=
 task_struct *tsk)
> =A0 =A0 =A0 =A0return NULL;
> =A0}
> =A0#endif /* CONFIG_CGROUP_KMEM */
> +
> +#ifdef CONFIG_INET
> +#include <net/sock.h>
> +static inline void sock_update_kmem_cgrp(struct sock *sk)
> +{
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 sk->sk_cgrp =3D kcg_from_task(current);

BUG_ON(sk->sk_cgrp) ? Or else release the old cgroup if necessary.

> @@ -339,6 +340,7 @@ struct sock {
> =A0#endif
> =A0 =A0 =A0 =A0__u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_mark;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_classid;
> + =A0 =A0 =A0 struct kmem_cgroup =A0 =A0 =A0*sk_cgrp;

Should this be protected by a #ifdef?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
