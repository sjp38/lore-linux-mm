Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2786B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 12:09:22 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p86G97i0030229
	for <linux-mm@kvack.org>; Tue, 6 Sep 2011 09:09:07 -0700
Received: from qyk34 (qyk34.prod.google.com [10.241.83.162])
	by hpaq2.eem.corp.google.com with ESMTP id p86G93Wd005707
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 6 Sep 2011 09:09:06 -0700
Received: by qyk34 with SMTP id 34so647116qyk.17
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 09:09:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1315276556-10970-1-git-send-email-glommer@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Tue, 6 Sep 2011 09:08:42 -0700
Message-ID: <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Mon, Sep 5, 2011 at 7:35 PM, Glauber Costa <glommer@parallels.com> wrote=
:
> This patch introduces per-cgroup tcp buffers limitation. This allows
> sysadmins to specify a maximum amount of kernel memory that
> tcp connections can use at any point in time. TCP is the main interest
> in this work, but extending it to other protocols would be easy.

With this approach we would be giving admins the ability to
independently limit user memory with memcg and kernel memory with this
new kmem cgroup.

At least in some situations admins prefer to give a particular
container X bytes without thinking about the kernel vs user split.
Sometimes the admin would prefer the kernel to keep the total
user+kernel memory below a certain threshold.  To achieve this with
this approach would we need a user space agent to monitor both kernel
and user usage for a container and grow/shrink memcg/kmem limits?

Do you foresee the kmem cgroup growing to include reclaimable slab,
where freeing one type of memory allows for reclaim of the other?

> It piggybacks in the memory control mechanism already present in
> /proc/sys/net/ipv4/tcp_mem. There is a soft limit, and a hard limit,
> that will suppress allocation when reached. For each cgroup, however,
> the file kmem.tcp_maxmem will be used to cap those values.
>
> The usage I have in mind here is containers. Each container will
> define its own values for soft and hard limits, but none of them will
> be possibly bigger than the value the box' sysadmin specified from
> the outside.
>
> To test for any performance impacts of this patch, I used netperf's
> TCP_RR benchmark on localhost, so we can have both recv and snd in action=
.
>
> Command line used was ./src/netperf -t TCP_RR -H localhost, and the
> results:
>
> Without the patch
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> Socket Size =A0 Request =A0Resp. =A0 Elapsed =A0Trans.
> Send =A0 Recv =A0 Size =A0 =A0 Size =A0 =A0Time =A0 =A0 Rate
> bytes =A0Bytes =A0bytes =A0 =A0bytes =A0 secs. =A0 =A0per sec
>
> 16384 =A087380 =A01 =A0 =A0 =A0 =A01 =A0 =A0 =A0 10.00 =A0 =A026996.35
> 16384 =A087380
>
> With the patch
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> Local /Remote
> Socket Size =A0 Request =A0Resp. =A0 Elapsed =A0Trans.
> Send =A0 Recv =A0 Size =A0 =A0 Size =A0 =A0Time =A0 =A0 Rate
> bytes =A0Bytes =A0bytes =A0 =A0bytes =A0 secs. =A0 =A0per sec
>
> 16384 =A087380 =A01 =A0 =A0 =A0 =A01 =A0 =A0 =A0 10.00 =A0 =A027291.86
> 16384 =A087380
>
> The difference is within a one-percent range.
>
> Nesting cgroups doesn't seem to be the dominating factor as well,
> with nestings up to 10 levels not showing a significant performance
> difference.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> ---
> =A0crypto/af_alg.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A07 ++-
> =A0include/linux/cgroup_subsys.h | =A0 =A04 +
> =A0include/net/netns/ipv4.h =A0 =A0 =A0| =A0 =A01 +
> =A0include/net/sock.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 66 +++++++++++++++-
> =A0include/net/tcp.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 12 ++-
> =A0include/net/udp.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
> =A0include/trace/events/sock.h =A0 | =A0 10 +-
> =A0init/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 +++
> =A0mm/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0net/core/sock.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0136 +++++++++++++++++=
++++++++++-------
> =A0net/decnet/af_decnet.c =A0 =A0 =A0 =A0| =A0 21 +++++-
> =A0net/ipv4/proc.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A08 +-
> =A0net/ipv4/sysctl_net_ipv4.c =A0 =A0| =A0 59 +++++++++++++--
> =A0net/ipv4/tcp.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0164 +++++++++++++++=
++++++++++++++++++++-----
> =A0net/ipv4/tcp_input.c =A0 =A0 =A0 =A0 =A0| =A0 17 ++--
> =A0net/ipv4/tcp_ipv4.c =A0 =A0 =A0 =A0 =A0 | =A0 27 +++++--
> =A0net/ipv4/tcp_output.c =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0net/ipv4/tcp_timer.c =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0net/ipv4/udp.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 20 ++++-
> =A0net/ipv6/tcp_ipv6.c =A0 =A0 =A0 =A0 =A0 | =A0 16 +++-
> =A0net/ipv6/udp.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A0net/sctp/socket.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 35 +++++++--
> =A022 files changed, 514 insertions(+), 112 deletions(-)
>
> diff --git a/crypto/af_alg.c b/crypto/af_alg.c
> index ac33d5f..df168d8 100644
> --- a/crypto/af_alg.c
> +++ b/crypto/af_alg.c
> @@ -29,10 +29,15 @@ struct alg_type_list {
>
> =A0static atomic_long_t alg_memory_allocated;
>
> +static atomic_long_t *memory_allocated_alg(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &alg_memory_allocated;
> +}
> +
> =A0static struct proto alg_proto =3D {
> =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D "ALG",
> =A0 =A0 =A0 =A0.owner =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> - =A0 =A0 =A0 .memory_allocated =A0 =A0 =A0 =3D &alg_memory_allocated,
> + =A0 =A0 =A0 .memory_allocated =A0 =A0 =A0 =3D memory_allocated_alg,
> =A0 =A0 =A0 =A0.obj_size =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D sizeof(struct al=
g_sock),
> =A0};
>
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.=
h
> index ac663c1..363b8e8 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -35,6 +35,10 @@ SUBSYS(cpuacct)
> =A0SUBSYS(mem_cgroup)
> =A0#endif
>
> +#ifdef CONFIG_CGROUP_KMEM
> +SUBSYS(kmem)
> +#endif
> +
> =A0/* */
>
> =A0#ifdef CONFIG_CGROUP_DEVICE
> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
> index d786b4f..bbd023a 100644
> --- a/include/net/netns/ipv4.h
> +++ b/include/net/netns/ipv4.h
> @@ -55,6 +55,7 @@ struct netns_ipv4 {
> =A0 =A0 =A0 =A0int current_rt_cache_rebuild_count;
>
> =A0 =A0 =A0 =A0unsigned int sysctl_ping_group_range[2];
> + =A0 =A0 =A0 long sysctl_tcp_mem[3];
>
> =A0 =A0 =A0 =A0atomic_t rt_genid;
> =A0 =A0 =A0 =A0atomic_t dev_addr_genid;
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 8e4062f..e085148 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -62,7 +62,9 @@
> =A0#include <linux/atomic.h>
> =A0#include <net/dst.h>
> =A0#include <net/checksum.h>
> +#include <linux/kmem_cgroup.h>
>
> +int sockets_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
> =A0/*
> =A0* This structure really needs to be cleaned up.
> =A0* Most of it is for TCP, and not used by any of
> @@ -339,6 +341,7 @@ struct sock {
> =A0#endif
> =A0 =A0 =A0 =A0__u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_mark;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_classid;
> + =A0 =A0 =A0 struct kmem_cgroup =A0 =A0 =A0*sk_cgrp;
> =A0 =A0 =A0 =A0void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*sk_state_cha=
nge)(struct sock *sk);
> =A0 =A0 =A0 =A0void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*sk_data_read=
y)(struct sock *sk, int bytes);
> =A0 =A0 =A0 =A0void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*sk_write_spa=
ce)(struct sock *sk);
> @@ -786,16 +789,21 @@ struct proto {
>
> =A0 =A0 =A0 =A0/* Memory pressure */
> =A0 =A0 =A0 =A0void =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(*enter_memory=
_pressure)(struct sock *sk);
> - =A0 =A0 =A0 atomic_long_t =A0 =A0 =A0 =A0 =A0 *memory_allocated; =A0 =
=A0 =A0/* Current allocated memory. */
> - =A0 =A0 =A0 struct percpu_counter =A0 *sockets_allocated; =A0 =A0 /* Cu=
rrent number of sockets. */
> + =A0 =A0 =A0 /* Current allocated memory. */
> + =A0 =A0 =A0 atomic_long_t =A0 =A0 =A0 =A0 =A0 *(*memory_allocated)(stru=
ct kmem_cgroup *sg);
> + =A0 =A0 =A0 /* Current number of sockets. */
> + =A0 =A0 =A0 struct percpu_counter =A0 *(*sockets_allocated)(struct kmem=
_cgroup *sg);
> +
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (*init_cgroup)(=
struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0struct cgroup_subsys *ss);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Pressure flag: try to collapse.
> =A0 =A0 =A0 =A0 * Technical note: it is used by multiple contexts non ato=
mically.
> =A0 =A0 =A0 =A0 * All the __sk_mem_schedule() is of this nature: accounti=
ng
> =A0 =A0 =A0 =A0 * is strict, actions are advisory and have some latency.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *memory_pressur=
e;
> - =A0 =A0 =A0 long =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*sysctl_mem;
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *(*memory_press=
ure)(struct kmem_cgroup *sg);
> + =A0 =A0 =A0 long =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*(*prot_mem)(st=
ruct kmem_cgroup *sg);
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *sysctl_wmem;
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *sysctl_rmem;
> =A0 =A0 =A0 =A0int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 max_header;
> @@ -826,6 +834,56 @@ struct proto {
> =A0#endif
> =A0};
>
> +#define sk_memory_pressure(sk) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> +({ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 int *__ret =3D NULL; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 if ((sk)->sk_prot->memory_pressure) =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __ret =3D (sk)->sk_prot->memory_pressure(sk=
->sk_cgrp); =A0 =A0\
> + =A0 =A0 =A0 __ret; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +})
> +
> +#define sk_sockets_allocated(sk) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 \
> +({ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 struct percpu_counter *__p; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 __p =3D (sk)->sk_prot->sockets_allocated(sk->sk_cgrp); =A0 =
=A0\
> + =A0 =A0 =A0 __p; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +})
> +
> +#define sk_memory_allocated(sk) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +({ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 atomic_long_t *__mem; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 __mem =3D (sk)->sk_prot->memory_allocated(sk->sk_cgrp); =A0=
 \
