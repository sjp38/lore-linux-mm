Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 02B2B6B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 03:19:17 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p9D7JEAh004356
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 00:19:14 -0700
Received: from gya6 (gya6.prod.google.com [10.243.49.6])
	by hpaq2.eem.corp.google.com with ESMTP id p9D7IkfI012940
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 00:19:13 -0700
Received: by gya6 with SMTP id 6so2542437gya.8
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 00:19:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1318242268-2234-2-git-send-email-glommer@parallels.com>
References: <1318242268-2234-1-git-send-email-glommer@parallels.com> <1318242268-2234-2-git-send-email-glommer@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 13 Oct 2011 00:18:49 -0700
Message-ID: <CAHH2K0awiPZZ9EJLyZy_p_ehf0-waQ-vGUAhAZEpdCMnYqKidA@mail.gmail.com>
Subject: Re: [PATCH v6 1/8] Basic kernel memory functionality for the Memory Controller
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

On Mon, Oct 10, 2011 at 3:24 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/mem=
ory.txt
> index 06eb6d9..bf00cd2 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
...
> @@ -255,6 +262,31 @@ When oom event notifier is registered, event will be=
 delivered.
> =A0 per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
> =A0 zone->lru_lock, it has no lock of its own.
>
> +2.7 Kernel Memory Extension (CONFIG_CGROUP_MEM_RES_CTLR_KMEM)
> +
> + With the Kernel memory extension, the Memory Controller is able to limi=
t

Extra leading space before 'With'.

> +the amount of kernel memory used by the system. Kernel memory is fundame=
ntally
> +different than user memory, since it can't be swapped out, which makes i=
t
> +possible to DoS the system by consuming too much of this precious resour=
ce.
> +Kernel memory limits are not imposed for the root cgroup.
> +
> +Memory limits as specified by the standard Memory Controller may or may =
not
> +take kernel memory into consideration. This is achieved through the file
> +memory.independent_kmem_limit. A Value different than 0 will allow for k=
ernel

s/Value/value/

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3508777..d25c5cb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
...
> +static int kmem_limit_independent_write(struct cgroup *cont, struct cfty=
pe *cft,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 u64 val)
> +{
> + =A0 =A0 =A0 cgroup_lock();
> + =A0 =A0 =A0 mem_cgroup_from_cont(cont)->kmem_independent_accounting =3D=
 !!val;
> + =A0 =A0 =A0 cgroup_unlock();

I do not think cgroup_lock,unlock are needed here.  The cont and
associated cgroup should be guaranteed by the caller to be valid.
Does this lock provide some other synchronization?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
