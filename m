Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC709000BD
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 14:52:58 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p8LIovvB018889
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:50:58 -0700
Received: from qyk30 (qyk30.prod.google.com [10.241.83.158])
	by wpaz29.hot.corp.google.com with ESMTP id p8LIjSUI010297
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:50:57 -0700
Received: by qyk30 with SMTP id 30so4880129qyk.12
        for <linux-mm@kvack.org>; Wed, 21 Sep 2011 11:50:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316393805-3005-3-git-send-email-glommer@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-3-git-send-email-glommer@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 21 Sep 2011 11:47:29 -0700
Message-ID: <CAHH2K0YgkG2J_bO+U9zbZYhTTqSLvr6NtxKxN8dRtfHs=iB8iA@mail.gmail.com>
Subject: Re: [PATCH v3 2/7] socket: initial cgroup code.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> We aim to control the amount of kernel memory pinned at any
> time by tcp sockets. To lay the foundations for this work,
> this patch adds a pointer to the kmem_cgroup to the socket
> structure.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
...
> +void sock_update_memcg(struct sock *sk)
> +{
> + =A0 =A0 =A0 /* right now a socket spends its whole life in the same cgr=
oup */
> + =A0 =A0 =A0 BUG_ON(sk->sk_cgrp);
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 sk->sk_cgrp =3D mem_cgroup_from_task(current);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We don't need to protect against anything task-related=
, because
> + =A0 =A0 =A0 =A0* we are basically stuck with the sock pointer that won'=
t change,
> + =A0 =A0 =A0 =A0* even if the task that originated the socket changes cg=
roups.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* What we do have to guarantee, is that the chain leadin=
g us to
> + =A0 =A0 =A0 =A0* the top level won't change under our noses. Incrementi=
ng the
> + =A0 =A0 =A0 =A0* reference count via cgroup_exclude_rmdir guarantees th=
at.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 cgroup_exclude_rmdir(mem_cgroup_css(sk->sk_cgrp));

This grabs a css_get() reference, which prevents rmdir (will return
-EBUSY).  How long is this reference held?  I wonder about the case
where a process creates a socket in memcg M1 and later is moved into
memcg M2.  At that point an admin would expect to be able to 'rmdir
M1'.  I think this rmdir would return -EBUSY and I suspect it would be
difficult for the admin to understand why the rmdir of M1 failed.  It
seems that to rmdir a memcg, an admin would have to kill all processes
that allocated sockets while in M1.  Such processes may not still be
in M1.

> + =A0 =A0 =A0 rcu_read_unlock();
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