> + =A0 =A0 =A0 __mem; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +})
> +
> +#define sk_prot_mem(sk) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +({ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 long *__mem =3D (sk)->sk_prot->prot_mem(sk->sk_cgrp); =A0 =
=A0 \
> + =A0 =A0 =A0 __mem; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +})
> +
> +#define sg_memory_pressure(prot, sg) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 \
> +({ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 int *__ret =3D NULL; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 if (prot->memory_pressure) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __ret =3D (prot)->memory_pressure(sg); =A0 =
=A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 __ret; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +})
> +
> +#define sg_memory_allocated(prot, sg) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0\
> +({ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 atomic_long_t *__mem; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 __mem =3D (prot)->memory_allocated(sg); =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 __mem; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +})
> +
> +#define sg_sockets_allocated(prot, sg) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 \
> +({ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 struct percpu_counter *__p; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 __p =3D (prot)->sockets_allocated(sg); =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 __p; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +})
> +
> =A0extern int proto_register(struct proto *prot, int alloc_slab);
> =A0extern void proto_unregister(struct proto *prot);
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 149a415..8e1ec4a 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -230,7 +230,6 @@ extern int sysctl_tcp_fack;
> =A0extern int sysctl_tcp_reordering;
> =A0extern int sysctl_tcp_ecn;
> =A0extern int sysctl_tcp_dsack;
> -extern long sysctl_tcp_mem[3];
> =A0extern int sysctl_tcp_wmem[3];
> =A0extern int sysctl_tcp_rmem[3];
> =A0extern int sysctl_tcp_app_win;
> @@ -253,9 +252,12 @@ extern int sysctl_tcp_cookie_size;
> =A0extern int sysctl_tcp_thin_linear_timeouts;
> =A0extern int sysctl_tcp_thin_dupack;
>
> -extern atomic_long_t tcp_memory_allocated;
> -extern struct percpu_counter tcp_sockets_allocated;
> -extern int tcp_memory_pressure;
> +struct kmem_cgroup;
> +extern long *tcp_sysctl_mem(struct kmem_cgroup *sg);
> +struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg);
> +int *memory_pressure_tcp(struct kmem_cgroup *sg);
> +int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss);
> +atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg);
>
> =A0/*
> =A0* The next routines deal with comparing 32 bit unsigned ints
> @@ -286,7 +288,7 @@ static inline bool tcp_too_many_orphans(struct sock *=
sk, int shift)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
> - =A0 =A0 =A0 =A0 =A0 atomic_long_read(&tcp_memory_allocated) > sysctl_tc=
p_mem[2])
> + =A0 =A0 =A0 =A0 =A0 atomic_long_read(sk_memory_allocated(sk)) > sk_prot=
_mem(sk)[2])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return true;
> =A0 =A0 =A0 =A0return false;
> =A0}
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 67ea6fc..0e27388 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -105,7 +105,8 @@ static inline struct udp_hslot *udp_hashslot2(struct =
udp_table *table,
>
> =A0extern struct proto udp_prot;
>
> -extern atomic_long_t udp_memory_allocated;
> +atomic_long_t *memory_allocated_udp(struct kmem_cgroup *sg);
> +long *udp_sysctl_mem(struct kmem_cgroup *sg);
>
> =A0/* sysctl variables for udp */
> =A0extern long sysctl_udp_mem[3];
> diff --git a/include/trace/events/sock.h b/include/trace/events/sock.h
> index 779abb9..12a6083 100644
> --- a/include/trace/events/sock.h
> +++ b/include/trace/events/sock.h
> @@ -37,7 +37,7 @@ TRACE_EVENT(sock_exceed_buf_limit,
>
> =A0 =A0 =A0 =A0TP_STRUCT__entry(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__array(char, name, 32)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(long *, sysctl_mem)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field(long *, prot_mem)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(long, allocated)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(int, sysctl_rmem)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__field(int, rmem_alloc)
> @@ -45,7 +45,7 @@ TRACE_EVENT(sock_exceed_buf_limit,
>
> =A0 =A0 =A0 =A0TP_fast_assign(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0strncpy(__entry->name, prot->name, 32);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->sysctl_mem =3D prot->sysctl_mem;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->prot_mem =3D sk->sk_prot->prot_mem=
(sk->sk_cgrp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->allocated =3D allocated;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->sysctl_rmem =3D prot->sysctl_rmem=
[0];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->rmem_alloc =3D atomic_read(&sk->s=
k_rmem_alloc);
> @@ -54,9 +54,9 @@ TRACE_EVENT(sock_exceed_buf_limit,
> =A0 =A0 =A0 =A0TP_printk("proto:%s sysctl_mem=3D%ld,%ld,%ld allocated=3D%=
ld "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"sysctl_rmem=3D%d rmem_alloc=3D%d",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->name,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->sysctl_mem[0],
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->sysctl_mem[1],
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->sysctl_mem[2],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->prot_mem[0],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->prot_mem[1],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->prot_mem[2],
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->allocated,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->sysctl_rmem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->rmem_alloc)
> diff --git a/init/Kconfig b/init/Kconfig
> index d627783..5955ac2 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -690,6 +690,17 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
> =A0 =A0 =A0 =A0 =A0select this option (if, for some reason, they need to =
disable it
> =A0 =A0 =A0 =A0 =A0then swapaccount=3D0 does the trick).
>
> +config CGROUP_KMEM
> + =A0 =A0 =A0 bool "Kernel Memory Resource Controller for Control Groups"
> + =A0 =A0 =A0 depends on CGROUPS
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 The Kernel Memory cgroup can limit the amount of memory=
 used by
> + =A0 =A0 =A0 =A0 certain kernel objects in the system. Those are fundame=
ntally
> + =A0 =A0 =A0 =A0 different from the entities handled by the Memory Contr=
oller,
> + =A0 =A0 =A0 =A0 which are page-based, and can be swapped. Users of the =
kmem
> + =A0 =A0 =A0 =A0 cgroup can use it to guarantee that no group of process=
es will
> + =A0 =A0 =A0 =A0 ever exhaust kernel resources alone.
> +
> =A0config CGROUP_PERF
> =A0 =A0 =A0 =A0bool "Enable perf_event per-cpu per-container group (cgrou=
p) monitoring"
> =A0 =A0 =A0 =A0depends on PERF_EVENTS && CGROUPS
> diff --git a/mm/Makefile b/mm/Makefile
> index 836e416..1b1aa24 100644
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -45,6 +45,7 @@ obj-$(CONFIG_MIGRATION) +=3D migrate.o
> =A0obj-$(CONFIG_QUICKLIST) +=3D quicklist.o
> =A0obj-$(CONFIG_TRANSPARENT_HUGEPAGE) +=3D huge_memory.o
> =A0obj-$(CONFIG_CGROUP_MEM_RES_CTLR) +=3D memcontrol.o page_cgroup.o
> +obj-$(CONFIG_CGROUP_KMEM) +=3D kmem_cgroup.o
> =A0obj-$(CONFIG_MEMORY_FAILURE) +=3D memory-failure.o
> =A0obj-$(CONFIG_HWPOISON_INJECT) +=3D hwpoison-inject.o
> =A0obj-$(CONFIG_DEBUG_KMEMLEAK) +=3D kmemleak.o
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 3449df8..2d968ea 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -134,6 +134,24 @@
> =A0#include <net/tcp.h>
> =A0#endif
>
> +static DEFINE_RWLOCK(proto_list_lock);
> +static LIST_HEAD(proto_list);
> +
> +int sockets_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 struct proto *proto;
> + =A0 =A0 =A0 int ret =3D 0;
> +
> + =A0 =A0 =A0 read_lock(&proto_list_lock);
> + =A0 =A0 =A0 list_for_each_entry(proto, &proto_list, node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (proto->init_cgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret |=3D proto->init_cgroup=
(cgrp, ss);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 read_unlock(&proto_list_lock);
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> =A0/*
> =A0* Each address family might have different locking rules, so we have
> =A0* one slock key per address family:
> @@ -1114,6 +1132,31 @@ void sock_update_classid(struct sock *sk)
> =A0EXPORT_SYMBOL(sock_update_classid);
> =A0#endif
>
> +void sock_update_kmem_cgrp(struct sock *sk)
> +{
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 sk->sk_cgrp =3D kcg_from_task(current);
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
> + =A0 =A0 =A0 cgroup_exclude_rmdir(&sk->sk_cgrp->css);
> +#endif
> +}
> +
> +void sock_release_kmem_cgrp(struct sock *sk)
> +{
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 cgroup_release_and_wakeup_rmdir(&sk->sk_cgrp->css);
> +#endif
> +}
> +
> =A0/**
> =A0* =A0 =A0 sk_alloc - All socket objects are allocated here
> =A0* =A0 =A0 @net: the applicable net namespace
> @@ -1139,6 +1182,7 @@ struct sock *sk_alloc(struct net *net, int family, =
gfp_t priority,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_set(&sk->sk_wmem_alloc, 1);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sock_update_classid(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_update_kmem_cgrp(sk);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return sk;
> @@ -1170,6 +1214,7 @@ static void __sk_free(struct sock *sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_cred(sk->sk_peer_cred);
> =A0 =A0 =A0 =A0put_pid(sk->sk_peer_pid);
> =A0 =A0 =A0 =A0put_net(sock_net(sk));
> + =A0 =A0 =A0 sock_release_kmem_cgrp(sk);
> =A0 =A0 =A0 =A0sk_prot_free(sk->sk_prot_creator, sk);
> =A0}
>
> @@ -1287,8 +1332,8 @@ struct sock *sk_clone(const struct sock *sk, const =
gfp_t priority)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk_set_socket(newsk, NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0newsk->sk_wq =3D NULL;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (newsk->sk_prot->sockets_allocated)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_counter_inc(newsk->s=
k_prot->sockets_allocated);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk_sockets_allocated(sk))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_counter_inc(sk_socke=
ts_allocated(sk));
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sock_flag(newsk, SOCK_TIMESTAMP) ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sock_flag(newsk, SOCK_TIMESTAMPING=
_RX_SOFTWARE))
> @@ -1676,29 +1721,51 @@ EXPORT_SYMBOL(sk_wait_data);
> =A0*/
> =A0int __sk_mem_schedule(struct sock *sk, int size, int kind)
> =A0{
> - =A0 =A0 =A0 struct proto *prot =3D sk->sk_prot;
> =A0 =A0 =A0 =A0int amt =3D sk_mem_pages(size);
> + =A0 =A0 =A0 struct proto *prot =3D sk->sk_prot;
> =A0 =A0 =A0 =A0long allocated;
> + =A0 =A0 =A0 int *memory_pressure;
> + =A0 =A0 =A0 long *prot_mem;
> + =A0 =A0 =A0 int parent_failure =3D 0;
> + =A0 =A0 =A0 struct kmem_cgroup *sg;
>
> =A0 =A0 =A0 =A0sk->sk_forward_alloc +=3D amt * SK_MEM_QUANTUM;
> - =A0 =A0 =A0 allocated =3D atomic_long_add_return(amt, prot->memory_allo=
cated);
> +
> + =A0 =A0 =A0 memory_pressure =3D sk_memory_pressure(sk);
> + =A0 =A0 =A0 prot_mem =3D sk_prot_mem(sk);
> +
> + =A0 =A0 =A0 allocated =3D atomic_long_add_return(amt, sk_memory_allocat=
ed(sk));
> +
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 for (sg =3D sk->sk_cgrp->parent; sg !=3D NULL; sg =3D sg->p=
arent) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 long alloc;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Large nestings are not the common case=
, and stopping in the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* middle would be complicated enough, th=
at we bill it all the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* way through the root, and if needed, u=
nbill everything later
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 alloc =3D atomic_long_add_return(amt,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0sg_memory_allocated(prot, sg));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 parent_failure |=3D (alloc > sk_prot_mem(sk=
)[2]);
> + =A0 =A0 =A0 }
> +#endif
> +
> + =A0 =A0 =A0 /* Over hard limit (we, or our parents) */
> + =A0 =A0 =A0 if (parent_failure || (allocated > prot_mem[2]))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto suppress_allocation;
>
> =A0 =A0 =A0 =A0/* Under limit. */
> - =A0 =A0 =A0 if (allocated <=3D prot->sysctl_mem[0]) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (prot->memory_pressure && *prot->memory_=
pressure)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *prot->memory_pressure =3D =
0;
> + =A0 =A0 =A0 if (allocated <=3D prot_mem[0]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memory_pressure && *memory_pressure)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *memory_pressure =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* Under pressure. */
> - =A0 =A0 =A0 if (allocated > prot->sysctl_mem[1])
> + =A0 =A0 =A0 if (allocated > prot_mem[1])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (prot->enter_memory_pressure)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prot->enter_memory_pressur=
e(sk);
>
> - =A0 =A0 =A0 /* Over hard limit. */
> - =A0 =A0 =A0 if (allocated > prot->sysctl_mem[2])
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto suppress_allocation;
> -
> =A0 =A0 =A0 =A0/* guarantee minimum buffer size under pressure */
> =A0 =A0 =A0 =A0if (kind =3D=3D SK_MEM_RECV) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (atomic_read(&sk->sk_rmem_alloc) < prot=
->sysctl_rmem[0])
> @@ -1712,13 +1779,13 @@ int __sk_mem_schedule(struct sock *sk, int size, =
int kind)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (prot->memory_pressure) {
> + =A0 =A0 =A0 if (memory_pressure) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int alloc;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!*prot->memory_pressure)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!*memory_pressure)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 alloc =3D percpu_counter_read_positive(prot=
->sockets_allocated);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (prot->sysctl_mem[2] > alloc *
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 alloc =3D percpu_counter_read_positive(sk_s=
ockets_allocated(sk));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (prot_mem[2] > alloc *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk_mem_pages(sk->sk_wmem_queued +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_re=
ad(&sk->sk_rmem_alloc) +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk->sk_fo=
rward_alloc))
> @@ -1741,7 +1808,13 @@ suppress_allocation:
>
> =A0 =A0 =A0 =A0/* Alas. Undo changes. */
> =A0 =A0 =A0 =A0sk->sk_forward_alloc -=3D amt * SK_MEM_QUANTUM;
> - =A0 =A0 =A0 atomic_long_sub(amt, prot->memory_allocated);
> +
> + =A0 =A0 =A0 atomic_long_sub(amt, sk_memory_allocated(sk));
> +
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 for (sg =3D sk->sk_cgrp->parent; sg !=3D NULL; sg =3D sg->p=
arent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_long_sub(amt, sg_memory_allocated(pr=
ot, sg));
> +#endif
> =A0 =A0 =A0 =A0return 0;
> =A0}
> =A0EXPORT_SYMBOL(__sk_mem_schedule);
> @@ -1753,14 +1826,24 @@ EXPORT_SYMBOL(__sk_mem_schedule);
> =A0void __sk_mem_reclaim(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct proto *prot =3D sk->sk_prot;
> + =A0 =A0 =A0 struct kmem_cgroup *sg =3D sk->sk_cgrp;
> + =A0 =A0 =A0 int *memory_pressure =3D sk_memory_pressure(sk);
>
> =A0 =A0 =A0 =A0atomic_long_sub(sk->sk_forward_alloc >> SK_MEM_QUANTUM_SHI=
FT,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prot->memory_allocated);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk_memory_allocated(sk));
> +
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 for (sg =3D sk->sk_cgrp->parent; sg !=3D NULL; sg =3D sg->p=
arent) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_long_sub(sk->sk_forward_alloc >> SK_=
MEM_QUANTUM_SHIFT,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 sg_memory_allocated(prot, sg));
> + =A0 =A0 =A0 }
> +#endif
> +
> =A0 =A0 =A0 =A0sk->sk_forward_alloc &=3D SK_MEM_QUANTUM - 1;
>
> - =A0 =A0 =A0 if (prot->memory_pressure && *prot->memory_pressure &&
> - =A0 =A0 =A0 =A0 =A0 (atomic_long_read(prot->memory_allocated) < prot->s=
ysctl_mem[0]))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *prot->memory_pressure =3D 0;
> + =A0 =A0 =A0 if (memory_pressure && *memory_pressure &&
> + =A0 =A0 =A0 =A0 =A0 (atomic_long_read(sk_memory_allocated(sk)) < sk_pro=
t_mem(sk)[0]))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *memory_pressure =3D 0;
> =A0}
> =A0EXPORT_SYMBOL(__sk_mem_reclaim);
>
> @@ -2252,9 +2335,6 @@ void sk_common_release(struct sock *sk)
> =A0}
> =A0EXPORT_SYMBOL(sk_common_release);
>
> -static DEFINE_RWLOCK(proto_list_lock);
> -static LIST_HEAD(proto_list);
> -
> =A0#ifdef CONFIG_PROC_FS
> =A0#define PROTO_INUSE_NR 64 =A0 =A0 =A0/* should be enough for the first=
 time */
> =A0struct prot_inuse {
> @@ -2479,13 +2559,17 @@ static char proto_method_implemented(const void *=
method)
>
> =A0static void proto_seq_printf(struct seq_file *seq, struct proto *proto=
)
> =A0{
> + =A0 =A0 =A0 struct kmem_cgroup *sg =3D kcg_from_task(current);
> +
> =A0 =A0 =A0 =A0seq_printf(seq, "%-9s %4u %6d =A0%6ld =A0 %-3s %6u =A0 %-3=
s =A0%-10s "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"%2c %2c %2c %2c %2c %2c %=
2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 proto->name,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 proto->obj_size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_prot_inuse_get(seq_file_net(seq)=
, proto),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0proto->memory_allocated !=3D NULL ? =
atomic_long_read(proto->memory_allocated) : -1L,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0proto->memory_pressure !=3D NULL ? *=
proto->memory_pressure ? "yes" : "no" : "NI",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0proto->memory_allocated !=3D NULL ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 atomic_long_read(sg_memory_=
allocated(proto, sg)) : -1L,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0proto->memory_pressure !=3D NULL ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *sg_memory_pressure(proto, =
sg) ? "yes" : "no" : "NI",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 proto->max_header,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 proto->slab =3D=3D NULL ? "no" : "yes=
",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 module_name(proto->owner),
> diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
> index 19acd00..463b299 100644
> --- a/net/decnet/af_decnet.c
> +++ b/net/decnet/af_decnet.c
> @@ -458,13 +458,28 @@ static void dn_enter_memory_pressure(struct sock *s=
k)
> =A0 =A0 =A0 =A0}
> =A0}
>
> +static atomic_long_t *memory_allocated_dn(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &decnet_memory_allocated;
> +}
> +
> +static int *memory_pressure_dn(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &dn_memory_pressure;
> +}
> +
> +static long *dn_sysctl_mem(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return sysctl_decnet_mem;
> +}
> +
> =A0static struct proto dn_proto =3D {
> =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D "NSP",
> =A0 =A0 =A0 =A0.owner =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> =A0 =A0 =A0 =A0.enter_memory_pressure =A0=3D dn_enter_memory_pressure,
> - =A0 =A0 =A0 .memory_pressure =A0 =A0 =A0 =A0=3D &dn_memory_pressure,
> - =A0 =A0 =A0 .memory_allocated =A0 =A0 =A0 =3D &decnet_memory_allocated,
> - =A0 =A0 =A0 .sysctl_mem =A0 =A0 =A0 =A0 =A0 =A0 =3D sysctl_decnet_mem,
> + =A0 =A0 =A0 .memory_pressure =A0 =A0 =A0 =A0=3D memory_pressure_dn,
> + =A0 =A0 =A0 .memory_allocated =A0 =A0 =A0 =3D memory_allocated_dn,
> + =A0 =A0 =A0 .prot_mem =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D dn_sysctl_mem,
> =A0 =A0 =A0 =A0.sysctl_wmem =A0 =A0 =A0 =A0 =A0 =A0=3D sysctl_decnet_wmem=
,
> =A0 =A0 =A0 =A0.sysctl_rmem =A0 =A0 =A0 =A0 =A0 =A0=3D sysctl_decnet_rmem=
,
> =A0 =A0 =A0 =A0.max_header =A0 =A0 =A0 =A0 =A0 =A0 =3D DN_MAX_NSP_DATA_HE=
ADER + 64,
> diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
> index b14ec7d..9c80acf 100644
> --- a/net/ipv4/proc.c
> +++ b/net/ipv4/proc.c
> @@ -52,20 +52,22 @@ static int sockstat_seq_show(struct seq_file *seq, vo=
id *v)
> =A0{
> =A0 =A0 =A0 =A0struct net *net =3D seq->private;
> =A0 =A0 =A0 =A0int orphans, sockets;
> + =A0 =A0 =A0 struct kmem_cgroup *sg =3D kcg_from_task(current);
> + =A0 =A0 =A0 struct percpu_counter *allocated =3D sg_sockets_allocated(&=
tcp_prot, sg);
>
> =A0 =A0 =A0 =A0local_bh_disable();
> =A0 =A0 =A0 =A0orphans =3D percpu_counter_sum_positive(&tcp_orphan_count)=
;
> - =A0 =A0 =A0 sockets =3D percpu_counter_sum_positive(&tcp_sockets_alloca=
ted);
> + =A0 =A0 =A0 sockets =3D percpu_counter_sum_positive(allocated);
> =A0 =A0 =A0 =A0local_bh_enable();
>
> =A0 =A0 =A0 =A0socket_seq_show(seq);
> =A0 =A0 =A0 =A0seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d me=
m %ld\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_prot_inuse_get(net, &tcp_prot), =
orphans,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_death_row.tw_count, sockets,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_long_read(&tcp_memory_allocat=
ed));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_long_read(sg_memory_allocated=
((&tcp_prot), sg)));
> =A0 =A0 =A0 =A0seq_printf(seq, "UDP: inuse %d mem %ld\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_prot_inuse_get(net, &udp_prot),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_long_read(&udp_memory_allocat=
ed));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_long_read(sg_memory_allocated=
((&udp_prot), sg)));
> =A0 =A0 =A0 =A0seq_printf(seq, "UDPLITE: inuse %d\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_prot_inuse_get(net, &udplite_pro=
t));
> =A0 =A0 =A0 =A0seq_printf(seq, "RAW: inuse %d\n",
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 69fd720..5e89480 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -14,6 +14,8 @@
> =A0#include <linux/init.h>
> =A0#include <linux/slab.h>
> =A0#include <linux/nsproxy.h>
> +#include <linux/kmem_cgroup.h>
> +#include <linux/swap.h>
> =A0#include <net/snmp.h>
> =A0#include <net/icmp.h>
> =A0#include <net/ip.h>
> @@ -174,6 +176,43 @@ static int proc_allowed_congestion_control(ctl_table=
 *ctl,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> +static int ipv4_tcp_mem(ctl_table *ctl, int write,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void __user *buffer,=
 size_t *lenp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loff_t *ppos)
> +{
> + =A0 =A0 =A0 int ret;
> + =A0 =A0 =A0 unsigned long vec[3];
> + =A0 =A0 =A0 struct kmem_cgroup *kmem =3D kcg_from_task(current);
> + =A0 =A0 =A0 struct net *net =3D current->nsproxy->net_ns;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 ctl_table tmp =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =3D &vec,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =3D sizeof(vec),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =3D ctl->mode,
> + =A0 =A0 =A0 };
> +
> + =A0 =A0 =A0 if (!write) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ctl->data =3D &net->ipv4.sysctl_tcp_mem;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return proc_doulongvec_minmax(ctl, write, b=
uffer, lenp, ppos);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ret =3D proc_doulongvec_minmax(&tmp, write, buffer, lenp, p=
pos);
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < 3; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vec[i] > kmem->tcp_max_memory)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < 3; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 net->ipv4.sysctl_tcp_mem[i] =3D vec[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem->tcp_prot_mem[i] =3D net->ipv4.sysctl_=
tcp_mem[i];
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static struct ctl_table ipv4_table[] =3D {
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "tcp_timestamps"=
,
> @@ -433,13 +472,6 @@ static struct ctl_table ipv4_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.proc_handler =A0 =3D proc_dointvec
> =A0 =A0 =A0 =A0},
> =A0 =A0 =A0 =A0{
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D "tcp_mem",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =A0 =A0 =A0 =A0 =A0 =3D &sysctl_tcp_m=
em,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =A0 =A0 =A0 =A0 =3D sizeof(sysctl_t=
cp_mem),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D proc_doulongvec_minma=
x
> - =A0 =A0 =A0 },
> - =A0 =A0 =A0 {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.procname =A0 =A0 =A0 =3D "tcp_wmem",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =A0 =A0 =A0 =A0 =A0 =3D &sysctl_tcp_=
wmem,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.maxlen =A0 =A0 =A0 =A0 =3D sizeof(sysctl_=
tcp_wmem),
> @@ -721,6 +753,12 @@ static struct ctl_table ipv4_net_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.proc_handler =A0 =3D ipv4_ping_group_rang=
e,
> =A0 =A0 =A0 =A0},
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D "tcp_mem",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =A0 =A0 =A0 =A0 =3D sizeof(init_net=
.ipv4.sysctl_tcp_mem),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D ipv4_tcp_mem,
> + =A0 =A0 =A0 },
> =A0 =A0 =A0 =A0{ }
> =A0};
>
> @@ -734,6 +772,7 @@ EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
> =A0static __net_init int ipv4_sysctl_init_net(struct net *net)
> =A0{
> =A0 =A0 =A0 =A0struct ctl_table *table;
> + =A0 =A0 =A0 unsigned long limit;
>
> =A0 =A0 =A0 =A0table =3D ipv4_net_table;
> =A0 =A0 =A0 =A0if (!net_eq(net, &init_net)) {
> @@ -769,6 +808,12 @@ static __net_init int ipv4_sysctl_init_net(struct ne=
t *net)
>
> =A0 =A0 =A0 =A0net->ipv4.sysctl_rt_cache_rebuild_count =3D 4;
>
> + =A0 =A0 =A0 limit =3D nr_free_buffer_pages() / 8;
> + =A0 =A0 =A0 limit =3D max(limit, 128UL);
> + =A0 =A0 =A0 net->ipv4.sysctl_tcp_mem[0] =3D limit / 4 * 3;
> + =A0 =A0 =A0 net->ipv4.sysctl_tcp_mem[1] =3D limit;
> + =A0 =A0 =A0 net->ipv4.sysctl_tcp_mem[2] =3D net->ipv4.sysctl_tcp_mem[0]=
 * 2;
> +
> =A0 =A0 =A0 =A0net->ipv4.ipv4_hdr =3D register_net_sysctl_table(net,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0net_ipv4_ctl_path, table);
> =A0 =A0 =A0 =A0if (net->ipv4.ipv4_hdr =3D=3D NULL)
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 46febca..e1918fa 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -266,6 +266,7 @@
> =A0#include <linux/crypto.h>
> =A0#include <linux/time.h>
> =A0#include <linux/slab.h>
> +#include <linux/nsproxy.h>
>
> =A0#include <net/icmp.h>
> =A0#include <net/tcp.h>
> @@ -282,23 +283,12 @@ int sysctl_tcp_fin_timeout __read_mostly =3D TCP_FI=
N_TIMEOUT;
> =A0struct percpu_counter tcp_orphan_count;
> =A0EXPORT_SYMBOL_GPL(tcp_orphan_count);
>
> -long sysctl_tcp_mem[3] __read_mostly;
> =A0int sysctl_tcp_wmem[3] __read_mostly;
> =A0int sysctl_tcp_rmem[3] __read_mostly;
>
> -EXPORT_SYMBOL(sysctl_tcp_mem);
> =A0EXPORT_SYMBOL(sysctl_tcp_rmem);
> =A0EXPORT_SYMBOL(sysctl_tcp_wmem);
>
> -atomic_long_t tcp_memory_allocated; =A0 =A0/* Current allocated memory. =
*/
> -EXPORT_SYMBOL(tcp_memory_allocated);
> -
> -/*
> - * Current number of TCP sockets.
> - */
> -struct percpu_counter tcp_sockets_allocated;
> -EXPORT_SYMBOL(tcp_sockets_allocated);
> -
> =A0/*
> =A0* TCP splice context
> =A0*/
> @@ -308,23 +298,157 @@ struct tcp_splice_state {
> =A0 =A0 =A0 =A0unsigned int flags;
> =A0};
>
> +#ifdef CONFIG_CGROUP_KMEM
> =A0/*
> =A0* Pressure flag: try to collapse.
> =A0* Technical note: it is used by multiple contexts non atomically.
> =A0* All the __sk_mem_schedule() is of this nature: accounting
> =A0* is strict, actions are advisory and have some latency.
> =A0*/
> -int tcp_memory_pressure __read_mostly;
> -EXPORT_SYMBOL(tcp_memory_pressure);
> -
> =A0void tcp_enter_memory_pressure(struct sock *sk)
> =A0{
> + =A0 =A0 =A0 struct kmem_cgroup *sg =3D sk->sk_cgrp;
> + =A0 =A0 =A0 if (!sg->tcp_memory_pressure) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPME=
MORYPRESSURES);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg->tcp_memory_pressure =3D 1;
> + =A0 =A0 =A0 }
> +}
> +
> +long *tcp_sysctl_mem(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return sg->tcp_prot_mem;
> +}
> +
> +atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &(sg->tcp_memory_allocated);
> +}
> +
> +static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64=
 val)
