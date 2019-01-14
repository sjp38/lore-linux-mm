Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 471BC8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 01:23:28 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id m4so2122902wrr.4
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 22:23:28 -0800 (PST)
Received: from mail-40130.protonmail.ch (mail-40130.protonmail.ch. [185.70.40.130])
        by mx.google.com with ESMTPS id i6si43106398wro.117.2019.01.13.22.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 22:23:25 -0800 (PST)
Date: Mon, 14 Jan 2019 06:23:17 +0000
From: Esme <esploit@protonmail.ch>
Reply-To: Esme <esploit@protonmail.ch>
Subject: Re: [PATCH v2] rbtree: fix the red root
Message-ID: <GBn2paWQ0Uy0COgTeJsgmC18Faw0x_yNIog8gpuC5TJ4kCn_IUH1EnHJW0mQeo3Qy5MMcpMzyw9Yer3lxyWYgtk5TJx8I3sJK4oVlIJh38s=@protonmail.ch>
In-Reply-To: <ad591828-76e8-324b-6ab8-dc87e4390f64@interlog.com>
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
 <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
 <CANN689G0zbk7sMbQ+p9NQGQ=NWq-Q0mQOOjeFkLp19YrTfgcLg@mail.gmail.com>
 <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
 <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
 <8v11ZOLyufY7NLAHDFApGwXOO_wGjVHtsbw1eiZ__YvI9EZCDe_4FNmlp0E-39lnzGQHhHAczQ6Q6lQPzVU2V6krtkblM8IFwIXPHZCuqGE=@protonmail.ch>
 <c6265fc0-4089-9d1a-ba7c-b267b847747e@interlog.com>
 <UKsodHRZU8smIdO2MHHL4Yzde_YB4iWX43TaHI1uY2tMo4nii4ucbaw4XC31XIY-Pe4oEovjF62qbkeMsIMTrvT1TdCCP4Fs_fxciAzXYVc=@protonmail.ch>
 <ad591828-76e8-324b-6ab8-dc87e4390f64@interlog.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "dgilbert@interlog.com" <dgilbert@interlog.com>
Cc: Qian Cai <cai@lca.pw>, David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Sunday, January 13, 2019 11:52 PM, Douglas Gilbert <dgilbert@interlog.co=
m> wrote:

