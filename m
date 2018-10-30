Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFEE56B04B2
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 21:01:44 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id c7so2695414vsd.23
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 18:01:44 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id f22si3292006vsg.194.2018.10.29.18.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 18:01:42 -0700 (PDT)
Message-ID: <50e780fba8f2af412e1962823cf759f7dff8b40d.camel@surriel.com>
Subject: Re: [PATCH] mm: handle no memcg case in memcg_kmem_charge() properly
From: Rik van Riel <riel@surriel.com>
Date: Mon, 29 Oct 2018 21:01:36 -0400
In-Reply-To: <CALvZod7tZd6t7d9o8Mj88211McpUH0oANFqESStt7G94-PBbaQ@mail.gmail.com>
References: <20181029215123.17830-1-guro@fb.com>
	 <CALvZod7tZd6t7d9o8Mj88211McpUH0oANFqESStt7G94-PBbaQ@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-xKxK4bAoXaiSFgDdPwZp"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>
Cc: Linux MM <linux-mm@kvack.org>, efault@gmx.de, LKML <linux-kernel@vger.kernel.org>, Kernel-team@fb.com, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>


--=-xKxK4bAoXaiSFgDdPwZp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2018-10-29 at 17:50 -0700, Shakeel Butt wrote:
> On Mon, Oct 29, 2018 at 2:52 PM Roman Gushchin <guro@fb.com> wrote:
> >=20
> > Mike Galbraith reported a regression caused by the commit
> > 9b6f7e163cd0
> > ("mm: rework memcg kernel stack accounting") on a system with
> > "cgroup_disable=3Dmemory" boot option: the system panics with the
> > following stack trace:
> >=20
> >   [0.928542] BUG: unable to handle kernel NULL pointer dereference
> > at 00000000000000f8
> >   [0.929317] PGD 0 P4D 0
> >   [0.929573] Oops: 0002 [#1] PREEMPT SMP PTI
> >   [0.929984] CPU: 0 PID: 1 Comm: systemd Not tainted 4.19.0-
> > preempt+ #410
> >   [0.930637] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> > BIOS ?-20180531_142017-buildhw-08.phx2.fed4
> >   [0.931862] RIP: 0010:page_counter_try_charge+0x22/0xc0
> >   [0.932376] Code: 41 5d c3 c3 0f 1f 40 00 0f 1f 44 00 00 48 85 ff
> > 0f 84 a7 00 00 00 41 56 48 89 f8 49 89 fe 49
> >   [0.934283] RSP: 0018:ffffacf68031fcb8 EFLAGS: 00010202
> >   [0.934826] RAX: 00000000000000f8 RBX: 0000000000000000 RCX:
> > 0000000000000000
> >   [0.935558] RDX: ffffacf68031fd08 RSI: 0000000000000020 RDI:
> > 00000000000000f8
> >   [0.936288] RBP: 0000000000000001 R08: 8000000000000063 R09:
> > ffff99ff7cd37a40
> >   [0.937021] R10: ffffacf68031fed0 R11: 0000000000200000 R12:
> > 0000000000000020
> >   [0.937749] R13: ffffacf68031fd08 R14: 00000000000000f8 R15:
> > ffff99ff7da1ec60
> >   [0.938486] FS:  00007fc2140bb280(0000) GS:ffff99ff7da00000(0000)
> > knlGS:0000000000000000
> >   [0.939311] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >   [0.939905] CR2: 00000000000000f8 CR3: 0000000012dc8002 CR4:
> > 0000000000760ef0
> >   [0.940638] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> > 0000000000000000
> >   [0.941366] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
> > 0000000000000400
> >   [0.942110] PKRU: 55555554
> >   [0.942412] Call Trace:
> >   [0.942673]  try_charge+0xcb/0x780
> >   [0.943031]  memcg_kmem_charge_memcg+0x28/0x80
> >   [0.943486]  ? __vmalloc_node_range+0x1e4/0x280
> >   [0.943971]  memcg_kmem_charge+0x8b/0x1d0
> >   [0.944396]  copy_process.part.41+0x1ca/0x2070
> >   [0.944853]  ? get_acl+0x1a/0x120
> >   [0.945200]  ? shmem_tmpfile+0x90/0x90
> >   [0.945596]  _do_fork+0xd7/0x3d0
> >   [0.945934]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> >   [0.946421]  do_syscall_64+0x5a/0x180
> >   [0.946798]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >=20
> > The problem occurs because get_mem_cgroup_from_current() returns
> > the NULL pointer if memory controller is disabled. Let's check
> > if this is a case at the beginning of memcg_kmem_charge() and
> > just return 0 if mem_cgroup_disabled() returns true. This is how
> > we handle this case in many other places in the memory controller
> > code.
> >=20
> > Fixes: 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
> > Reported-by: Mike Galbraith <efault@gmx.de>
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > ---
> >  mm/memcontrol.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 54920cbc46bf..6e1469b80cb7 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2593,7 +2593,7 @@ int memcg_kmem_charge(struct page *page,
> > gfp_t gfp, int order)
> >         struct mem_cgroup *memcg;
> >         int ret =3D 0;
> >=20
> > -       if (memcg_kmem_bypass())
> > +       if (mem_cgroup_disabled() || memcg_kmem_bypass())
> >                 return 0;
> >=20
>=20
> Why not check memcg_kmem_enabled() before calling memcg_kmem_charge()
> in memcg_charge_kernel_stack()?

Check Roman's backtrace again. The function
memcg_charge_kernel_stack() is not in it.

That is why it is generally better to check
in the called function, rather than add a
check to every call site (and maybe miss one
or two).

Acked-by: Rik van Riel <riel@surriel.com>
--=20
All Rights Reversed.

--=-xKxK4bAoXaiSFgDdPwZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlvXrXAACgkQznnekoTE
3oPXGQf7BoaA5KT3SOfI7bfRPLMsQfHJDgulsQqAV5NbT3IuZKy4+b0PKPPK3bNd
EM4rFRS4akHfZCyI8PbW81cq6Jo4O+pR4pl1RjE9PG5WGFGWwwmOQcFZ9QthbX0v
mKLG1ObiT70qWVcgA7ImYwV0lYlGakDywj6mXPdQxk/ppVTMRBdjTIodwwodOm4C
Q5qUwRPP8Z9XG+frqymGsg0AiU7uPO0U7P/AUFeGmaXx+kOi7QIjsmt8M0gakGqy
4kJFDiQjSsarDICcsbj2f4/ep1wxvwg0JyUT4xDedxn++v+2kOOUwo9XKZ/YxNvW
djzengEvPZsHWshdeuLdB0LAJWbiVw==
=od5N
-----END PGP SIGNATURE-----

--=-xKxK4bAoXaiSFgDdPwZp--