> +{
> + =A0 =A0 =A0 struct kmem_cgroup *sg =3D kcg_from_cgroup(cgrp);
> + =A0 =A0 =A0 struct net *net =3D current->nsproxy->net_ns;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 if (!cgroup_lock_live_group(cgrp))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We can't allow more memory than our parents. Since thi=
s
> + =A0 =A0 =A0 =A0* will be tested for all calls, by induction, there is n=
o need
> + =A0 =A0 =A0 =A0* to test any parent other than our own
> + =A0 =A0 =A0 =A0* */
> + =A0 =A0 =A0 if (sg->parent && (val > sg->parent->tcp_max_memory))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D sg->parent->tcp_max_memory;
> +
> + =A0 =A0 =A0 sg->tcp_max_memory =3D val;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < 3; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg->tcp_prot_mem[i] =A0=3D min_t(long, val,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0net->ipv4.sysctl_tcp_mem[i]);
> +
> + =A0 =A0 =A0 cgroup_unlock();
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
> +{
> + =A0 =A0 =A0 struct kmem_cgroup *sg =3D kcg_from_cgroup(cgrp);
> + =A0 =A0 =A0 u64 ret;
> +
> + =A0 =A0 =A0 if (!cgroup_lock_live_group(cgrp))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> + =A0 =A0 =A0 ret =3D sg->tcp_max_memory;
> +
> + =A0 =A0 =A0 cgroup_unlock();
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static struct cftype tcp_files[] =3D {
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "tcp_maxmem",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D tcp_write_maxmem,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D tcp_read_maxmem,
> + =A0 =A0 =A0 },
> +};
> +
> +int tcp_init_cgroup(struct cgroup *cgrp, struct cgroup_subsys *ss)
> +{
> + =A0 =A0 =A0 struct kmem_cgroup *sg =3D kcg_from_cgroup(cgrp);
> + =A0 =A0 =A0 unsigned long limit;
> + =A0 =A0 =A0 struct net *net =3D current->nsproxy->net_ns;
> +
> + =A0 =A0 =A0 sg->tcp_memory_pressure =3D 0;
> + =A0 =A0 =A0 atomic_long_set(&sg->tcp_memory_allocated, 0);
> + =A0 =A0 =A0 percpu_counter_init(&sg->tcp_sockets_allocated, 0);
> +
> + =A0 =A0 =A0 limit =3D nr_free_buffer_pages() / 8;
> + =A0 =A0 =A0 limit =3D max(limit, 128UL);
> +
> + =A0 =A0 =A0 if (sg->parent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg->tcp_max_memory =3D sg->parent->tcp_max_=
memory;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sg->tcp_max_memory =3D limit * 2;
> +
> + =A0 =A0 =A0 sg->tcp_prot_mem[0] =3D net->ipv4.sysctl_tcp_mem[0];
> + =A0 =A0 =A0 sg->tcp_prot_mem[1] =3D net->ipv4.sysctl_tcp_mem[1];
> + =A0 =A0 =A0 sg->tcp_prot_mem[2] =3D net->ipv4.sysctl_tcp_mem[2];
> +
> + =A0 =A0 =A0 return cgroup_add_files(cgrp, ss, tcp_files, ARRAY_SIZE(tcp=
_files));
> +}
> +EXPORT_SYMBOL(tcp_init_cgroup);
> +
> +int *memory_pressure_tcp(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &sg->tcp_memory_pressure;
> +}
> +
> +struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &sg->tcp_sockets_allocated;
> +}
> +#else
> +
> +/* Current number of TCP sockets. */
> +struct percpu_counter tcp_sockets_allocated;
> +atomic_long_t tcp_memory_allocated; =A0 =A0/* Current allocated memory. =
*/
> +int tcp_memory_pressure;
> +
> +int *memory_pressure_tcp(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &tcp_memory_pressure;
> +}
> +
> +struct percpu_counter *sockets_allocated_tcp(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &tcp_sockets_allocated;
> +}
> +
> +void tcp_enter_memory_pressure(struct sock *sock)
> +{
> =A0 =A0 =A0 =A0if (!tcp_memory_pressure) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPM=
EMORYPRESSURES);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_memory_pressure =3D 1;
> =A0 =A0 =A0 =A0}
> =A0}
> +
> +long *tcp_sysctl_mem(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return init_net.ipv4.sysctl_tcp_mem;
> +}
> +
> +atomic_long_t *memory_allocated_tcp(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &tcp_memory_allocated;
> +}
> +#endif /* CONFIG_CGROUP_KMEM */
> +
> +EXPORT_SYMBOL(memory_pressure_tcp);
> +EXPORT_SYMBOL(sockets_allocated_tcp);
> =A0EXPORT_SYMBOL(tcp_enter_memory_pressure);
> +EXPORT_SYMBOL(tcp_sysctl_mem);
> +EXPORT_SYMBOL(memory_allocated_tcp);
>
> =A0/* Convert seconds to retransmits based on initial and max timeout */
> =A0static u8 secs_to_retrans(int seconds, int timeout, int rto_max)
> @@ -3226,7 +3350,9 @@ void __init tcp_init(void)
>
> =A0 =A0 =A0 =A0BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
>
> +#ifndef CONFIG_CGROUP_KMEM
> =A0 =A0 =A0 =A0percpu_counter_init(&tcp_sockets_allocated, 0);
> +#endif
> =A0 =A0 =A0 =A0percpu_counter_init(&tcp_orphan_count, 0);
> =A0 =A0 =A0 =A0tcp_hashinfo.bind_bucket_cachep =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kmem_cache_create("tcp_bind_bucket",
> @@ -3277,14 +3403,10 @@ void __init tcp_init(void)
> =A0 =A0 =A0 =A0sysctl_tcp_max_orphans =3D cnt / 2;
> =A0 =A0 =A0 =A0sysctl_max_syn_backlog =3D max(128, cnt / 256);
>
> - =A0 =A0 =A0 limit =3D nr_free_buffer_pages() / 8;
> - =A0 =A0 =A0 limit =3D max(limit, 128UL);
> - =A0 =A0 =A0 sysctl_tcp_mem[0] =3D limit / 4 * 3;
> - =A0 =A0 =A0 sysctl_tcp_mem[1] =3D limit;
> - =A0 =A0 =A0 sysctl_tcp_mem[2] =3D sysctl_tcp_mem[0] * 2;
> -
> =A0 =A0 =A0 =A0/* Set per-socket limits to no more than 1/128 the pressur=
e threshold */
> - =A0 =A0 =A0 limit =3D ((unsigned long)sysctl_tcp_mem[1]) << (PAGE_SHIFT=
 - 7);
> + =A0 =A0 =A0 limit =3D (unsigned long)init_net.ipv4.sysctl_tcp_mem[1];
> + =A0 =A0 =A0 limit <<=3D (PAGE_SHIFT - 7);
> +
> =A0 =A0 =A0 =A0max_share =3D min(4UL*1024*1024, limit);
>
> =A0 =A0 =A0 =A0sysctl_tcp_wmem[0] =3D SK_MEM_QUANTUM;
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index ea0d218..c44e830 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -316,7 +316,7 @@ static void tcp_grow_window(struct sock *sk, struct s=
k_buff *skb)
> =A0 =A0 =A0 =A0/* Check #1 */
> =A0 =A0 =A0 =A0if (tp->rcv_ssthresh < tp->window_clamp &&
> =A0 =A0 =A0 =A0 =A0 =A0(int)tp->rcv_ssthresh < tcp_space(sk) &&
> - =A0 =A0 =A0 =A0 =A0 !tcp_memory_pressure) {
> + =A0 =A0 =A0 =A0 =A0 !sk_memory_pressure(sk)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int incr;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Check #2. Increase window, if skb with =
such overhead
> @@ -393,15 +393,16 @@ static void tcp_clamp_window(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> =A0 =A0 =A0 =A0struct inet_connection_sock *icsk =3D inet_csk(sk);
> + =A0 =A0 =A0 struct proto *prot =3D sk->sk_prot;
>
> =A0 =A0 =A0 =A0icsk->icsk_ack.quick =3D 0;
>
> - =A0 =A0 =A0 if (sk->sk_rcvbuf < sysctl_tcp_rmem[2] &&
> + =A0 =A0 =A0 if (sk->sk_rcvbuf < prot->sysctl_rmem[2] &&
> =A0 =A0 =A0 =A0 =A0 =A0!(sk->sk_userlocks & SOCK_RCVBUF_LOCK) &&
> - =A0 =A0 =A0 =A0 =A0 !tcp_memory_pressure &&
> - =A0 =A0 =A0 =A0 =A0 atomic_long_read(&tcp_memory_allocated) < sysctl_tc=
p_mem[0]) {
> + =A0 =A0 =A0 =A0 =A0 !sk_memory_pressure(sk) &&
> + =A0 =A0 =A0 =A0 =A0 atomic_long_read(sk_memory_allocated(sk)) < sk_prot=
_mem(sk)[0]) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk->sk_rcvbuf =3D min(atomic_read(&sk->sk_=
rmem_alloc),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sys=
ctl_tcp_rmem[2]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pro=
t->sysctl_rmem[2]);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->rcv_ssthresh =3D min(tp->window_clamp,=
 2U * tp->advmss);
> @@ -4806,7 +4807,7 @@ static int tcp_prune_queue(struct sock *sk)
>
> =A0 =A0 =A0 =A0if (atomic_read(&sk->sk_rmem_alloc) >=3D sk->sk_rcvbuf)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_clamp_window(sk);
> - =A0 =A0 =A0 else if (tcp_memory_pressure)
> + =A0 =A0 =A0 else if (sk_memory_pressure(sk))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->rcv_ssthresh =3D min(tp->rcv_ssthresh,=
 4U * tp->advmss);
>
> =A0 =A0 =A0 =A0tcp_collapse_ofo_queue(sk);
> @@ -4872,11 +4873,11 @@ static int tcp_should_expand_sndbuf(struct sock *=
sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> =A0 =A0 =A0 =A0/* If we are under global TCP memory pressure, do not expa=
nd. =A0*/
> - =A0 =A0 =A0 if (tcp_memory_pressure)
> + =A0 =A0 =A0 if (sk_memory_pressure(sk))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> =A0 =A0 =A0 =A0/* If we are under soft global TCP memory pressure, do not=
 expand. =A0*/
> - =A0 =A0 =A0 if (atomic_long_read(&tcp_memory_allocated) >=3D sysctl_tcp=
_mem[0])
> + =A0 =A0 =A0 if (atomic_long_read(sk_memory_allocated(sk)) >=3D sk_prot_=
mem(sk)[0])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> =A0 =A0 =A0 =A0/* If we filled the congestion window, do not expand. =A0*=
/
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 1c12b8e..af6c095 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1848,6 +1848,7 @@ static int tcp_v4_init_sock(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct inet_connection_sock *icsk =3D inet_csk(sk);
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> + =A0 =A0 =A0 struct kmem_cgroup *sg;
>
> =A0 =A0 =A0 =A0skb_queue_head_init(&tp->out_of_order_queue);
> =A0 =A0 =A0 =A0tcp_init_xmit_timers(sk);
> @@ -1901,7 +1902,13 @@ static int tcp_v4_init_sock(struct sock *sk)
> =A0 =A0 =A0 =A0sk->sk_rcvbuf =3D sysctl_tcp_rmem[1];
>
> =A0 =A0 =A0 =A0local_bh_disable();
> - =A0 =A0 =A0 percpu_counter_inc(&tcp_sockets_allocated);
> + =A0 =A0 =A0 percpu_counter_inc(sk_sockets_allocated(sk));
> +
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 for (sg =3D sk->sk_cgrp->parent; sg; sg =3D sg->parent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_counter_inc(sg_sockets_allocated(sk-=
>sk_prot, sg));
> +#endif
> +
> =A0 =A0 =A0 =A0local_bh_enable();
>
> =A0 =A0 =A0 =A0return 0;
> @@ -1910,6 +1917,7 @@ static int tcp_v4_init_sock(struct sock *sk)
> =A0void tcp_v4_destroy_sock(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> + =A0 =A0 =A0 struct kmem_cgroup *sg;
>
> =A0 =A0 =A0 =A0tcp_clear_xmit_timers(sk);
>
> @@ -1957,7 +1965,11 @@ void tcp_v4_destroy_sock(struct sock *sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->cookie_values =3D NULL;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 percpu_counter_dec(&tcp_sockets_allocated);
> + =A0 =A0 =A0 percpu_counter_dec(sk_sockets_allocated(sk));
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 for (sg =3D sk->sk_cgrp->parent; sg; sg =3D sg->parent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_counter_dec(sg_sockets_allocated(sk-=
>sk_prot, sg));
> +#endif
> =A0}
> =A0EXPORT_SYMBOL(tcp_v4_destroy_sock);
>
> @@ -2598,11 +2610,14 @@ struct proto tcp_prot =3D {
> =A0 =A0 =A0 =A0.unhash =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D inet_unhash,
> =A0 =A0 =A0 =A0.get_port =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D inet_csk_get_por=
t,
> =A0 =A0 =A0 =A0.enter_memory_pressure =A0=3D tcp_enter_memory_pressure,
> - =A0 =A0 =A0 .sockets_allocated =A0 =A0 =A0=3D &tcp_sockets_allocated,
> + =A0 =A0 =A0 .memory_pressure =A0 =A0 =A0 =A0=3D memory_pressure_tcp,
> + =A0 =A0 =A0 .sockets_allocated =A0 =A0 =A0=3D sockets_allocated_tcp,
> =A0 =A0 =A0 =A0.orphan_count =A0 =A0 =A0 =A0 =A0 =3D &tcp_orphan_count,
> - =A0 =A0 =A0 .memory_allocated =A0 =A0 =A0 =3D &tcp_memory_allocated,
> - =A0 =A0 =A0 .memory_pressure =A0 =A0 =A0 =A0=3D &tcp_memory_pressure,
> - =A0 =A0 =A0 .sysctl_mem =A0 =A0 =A0 =A0 =A0 =A0 =3D sysctl_tcp_mem,
> + =A0 =A0 =A0 .memory_allocated =A0 =A0 =A0 =3D memory_allocated_tcp,
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 .init_cgroup =A0 =A0 =A0 =A0 =A0 =A0=3D tcp_init_cgroup,
> +#endif
> + =A0 =A0 =A0 .prot_mem =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D tcp_sysctl_mem,
> =A0 =A0 =A0 =A0.sysctl_wmem =A0 =A0 =A0 =A0 =A0 =A0=3D sysctl_tcp_wmem,
> =A0 =A0 =A0 =A0.sysctl_rmem =A0 =A0 =A0 =A0 =A0 =A0=3D sysctl_tcp_rmem,
> =A0 =A0 =A0 =A0.max_header =A0 =A0 =A0 =A0 =A0 =A0 =3D MAX_TCP_HEADER,
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 882e0b0..06aeb31 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1912,7 +1912,7 @@ u32 __tcp_select_window(struct sock *sk)
> =A0 =A0 =A0 =A0if (free_space < (full_space >> 1)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0icsk->icsk_ack.quick =3D 0;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tcp_memory_pressure)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk_memory_pressure(sk))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->rcv_ssthresh =3D min(t=
p->rcv_ssthresh,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 4U * tp->advmss);
>
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index ecd44b0..2c67617 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -261,7 +261,7 @@ static void tcp_delack_timer(unsigned long data)
> =A0 =A0 =A0 =A0}
>
> =A0out:
> - =A0 =A0 =A0 if (tcp_memory_pressure)
> + =A0 =A0 =A0 if (sk_memory_pressure(sk))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk_mem_reclaim(sk);
> =A0out_unlock:
> =A0 =A0 =A0 =A0bh_unlock_sock(sk);
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 1b5a193..6c08c65 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -120,9 +120,6 @@ EXPORT_SYMBOL(sysctl_udp_rmem_min);
> =A0int sysctl_udp_wmem_min __read_mostly;
> =A0EXPORT_SYMBOL(sysctl_udp_wmem_min);
>
> -atomic_long_t udp_memory_allocated;
> -EXPORT_SYMBOL(udp_memory_allocated);
> -
> =A0#define MAX_UDP_PORTS 65536
> =A0#define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
>
> @@ -1918,6 +1915,19 @@ unsigned int udp_poll(struct file *file, struct so=
cket *sock, poll_table *wait)
> =A0}
> =A0EXPORT_SYMBOL(udp_poll);
>
> +static atomic_long_t udp_memory_allocated;
> +atomic_long_t *memory_allocated_udp(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &udp_memory_allocated;
> +}
> +EXPORT_SYMBOL(memory_allocated_udp);
> +
> +long *udp_sysctl_mem(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return sysctl_udp_mem;
> +}
> +EXPORT_SYMBOL(udp_sysctl_mem);
> +
> =A0struct proto udp_prot =3D {
> =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D "UDP",
> =A0 =A0 =A0 =A0.owner =A0 =A0 =A0 =A0 =A0 =A0 =3D THIS_MODULE,
> @@ -1936,8 +1946,8 @@ struct proto udp_prot =3D {
> =A0 =A0 =A0 =A0.unhash =A0 =A0 =A0 =A0 =A0 =A0=3D udp_lib_unhash,
> =A0 =A0 =A0 =A0.rehash =A0 =A0 =A0 =A0 =A0 =A0=3D udp_v4_rehash,
> =A0 =A0 =A0 =A0.get_port =A0 =A0 =A0 =A0 =A0=3D udp_v4_get_port,
> - =A0 =A0 =A0 .memory_allocated =A0=3D &udp_memory_allocated,
> - =A0 =A0 =A0 .sysctl_mem =A0 =A0 =A0 =A0=3D sysctl_udp_mem,
> + =A0 =A0 =A0 .memory_allocated =A0=3D &memory_allocated_udp,
> + =A0 =A0 =A0 .prot_mem =A0 =A0 =A0 =A0 =A0=3D udp_sysctl_mem,
> =A0 =A0 =A0 =A0.sysctl_wmem =A0 =A0 =A0 =3D &sysctl_udp_wmem_min,
> =A0 =A0 =A0 =A0.sysctl_rmem =A0 =A0 =A0 =3D &sysctl_udp_rmem_min,
> =A0 =A0 =A0 =A0.obj_size =A0 =A0 =A0 =A0 =A0=3D sizeof(struct udp_sock),
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index d1fb63f..0762e68 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1959,6 +1959,7 @@ static int tcp_v6_init_sock(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0struct inet_connection_sock *icsk =3D inet_csk(sk);
> =A0 =A0 =A0 =A0struct tcp_sock *tp =3D tcp_sk(sk);
> + =A0 =A0 =A0 struct kmem_cgroup *sg;
>
> =A0 =A0 =A0 =A0skb_queue_head_init(&tp->out_of_order_queue);
> =A0 =A0 =A0 =A0tcp_init_xmit_timers(sk);
> @@ -2012,7 +2013,12 @@ static int tcp_v6_init_sock(struct sock *sk)
> =A0 =A0 =A0 =A0sk->sk_rcvbuf =3D sysctl_tcp_rmem[1];
>
> =A0 =A0 =A0 =A0local_bh_disable();
> - =A0 =A0 =A0 percpu_counter_inc(&tcp_sockets_allocated);
> + =A0 =A0 =A0 percpu_counter_inc(sk_sockets_allocated(sk));
> +#ifdef CONFIG_CGROUP_KMEM
> + =A0 =A0 =A0 for (sg =3D sk->sk_cgrp->parent; sg; sg =3D sg->parent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_counter_dec(sg_sockets_allocated(sk-=
>sk_prot, sg));
> +#endif
> +
> =A0 =A0 =A0 =A0local_bh_enable();
>
> =A0 =A0 =A0 =A0return 0;
> @@ -2221,11 +2227,11 @@ struct proto tcpv6_prot =3D {
> =A0 =A0 =A0 =A0.unhash =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D inet_unhash,
> =A0 =A0 =A0 =A0.get_port =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D inet_csk_get_por=
t,
> =A0 =A0 =A0 =A0.enter_memory_pressure =A0=3D tcp_enter_memory_pressure,
> - =A0 =A0 =A0 .sockets_allocated =A0 =A0 =A0=3D &tcp_sockets_allocated,
> - =A0 =A0 =A0 .memory_allocated =A0 =A0 =A0 =3D &tcp_memory_allocated,
> - =A0 =A0 =A0 .memory_pressure =A0 =A0 =A0 =A0=3D &tcp_memory_pressure,
> + =A0 =A0 =A0 .sockets_allocated =A0 =A0 =A0=3D sockets_allocated_tcp,
> + =A0 =A0 =A0 .memory_allocated =A0 =A0 =A0 =3D memory_allocated_tcp,
> + =A0 =A0 =A0 .memory_pressure =A0 =A0 =A0 =A0=3D memory_pressure_tcp,
> =A0 =A0 =A0 =A0.orphan_count =A0 =A0 =A0 =A0 =A0 =3D &tcp_orphan_count,
> - =A0 =A0 =A0 .sysctl_mem =A0 =A0 =A0 =A0 =A0 =A0 =3D sysctl_tcp_mem,
> + =A0 =A0 =A0 .prot_mem =A0 =A0 =A0 =A0 =A0 =A0 =A0 =3D tcp_sysctl_mem,
> =A0 =A0 =A0 =A0.sysctl_wmem =A0 =A0 =A0 =A0 =A0 =A0=3D sysctl_tcp_wmem,
> =A0 =A0 =A0 =A0.sysctl_rmem =A0 =A0 =A0 =A0 =A0 =A0=3D sysctl_tcp_rmem,
> =A0 =A0 =A0 =A0.max_header =A0 =A0 =A0 =A0 =A0 =A0 =3D MAX_TCP_HEADER,
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 29213b5..ef4b5b3 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -1465,8 +1465,8 @@ struct proto udpv6_prot =3D {
> =A0 =A0 =A0 =A0.unhash =A0 =A0 =A0 =A0 =A0 =A0=3D udp_lib_unhash,
> =A0 =A0 =A0 =A0.rehash =A0 =A0 =A0 =A0 =A0 =A0=3D udp_v6_rehash,
> =A0 =A0 =A0 =A0.get_port =A0 =A0 =A0 =A0 =A0=3D udp_v6_get_port,
> - =A0 =A0 =A0 .memory_allocated =A0=3D &udp_memory_allocated,
> - =A0 =A0 =A0 .sysctl_mem =A0 =A0 =A0 =A0=3D sysctl_udp_mem,
> + =A0 =A0 =A0 .memory_allocated =A0=3D memory_allocated_udp,
> + =A0 =A0 =A0 .prot_mem =A0 =A0 =A0 =A0 =A0=3D udp_sysctl_mem,
> =A0 =A0 =A0 =A0.sysctl_wmem =A0 =A0 =A0 =3D &sysctl_udp_wmem_min,
> =A0 =A0 =A0 =A0.sysctl_rmem =A0 =A0 =A0 =3D &sysctl_udp_rmem_min,
> =A0 =A0 =A0 =A0.obj_size =A0 =A0 =A0 =A0 =A0=3D sizeof(struct udp6_sock),
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 836aa63..1b0300d 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -119,11 +119,30 @@ static int sctp_memory_pressure;
> =A0static atomic_long_t sctp_memory_allocated;
> =A0struct percpu_counter sctp_sockets_allocated;
>
> +static long *sctp_sysctl_mem(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return sysctl_sctp_mem;
> +}
> +
> =A0static void sctp_enter_memory_pressure(struct sock *sk)
> =A0{
> =A0 =A0 =A0 =A0sctp_memory_pressure =3D 1;
> =A0}
>
> +static int *memory_pressure_sctp(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &sctp_memory_pressure;
> +}
> +
> +static atomic_long_t *memory_allocated_sctp(struct kmem_cgroup *sg)
> +{
> + =A0 =A0 =A0 return &sctp_memory_allocated;
> +}
> +
> +static struct percpu_counter *sockets_allocated_sctp(struct kmem_cgroup =
*sg)
> +{
> + =A0 =A0 =A0 return &sctp_sockets_allocated;
> +}
>
> =A0/* Get the sndbuf space available at the time on the association. =A0*=
/
> =A0static inline int sctp_wspace(struct sctp_association *asoc)
> @@ -6831,13 +6850,13 @@ struct proto sctp_prot =3D {
> =A0 =A0 =A0 =A0.unhash =A0 =A0 =A0=3D =A0sctp_unhash,
> =A0 =A0 =A0 =A0.get_port =A0 =A0=3D =A0sctp_get_port,
> =A0 =A0 =A0 =A0.obj_size =A0 =A0=3D =A0sizeof(struct sctp_sock),
> - =A0 =A0 =A0 .sysctl_mem =A0=3D =A0sysctl_sctp_mem,
> + =A0 =A0 =A0 .prot_mem =A0 =A0=3D =A0sctp_sysctl_mem,
> =A0 =A0 =A0 =A0.sysctl_rmem =3D =A0sysctl_sctp_rmem,
> =A0 =A0 =A0 =A0.sysctl_wmem =3D =A0sysctl_sctp_wmem,
> - =A0 =A0 =A0 .memory_pressure =3D &sctp_memory_pressure,
> + =A0 =A0 =A0 .memory_pressure =3D memory_pressure_sctp,
> =A0 =A0 =A0 =A0.enter_memory_pressure =3D sctp_enter_memory_pressure,
> - =A0 =A0 =A0 .memory_allocated =3D &sctp_memory_allocated,
> - =A0 =A0 =A0 .sockets_allocated =3D &sctp_sockets_allocated,
> + =A0 =A0 =A0 .memory_allocated =3D memory_allocated_sctp,
> + =A0 =A0 =A0 .sockets_allocated =3D sockets_allocated_sctp,
> =A0};
>
> =A0#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> @@ -6863,12 +6882,12 @@ struct proto sctpv6_prot =3D {
> =A0 =A0 =A0 =A0.unhash =A0 =A0 =A0 =A0 =3D sctp_unhash,
> =A0 =A0 =A0 =A0.get_port =A0 =A0 =A0 =3D sctp_get_port,
> =A0 =A0 =A0 =A0.obj_size =A0 =A0 =A0 =3D sizeof(struct sctp6_sock),
> - =A0 =A0 =A0 .sysctl_mem =A0 =A0 =3D sysctl_sctp_mem,
> + =A0 =A0 =A0 .prot_mem =A0 =A0 =A0 =3D sctp_sysctl_mem,
> =A0 =A0 =A0 =A0.sysctl_rmem =A0 =A0=3D sysctl_sctp_rmem,
> =A0 =A0 =A0 =A0.sysctl_wmem =A0 =A0=3D sysctl_sctp_wmem,
> - =A0 =A0 =A0 .memory_pressure =3D &sctp_memory_pressure,
> + =A0 =A0 =A0 .memory_pressure =3D memory_pressure_sctp,
> =A0 =A0 =A0 =A0.enter_memory_pressure =3D sctp_enter_memory_pressure,
> - =A0 =A0 =A0 .memory_allocated =3D &sctp_memory_allocated,
> - =A0 =A0 =A0 .sockets_allocated =3D &sctp_sockets_allocated,
> + =A0 =A0 =A0 .memory_allocated =3D memory_allocated_sctp,
> + =A0 =A0 =A0 .sockets_allocated =3D sockets_allocated_sctp,
> =A0};
> =A0#endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
> --
> 1.7.6
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