> On 2019-01-13 10:59 p.m., Esme wrote:
>
> > =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Origina=
l Message =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=
=90
> > On Sunday, January 13, 2019 10:52 PM, Douglas Gilbert dgilbert@interlog=
.com wrote:
> >
> > > On 2019-01-13 10:07 p.m., Esme wrote:
> > >
> > > > =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Ori=
ginal Message =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=
=E2=80=90
> > > > On Sunday, January 13, 2019 9:33 PM, Qian Cai cai@lca.pw wrote:
> > > >
> > > > > On 1/13/19 9:20 PM, David Lechner wrote:
> > > > >
> > > > > > On 1/11/19 8:58 PM, Michel Lespinasse wrote:
> > > > > >
> > > > > > > On Fri, Jan 11, 2019 at 3:47 PM David Lechner david@lechnolog=
y.com wrote:
> > > > > > >
> > > > > > > > On 1/11/19 2:58 PM, Qian Cai wrote:
> > > > > > > >
> > > > > > > > > A GPF was reported,
> > > > > > > > > kasan: CONFIG_KASAN_INLINE enabled
> > > > > > > > > kasan: GPF could be caused by NULL-ptr deref or user memo=
ry access
> > > > > > > > > general protection fault: 0000 [#1] SMP KASAN
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ka=
san_die_handler.cold.22+0x11/0x31
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 no=
tifier_call_chain+0x17b/0x390
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 at=
omic_notifier_call_chain+0xa7/0x1b0
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 no=
tify_die+0x1be/0x2e0
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do=
_general_protection+0x13e/0x330
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ge=
neral_protection+0x1e/0x30
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 rb=
_insert_color+0x189/0x1480
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 cr=
eate_object+0x785/0xca0
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 km=
emleak_alloc+0x2f/0x50
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 km=
em_cache_alloc+0x1b9/0x3c0
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ge=
tname_flags+0xdb/0x5d0
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ge=
tname+0x1e/0x20
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do=
_sys_open+0x3a1/0x7d0
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 __=
x64_sys_open+0x7e/0xc0
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 do=
_syscall_64+0x1b3/0x820
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 en=
try_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > > > > > > It turned out,
> > > > > > > > > gparent =3D rb_red_parent(parent);
> > > > > > > > > tmp =3D gparent->rb_right; <-- GPF was triggered here.
> > > > > > > > > Apparently, "gparent" is NULL which indicates "parent" is=
 rbtree's root
> > > > > > > > > which is red. Otherwise, it will be treated properly a fe=
w lines above.
> > > > > > > > > /*
> > > > > > > > > =C2=A0=C2=A0 * If there is a black parent, we are done.
> > > > > > > > > =C2=A0=C2=A0 * Otherwise, take some corrective action as,
> > > > > > > > > =C2=A0=C2=A0 * per 4), we don't want a red root or two
> > > > > > > > > =C2=A0=C2=A0 * consecutive red nodes.
> > > > > > > > > =C2=A0=C2=A0 */
> > > > > > > > > if(rb_is_black(parent))
> > > > > > > > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 break;
> > > > > > > > > Hence, it violates the rule #1 (the root can't be red) an=
d need a fix
> > > > > > > > > up, and also add a regression test for it. This looks lik=
e was
> > > > > > > > > introduced by 6d58452dc06 where it no longer always paint=
 the root as
> > > > > > > > > black.
> > > > > > > > > Fixes: 6d58452dc06 (rbtree: adjust root color in rb_inser=
t_color() only
> > > > > > > > > when necessary)
> > > > > > > > > Reported-by: Esme esploit@protonmail.ch
> > > > > > > > > Tested-by: Joey Pabalinas joeypabalinas@gmail.com
> > > > > > > > > Signed-off-by: Qian Cai cai@lca.pw
> > > > > > > >
> > > > > > > > Tested-by: David Lechner david@lechnology.com
> > > > > > > > FWIW, this fixed the following crash for me:
> > > > > > > > Unable to handle kernel NULL pointer dereference at virtual=
 address 00000004
> > > > > > >
> > > > > > > Just to clarify, do you have a way to reproduce this crash wi=
thout the fix ?
> > > > > >
> > > > > > I am starting to suspect that my crash was caused by some new c=
ode
> > > > > > in the drm-misc-next tree that might be causing a memory corrup=
tion.
> > > > > > It threw me off that the stack trace didn't contain anything re=
lated
> > > > > > to drm.
> > > > > > See: https://patchwork.freedesktop.org/patch/276719/
> > > > >
> > > > > It may be useful for those who could reproduce this issue to turn=
 on those
> > > > > memory corruption debug options to narrow down a bit.
> > > > > CONFIG_DEBUG_PAGEALLOC=3Dy
> > > > > CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=3Dy
> > > > > CONFIG_KASAN=3Dy
> > > > > CONFIG_KASAN_GENERIC=3Dy
> > > > > CONFIG_SLUB_DEBUG_ON=3Dy
> > > >
> > > > I have been on SLAB, I configured SLAB DEBUG with a fresh pull from=
 github. Linux syzkaller 5.0.0-rc2 #9 SMP Sun Jan 13 21:57:40 EST 2019 x86_=
64
> > > > ...
> > > > In an effort to get a different stack into the kernel, I felt that =
nothing works better than fork bomb? :)
> > > > Let me know if that helps.
> > > > root@syzkaller:~# gcc -o test3 test3.c
> > > > root@syzkaller:~# while : ; do ./test3 & done
> > >
> > > And is test3 the same multi-threaded program that enters the kernel v=
ia
> > > /dev/sg0 and then calls SCSI_IOCTL_SEND_COMMAND which goes to the SCS=
I
> > > mid-level and thence to the block layer?
> > > And please remind me, does it also fail on lk 4.20.2 ?
> > > Doug Gilbert
> >
> > Yes, the same C repro from the earlier thread. It was a 4.20.0 kernel w=
here it was first detected. I can move to 4.20.2 and see if that changes an=
ything.
>
> Hi,
> I don't think there is any need to check lk 4.20.2 (as it would
> be very surprising if it didn't also have this "feature").
>
> More interesting might be: has "test3" been run on lk 4.19 or
> any earlier kernel?
>
> Doug Gilbert

I did not yet verify the previous branches but did tune out kmemleak (CONFI=
G_DEBUG_MEMLEAK no longer set) as it seemed a bit obtrusive in this matter,=
 this is what I see now (note redzone?).
/Esme

  114.826116] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[  114.828121] BUG kmalloc-64 (Tainted: G        W        ): Padding overwr=
itten. 0x000000006913c65d-0x000000006e410492
[  114.830551] ------------------------------------------------------------=
-----------------
[  114.830551]
[  114.832755] INFO: Slab 0x0000000054f47c55 objects=3D19 used=3D19 fp=3D0x=
          (null) flags=3D0x1fffc0000010200
