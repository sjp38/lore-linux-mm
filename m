Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40A2F6B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 11:09:31 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j2so4372894qtl.1
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 08:09:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s22si219211qke.261.2018.03.19.08.09.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Mar 2018 08:09:29 -0700 (PDT)
Date: Mon, 19 Mar 2018 17:09:28 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: get_user_pages returning 0 (was Re: kernel BUG at
 drivers/vhost/vhost.c:LINE!)
Message-ID: <20180319161406-mutt-send-email-mst@kernel.org>
References: <001a11427716098c150567bcd12f@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <001a11427716098c150567bcd12f@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com>
Cc: jasowang@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com, virtualization@lists.linux-foundation.org, David Sterba <dsterba@suse.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, aarcange@redhat.com, linux-mm@kvack.org

Hello!
The following code triggered by syzbot=20

        r =3D get_user_pages_fast(log, 1, 1, &page);
        if (r < 0)
                return r;
        BUG_ON(r !=3D 1);

Just looking at get_user_pages_fast's documentation this seems
impossible - it is supposed to only ever return # of pages
pinned or errno.

However, poking at code, I see at least one path that might cause this:

                        ret =3D faultin_page(tsk, vma, start, &foll_flags,
                                        nonblocking);
                        switch (ret) {
                        case 0:
                                goto retry;
                        case -EFAULT:
                        case -ENOMEM:
                        case -EHWPOISON:
                                return i ? i : ret;
                        case -EBUSY:
                                return i;

which originally comes from:

commit 53a7706d5ed8f1a53ba062b318773160cc476dde
Author: Michel Lespinasse <walken@google.com>
Date:   Thu Jan 13 15:46:14 2011 -0800

    mlock: do not hold mmap_sem for extended periods of time
   =20
    __get_user_pages gets a new 'nonblocking' parameter to signal that the
    caller is prepared to re-acquire mmap_sem and retry the operation if
    needed.  This is used to split off long operations if they are going to
    block on a disk transfer, or when we detect contention on the mmap_sem.
   =20
    [akpm@linux-foundation.org: remove ref to rwsem_is_contended()]
    Signed-off-by: Michel Lespinasse <walken@google.com>
    Cc: Hugh Dickins <hughd@google.com>
    Cc: Rik van Riel <riel@redhat.com>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Nick Piggin <npiggin@kernel.dk>
    Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
    Cc: Ingo Molnar <mingo@elte.hu>
    Cc: "H. Peter Anvin" <hpa@zytor.com>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: David Howells <dhowells@redhat.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

I started looking into this, if anyone has any feedback meanwhile,
that would be appreciated.

In particular I don't really see why would this trigger
on commit 8f5fd927c3a7576d57248a2d7a0861c3f2795973:

Merge: 8757ae2 093e037
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Fri Mar 16 13:37:42 2018 -0700

    Merge tag 'for-4.16-rc5-tag' of git://git.kernel.org/pub/scm/linux/kern=
el/git/kdave/linux

is btrfs used on these systems?


syzbot output below:

------------------------

Hello,

syzbot hit the following crash on upstream commit
8f5fd927c3a7576d57248a2d7a0861c3f2795973 (Fri Mar 16 20:37:42 2018 +0000)
Merge tag 'for-4.16-rc5-tag' of
git://git.kernel.org/pub/scm/linux/kernel/git/kdave/linux

So far this crash happened 2 times on upstream.
C reproducer is attached.
syzkaller reproducer is attached.
Raw console output is attached.
compiler: gcc (GCC) 7.1.1 20170620
=2Econfig is attached.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com
It will help syzbot understand when the bug is fixed. See footer for
details.
If you forward the report, please keep this part and the footer.

audit: type=3D1400 audit(1521377060.016:6): avc:  denied  { map } for
pid=3D4210 comm=3D"bash" path=3D"/bin/bash" dev=3D"sda1" ino=3D1457
scontext=3Dunconfined_u:system_r:insmod_t:s0-s0:c0.c1023
tcontext=3Dsystem_u:object_r:file_t:s0 tclass=3Dfile permissive=3D1
audit: type=3D1400 audit(1521377077.866:7): avc:  denied  { map } for
pid=3D4228 comm=3D"syzkaller050160" path=3D"/root/syzkaller050160487" dev=
=3D"sda1"
ino=3D16481 scontext=3Dunconfined_u:system_r:insmod_t:s0-s0:c0.c1023
tcontext=3Dunconfined_u:object_r:user_home_t:s0 tclass=3Dfile permissive=3D1
------------[ cut here ]------------
kernel BUG at drivers/vhost/vhost.c:1655!
invalid opcode: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 1 PID: 4228 Comm: syzkaller050160 Not tainted 4.16.0-rc5+ #357
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
Google 01/01/2011
RIP: 0010:set_bit_to_user drivers/vhost/vhost.c:1655 [inline]
RIP: 0010:log_write+0x3ca/0x490 drivers/vhost/vhost.c:1679
RSP: 0018:ffff8801b0fa77b0 EFLAGS: 00010293
RAX: ffff8801af534240 RBX: dffffc0000000000 RCX: ffffffff8443f50a
RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8801af535618
RBP: ffff8801b0fa78f0 R08: 0000000000000040 R09: 0000000000000001
R10: ffff8801b0fa76d0 R11: 0000000000000002 R12: 0001ffffffffffff
R13: ffffed00361f4f09 R14: ffff8801b0fa78c8 R15: ffff8801b0fa7848
FS:  00000000007df880(0000) GS:ffff8801db300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020d7c000 CR3: 00000001d3e5b005 CR4: 00000000001606e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 vhost_update_used_flags+0x379/0x480 drivers/vhost/vhost.c:1726
 vhost_vq_init_access+0xca/0x540 drivers/vhost/vhost.c:1766
 vhost_net_set_backend drivers/vhost/net.c:1166 [inline]
 vhost_net_ioctl+0xee0/0x1920 drivers/vhost/net.c:1320
 vfs_ioctl fs/ioctl.c:46 [inline]
 do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:686
 SYSC_ioctl fs/ioctl.c:701 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:692
 do_syscall_64+0x281/0x940 arch/x86/entry/common.c:287
 entry_SYSCALL_64_after_hwframe+0x42/0xb7
RIP: 0033:0x43ff09
RSP: 002b:00007ffe94d57fc8 EFLAGS: 00000207 ORIG_RAX: 0000000000000010
RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 000000000043ff09
RDX: 0000000020d7c000 RSI: 000000004008af30 RDI: 0000000000000003
RBP: 00000000006ca018 R08: 00000000004002c8 R09: 00000000004002c8
R10: 00000000004002c8 R11: 0000000000000207 R12: 0000000000401830
R13: 00000000004018c0 R14: 0000000000000000 R15: 0000000000000000
Code: 5e 41 5f 5d c3 31 c0 eb a6 e8 b3 22 2d fd 4c 89 ef e8 5b bb 4d fd 4c
89 f8 48 c1 e8 03 c6 04 18 f8 e9 3a ff ff ff e8 96 22 2d fd <0f> 0b e8 8f 22
2d fd 4d 8d 6c 24 ff e9 89 fe ff ff e8 80 22 2d
RIP: set_bit_to_user drivers/vhost/vhost.c:1655 [inline] RSP:
ffff8801b0fa77b0
RIP: log_write+0x3ca/0x490 drivers/vhost/vhost.c:1679 RSP: ffff8801b0fa77b0
---[ end trace 867ce9e35847b153 ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled
Rebooting in 86400 seconds..



[....] Starting enhanced syslogd: rsyslogd[   15.400171] audit: type=3D1400=
 audit(1521377057.354:5): avc:  denied  { syslog } for  pid=3D4071 comm=3D"=
rsyslogd" capability=3D34  scontext=3Dsystem_u:system_r:kernel_t:s0 tcontex=
t=3Dsystem_u:system_r:kernel_t:s0 tclass=3Dcapability2 permissive=3D1
=1B[?25l=1B[?1c=1B7=1B[1G[=1B[32m ok =1B[39;49m=1B8=1B[?25h=1B[?0c.
Starting mcstransd:=20
[....] Starting periodic command scheduler: cron=1B[?25l=1B[?1c=1B7=1B[1G[=
=1B[32m ok =1B[39;49m=1B8=1B[?25h=1B[?0c.
[....] Starting OpenBSD Secure Shell server: sshd=1B[?25l=1B[?1c=1B7=1B[1G[=
=1B[32m ok =1B[39;49m=1B8=1B[?25h=1B[?0c.
[....] Starting file context maintaining daemon: restorecond=1B[?25l=1B[?1c=
=1B7=1B[1G[=1B[32m ok =1B[39;49m=1B8=1B[?25h=1B[?0c.

Debian GNU/Linux 7 syzkaller ttyS0

syzkaller login: [   18.063012] audit: type=3D1400 audit(1521377060.016:6):=
 avc:  denied  { map } for  pid=3D4210 comm=3D"bash" path=3D"/bin/bash" dev=
=3D"sda1" ino=3D1457 scontext=3Dunconfined_u:system_r:insmod_t:s0-s0:c0.c10=
23 tcontext=3Dsystem_u:object_r:file_t:s0 tclass=3Dfile permissive=3D1
Warning: Permanently added '10.128.0.48' (ECDSA) to the list of known hosts.
executing program
[   35.912387] audit: type=3D1400 audit(1521377077.866:7): avc:  denied  { =
map } for  pid=3D4228 comm=3D"syzkaller050160" path=3D"/root/syzkaller05016=
0487" dev=3D"sda1" ino=3D16481 scontext=3Dunconfined_u:system_r:insmod_t:s0=
-s0:c0.c1023 tcontext=3Dunconfined_u:object_r:user_home_t:s0 tclass=3Dfile =
permissive=3D1
[   35.918516] ------------[ cut here ]------------
[   35.943043] kernel BUG at drivers/vhost/vhost.c:1655!
[   35.948327] invalid opcode: 0000 [#1] SMP KASAN
[   35.952967] Dumping ftrace buffer:
[   35.956472]    (ftrace buffer empty)
[   35.960152] Modules linked in:
[   35.963316] CPU: 1 PID: 4228 Comm: syzkaller050160 Not tainted 4.16.0-rc=
5+ #357
[   35.970729] Hardware name: Google Google Compute Engine/Google Compute E=
ngine, BIOS Google 01/01/2011
[   35.980057] RIP: 0010:log_write+0x3ca/0x490
[   35.984344] RSP: 0018:ffff8801b0fa77b0 EFLAGS: 00010293
[   35.989677] RAX: ffff8801af534240 RBX: dffffc0000000000 RCX: ffffffff844=
3f50a
[   35.996918] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8801af5=
35618
[   36.004155] RBP: ffff8801b0fa78f0 R08: 0000000000000040 R09: 00000000000=
00001
[   36.011392] R10: ffff8801b0fa76d0 R11: 0000000000000002 R12: 0001fffffff=
fffff
[   36.018632] R13: ffffed00361f4f09 R14: ffff8801b0fa78c8 R15: ffff8801b0f=
a7848
[   36.025871] FS:  00000000007df880(0000) GS:ffff8801db300000(0000) knlGS:=
0000000000000000
[   36.034065] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   36.039915] CR2: 0000000020d7c000 CR3: 00000001d3e5b005 CR4: 00000000001=
606e0
[   36.047156] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[   36.054393] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[   36.061631] Call Trace:
[   36.064192]  ? copy_overflow+0x30/0x30
[   36.068047]  ? translate_desc+0x2bd/0x590
[   36.072170]  vhost_update_used_flags+0x379/0x480
[   36.076895]  vhost_vq_init_access+0xca/0x540
[   36.081276]  vhost_net_ioctl+0xee0/0x1920
[   36.085397]  ? vhost_net_stop_vq+0xf0/0xf0
[   36.089603]  ? avc_ss_reset+0x110/0x110
[   36.093547]  ? __handle_mm_fault+0x5ba/0x38c0
[   36.098012]  ? __pmd_alloc+0x4e0/0x4e0
[   36.101869]  ? trace_hardirqs_off+0x10/0x10
[   36.106161]  ? __fd_install+0x25f/0x740
[   36.110106]  ? find_held_lock+0x35/0x1d0
[   36.114145]  ? check_same_owner+0x320/0x320
[   36.118438]  ? rcu_note_context_switch+0x710/0x710
[   36.123334]  ? __do_page_fault+0x5f7/0xc90
[   36.127540]  ? vhost_net_stop_vq+0xf0/0xf0
[   36.131742]  do_vfs_ioctl+0x1b1/0x1520
[   36.135601]  ? ioctl_preallocate+0x2b0/0x2b0
[   36.139979]  ? selinux_capable+0x40/0x40
[   36.144009]  ? up_read+0x1a/0x40
[   36.147349]  ? security_file_ioctl+0x7d/0xb0
[   36.151727]  ? security_file_ioctl+0x89/0xb0
[   36.156104]  SyS_ioctl+0x8f/0xc0
[   36.159436]  ? do_vfs_ioctl+0x1520/0x1520
[   36.163557]  do_syscall_64+0x281/0x940
[   36.167412]  ? __do_page_fault+0xc90/0xc90
[   36.171615]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[   36.176338]  ? syscall_return_slowpath+0x550/0x550
[   36.181233]  ? syscall_return_slowpath+0x2ac/0x550
[   36.186128]  ? prepare_exit_to_usermode+0x350/0x350
[   36.191113]  ? retint_user+0x18/0x18
[   36.194799]  ? trace_hardirqs_off_thunk+0x1a/0x1c
[   36.199613]  entry_SYSCALL_64_after_hwframe+0x42/0xb7
[   36.204772] RIP: 0033:0x43ff09
[   36.207934] RSP: 002b:00007ffe94d57fc8 EFLAGS: 00000207 ORIG_RAX: 000000=
0000000010
[   36.215608] RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 00000000004=
3ff09
[   36.222847] RDX: 0000000020d7c000 RSI: 000000004008af30 RDI: 00000000000=
00003
[   36.230085] RBP: 00000000006ca018 R08: 00000000004002c8 R09: 00000000004=
002c8
[   36.237324] R10: 00000000004002c8 R11: 0000000000000207 R12: 00000000004=
01830
[   36.244563] R13: 00000000004018c0 R14: 0000000000000000 R15: 00000000000=
00000
[   36.251810] Code: 5e 41 5f 5d c3 31 c0 eb a6 e8 b3 22 2d fd 4c 89 ef e8 =
5b bb 4d fd 4c 89 f8 48 c1 e8 03 c6 04 18 f8 e9 3a ff ff ff e8 96 22 2d fd =
<0f> 0b e8 8f 22 2d fd 4d 8d 6c 24 ff e9 89 fe ff ff e8 80 22 2d=20
[   36.270877] RIP: log_write+0x3ca/0x490 RSP: ffff8801b0fa77b0
[   36.276691] ---[ end trace 867ce9e35847b153 ]---
[   36.281425] Kernel panic - not syncing: Fatal exception
[   36.287129] Dumping ftrace buffer:
[   36.290635]    (ftrace buffer empty)
[   36.294312] Kernel Offset: disabled
[   36.297909] Rebooting in 86400 seconds..

# See https://goo.gl/kgGztJ for information about syzkaller reproducers.
#{Threaded:false Collide:false Repeat:false Procs:1 Sandbox: Fault:false Fa=
ultCall:-1 FaultNth:0 EnableTun:false UseTmpDir:false HandleSegv:false Wait=
Repeat:false Debug:false Repro:false}
r0 =3D openat$vnet(0xffffffffffffff9c, &(0x7f00002ac000)=3D'/dev/vhost-net\=
x00', 0x2, 0x0)
ioctl$int_in(r0, 0x40000000af01, &(0x7f0000000040))
r1 =3D openat$audio(0xffffffffffffff9c, &(0x7f0000000180)=3D'/dev/audio\x00=
', 0x0, 0x0)
close(r1)
socket$packet(0x11, 0x3, 0x300)
ioctl$VHOST_SET_VRING_ADDR(r0, 0x4028af11, &(0x7f0000000500)=3D{0x0, 0x1, &=
(0x7f0000000740)=3D""/142, &(0x7f00000003c0)=3D""/69, &(0x7f0000000140)=3D"=
"/14, 0xfffffffffffffffc})
ioctl$VHOST_SET_FEATURES(r0, 0x4008af00, &(0x7f0000000640)=3D0x200000000)
write$vnet(r0, &(0x7f0000000580)=3D{0x1, {&(0x7f00000001c0)=3D""/219, 0x34c=
, &(0x7f0000000480)=3D""/98, 0xffffffffffffffff, 0x2}}, 0x68)
ioctl$VHOST_NET_SET_BACKEND(r0, 0x4008af30, &(0x7f0000d7c000)=3D{0x0, r1})

// autogenerated by syzkaller (http://github.com/google/syzkaller)

#define _GNU_SOURCE
#include <endian.h>
#include <stdint.h>
#include <string.h>
#include <sys/syscall.h>
#include <unistd.h>

uint64_t r[2] =3D {0xffffffffffffffff, 0xffffffffffffffff};
void loop()
{
  long res;
  memcpy((void*)0x202ac000, "/dev/vhost-net", 15);
  res =3D syscall(__NR_openat, 0xffffffffffffff9c, 0x202ac000, 2, 0);
  if (res !=3D -1)
    r[0] =3D res;
  *(uint64_t*)0x20000040 =3D 0;
  syscall(__NR_ioctl, r[0], 0x40000000af01, 0x20000040);
  memcpy((void*)0x20000180, "/dev/audio", 11);
  res =3D syscall(__NR_openat, 0xffffffffffffff9c, 0x20000180, 0, 0);
  if (res !=3D -1)
    r[1] =3D res;
  syscall(__NR_close, r[1]);
  syscall(__NR_socket, 0x11, 3, 0x300);
  *(uint32_t*)0x20000500 =3D 0;
  *(uint32_t*)0x20000504 =3D 1;
  *(uint64_t*)0x20000508 =3D 0x20000740;
  *(uint64_t*)0x20000510 =3D 0x200003c0;
  *(uint64_t*)0x20000518 =3D 0x20000140;
  *(uint64_t*)0x20000520 =3D 0xfffffffffffffffc;
  syscall(__NR_ioctl, r[0], 0x4028af11, 0x20000500);
  *(uint64_t*)0x20000640 =3D 0x200000000;
  syscall(__NR_ioctl, r[0], 0x4008af00, 0x20000640);
  *(uint32_t*)0x20000580 =3D 1;
  *(uint64_t*)0x20000588 =3D 0x200001c0;
  *(uint64_t*)0x20000590 =3D 0x34c;
  *(uint64_t*)0x20000598 =3D 0x20000480;
  *(uint8_t*)0x200005a0 =3D -1;
  *(uint8_t*)0x200005a1 =3D 2;
  *(uint64_t*)0x200005a8 =3D 0;
  *(uint64_t*)0x200005b0 =3D 0;
  *(uint64_t*)0x200005b8 =3D 0;
  *(uint64_t*)0x200005c0 =3D 0;
  *(uint64_t*)0x200005c8 =3D 0;
  *(uint64_t*)0x200005d0 =3D 0;
  *(uint64_t*)0x200005d8 =3D 0;
  *(uint64_t*)0x200005e0 =3D 0;
  syscall(__NR_write, r[0], 0x20000580, 0x68);
  *(uint32_t*)0x20d7c000 =3D 0;
  *(uint32_t*)0x20d7c004 =3D r[1];
  syscall(__NR_ioctl, r[0], 0x4008af30, 0x20d7c000);
}

int main()
{
  syscall(__NR_mmap, 0x20000000, 0x1000000, 3, 0x32, -1, 0);
  loop();
  return 0;
}

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86 4.16.0-rc5 Kernel Configuration
#
=2E. skipped ...

---
This bug is generated by a dumb bot. It may contain errors.
See https://goo.gl/tpsmEJ for details.
Direct all questions to syzkaller@googlegroups.com.

syzbot will keep track of this bug report.
If you forgot to add the Reported-by tag, once the fix for this bug is
merged
into any tree, please reply to this email with:
#syz fix: exact-commit-title
If you want to test a patch for this bug, please reply with:
#syz test: git://repo/address.git branch
and provide the patch inline or as an attachment.
To mark this as a duplicate of another syzbot report, please reply with:
#syz dup: exact-subject-of-another-report
If it's a one-off invalid bug report, please reply with:
#syz invalid
Note: if the crash happens again, it will cause creation of a new bug
report.
Note: all commands must start from beginning of the line in the email body.
