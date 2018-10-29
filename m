Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 603DB6B04AD
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 17:52:17 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id k14-v6so3488672ybd.2
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:52:17 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w73-v6si13218147yww.453.2018.10.29.14.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 14:52:16 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm: handle no memcg case in memcg_kmem_charge() properly
Date: Mon, 29 Oct 2018 21:51:55 +0000
Message-ID: <20181029215123.17830-1-guro@fb.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Mike Galbraith <efault@gmx.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Roman
 Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew
 Morton <akpm@linux-foundation.org>

Mike Galbraith reported a regression caused by the commit 9b6f7e163cd0
("mm: rework memcg kernel stack accounting") on a system with
"cgroup_disable=3Dmemory" boot option: the system panics with the
following stack trace:

  [0.928542] BUG: unable to handle kernel NULL pointer dereference at 00000=
000000000f8
  [0.929317] PGD 0 P4D 0
  [0.929573] Oops: 0002 [#1] PREEMPT SMP PTI
  [0.929984] CPU: 0 PID: 1 Comm: systemd Not tainted 4.19.0-preempt+ #410
  [0.930637] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS ?-=
20180531_142017-buildhw-08.phx2.fed4
  [0.931862] RIP: 0010:page_counter_try_charge+0x22/0xc0
  [0.932376] Code: 41 5d c3 c3 0f 1f 40 00 0f 1f 44 00 00 48 85 ff 0f 84 a7=
 00 00 00 41 56 48 89 f8 49 89 fe 49
  [0.934283] RSP: 0018:ffffacf68031fcb8 EFLAGS: 00010202
  [0.934826] RAX: 00000000000000f8 RBX: 0000000000000000 RCX: 0000000000000=
000
  [0.935558] RDX: ffffacf68031fd08 RSI: 0000000000000020 RDI: 0000000000000=
0f8
  [0.936288] RBP: 0000000000000001 R08: 8000000000000063 R09: ffff99ff7cd37=
a40
  [0.937021] R10: ffffacf68031fed0 R11: 0000000000200000 R12: 0000000000000=
020
  [0.937749] R13: ffffacf68031fd08 R14: 00000000000000f8 R15: ffff99ff7da1e=
c60
  [0.938486] FS:  00007fc2140bb280(0000) GS:ffff99ff7da00000(0000) knlGS:00=
00000000000000
  [0.939311] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [0.939905] CR2: 00000000000000f8 CR3: 0000000012dc8002 CR4: 0000000000760=
ef0
  [0.940638] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000=
000
  [0.941366] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000=
400
  [0.942110] PKRU: 55555554
  [0.942412] Call Trace:
  [0.942673]  try_charge+0xcb/0x780
  [0.943031]  memcg_kmem_charge_memcg+0x28/0x80
  [0.943486]  ? __vmalloc_node_range+0x1e4/0x280
  [0.943971]  memcg_kmem_charge+0x8b/0x1d0
  [0.944396]  copy_process.part.41+0x1ca/0x2070
  [0.944853]  ? get_acl+0x1a/0x120
  [0.945200]  ? shmem_tmpfile+0x90/0x90
  [0.945596]  _do_fork+0xd7/0x3d0
  [0.945934]  ? trace_hardirqs_off_thunk+0x1a/0x1c
  [0.946421]  do_syscall_64+0x5a/0x180
  [0.946798]  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The problem occurs because get_mem_cgroup_from_current() returns
the NULL pointer if memory controller is disabled. Let's check
if this is a case at the beginning of memcg_kmem_charge() and
just return 0 if mem_cgroup_disabled() returns true. This is how
we handle this case in many other places in the memory controller
code.

Fixes: 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
Reported-by: Mike Galbraith <efault@gmx.de>
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 54920cbc46bf..6e1469b80cb7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2593,7 +2593,7 @@ int memcg_kmem_charge(struct page *page, gfp_t gfp, i=
nt order)
 	struct mem_cgroup *memcg;
 	int ret =3D 0;
=20
-	if (memcg_kmem_bypass())
+	if (mem_cgroup_disabled() || memcg_kmem_bypass())
 		return 0;
=20
 	memcg =3D get_mem_cgroup_from_current();
--=20
2.17.2
