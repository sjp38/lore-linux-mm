Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 224489000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 07:58:16 -0400 (EDT)
Received: by qyl38 with SMTP id 38so2484865qyl.14
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 04:58:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316051175-17780-5-git-send-email-glommer@parallels.com>
References: <1316051175-17780-1-git-send-email-glommer@parallels.com>
	<1316051175-17780-5-git-send-email-glommer@parallels.com>
Date: Wed, 28 Sep 2011 15:58:13 +0400
Message-ID: <CANaxB-wy8VDv0Wjni6UzcfBzSgNn=bZBey5f+fXHebNuek=O1A@mail.gmail.com>
Subject: Re: [PATCH v2 4/7] per-cgroup tcp buffers control
From: Andrew Wagin <avagin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

* tcp_destroy_cgroup_fill() is executed for each cgroup and
initializes some proto methods. proto_list is global and we can
initialize each proto one time. Do we need this really?

* And when a cgroup is destroyed, it cleans proto methods
(tcp_destroy_cgroup_fill), how other cgroups will work after that?

* What about proto, which is registered when cgroup mounted?

My opinion that we may initialize proto by the following way:

+#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM+       .enter_memory_pressure
=3D tcp_enter_memory_pressure_nocg,
+       .sockets_allocated      =3D sockets_allocated_tcp_nocg,
+       .memory_allocated       =3D memory_allocated_tcp_nocg,
+       .memory_pressure        =3D memory_pressure_tcp_nocg,
+#else
        .enter_memory_pressure  =3D tcp_enter_memory_pressure,
        .sockets_allocated      =3D sockets_allocated_tcp,
        .memory_allocated       =3D memory_allocated_tcp,
        .memory_pressure        =3D memory_pressure_tcp,
+#endif

It should work, because the root memory cgroup always exists.

>+int tcp_init_cgroup_fill(struct proto *prot, struct cgroup *cgrp,
>+                        struct cgroup_subsys *ss)
>+{
>+       prot->enter_memory_pressure     =3D tcp_enter_memory_pressure;
>+       prot->memory_allocated          =3D memory_allocated_tcp;
>+       prot->prot_mem                  =3D tcp_sysctl_mem;
>+       prot->sockets_allocated         =3D sockets_allocated_tcp;
>+       prot->memory_pressure           =3D memory_pressure_tcp;
>+
>+       return 0;
>+}


> +void tcp_destroy_cgroup_fill(struct proto *prot, struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_su=
bsys *ss)
> +{
> + =A0 =A0 =A0 prot->enter_memory_pressure =A0 =A0 =3D tcp_enter_memory_pr=
essure_nocg;
> + =A0 =A0 =A0 prot->memory_allocated =A0 =A0 =A0 =A0 =A0=3D memory_alloca=
ted_tcp_nocg;
> + =A0 =A0 =A0 prot->prot_mem =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D tcp_s=
ysctl_mem_nocg;
> + =A0 =A0 =A0 prot->sockets_allocated =A0 =A0 =A0 =A0 =3D sockets_allocat=
ed_tcp_nocg;
> + =A0 =A0 =A0 prot->memory_pressure =A0 =A0 =A0 =A0 =A0 =3D memory_pressu=
re_tcp_nocg;
>

>@@ -2220,12 +2220,16 @@ struct proto tcpv6_prot =3D {
>       .hash                   =3D tcp_v6_hash,
>       .unhash                 =3D inet_unhash,
>       .get_port               =3D inet_csk_get_port
> + =A0 =A0 =A0 .enter_memory_pressure =A0=3D tcp_enter_memory_pressure_noc=
g,
> + =A0 =A0 =A0 .sockets_allocated =A0 =A0 =A0=3D sockets_allocated_tcp_noc=
g,
> + =A0 =A0 =A0 .memory_allocated =A0 =A0 =A0 =3D memory_allocated_tcp_nocg=
,
> + =A0 =A0 =A0 .memory_pressure =A0 =A0 =A0 =A0=3D memory_pressure_tcp_noc=
g,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
