Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 688548E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 22:07:44 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id j30so7887556wre.16
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 19:07:44 -0800 (PST)
Received: from mail-40133.protonmail.ch (mail-40133.protonmail.ch. [185.70.40.133])
        by mx.google.com with ESMTPS id s82si17523173wmf.82.2019.01.13.19.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 19:07:42 -0800 (PST)
Date: Mon, 14 Jan 2019 03:07:31 +0000
From: Esme <esploit@protonmail.ch>
Reply-To: Esme <esploit@protonmail.ch>
Subject: Re: [PATCH v2] rbtree: fix the red root
Message-ID: <8v11ZOLyufY7NLAHDFApGwXOO_wGjVHtsbw1eiZ__YvI9EZCDe_4FNmlp0E-39lnzGQHhHAczQ6Q6lQPzVU2V6krtkblM8IFwIXPHZCuqGE=@protonmail.ch>
In-Reply-To: <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
 <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
 <CANN689G0zbk7sMbQ+p9NQGQ=NWq-Q0mQOOjeFkLp19YrTfgcLg@mail.gmail.com>
 <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
 <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Sunday, January 13, 2019 9:33 PM, Qian Cai <cai@lca.pw> wrote:

> On 1/13/19 9:20 PM, David Lechner wrote:
>
> > On 1/11/19 8:58 PM, Michel Lespinasse wrote:
> >
> > > On Fri, Jan 11, 2019 at 3:47 PM David Lechner david@lechnology.com wr=
ote:
> > >
> > > > On 1/11/19 2:58 PM, Qian Cai wrote:
> > > >
> > > > > A GPF was reported,
> > > > > kasan: CONFIG_KASAN_INLINE enabled
> > > > > kasan: GPF could be caused by NULL-ptr deref or user memory acces=
s
> > > > > general protection fault: 0000 [#1] SMP KASAN
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 kasan_die_=
handler.cold.22+0x11/0x31
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 notifier_c=
all_chain+0x17b/0x390
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 atomic_not=
ifier_call_chain+0xa7/0x1b0
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 notify_die=
+0x1be/0x2e0
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do_general=
_protection+0x13e/0x330
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 general_pr=
otection+0x1e/0x30
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 rb_insert_=
color+0x189/0x1480
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 create_obj=
ect+0x785/0xca0
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 kmemleak_a=
lloc+0x2f/0x50
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 kmem_cache=
_alloc+0x1b9/0x3c0
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 getname_fl=
ags+0xdb/0x5d0
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 getname+0x=
1e/0x20
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do_sys_ope=
n+0x3a1/0x7d0
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 __x64_sys_=
open+0x7e/0xc0
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do_syscall=
_64+0x1b3/0x820
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 entry_SYSC=
ALL_64_after_hwframe+0x49/0xbe
> > > > > It turned out,
> > > > > gparent =3D rb_red_parent(parent);
> > > > > tmp =3D gparent->rb_right; <-- GPF was triggered here.
> > > > > Apparently, "gparent" is NULL which indicates "parent" is rbtree'=
s root
> > > > > which is red. Otherwise, it will be treated properly a few lines =
above.
> > > > > /*
> > > > > =C2=A0=C2=A0 * If there is a black parent, we are done.
> > > > > =C2=A0=C2=A0 * Otherwise, take some corrective action as,
> > > > > =C2=A0=C2=A0 * per 4), we don't want a red root or two
> > > > > =C2=A0=C2=A0 * consecutive red nodes.
> > > > > =C2=A0=C2=A0 */
> > > > > if(rb_is_black(parent))
> > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 break;
> > > > > Hence, it violates the rule #1 (the root can't be red) and need a=
 fix
> > > > > up, and also add a regression test for it. This looks like was
> > > > > introduced by 6d58452dc06 where it no longer always paint the roo=
t as
> > > > > black.
> > > > >
> > > > > Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color(=
) only
> > > > > when necessary)
> > > > > Reported-by: Esme esploit@protonmail.ch
> > > > > Tested-by: Joey Pabalinas joeypabalinas@gmail.com
> > > > > Signed-off-by: Qian Cai cai@lca.pw
> > > > >
> > > > > -----------------------------------------------------------------=
---------------------------------------------------------------------------=
-------------------------------------------------------------------------
> > > >
> > > > Tested-by: David Lechner david@lechnology.com
> > > > FWIW, this fixed the following crash for me:
> > > > Unable to handle kernel NULL pointer dereference at virtual address=
 00000004