[  114.835063] CPU: 0 PID: 6310 Comm: x Tainted: G    B   W         5.0.0-r=
c2 #15
[  114.836829] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.11.1-1ubuntu1 04/01/2014
[  114.838847] Call Trace:
[  114.839497]  dump_stack+0x1d8/0x2c6
[  114.840274]  ? dump_stack_print_info.cold.1+0x20/0x20
[  114.841402]  slab_err+0xab/0xcf
[  114.842103]  ? __asan_report_load1_noabort+0x14/0x20
[  114.843244]  ? memchr_inv+0x2c1/0x330
[  114.844059]  slab_pad_check.part.50.cold.87+0x27/0x81
[  114.845123]  ? __request_module+0x434/0xede
[  114.846012]  check_slab+0xb0/0xf0
[  114.846715]  alloc_debug_processing+0x58/0x170
[  114.847648]  ___slab_alloc+0x63e/0x750
[  114.848439]  ? __request_module+0x434/0xede
[  114.849368]  ? trace_hardirqs_on+0x2f0/0x2f0
[  114.850299]  ? check_same_owner+0x340/0x340
[  114.851212]  ? vsnprintf+0x207/0x1b50
[  114.852015]  ? __request_module+0x434/0xede
[  114.852960]  __slab_alloc+0x68/0xc0
[  114.853715]  ? __slab_alloc+0x68/0xc0
[  114.854540]  kmem_cache_alloc_trace+0x2aa/0x330
[  114.855527]  ? __request_module+0x434/0xede
[  114.856416]  __request_module+0x434/0xede
[  114.857271]  ? free_modprobe_argv+0xa0/0xa0
[  114.858159]  ? kasan_check_write+0x14/0x20
[  114.859025]  ? __init_rwsem+0x1cc/0x2a0
[  114.859840]  ? spin_dump.cold.3+0xe7/0xe7
[  114.860690]  ? deactivate_slab.isra.70+0x589/0x5c0
[  114.861699]  ? __sanitizer_cov_trace_cmp4+0x16/0x20
[  114.862801]  ? map_id_range_down+0x1ee/0x430
[  114.863744]  ? __put_user_ns+0x60/0x60
[  114.864571]  ? set_track+0x74/0x120
[  114.865373]  ? init_object+0x79/0x80
[  114.866153]  ? lockdep_init_map+0x105/0x590
[  114.867074]  ? lockdep_init_map+0x105/0x590
[  114.867996]  ? kasan_check_write+0x14/0x20
[  114.868873]  ? inode_init_always+0xae1/0xd80
[  114.869787]  ? lock_acquire+0x1ed/0x510
[  114.870617]  ? new_inode_pseudo+0xcc/0x1a0
[  114.871517]  ? lock_downgrade+0x8f0/0x8f0
[  114.872471]  ? kasan_check_read+0x11/0x20
[  114.873357]  ? do_raw_spin_unlock+0xa7/0x330
[  114.874272]  ? do_raw_spin_trylock+0x270/0x270
[  114.875209]  ? _raw_spin_unlock+0x22/0x30
[  114.876040]  ? prune_icache_sb+0x1c0/0x1c0
[  114.876908]  ? __kasan_slab_free+0x13f/0x170
[  114.877807]  ? __sanitizer_cov_trace_const_cmp4+0x16/0x20
[  114.878995]  ? __sock_create+0x23f/0x930
[  114.879840]  __sock_create+0x6e2/0x930
[  114.880647]  ? kernel_sock_ip_overhead+0x570/0x570
[  114.881675]  ? __kasan_slab_free+0x13f/0x170
[  114.882624]  ? putname+0xf2/0x130
[  114.883347]  ? kasan_slab_free+0xe/0x10
[  114.884198]  ? kmem_cache_free+0x2aa/0x330
[  114.885058]  ? putname+0xf7/0x130
[  114.885763]  __sys_socket+0x106/0x260
[  114.886553]  ? move_addr_to_kernel+0x70/0x70
[  114.887506]  ? entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  114.888633]  ? __bpf_trace_preemptirq_template+0x30/0x30
[  114.889743]  __x64_sys_socket+0x73/0xb0
[  114.890548]  do_syscall_64+0x1b3/0x810
[  114.891357]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
[  114.892487]  ? syscall_return_slowpath+0x5e0/0x5e0
[  114.893531]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  114.894497]  ? trace_hardirqs_on_caller+0x2e0/0x2e0
[  114.895505]  ? prepare_exit_to_usermode+0x3b0/0x3b0
[  114.896516]  ? prepare_exit_to_usermode+0x291/0x3b0
[  114.897567]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  114.898564]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  114.899670] RIP: 0033:0x7fa123f52229
[  114.900433] Code: 00 f3 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 48 =
89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48=
> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 3f 4c 28
[  114.904409] RSP: 002b:00007ffcd04e76f8 EFLAGS: 00000213 ORIG_RAX: 000000=
0000000029
[  114.905990] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007fa123f=
52229
[  114.907464] RDX: 0000000000000088 RSI: 0000000000000800 RDI: 00000000000=
0000c
[  114.908913] RBP: 00007ffcd04e7710 R08: 0000000000000000 R09: 00000000000=
0001a
[  114.910348] R10: 000000000000ffff R11: 0000000000000213 R12: 0000560c05d=
ffe30
[  114.911858] R13: 00007ffcd04e7830 R14: 0000000000000000 R15: 00000000000=
00000
[  114.913404] Padding 000000006913c65d: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.915437] Padding 000000002d53f25c: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.917390] Padding 0000000078f7d621: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.919402] Padding 0000000063547658: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.921414] Padding 000000001a301f4e: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.923364] Padding 0000000046589d24: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.925340] Padding 0000000008fb13da: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.927291] Padding 00000000ae5cc298: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.929239] Padding 00000000d49cc239: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.931177] Padding 00000000d66ad6f5: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.933110] Padding 00000000069ad671: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.934986] Padding 00000000ffaf648c: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.936895] Padding 00000000c96d1b58: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.938848] Padding 00000000768e4920: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.940965] Padding 000000000d06b43c: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.942890] Padding 00000000af5ae9fa: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.944790] Padding 000000006b526f1e: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.946727] Padding 000000009c8dffe3: 00 00 00 00 00 00 00 00 00 00 00 0=
0 00 00 00 00  ................
[  114.948709] FIX kmalloc-64: Restoring 0x000000006913c65d-0x000000006e410=
492=3D0x5a
[  114.948709]
[  114.950620] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[  114.952450] BUG kmalloc-64 (Tainted: G    B   W        ): Redzone overwr=
itten
[  114.953901] ------------------------------------------------------------=
-----------------
[  114.953901]
[  114.955955] INFO: 0x0000000023852d36-0x000000003d7a667f. First byte 0x0 =
instead of 0xbb
[  114.957662] INFO: Slab 0x0000000054f47c55 objects=3D19 used=3D19 fp=3D0x=
          (null) flags=3D0x1fffc0000010200
