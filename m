Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 393766B0006
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 11:29:04 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id r202so138380vke.1
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 08:29:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r42sor7802436uad.179.2018.03.08.08.29.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Mar 2018 08:29:02 -0800 (PST)
MIME-Version: 1.0
From: Alexander Potapenko <glider@google.com>
Date: Thu, 8 Mar 2018 17:29:00 +0100
Message-ID: <CAG_fn=VW5tfzT6cHJd+jF=t3WO6XS3HqSF_TYnKdycX_M_48vw@mail.gmail.com>
Subject: Uninitialized nodemask in do_mbind()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Dmitriy Vyukov <dvyukov@google.com>

Hi linux-mm maintainers,

the following program:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
#define _GNU_SOURCE
#include <endian.h>
#include <stdint.h>
#include <string.h>
#include <sys/syscall.h>
#include <unistd.h>

int main()
{
  syscall(__NR_mmap, 0x20000000, 0xa000, 3, 0x32, -1, 0);
  syscall(__NR_mlock, 0x20002000, 0x4000);
  syscall(__NR_munlock, 0x20003000, 0x3000);
  *(uint64_t*)0x20006000 =3D 0;
  syscall(__NR_mbind, 0x20002000, 0x4000, 1, 0x20006000, 0x3ff, 0);
  return 0;
}
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

triggers use of uninitialized memory in __mpol_equal() here:

  case MPOL_PREFERRED:
    return a->v.preferred_node =3D=3D b->v.preferred_node;
(https://elixir.bootlin.com/linux/latest/source/mm/mempolicy.c#L2108)

It is detectable with KMSAN (see the report below) or with the following pa=
tch:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d879f1d8a44a..26afdc657f32 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -279,6 +279,7 @@ static struct mempolicy *mpol_new(unsigned short
mode, unsigned short flags,
        atomic_set(&policy->refcnt, 1);
        policy->mode =3D mode;
        policy->flags =3D flags;
+       policy->v.preferred_node =3D 0xfefa;

        return policy;
 }
@@ -2124,6 +2125,8 @@ bool __mpol_equal(struct mempolicy *a, struct
mempolicy *b)
        case MPOL_INTERLEAVE:
                return !!nodes_equal(a->v.nodes, b->v.nodes);
        case MPOL_PREFERRED:
+               BUG_ON(a->v.preferred_node =3D 0xfefa);
+               BUG_ON(b->v.preferred_node =3D 0xfefa);
                return a->v.preferred_node =3D=3D b->v.preferred_node;
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

It's sufficient to zero-initialize v.preferred_node in mpol_new(), but
looks like it's required to call mpol_set_nodemask() after mpol_new(),
which didn't happen on this path (namely we skipped the "if (flags &
(MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))" condition in do_mbind()), so the
fix should be a bit more involved.

KMSAN report is as follows:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BUG: KMSAN: use of uninitialized memory in vma_merge+0x876/0x1fa0 mm/mmap.c=
:1134
CPU: 0 PID: 3510 Comm: syz-executor1 Not tainted 4.16.0-rc4+ #3858
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/=
2014
Call Trace:
 __dump_stack lib/dump_stack.c:17 [inline]
 dump_stack+0x185/0x1d0 lib/dump_stack.c:53
 kmsan_report+0x142/0x1f0 mm/kmsan/kmsan.c:1093
 __msan_warning_32+0x6c/0xb0 mm/kmsan/kmsan_instr.c:676
 vma_merge+0x876/0x1fa0 mm/mmap.c:1134
 mbind_range mm/mempolicy.c:731 [inline]
 do_mbind mm/mempolicy.c:1233 [inline]
 SYSC_mbind+0x1436/0x2200 mm/mempolicy.c:1357
 SyS_mbind+0x8a/0xb0 mm/mempolicy.c:1339
 do_syscall_64+0x2f1/0x450 arch/x86/entry/common.c:287
 entry_SYSCALL_64_after_hwframe+0x3d/0xa2
RIP: 0033:0x449099
RSP: 002b:00007fd01b907c68 EFLAGS: 00000246 ORIG_RAX: 00000000000000ed
RAX: ffffffffffffffda RBX: 00007fd01b9086cc RCX: 0000000000449099
RDX: 0000000000000001 RSI: 0000000000004000 RDI: 0000000020002000
RBP: 000000000071bea0 R08: 00000000000003ff R09: 0000000000000000
R10: 0000000020006000 R11: 0000000000000246 R12: 00000000ffffffff
R13: 0000000000005b20 R14: 00000000006ebbc0 R15: 00007fd01b908700
origin:
 kmsan_save_stack_with_flags mm/kmsan/kmsan.c:303 [inline]
 kmsan_internal_poison_shadow+0xb8/0x1b0 mm/kmsan/kmsan.c:213
 kmsan_kmalloc+0x94/0x100 mm/kmsan/kmsan.c:339
 kmem_cache_alloc+0xa5b/0xc60 mm/slub.c:2756
 mpol_new+0x35f/0x550 mm/mempolicy.c:276
 do_mbind mm/mempolicy.c:1190 [inline]
 SYSC_mbind+0x6bc/0x2200 mm/mempolicy.c:1357
 SyS_mbind+0x8a/0xb0 mm/mempolicy.c:1339
 do_syscall_64+0x2f1/0x450 arch/x86/entry/common.c:287
 entry_SYSCALL_64_after_hwframe+0x3d/0xa2
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

WBR,
Alexander


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