> > >
> > > Just to clarify, do you have a way to reproduce this crash without th=
e fix ?
> >
> > I am starting to suspect that my crash was caused by some new code
> > in the drm-misc-next tree that might be causing a memory corruption.
> > It threw me off that the stack trace didn't contain anything related
> > to drm.
> > See: https://patchwork.freedesktop.org/patch/276719/
>
> It may be useful for those who could reproduce this issue to turn on thos=
e
> memory corruption debug options to narrow down a bit.
>
> CONFIG_DEBUG_PAGEALLOC=3Dy
> CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=3Dy
> CONFIG_KASAN=3Dy
> CONFIG_KASAN_GENERIC=3Dy
> CONFIG_SLUB_DEBUG_ON=3Dy

I have been on SLAB, I configured SLAB DEBUG with a fresh pull from github.=
 Linux syzkaller 5.0.0-rc2 #9 SMP Sun Jan 13 21:57:40 EST 2019 x86_64
...

In an effort to get a different stack into the kernel, I felt that nothing =
works better than fork bomb? :)

Let me know if that helps.

root@syzkaller:~# gcc -o test3 test3.c
root@syzkaller:~# while : ; do ./test3 & done
[1] 5671
[2] 5672
[3] 5673
[4] 5675
[5] 5677
[6] 5693
[7] 5699
[8] 5701
[9] 5741
[  128.063843] INFO: trying to register non-static key.
[  128.064903] the code is fine but needs lockdep annotation.
[  128.066010] turning off the locking correctness validator.
[  128.067120] CPU: 0 PID: 5719 Comm: modprobe Not tainted 5.0.0-rc2 #9
[  128.068420] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.11.1-1ubuntu1 04/01/2014
[  128.070236] Call Trace:
[  128.070763]  dump_stack+0x104/0x174
[  128.071467]  register_lock_class+0x598/0x5a0
[  128.072326]  __lock_acquire+0x84/0x16d0
[  128.073090]  ? find_held_lock+0x35/0xa0
[  128.073876]  lock_acquire+0xe7/0x200
[  128.074599]  ? acct_collect+0xd9/0x250
[  128.075352]  _raw_spin_lock_irq+0x49/0x60
[  128.076165]  ? acct_collect+0xd9/0x250
[  128.076931]  acct_collect+0xd9/0x250
[  128.077687]  do_exit+0x430/0x1370
[  128.078373]  ? task_work_run+0xb1/0x110
[  128.079158]  do_group_exit+0x79/0x130
[  128.079904]  __x64_sys_exit_group+0x1c/0x20
[  128.080751]  do_syscall_64+0x99/0x2f0
[  128.081493]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  128.082533] RIP: 0033:0x7f7f37cc7618
[  128.083317] Code: 00 00 be 3c 00 00 00 eb 19 66 0f 1f 84 00 00 00 00 00 =
48 89 d7 89 f0 0f 05 48 3d 00 f0 ff ff 77 21 f4 48 89 d7 44 89 c0 0f 05 <48=
> 3d 00 f0 ff ff 76 e0 f7 d8 64 41 89 01 eb
[  128.087116] RSP: 002b:00007ffe905975c8 EFLAGS: 00000246 ORIG_RAX: 000000=
00000000e7
[  128.088634] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00007f7f37c=
c7618
[  128.090035] RDX: 0000000000000001 RSI: 000000000000003c RDI: 00000000000=
00001
[  128.091410] RBP: 00007f7f37fa48e0 R08: 00000000000000e7 R09: fffffffffff=
fff98
[  128.092866] R10: 00007ffe90597548 R11: 0000000000000246 R12: 00007f7f37f=
a48e0
[  128.094386] R13: 00007f7f37fa9c20 R14: 0000000000000000 R15: 00000000000=
00000
[  128.130418] BUG: unable to handle kernel NULL pointer dereference at 000=
0000000000008
[  128.132110] #PF error: [normal kernel read fault]
[  128.133066] PGD 0 P4D 0
[  128.133644] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  128.134575] CPU: 0 PID: 5756 Comm: kworker/u4:6 Not tainted 5.0.0-rc2 #9
[  128.135922] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.11.1-1ubuntu1 04/01/2014
[  128.137706] RIP: 0010:rb_insert_color+0x18/0x150
[  128.138625] Code: fd c7 43 44 00 00 00 00 e9 3b ff ff ff 90 90 90 90 90 =
48 8b 07 48 85 c0 0f 84 38 01 00 00 48 8b 10 f6 c2 01 0f 85 34 01 00 00 <48=
> 8b 4a 08 49 89 d0 48 39 c1 74 4b 48 85 cc
[  128.142347] RSP: 0018:ffffc90001143a68 EFLAGS: 00010046
[  128.143448] RAX: ffff8880607e28a8 RBX: 0000000000000000 RCX: 00000000000=
00000
[  128.144884] RDX: 0000000000000000 RSI: ffffffff865eb010 RDI: ffff88805ba=
a09e8
[  128.146427] RBP: ffffc90001143ab8 R08: 0000000000000001 R09: 00000000000=
00001
[  128.147889] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000000=
00282
[  128.149375] R13: ffff88805baa09c8 R14: ffff88805baa0988 R15: ffffffff84e=
e2f50
[  128.150815] FS:  0000000000000000(0000) GS:ffff88807f800000(0000) knlGS:=
0000000000000000
[  128.152424] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  128.153638] CR2: 0000000000000008 CR3: 000000006026a000 CR4: 00000000000=
006f0
[  128.155026] Call Trace:
[  128.155536]  ? create_object+0x22d/0x2c0
[  128.156324]  kmemleak_alloc+0x2f/0x50
[  128.157062]  kmem_cache_alloc+0x1b8/0x3d0
[  128.157865]  ? __anon_vma_prepare+0x113/0x1e0
[  128.158738]  __anon_vma_prepare+0x113/0x1e0
[  128.159559]  ? __pte_alloc+0x11e/0x1e0
[  128.160300]  __handle_mm_fault+0x1f8f/0x21d0
[  128.161162]  ? touch_atime+0x5f/0x140
[  128.161917]  handle_mm_fault+0x306/0x5d0
[  128.162719]  ? handle_mm_fault+0x48/0x5d0
[  128.163598]  __get_user_pages+0x53c/0xfa0
[  128.164498]  get_user_pages_remote+0x1e8/0x350
[  128.165525]  copy_strings.isra.28+0x288/0x530
[  128.166485]  copy_strings_kernel+0x56/0x80
[  128.167335]  __do_execve_file.isra.37+0x88e/0x1020
[  128.168316]  ? __do_execve_file.isra.37+0x223/0x1020
[  128.169341]  do_execve+0x4a/0x60
[  128.170030]  call_usermodehelper_exec_async+0x1b8/0x200
[  128.171060]  ? umh_complete+0x80/0x80
[  128.171852]  ret_from_fork+0x24/0x30
[  128.172579] Modules linked in:
[  128.173296] CR2: 0000000000000008
[  128.174000] ---[ end trace 5243d337fc3ae408 ]---
[  128.174952] RIP: 0010:rb_insert_color+0x18/0x150
[  128.175899] Code: fd c7 43 44 00 00 00 00 e9 3b ff ff ff 90 90 90 90 90 =
48 8b 07 48 85 c0 0f 84 38 01 00 00 48 8b 10 f6 c2 01 0f 85 34 01 00 00 <48=
> 8b 4a 08 49 89 d0 48 39 c1 74 4b 48 85 c9
[  128.179890] RSP: 0018:ffffc90001143a68 EFLAGS: 00010046
[  128.180957] RAX: ffff8880607e28a8 RBX: 0000000000000000 RCX: 00000000000=
00000
[  128.182400] RDX: 0000000000000000 RSI: ffffffff865eb010 RDI: ffff88805ba=
a09e8
[  128.183917] RBP: ffffc90001143ab8 R08: 0000000000000001 R09: 00000000000=
00001
[  128.185373] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000000=
00282
[  128.186822] R13: ffff88805baa09c8 R14: ffff88805baa0988 R15: ffffffff84e=
e2f50
[  128.188247] FS:  0000000000000000(0000) GS:ffff88807f800000(0000) knlGS:=
0000000000000000
[  128.189875] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  128.191024] CR2: 0000000000000008 CR3: 000000006026a000 CR4: 00000000000=
006f0
[  128.192455] Kernel panic - not syncing: Fatal exception
[  129.266473] Shutting down cpus with NMI
[  129.272005] Kernel Offset: disabled
[  129.272732] Rebooting in 86400 seconds..