[  114.959669] INFO: Object 0x00000000a07d3417 @offset=3D3336 fp=3D0x      =
    (null)
[  114.959669]
[  114.961491] Redzone 0000000023852d36: 00 00 00 00 00 00 00 00           =
               ........
[  114.963588] Object 00000000a07d3417: 00 00 00 00 00 00 00 00 00 00 00 00=
 00 00 00 00  ................
[  114.965520] Object 000000002b232d06: 00 00 00 00 00 00 00 00 00 00 00 00=
 00 00 00 00  ................
[  114.967533] Object 000000000b434529: 00 00 00 00 00 00 00 00 00 00 00 00=
 00 00 00 00  ................
[  114.969480] Object 0000000098adb243: 00 00 00 00 00 00 00 00 00 00 00 00=
 00 00 00 00  ................
[  114.971505] Redzone 0000000026bb1e28: 00 00 00 00 00 00 00 00           =
               ........
[  114.973502] Padding 00000000e8bc385c: 00 00 00 00 00 00 00 00           =
               ........
[  114.975687] CPU: 0 PID: 6310 Comm: x Tainted: G    B   W         5.0.0-r=
c2 #15
[  114.977357] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.11.1-1ubuntu1 04/01/2014
[  114.979208] Call Trace:
[  114.979755]  dump_stack+0x1d8/0x2c6
[  114.980541]  ? dump_stack_print_info.cold.1+0x20/0x20
[  114.981691]  ? print_section+0x41/0x50
[  114.982565]  print_trailer+0x172/0x17b
[  114.983380]  check_bytes_and_report.cold.86+0x40/0x70
[  114.984695]  check_object+0x16c/0x290
[  114.985547]  ? __request_module+0x434/0xede
[  114.986511]  alloc_debug_processing+0xda/0x170
[  114.987497]  ___slab_alloc+0x63e/0x750
[  114.988291]  ? __request_module+0x434/0xede
[  114.989177]  ? trace_hardirqs_on+0x2f0/0x2f0
[  114.990069]  ? check_same_owner+0x340/0x340
[  114.991005]  ? vsnprintf+0x207/0x1b50
[  114.991786]  ? __request_module+0x434/0xede
[  114.992710]  __slab_alloc+0x68/0xc0
[  114.993440]  ? __slab_alloc+0x68/0xc0
[  114.994216]  kmem_cache_alloc_trace+0x2aa/0x330
[  114.995278]  ? __request_module+0x434/0xede
[  114.996253]  __request_module+0x434/0xede
[  114.997262]  ? free_modprobe_argv+0xa0/0xa0
[  114.998160]  ? kasan_check_write+0x14/0x20
[  114.999033]  ? __init_rwsem+0x1cc/0x2a0
[  114.999842]  ? spin_dump.cold.3+0xe7/0xe7
[  115.000684]  ? deactivate_slab.isra.70+0x589/0x5c0
[  115.001739]  ? __sanitizer_cov_trace_cmp4+0x16/0x20
[  115.002836]  ? map_id_range_down+0x1ee/0x430
[  115.003804]  ? __put_user_ns+0x60/0x60
[  115.004630]  ? set_track+0x74/0x120
[  115.005395]  ? init_object+0x79/0x80
[  115.006185]  ? lockdep_init_map+0x105/0x590
[  115.007082]  ? lockdep_init_map+0x105/0x590
[  115.007957]  ? kasan_check_write+0x14/0x20
[  115.008916]  ? inode_init_always+0xae1/0xd80
[  115.009820]  ? lock_acquire+0x1ed/0x510
[  115.010645]  ? new_inode_pseudo+0xcc/0x1a0
[  115.011513]  ? lock_downgrade+0x8f0/0x8f0
[  115.012421]  ? kasan_check_read+0x11/0x20
[  115.013294]  ? do_raw_spin_unlock+0xa7/0x330
[  115.014229]  ? do_raw_spin_trylock+0x270/0x270
[  115.015180]  ? _raw_spin_unlock+0x22/0x30
[  115.016034]  ? prune_icache_sb+0x1c0/0x1c0
[  115.016918]  ? __kasan_slab_free+0x13f/0x170
[  115.017831]  ? __sanitizer_cov_trace_const_cmp4+0x16/0x20
[  115.019010]  ? __sock_create+0x23f/0x930
[  115.019871]  __sock_create+0x6e2/0x930
[  115.020673]  ? kernel_sock_ip_overhead+0x570/0x570
[  115.021703]  ? __kasan_slab_free+0x13f/0x170
[  115.022677]  ? putname+0xf2/0x130
[  115.023383]  ? kasan_slab_free+0xe/0x10
[  115.024193]  ? kmem_cache_free+0x2aa/0x330
[  115.025062]  ? putname+0xf7/0x130
[  115.025771]  __sys_socket+0x106/0x260
[  115.026549]  ? move_addr_to_kernel+0x70/0x70
[  115.027462]  ? entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  115.028560]  ? __bpf_trace_preemptirq_template+0x30/0x30
[  115.029707]  __x64_sys_socket+0x73/0xb0
[  115.030523]  do_syscall_64+0x1b3/0x810
[  115.031319]  ? entry_SYSCALL_64_after_hwframe+0x3e/0xbe
[  115.032451]  ? syscall_return_slowpath+0x5e0/0x5e0
[  115.033472]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  115.034471]  ? trace_hardirqs_on_caller+0x2e0/0x2e0
[  115.035503]  ? prepare_exit_to_usermode+0x3b0/0x3b0
[  115.036613]  ? prepare_exit_to_usermode+0x291/0x3b0
[  115.037647]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[  115.038645]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  115.039678] RIP: 0033:0x7fa123f52229
[  115.040423] Code: 00 f3 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 48 =
89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48=
> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 3f 4c 2b
[  115.044451] RSP: 002b:00007ffcd04e76f8 EFLAGS: 00000213 ORIG_RAX: 000000=
0000000029
[  115.046010] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007fa123f=
52229
[  115.047462] RDX: 0000000000000088 RSI: 0000000000000800 RDI: 00000000000=
0000c
[  115.048938] RBP: 00007ffcd04e7710 R08: 0000000000000000 R09: 00000000000=
0001a
[  115.050379] R10: 000000000000ffff R11: 0000000000000213 R12: 0000560c05d=
ffe30
[  115.051849] R13: 00007ffcd04e7830 R14: 0000000000000000 R15: 00000000000=
00000
[  115.053422] FIX kmalloc-64: Restoring 0x0000000023852d36-0x000000003d7a6=
67f=3D0xbb
[  115.053422]
[  115.055233] FIX kmalloc-64: Marking all objects used
[12] 6325
[  115.075174] hrtimer: interrupt took 169862 ns
[13] 6362
