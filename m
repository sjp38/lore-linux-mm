Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0039E6B02A8
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 11:56:14 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id r132-v6so9064716ywg.21
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 08:56:14 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u62-v6si14469431ybb.380.2018.10.30.08.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 08:56:13 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: handle no memcg case in memcg_kmem_charge() properly
Date: Tue, 30 Oct 2018 15:55:39 +0000
Message-ID: <20181030155532.GA17612@tower.DHCP.thefacebook.com>
References: <20181029215123.17830-1-guro@fb.com>
 <20181030061249.GS32673@dhcp22.suse.cz>
In-Reply-To: <20181030061249.GS32673@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <65515EED1E43F74C8166BE9C00A911E0@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike Galbraith <efault@gmx.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>

On Tue, Oct 30, 2018 at 07:12:49AM +0100, Michal Hocko wrote:
> On Mon 29-10-18 21:51:55, Roman Gushchin wrote:
> > Mike Galbraith reported a regression caused by the commit 9b6f7e163cd0
> > ("mm: rework memcg kernel stack accounting") on a system with
> > "cgroup_disable=3Dmemory" boot option: the system panics with the
> > following stack trace:
> >=20
> >   [0.928542] BUG: unable to handle kernel NULL pointer dereference at 0=
0000000000000f8
> >   [0.929317] PGD 0 P4D 0
> >   [0.929573] Oops: 0002 [#1] PREEMPT SMP PTI
> >   [0.929984] CPU: 0 PID: 1 Comm: systemd Not tainted 4.19.0-preempt+ #4=
10
> >   [0.930637] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S ?-20180531_142017-buildhw-08.phx2.fed4
> >   [0.931862] RIP: 0010:page_counter_try_charge+0x22/0xc0
> >   [0.932376] Code: 41 5d c3 c3 0f 1f 40 00 0f 1f 44 00 00 48 85 ff 0f 8=
4 a7 00 00 00 41 56 48 89 f8 49 89 fe 49
> >   [0.934283] RSP: 0018:ffffacf68031fcb8 EFLAGS: 00010202
> >   [0.934826] RAX: 00000000000000f8 RBX: 0000000000000000 RCX: 000000000=
0000000
> >   [0.935558] RDX: ffffacf68031fd08 RSI: 0000000000000020 RDI: 000000000=
00000f8
> >   [0.936288] RBP: 0000000000000001 R08: 8000000000000063 R09: ffff99ff7=
cd37a40
> >   [0.937021] R10: ffffacf68031fed0 R11: 0000000000200000 R12: 000000000=
0000020
> >   [0.937749] R13: ffffacf68031fd08 R14: 00000000000000f8 R15: ffff99ff7=
da1ec60
> >   [0.938486] FS:  00007fc2140bb280(0000) GS:ffff99ff7da00000(0000) knlG=
S:0000000000000000
> >   [0.939311] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >   [0.939905] CR2: 00000000000000f8 CR3: 0000000012dc8002 CR4: 000000000=
0760ef0
> >   [0.940638] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
> >   [0.941366] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 000000000=
0000400
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
>=20
> I tend to agree with Shakeel that consistency with the other caller
> would be less confusing.

I totally agree that consistency is a thing here (and everywhere),
however using memcg_kmem_enabled() here is not consistent at all.
memcg_kmem_enabled() is tight to the slab allocation accounting,
but here we have a different type of allocation: we actually charge
an area preallocated using vmalloc.

> I would split the function to __memcg_kmem_charge
> without any checks and call it from __alloc_pages_nodemask and add the
> check to memcg_kmem_charge. This would be less confusing I guess.
> Something for a follow up clean up though.

Sure. Alternatively, we can check the pointer returned by
get_mem_cgroup_from_current() in memcg_kmem_charge().

Anyway, let's postpone this clean up a bit, now the main goal
is to fix the panic.

> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

--

Andrew, can you, please, pull this patch to 4.20-rc1 or -rc2?
It has been acked by Rik and Michal, and tested by Mike.

Thanks!
