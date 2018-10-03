Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB6E6B026F
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 13:16:26 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id f18so1650866itk.6
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 10:16:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d188-v6sor800945itg.10.2018.10.03.10.16.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Oct 2018 10:16:22 -0700 (PDT)
MIME-Version: 1.0
References: <20180927194601.207765-1-wonderfly@google.com> <20181001152324.72a20bea@gandalf.local.home>
 <CAJmjG29Jwn_1E5zexcm8eXTG=cTWyEr1gjSfSAS2fueB_V0tfg@mail.gmail.com>
 <20181002084225.6z2b74qem3mywukx@pathway.suse.cz> <CAJmjG2-RrG5XKeW1-+rN3C=F6bZ-L3=YKhCiQ_muENDTzm_Ofg@mail.gmail.com>
 <20181002212327.7aab0b79@vmware.local.home> <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
In-Reply-To: <20181003091400.rgdjpjeaoinnrysx@pathway.suse.cz>
From: Daniel Wang <wonderfly@google.com>
Date: Wed, 3 Oct 2018 10:16:08 -0700
Message-ID: <CAJmjG2_4JFA=qL-d2Pb9umUEcPt9h13w-g40JQMbdKsZTRSZww@mail.gmail.com>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256;
	boundary="0000000000009098dd05775632c3"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: rostedt@goodmis.org, stable@vger.kernel.org, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Mel Gorman <mgorman@suse.de>, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@i-love.sakura.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, Cong Wang <xiyou.wangcong@gmail.com>, Peter Feiner <pfeiner@google.com>

--0000000000009098dd05775632c3
Content-Type: text/plain; charset="UTF-8"

On Wed, Oct 3, 2018 at 2:14 AM Petr Mladek <pmladek@suse.com> wrote:
>
> On Tue 2018-10-02 21:23:27, Steven Rostedt wrote:
> > I don't see the big deal of backporting this. The biggest complaints
> > about backports are from fixes that were added to late -rc releases
> > where the fixes didn't get much testing. This commit was added in 4.16,
> > and hasn't had any issues due to the design. Although a fix has been
> > added:
> >
> > c14376de3a1 ("printk: Wake klogd when passing console_lock owner")
>
> As I said, I am fine with backporting the console_lock owner stuff
> into the stable release.
>
> I just wonder (like Sergey) what the real problem is. The console_lock
> owner handshake is not fully reliable. It is might be good enough
> to prevent softlockup. But we should not relay on it to prevent
> a deadlock.

Yes. I myself was curious too. :)

>
> My new theory ;-)
>
> printk_safe_flush() is called in nmi_trigger_cpumask_backtrace().
> => watchdog_timer_fn() is blocked until all backtraces are printed.
>
> Now, the original report complained that the system rebooted before
> all backtraces were printed. It means that panic() was called
> on another CPU. My guess is that it is from the hardlockup detector.
> And the panic() was not able to flush the console because it was
> not able to take console_lock.
>
> IMHO, there was not a real deadlock. The console_lock owner
> handshake jsut helped to get console_lock in panic() and
> flush all messages before reboot => it is reasonable
> and acceptable fix.

I had the same speculation. Tried to capture a lockdep snippet with
CONFIG_PROVE_LOCKING turned on but didn't get anything. But
maybe I was doing it wrong.

>
> Just to be sure. Daniel, could you please send a log with
> the console_lock owner stuff backported? There we would see
> who called the panic() and why it rebooted early.

Sure. Here is one. It's a bit long but complete. I attached another log
snippet below it which is what I got when `softlockup_panic` was turned
off. The log was from the IRQ task that was flushing the printk buffer. I
will be taking a closer look at it too but in case you'll find it helpful.

lockup-test-16-2 login: [   89.277372] LoadPin: kernel-module
pinning-ignored obj="/tmp/release/hog.ko" pid=1992 cmdline="insmod
hog.ko"
[   89.280029] hog: loading out-of-tree module taints kernel.
[   89.294559] Hogging a CPU now
[   92.619688] watchdog: BUG: soft lockup - CPU#6 stuck for 3s! [hog:1993]
[   92.626490] Modules linked in: hog(O) ipt_MASQUERADE
nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 xt_addrtype nf_nat
br_netfilter ip6table_filter ip6_tables aesni_intel aes_x86_64
crypto_simd cryptd glue_helper
[   92.645567] CPU: 6 PID: 1993 Comm: hog Tainted: G           O     4.15.0+ #12
[   92.652899] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.662245] RIP: 0010:hog_thread+0x13/0x1000 [hog]
[   92.667164] RSP: 0018:ffffb489c741ff10 EFLAGS: 00000282 ORIG_RAX:
ffffffffffffff11
[   92.675139] RAX: 0000000000000011 RBX: ffff9f5c75a88900 RCX: 0000000000000000
[   92.682474] RDX: ffff9f5c8339d840 RSI: ffff9f5c833954b8 RDI: ffff9f5c833954b8
[   92.689727] RBP: ffffb489c741ff48 R08: 0000000000000030 R09: 0000000000000000
[   92.696985] R10: 00000000000003a8 R11: 0000000000000000 R12: ffff9f5c7959e080
[   92.704251] R13: ffffb489c7f2bc70 R14: 0000000000000000 R15: ffff9f5c75a88948
[   92.711498] FS:  0000000000000000(0000) GS:ffff9f5c83380000(0000)
knlGS:0000000000000000
[   92.719699] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.725556] CR2: 0000558184c9b89c CR3: 0000000499e12006 CR4: 00000000003606a0
[   92.732976] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.740231] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.747487] Call Trace:
[   92.750054]  kthread+0x120/0x160
[   92.753419]  ? 0xffffffffc030d000
[   92.756859]  ? kthread_stop+0x120/0x120
[   92.760819]  ret_from_fork+0x35/0x40
[   92.764594] Code: <eb> fe 00 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00
[   92.772656] Sending NMI from CPU 6 to CPUs 0-5,7-15:
[   92.777743] NMI backtrace for cpu 0
[   92.777746] CPU: 0 PID: 1844 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.777747] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.777755] RIP: 0010:native_queued_spin_lock_slowpath+0x18/0x1b0
[   92.777756] RSP: 0018:ffffb489c7dcbdb0 EFLAGS: 00000002
[   92.777757] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.777758] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.777759] RBP: ffffb489c7dcbde0 R08: 00000000f9f8f56c R09: 000000004c55ba96
[   92.777760] R10: 0000000084f6cd57 R11: 0000000041f66b45 R12: ffff9f5c82ca5a68
[   92.777761] R13: ffffb489c7dcbe38 R14: ffffb489c7dcbe38 R15: 0000000000000040
[   92.777762] FS:  00007f1e21116700(0000) GS:ffff9f5c83200000(0000)
knlGS:0000000000000000
[   92.777763] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.777764] CR2: 000055ada196235c CR3: 0000000edda30001 CR4: 00000000003606b0
[   92.777768] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.777769] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.777769] Call Trace:
[   92.777774]  do_raw_spin_lock+0xa0/0xb0
[   92.777778]  _raw_spin_lock_irqsave+0x20/0x30
[   92.777784]  _extract_crng+0x45/0x120
[   92.777787]  urandom_read+0xea/0x270
[   92.777793]  vfs_read+0xad/0x170
[   92.777795]  SyS_read+0x4b/0xa0
[   92.777798]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.777801]  do_syscall_64+0x63/0x1f0
[   92.777804]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.777806] RIP: 0033:0x7f1e20aec410
[   92.777807] RSP: 002b:00007ffd42a321e8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.777808] RAX: ffffffffffffffda RBX: 0000000000000040 RCX: 00007f1e20aec410
[   92.777809] RDX: 0000000000100000 RSI: 00007f1e2062f000 RDI: 0000000000000000
[   92.777810] RBP: 00007ffd42a32210 R08: ffffffffffffffff R09: 0000000000000000
[   92.777810] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.777811] R13: 00007f1e21116690 R14: 0000000000100000 R15: 00007f1e2062f000
[   92.777812] Code: 48 8b 2c 24 48 c7 00 00 00 00 00 e9 1d fe ff ff
0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85 c0 7e 1a ba 01 00 00
00 90 8b 07 <85> c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 eb ec 81
fe 00
[   92.777834] NMI backtrace for cpu 9
[   92.777836] CPU: 9 PID: 1875 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.777837] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.777840] RIP: 0010:native_queued_spin_lock_slowpath+0x18/0x1b0
[   92.777841] RSP: 0018:ffffb489c785bdb0 EFLAGS: 00000002
[   92.777842] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.777843] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.777844] RBP: ffffb489c785bde0 R08: 00000000af260603 R09: 0000000099b415a4
[   92.777844] R10: 000000006ee0b179 R11: 00000000f7237bdc R12: ffff9f5c82ca5a68
[   92.777845] R13: ffffb489c785be38 R14: ffffb489c785be38 R15: 0000000000000040
[   92.777846] FS:  00007f4b27878700(0000) GS:ffff9f5c83440000(0000)
knlGS:0000000000000000
[   92.777847] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.777848] CR2: 00005556ecb96938 CR3: 0000000edd498005 CR4: 00000000003606a0
[   92.777851] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.777852] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.777853] Call Trace:
[   92.777856]  do_raw_spin_lock+0xa0/0xb0
[   92.777859]  _raw_spin_lock_irqsave+0x20/0x30
[   92.777862]  _extract_crng+0x45/0x120
[   92.777865]  urandom_read+0xea/0x270
[   92.777868]  vfs_read+0xad/0x170
[   92.777870]  SyS_read+0x4b/0xa0
[   92.777872]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.777874]  do_syscall_64+0x63/0x1f0
[   92.777876]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.777877] RIP: 0033:0x7f4b2724e410
[   92.777878] RSP: 002b:00007fffcc371cc8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.777879] RAX: ffffffffffffffda RBX: 000000000000003d RCX: 00007f4b2724e410
[   92.777880] RDX: 0000000000100000 RSI: 00007f4b26d91000 RDI: 0000000000000000
[   92.777881] RBP: 00007fffcc371cf0 R08: ffffffffffffffff R09: 0000000000000000
[   92.777881] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.777882] R13: 00007f4b27878690 R14: 0000000000100000 R15: 00007f4b26d91000
[   92.777883] Code: 48 8b 2c 24 48 c7 00 00 00 00 00 e9 1d fe ff ff
0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85 c0 7e 1a ba 01 00 00
00 90 8b 07 <85> c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 eb ec 81
fe 00
[   92.777903] NMI backtrace for cpu 1
[   92.777904] CPU: 1 PID: 1853 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.777905] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.777907] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[   92.777908] RSP: 0018:ffffb489c7bd3db0 EFLAGS: 00000002
[   92.777909] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.777909] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.777910] RBP: ffffb489c7bd3de0 R08: 000000004de274a7 R09: 000000007bb3f38c
[   92.777911] R10: 00000000dcb5416d R11: 0000000095dfea80 R12: ffff9f5c82ca5a68
[   92.777912] R13: ffffb489c7bd3e38 R14: ffffb489c7bd3e38 R15: 0000000000000040
[   92.777913] FS:  00007fe443813700(0000) GS:ffff9f5c83240000(0000)
knlGS:0000000000000000
[   92.777913] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.777914] CR2: 00007f31139788c0 CR3: 0000000eddafa001 CR4: 00000000003606a0
[   92.777917] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.777918] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.777918] Call Trace:
[   92.777921]  do_raw_spin_lock+0xa0/0xb0
[   92.777922]  _raw_spin_lock_irqsave+0x20/0x30
[   92.777924]  _extract_crng+0x45/0x120
[   92.777926]  urandom_read+0xea/0x270
[   92.777928]  vfs_read+0xad/0x170
[   92.777930]  SyS_read+0x4b/0xa0
[   92.777931]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.777932]  do_syscall_64+0x63/0x1f0
[   92.777934]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.777935] RIP: 0033:0x7fe4431e9410
[   92.777936] RSP: 002b:00007ffe86708e88 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.777937] RAX: ffffffffffffffda RBX: 000000000000003a RCX: 00007fe4431e9410
[   92.777938] RDX: 0000000000100000 RSI: 00007fe442d2c000 RDI: 0000000000000000
[   92.777938] RBP: 00007ffe86708eb0 R08: ffffffffffffffff R09: 0000000000000000
[   92.777939] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.777940] R13: 00007fe443813690 R14: 0000000000100000 R15: 00007fe442d2c000
[   92.777940] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85
c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2
5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00
00 b9
[   92.777960] NMI backtrace for cpu 13
[   92.777962] CPU: 13 PID: 1851 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.777963] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.777966] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[   92.777967] RSP: 0018:ffffb489c7c9fdb0 EFLAGS: 00000002
[   92.777968] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.777969] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.777970] RBP: ffffb489c7c9fde0 R08: 000000002e505de7 R09: 0000000094345515
[   92.777970] R10: 00000000bde83e93 R11: 00000000764dd3c0 R12: ffff9f5c82ca5a68
[   92.777971] R13: ffffb489c7c9fe38 R14: ffffb489c7c9fe38 R15: 0000000000000040
[   92.777972] FS:  00007fc869785700(0000) GS:ffff9f5c83540000(0000)
knlGS:0000000000000000
[   92.777973] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.777974] CR2: 000000c420d93000 CR3: 0000000ef4dee004 CR4: 00000000003606a0
[   92.777977] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.777978] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.777978] Call Trace:
[   92.777982]  do_raw_spin_lock+0xa0/0xb0
[   92.777984]  _raw_spin_lock_irqsave+0x20/0x30
[   92.777987]  _extract_crng+0x45/0x120
[   92.777989]  urandom_read+0xea/0x270
[   92.777991]  vfs_read+0xad/0x170
[   92.777993]  SyS_read+0x4b/0xa0
[   92.778006]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778007]  do_syscall_64+0x63/0x1f0
[   92.778010]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778011] RIP: 0033:0x7fc86915b410
[   92.778012] RSP: 002b:00007ffc289f5578 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778013] RAX: ffffffffffffffda RBX: 0000000000000028 RCX: 00007fc86915b410
[   92.778014] RDX: 0000000000100000 RSI: 00007fc868c9e000 RDI: 0000000000000000
[   92.778015] RBP: 00007ffc289f55a0 R08: ffffffffffffffff R09: 0000000000000000
[   92.778015] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778016] R13: 00007fc869785690 R14: 0000000000100000 R15: 00007fc868c9e000
[   92.778017] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85
c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2
5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00
00 b9
[   92.778037] NMI backtrace for cpu 5
[   92.778038] CPU: 5 PID: 1865 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778039] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778041] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[   92.778041] RSP: 0018:ffffb489c791fdb0 EFLAGS: 00000002
[   92.778042] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778043] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778044] RBP: ffffb489c791fde0 R08: 00000000b5f5cc7e R09: 000000001db25a77
[   92.778044] R10: 000000000ffafde2 R11: 00000000fdf34257 R12: ffff9f5c82ca5a68
[   92.778045] R13: ffffb489c791fe38 R14: ffffb489c791fe38 R15: 0000000000000040
[   92.778046] FS:  00007f495240c700(0000) GS:ffff9f5c83340000(0000)
knlGS:0000000000000000
[   92.778047] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778048] CR2: 000000c420d8d068 CR3: 0000000edd40a004 CR4: 00000000003606a0
[   92.778051] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778052] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778052] Call Trace:
[   92.778054]  do_raw_spin_lock+0xa0/0xb0
[   92.778056]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778058]  _extract_crng+0x45/0x120
[   92.778060]  urandom_read+0xea/0x270
[   92.778062]  vfs_read+0xad/0x170
[   92.778064]  SyS_read+0x4b/0xa0
[   92.778065]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778066]  do_syscall_64+0x63/0x1f0
[   92.778068]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778069] RIP: 0033:0x7f4951de2410
[   92.778070] RSP: 002b:00007fff89373808 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778071] RAX: ffffffffffffffda RBX: 0000000000000029 RCX: 00007f4951de2410
[   92.778071] RDX: 0000000000100000 RSI: 00007f4951925000 RDI: 0000000000000000
[   92.778072] RBP: 00007fff89373830 R08: ffffffffffffffff R09: 0000000000000000
[   92.778073] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778073] R13: 00007f495240c690 R14: 0000000000100000 R15: 00007f4951925000
[   92.778074] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85
c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2
5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00
00 b9
[   92.778094] NMI backtrace for cpu 2
[   92.778096] CPU: 2 PID: 1850 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778097] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778100] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[   92.778101] RSP: 0018:ffffb489c7573db0 EFLAGS: 00000002
[   92.778102] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778103] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778104] RBP: ffffb489c7573de0 R08: 000000005881149c R09: 0000000016f603e6
[   92.778105] R10: 000000007e14a1cc R11: 00000000a07e8a75 R12: ffff9f5c82ca5a68
[   92.778105] R13: ffffb489c7573e38 R14: ffffb489c7573e38 R15: 0000000000000040
[   92.778107] FS:  00007f30c1a57700(0000) GS:ffff9f5c83280000(0000)
knlGS:0000000000000000
[   92.778108] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778108] CR2: 000055ada37359c0 CR3: 0000000eddabe001 CR4: 00000000003606a0
[   92.778112] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778112] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778113] Call Trace:
[   92.778116]  do_raw_spin_lock+0xa0/0xb0
[   92.778118]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778121]  _extract_crng+0x45/0x120
[   92.778123]  urandom_read+0xea/0x270
[   92.778125]  vfs_read+0xad/0x170
[   92.778127]  SyS_read+0x4b/0xa0
[   92.778129]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778130]  do_syscall_64+0x63/0x1f0
[   92.778133]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778134] RIP: 0033:0x7f30c142d410
[   92.778135] RSP: 002b:00007ffc67fe0ac8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778136] RAX: ffffffffffffffda RBX: 0000000000000039 RCX: 00007f30c142d410
[   92.778137] RDX: 0000000000100000 RSI: 00007f30c0f70000 RDI: 0000000000000000
[   92.778138] RBP: 00007ffc67fe0af0 R08: ffffffffffffffff R09: 0000000000000000
[   92.778139] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778139] R13: 00007f30c1a57690 R14: 0000000000100000 R15: 00007f30c0f70000
[   92.778140] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85
c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2
5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00
00 b9
[   92.778160] NMI backtrace for cpu 10
[   92.778162] CPU: 10 PID: 1846 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778162] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778164] RIP: 0010:native_queued_spin_lock_slowpath+0x20/0x1b0
[   92.778165] RSP: 0018:ffffb489c7cfbdb0 EFLAGS: 00000097
[   92.778166] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778167] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778168] RBP: ffffb489c7cfbde0 R08: 00000000c8adce20 R09: 00000000488b6915
[   92.778168] R10: 00000000b1e0660c R11: 0000000010ab43f9 R12: ffff9f5c82ca5a68
[   92.778169] R13: ffffb489c7cfbe38 R14: ffffb489c7cfbe38 R15: 0000000000000040
[   92.778170] FS:  00007fc53087c700(0000) GS:ffff9f5c83480000(0000)
knlGS:0000000000000000
[   92.778171] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778172] CR2: 00007f31139788c0 CR3: 0000000edda36006 CR4: 00000000003606a0
[   92.778175] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778176] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778176] Call Trace:
[   92.778178]  do_raw_spin_lock+0xa0/0xb0
[   92.778180]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778182]  _extract_crng+0x45/0x120
[   92.778184]  urandom_read+0xea/0x270
[   92.778186]  vfs_read+0xad/0x170
[   92.778188]  SyS_read+0x4b/0xa0
[   92.778189]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778190]  do_syscall_64+0x63/0x1f0
[   92.778192]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778193] RIP: 0033:0x7fc530252410
[   92.778193] RSP: 002b:00007fffe389c818 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778195] RAX: ffffffffffffffda RBX: 000000000000003a RCX: 00007fc530252410
[   92.778195] RDX: 0000000000100000 RSI: 00007fc52fd95000 RDI: 0000000000000000
[   92.778196] RBP: 00007fffe389c840 R08: ffffffffffffffff R09: 0000000000000000
[   92.778197] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778197] R13: 00007fc53087c690 R14: 0000000000100000 R15: 00007fc52fd95000
[   92.778198] Code: 00 00 00 e9 1d fe ff ff 0f 1f 00 0f 1f 44 00 00
8b 05 d5 ad d8 00 55 85 c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a
f0 0f b1 17 <85> c0 75 f2 5d c3 f3 90 eb ec 81 fe 00 01 00 00 0f 84 9a
00 00
[   92.778218] NMI backtrace for cpu 8
[   92.778220] CPU: 8 PID: 1848 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778220] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778222] RIP: 0010:native_queued_spin_lock_slowpath+0x18/0x1b0
[   92.778223] RSP: 0018:ffffb489c7d6bdb0 EFLAGS: 00000002
[   92.778224] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778225] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778225] RBP: ffffb489c7d6bde0 R08: 000000008a2cdbe2 R09: 00000000b1c3e3b9
[   92.778226] R10: 000000007230bf45 R11: 00000000d22a51bb R12: ffff9f5c82ca5a68
[   92.778227] R13: ffffb489c7d6be38 R14: ffffb489c7d6be38 R15: 0000000000000040
[   92.778228] FS:  00007f3d84692700(0000) GS:ffff9f5c83400000(0000)
knlGS:0000000000000000
[   92.778229] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778229] CR2: 00007fe831dbc140 CR3: 0000000ede342001 CR4: 00000000003606a0
[   92.778232] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778233] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778233] Call Trace:
[   92.778235]  do_raw_spin_lock+0xa0/0xb0
[   92.778237]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778239]  _extract_crng+0x45/0x120
[   92.778241]  urandom_read+0xea/0x270
[   92.778243]  vfs_read+0xad/0x170
[   92.778245]  SyS_read+0x4b/0xa0
[   92.778246]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778247]  do_syscall_64+0x63/0x1f0
[   92.778249]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778250] RIP: 0033:0x7f3d84068410
[   92.778251] RSP: 002b:00007fffea90d928 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778252] RAX: ffffffffffffffda RBX: 000000000000003b RCX: 00007f3d84068410
[   92.778253] RDX: 0000000000100000 RSI: 00007f3d83bab000 RDI: 0000000000000000
[   92.778253] RBP: 00007fffea90d950 R08: ffffffffffffffff R09: 0000000000000000
[   92.778254] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778255] R13: 00007f3d84692690 R14: 0000000000100000 R15: 00007f3d83bab000
[   92.778255] Code: 48 8b 2c 24 48 c7 00 00 00 00 00 e9 1d fe ff ff
0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85 c0 7e 1a ba 01 00 00
00 90 8b 07 <85> c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 eb ec 81
fe 00
[   92.778275] NMI backtrace for cpu 4
[   92.778277] CPU: 4 PID: 1864 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778278] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778281] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[   92.778282] RSP: 0018:ffffb489c7ddbdb0 EFLAGS: 00000002
[   92.778283] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778284] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778285] RBP: ffffb489c7ddbde0 R08: 000000000ffa62a0 R09: 000000002e18c499
[   92.778285] R10: 000000007d13e3b0 R11: 0000000057f7d879 R12: ffff9f5c82ca5a68
[   92.778286] R13: ffffb489c7ddbe38 R14: ffffb489c7ddbe38 R15: 0000000000000040
[   92.778287] FS:  00007f2f743d5700(0000) GS:ffff9f5c83300000(0000)
knlGS:0000000000000000
[   92.778288] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778289] CR2: 000055c6f86eddf8 CR3: 0000000eddbde005 CR4: 00000000003606a0
[   92.778292] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778293] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778293] Call Trace:
[   92.778297]  do_raw_spin_lock+0xa0/0xb0
[   92.778299]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778302]  _extract_crng+0x45/0x120
[   92.778304]  urandom_read+0xea/0x270
[   92.778306]  vfs_read+0xad/0x170
[   92.778308]  SyS_read+0x4b/0xa0
[   92.778310]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778311]  do_syscall_64+0x63/0x1f0
[   92.778313]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778315] RIP: 0033:0x7f2f73dab410
[   92.778315] RSP: 002b:00007ffcbb71e838 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778317] RAX: ffffffffffffffda RBX: 0000000000000047 RCX: 00007f2f73dab410
[   92.778317] RDX: 0000000000100000 RSI: 00007f2f738ee000 RDI: 0000000000000000
[   92.778318] RBP: 00007ffcbb71e860 R08: ffffffffffffffff R09: 0000000000000000
[   92.778319] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778320] R13: 00007f2f743d5690 R14: 0000000000100000 R15: 00007f2f738ee000
[   92.778321] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85
c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2
5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00
00 b9
[   92.778341] NMI backtrace for cpu 12
[   92.778342] CPU: 12 PID: 1860 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778343] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778345] RIP: 0010:native_queued_spin_lock_slowpath+0x20/0x1b0
[   92.778346] RSP: 0018:ffffb489c74f3db0 EFLAGS: 00000046
[   92.778346] RAX: 0000000000000000 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778347] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778348] RBP: ffffb489c74f3de0 R08: 00000000a966dd49 R09: 00000000fab8387b
[   92.778349] R10: 0000000036100fb1 R11: 00000000f1645322 R12: ffff9f5c82ca5a68
[   92.778349] R13: ffffb489c74f3e38 R14: ffffb489c74f3e38 R15: 0000000000000040
[   92.778350] FS:  00007f214a3b0700(0000) GS:ffff9f5c83500000(0000)
knlGS:0000000000000000
[   92.778351] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778352] CR2: 00007efe1164bba0 CR3: 0000000eddb92002 CR4: 00000000003606a0
[   92.778356] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778357] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778357] Call Trace:
[   92.778359]  do_raw_spin_lock+0xa0/0xb0
[   92.778361]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778363]  _extract_crng+0x45/0x120
[   92.778365]  urandom_read+0xea/0x270
[   92.778367]  vfs_read+0xad/0x170
[   92.778369]  SyS_read+0x4b/0xa0
[   92.778370]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778371]  do_syscall_64+0x63/0x1f0
[   92.778373]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778374] RIP: 0033:0x7f2149d86410
[   92.778375] RSP: 002b:00007ffec719e588 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778376] RAX: ffffffffffffffda RBX: 0000000000000044 RCX: 00007f2149d86410
[   92.778376] RDX: 0000000000100000 RSI: 00007f21498c9000 RDI: 0000000000000000
[   92.778377] RBP: 00007ffec719e5b0 R08: ffffffffffffffff R09: 0000000000000000
[   92.778378] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778378] R13: 00007f214a3b0690 R14: 0000000000100000 R15: 00007f21498c9000
[   92.778379] Code: 00 00 00 e9 1d fe ff ff 0f 1f 00 0f 1f 44 00 00
8b 05 d5 ad d8 00 55 85 c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a
f0 0f b1 17 <85> c0 75 f2 5d c3 f3 90 eb ec 81 fe 00 01 00 00 0f 84 9a
00 00
[   92.778399] NMI backtrace for cpu 7
[   92.778402] CPU: 7 PID: 1871 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778402] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778406] RIP: 0010:native_queued_spin_lock_slowpath+0x18/0x1b0
[   92.778406] RSP: 0018:ffffb489c7c03db0 EFLAGS: 00000002
[   92.778408] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778408] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778409] RBP: ffffb489c7c03de0 R08: 00000000aa046079 R09: 000000001b50b1a2
[   92.778410] R10: 00000000a366b6ee R11: 00000000f201d652 R12: ffff9f5c82ca5a68
[   92.778411] R13: ffffb489c7c03e38 R14: ffffb489c7c03e38 R15: 0000000000000040
[   92.778412] FS:  00007f2a946e7700(0000) GS:ffff9f5c833c0000(0000)
knlGS:0000000000000000
[   92.778413] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778413] CR2: 00005588da6ad210 CR3: 0000000edd470001 CR4: 00000000003606a0
[   92.778417] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778418] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778418] Call Trace:
[   92.778422]  do_raw_spin_lock+0xa0/0xb0
[   92.778424]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778426]  _extract_crng+0x45/0x120
[   92.778429]  urandom_read+0xea/0x270
[   92.778431]  vfs_read+0xad/0x170
[   92.778433]  SyS_read+0x4b/0xa0
[   92.778435]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778436]  do_syscall_64+0x63/0x1f0
[   92.778438]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778439] RIP: 0033:0x7f2a940bd410
[   92.778440] RSP: 002b:00007fff62b4d7a8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778441] RAX: ffffffffffffffda RBX: 0000000000000035 RCX: 00007f2a940bd410
[   92.778442] RDX: 0000000000100000 RSI: 00007f2a93c00000 RDI: 0000000000000000
[   92.778443] RBP: 00007fff62b4d7d0 R08: ffffffffffffffff R09: 0000000000000000
[   92.778444] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778444] R13: 00007f2a946e7690 R14: 0000000000100000 R15: 00007f2a93c00000
[   92.778445] Code: 48 8b 2c 24 48 c7 00 00 00 00 00 e9 1d fe ff ff
0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85 c0 7e 1a ba 01 00 00
00 90 8b 07 <85> c0 75 0a f0 0f b1 17 85 c0 75 f2 5d c3 f3 90 eb ec 81
fe 00
[   92.778473] NMI backtrace for cpu 3
[   92.778476] CPU: 3 PID: 1862 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778476] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778480] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[   92.778480] RSP: 0018:ffffb489c7c67db0 EFLAGS: 00000002
[   92.778482] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778482] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778483] RBP: ffffb489c7c67de0 R08: 000000000bb268a5 R09: 0000000023d30aaf
[   92.778484] R10: 00000000020fd5a8 R11: 0000000053afde7e R12: ffff9f5c82ca5a68
[   92.778485] R13: ffffb489c7c67e38 R14: ffffb489c7c67e38 R15: 0000000000000040
[   92.778486] FS:  00007f9aeb39d700(0000) GS:ffff9f5c832c0000(0000)
knlGS:0000000000000000
[   92.778487] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778488] CR2: 00007f8af1af22d0 CR3: 0000000eddbba006 CR4: 00000000003606a0
[   92.778491] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778492] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778492] Call Trace:
[   92.778496]  do_raw_spin_lock+0xa0/0xb0
[   92.778498]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778501]  _extract_crng+0x45/0x120
[   92.778503]  urandom_read+0xea/0x270
[   92.778505]  vfs_read+0xad/0x170
[   92.778507]  SyS_read+0x4b/0xa0
[   92.778509]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778510]  do_syscall_64+0x63/0x1f0
[   92.778512]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778514] RIP: 0033:0x7f9aead73410
[   92.778514] RSP: 002b:00007fff1035a0a8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778516] RAX: ffffffffffffffda RBX: 000000000000003e RCX: 00007f9aead73410
[   92.778516] RDX: 0000000000100000 RSI: 00007f9aea8b6000 RDI: 0000000000000000
[   92.778517] RBP: 00007fff1035a0d0 R08: ffffffffffffffff R09: 0000000000000000
[   92.778518] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778519] R13: 00007f9aeb39d690 R14: 0000000000100000 R15: 00007f9aea8b6000
[   92.778520] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85
c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2
5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00
00 b9
[   92.778541] NMI backtrace for cpu 11
[   92.778542] CPU: 11 PID: 1870 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778543] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778545] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[   92.778546] RSP: 0018:ffffb489c7e13db0 EFLAGS: 00000002
[   92.778547] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778548] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778548] RBP: ffffb489c7e13de0 R08: 00000000ee7a4106 R09: 00000000e50a300e
[   92.778549] R10: 00000000dc4f7e72 R11: 000000003677b6df R12: ffff9f5c82ca5a68
[   92.778550] R13: ffffb489c7e13e38 R14: ffffb489c7e13e38 R15: 0000000000000040
[   92.778551] FS:  00007fab474ee700(0000) GS:ffff9f5c834c0000(0000)
knlGS:0000000000000000
[   92.778552] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778553] CR2: 0000563ea45d4938 CR3: 0000000edd466005 CR4: 00000000003606a0
[   92.778556] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778557] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778557] Call Trace:
[   92.778559]  do_raw_spin_lock+0xa0/0xb0
[   92.778561]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778564]  _extract_crng+0x45/0x120
[   92.778566]  urandom_read+0xea/0x270
[   92.778568]  vfs_read+0xad/0x170
[   92.778570]  SyS_read+0x4b/0xa0
[   92.778571]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778572]  do_syscall_64+0x63/0x1f0
[   92.778574]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778575] RIP: 0033:0x7fab46ec4410
[   92.778575] RSP: 002b:00007fff47b5e7e8 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778577] RAX: ffffffffffffffda RBX: 0000000000000036 RCX: 00007fab46ec4410
[   92.778577] RDX: 0000000000100000 RSI: 00007fab46a07000 RDI: 0000000000000000
[   92.778578] RBP: 00007fff47b5e810 R08: ffffffffffffffff R09: 0000000000000000
[   92.778579] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778579] R13: 00007fab474ee690 R14: 0000000000100000 R15: 00007fab46a07000
[   92.778580] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85
c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2
5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00
00 b9
[   92.778601] NMI backtrace for cpu 15
[   92.778603] CPU: 15 PID: 1857 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778603] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778605] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[   92.778606] RSP: 0018:ffffb489c7cb3db0 EFLAGS: 00000002
[   92.778607] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778607] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778608] RBP: ffffb489c7cb3de0 R08: 000000004be85ff2 R09: 0000000018b0b19c
[   92.778609] R10: 0000000035e781b4 R11: 0000000093e5d5cb R12: ffff9f5c82ca5a68
[   92.778610] R13: ffffb489c7cb3e38 R14: ffffb489c7cb3e38 R15: 0000000000000040
[   92.778611] FS:  00007f05286cc700(0000) GS:ffff9f5c835c0000(0000)
knlGS:0000000000000000
[   92.778611] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778612] CR2: 00005626d2f49210 CR3: 0000000eddb90005 CR4: 00000000003606a0
[   92.778615] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778616] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778616] Call Trace:
[   92.778618]  do_raw_spin_lock+0xa0/0xb0
[   92.778620]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778622]  _extract_crng+0x45/0x120
[   92.778624]  urandom_read+0xea/0x270
[   92.778626]  vfs_read+0xad/0x170
[   92.778628]  SyS_read+0x4b/0xa0
[   92.778629]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778630]  do_syscall_64+0x63/0x1f0
[   92.778632]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778633] RIP: 0033:0x7f05280a2410
[   92.778634] RSP: 002b:00007ffc27d2fa58 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778635] RAX: ffffffffffffffda RBX: 000000000000002e RCX: 00007f05280a2410
[   92.778635] RDX: 0000000000100000 RSI: 00007f0527be5000 RDI: 0000000000000000
[   92.778636] RBP: 00007ffc27d2fa80 R08: ffffffffffffffff R09: 0000000000000000
[   92.778637] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778637] R13: 00007f05286cc690 R14: 0000000000100000 R15: 00007f0527be5000
[   92.778638] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85
c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2
5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00
00 b9
[   92.778659] NMI backtrace for cpu 14
[   92.778661] CPU: 14 PID: 1867 Comm: dd Tainted: G           O     4.15.0+ #12
[   92.778661] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   92.778664] RIP: 0010:native_queued_spin_lock_slowpath+0x28/0x1b0
[   92.778665] RSP: 0018:ffffb489c7e03db0 EFLAGS: 00000002
[   92.778666] RAX: 0000000000000001 RBX: ffff9f5c82ca5a68 RCX: 0000000000000000
[   92.778667] RDX: 0000000000000001 RSI: 0000000000000001 RDI: ffff9f5c82ca5a68
[   92.778668] RBP: ffffb489c7e03de0 R08: 00000000edb4d0c8 R09: 00000000a4a0a15d
[   92.778669] R10: 000000004eecd136 R11: 0000000035b246a1 R12: ffff9f5c82ca5a68
[   92.778669] R13: ffffb489c7e03e38 R14: ffffb489c7e03e38 R15: 0000000000000040
[   92.778671] FS:  00007ff0fd2ee700(0000) GS:ffff9f5c83580000(0000)
knlGS:0000000000000000
[   92.778671] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   92.778672] CR2: 000000c420dbc010 CR3: 0000000edd43c004 CR4: 00000000003606a0
[   92.778676] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   92.778676] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[   92.778677] Call Trace:
[   92.778680]  do_raw_spin_lock+0xa0/0xb0
[   92.778682]  _raw_spin_lock_irqsave+0x20/0x30
[   92.778684]  _extract_crng+0x45/0x120
[   92.778686]  urandom_read+0xea/0x270
[   92.778689]  vfs_read+0xad/0x170
[   92.778691]  SyS_read+0x4b/0xa0
[   92.778692]  ? __audit_syscall_exit+0x21e/0x2c0
[   92.778694]  do_syscall_64+0x63/0x1f0
[   92.778696]  entry_SYSCALL64_slow_path+0x25/0x25
[   92.778697] RIP: 0033:0x7ff0fccc4410
[   92.778698] RSP: 002b:00007ffe7ee66a28 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[   92.778699] RAX: ffffffffffffffda RBX: 000000000000003c RCX: 00007ff0fccc4410
[   92.778700] RDX: 0000000000100000 RSI: 00007ff0fc807000 RDI: 0000000000000000
[   92.778701] RBP: 00007ffe7ee66a50 R08: ffffffffffffffff R09: 0000000000000000
[   92.778702] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[   92.778702] R13: 00007ff0fd2ee690 R14: 0000000000100000 R15: 00007ff0fc807000
[   92.778703] Code: 0f 1f 00 0f 1f 44 00 00 8b 05 d5 ad d8 00 55 85
c0 7e 1a ba 01 00 00 00 90 8b 07 85 c0 75 0a f0 0f b1 17 85 c0 75 f2
5d c3 f3 90 <eb> ec 81 fe 00 01 00 00 0f 84 9a 00 00 00 41 b8 01 01 00
00 b9
[   92.778780] Kernel panic - not syncing: softlockup: hung tasks
[   95.939261] CPU: 6 PID: 1993 Comm: hog Tainted: G           O L   4.15.0+ #12
[   95.946506] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[   95.955921] Call Trace:
[   95.958832]  <IRQ>
[   95.960962]  dump_stack+0x63/0x8a
[   95.964394]  panic+0xd6/0x22d
[   95.967473]  ? cpumask_next+0x1a/0x20
[   95.971280]  watchdog_timer_fn+0x22b/0x240
[   95.975486]  ? watchdog+0x30/0x30
[   95.979099]  __hrtimer_run_queues+0xd6/0x2f0
[   95.983585]  hrtimer_interrupt+0x11b/0x290
[   95.987793]  smp_apic_timer_interrupt+0x6c/0x140
[   95.992524]  apic_timer_interrupt+0x98/0xa0
[   95.996819]  </IRQ>
[   95.999032] RIP: 0010:hog_thread+0x13/0x1000 [hog]
[   96.003933] RSP: 0018:ffffb489c741ff10 EFLAGS: 00000282 ORIG_RAX:
ffffffffffffff11
[   96.011610] RAX: 0000000000000011 RBX: ffff9f5c75a88900 RCX: 0000000000000000
[   96.018852] RDX: ffff9f5c8339d840 RSI: ffff9f5c833954b8 RDI: ffff9f5c833954b8
[   96.026095] RBP: ffffb489c741ff48 R08: 0000000000000030 R09: 0000000000000000
[   96.033339] R10: 00000000000003a8 R11: 0000000000000000 R12: ffff9f5c7959e080
[   96.040621] R13: ffffb489c7f2bc70 R14: 0000000000000000 R15: ffff9f5c75a88948
[   96.047876]  kthread+0x120/0x160
[   96.051235]  ? 0xffffffffc030d000
[   96.054662]  ? kthread_stop+0x120/0x120
[   96.058611]  ret_from_fork+0x35/0x40
[   96.064388] Kernel Offset: 0x31000000 from 0xffffffff81000000
(relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[   96.075390] ACPI MEMORY or I/O RESET_REG.
SeaBIOS (version 1.8.2-20171012_061934-google)          <-----  Reboot
happened here
Total RAM Size = 0x0000000f00000000 = 61440 MiB
CPUs found: 16     Max CPUs supported: 16
=====================

Log snippet for the buffer flushing worker when `softlockup_panic` is
turned off:

[  348.058207] NMI backtrace for cpu 8
[  348.058207] CPU: 8 PID: 1700 Comm: dd Tainted: G           O L  4.14.73 #18
[  348.058208] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[  348.058208] task: ffff9afe5dfc0000 task.stack: ffffbc14c7d14000
[  348.058208] RIP: 0010:delay_tsc+0x35/0x50
[  348.058209] RSP: 0018:ffff9afe83403e50 EFLAGS: 00000087
[  348.058210] RAX: 000000b377ae8e51 RBX: ffffffffa13283c0 RCX: 000000b377ae8e28
[  348.058210] RDX: 0000000000000029 RSI: 0000000000000008 RDI: 0000000000000899
[  348.058210] RBP: ffff9afe83403e78 R08: 0000000000000030 R09: 0000000000000000
[  348.058211] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000002708
[  348.058211] R13: 0000000000000020 R14: ffffffffa12cfc89 R15: ffffffffa13283c0
[  348.058212] FS:  00007f87d366d700(0000) GS:ffff9afe83400000(0000)
knlGS:0000000000000000
[  348.058212] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  348.058213] CR2: 00007f3a666bf130 CR3: 0000000eeed3e005 CR4: 00000000003606a0
[  348.058213] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  348.058213] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  348.058214] Call Trace:
[  348.058214]  <IRQ>
[  348.058214]  wait_for_xmitr+0x2c/0xb0
[  348.058215]  serial8250_console_putchar+0x1c/0x40
[  348.058215]  ? wait_for_xmitr+0xb0/0xb0
[  348.058215]  uart_console_write+0x33/0x70
[  348.058216]  serial8250_console_write+0xe2/0x2b0
[  348.058216]  ? msg_print_text+0xa6/0x110
[  348.058216]  console_unlock+0x306/0x4a0
[  348.058217]  wake_up_klogd_work_func+0x55/0x60
[  348.058217]  irq_work_run_list+0x50/0x80
[  348.058217]  smp_irq_work_interrupt+0x3f/0xe0
[  348.058218]  irq_work_interrupt+0x7d/0x90
[  348.058218]  </IRQ>
[  348.058218] RIP: 0010:_raw_spin_unlock_irqrestore+0x17/0x20
[  348.058219] RSP: 0018:ffffbc14c7d17e00 EFLAGS: 00000212 ORIG_RAX:
ffffffffffffff09
[  348.058220] RAX: 0000000000000008 RBX: 0000000000000212 RCX: 00000000f051d16f
[  348.058220] RDX: 00000000d5d8d427 RSI: 0000000000000212 RDI: 0000000000000212
[  348.058220] RBP: ffffbc14c7d17e08 R08: 000000007064b05b R09: 000000008702a7b3
[  348.058221] R10: 000000007b5e67a9 R11: 00000000bd0b4c4f R12: 00007f87d2c63200
[  348.058221] R13: 00000000000dd200 R14: ffffbc14c7d17e30 R15: 0000000000000040
[  348.058221]  urandom_read+0xf9/0x2c0
[  348.058222]  vfs_read+0xad/0x170
[  348.058222]  SyS_read+0x4b/0xa0
[  348.058222]  ? __audit_syscall_exit+0x21e/0x2c0
[  348.058223]  do_syscall_64+0x70/0x200
[  348.058223]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[  348.058224] RIP: 0033:0x7f87d3043410
[  348.058224] RSP: 002b:00007ffff267bb58 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[  348.058225] RAX: ffffffffffffffda RBX: 000000000000002b RCX: 00007f87d3043410
[  348.058225] RDX: 0000000000100000 RSI: 00007f87d2b86000 RDI: 0000000000000000
[  348.058226] RBP: 00007ffff267bb80 R08: ffffffffffffffff R09: 0000000000000000
[  348.058226] R10: 0000000000001000 R11: 0000000000000246 R12: 0000000000000000
[  348.058227] R13: 00007f87d366d690 R14: 0000000000100000 R15: 00007f87d2b86000
[  348.058227] Code: a3 99 5f 0f ae e8 0f 31 48 89 d1 48 c1 e1 20 48
09 c1 0f ae e8 0f 31 48 c1 e2 20 48 09 d0 48 89 c2 48 29 ca 48 39 fa
73 15 f3 90 <65> 8b 15 9c a3 99 5f 39 d6 74 dc 48 29 c1 48 01 cf eb be
5d c3


-- 
Best,
Daniel

--0000000000009098dd05775632c3
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIIS7QYJKoZIhvcNAQcCoIIS3jCCEtoCAQExDzANBglghkgBZQMEAgEFADALBgkqhkiG9w0BBwGg
ghBTMIIEXDCCA0SgAwIBAgIOSBtqDm4P/739RPqw/wcwDQYJKoZIhvcNAQELBQAwZDELMAkGA1UE
BhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExOjA4BgNVBAMTMUdsb2JhbFNpZ24gUGVy
c29uYWxTaWduIFBhcnRuZXJzIENBIC0gU0hBMjU2IC0gRzIwHhcNMTYwNjE1MDAwMDAwWhcNMjEw
NjE1MDAwMDAwWjBMMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEiMCAG
A1UEAxMZR2xvYmFsU2lnbiBIViBTL01JTUUgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBALR23lKtjlZW/17kthzYcMHHKFgywfc4vLIjfq42NmMWbXkNUabIgS8KX4PnIFsTlD6F
GO2fqnsTygvYPFBSMX4OCFtJXoikP2CQlEvO7WooyE94tqmqD+w0YtyP2IB5j4KvOIeNv1Gbnnes
BIUWLFxs1ERvYDhmk+OrvW7Vd8ZfpRJj71Rb+QQsUpkyTySaqALXnyztTDp1L5d1bABJN/bJbEU3
Hf5FLrANmognIu+Npty6GrA6p3yKELzTsilOFmYNWg7L838NS2JbFOndl+ce89gM36CW7vyhszi6
6LqqzJL8MsmkP53GGhf11YMP9EkmawYouMDP/PwQYhIiUO0CAwEAAaOCASIwggEeMA4GA1UdDwEB
/wQEAwIBBjAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwEgYDVR0TAQH/BAgwBgEB/wIB
ADAdBgNVHQ4EFgQUyzgSsMeZwHiSjLMhleb0JmLA4D8wHwYDVR0jBBgwFoAUJiSSix/TRK+xsBtt
r+500ox4AAMwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9n
c3BlcnNvbmFsc2lnbnB0bnJzc2hhMmcyLmNybDBMBgNVHSAERTBDMEEGCSsGAQQBoDIBKDA0MDIG
CCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzANBgkqhkiG
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
QAYIKwYBBQUHMAKGNGh0dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzaHZzbWlt
ZWNhMS5jcnQwHQYDVR0OBBYEFHswV6b+EY77vBWQKD6Dmp9n2Jp7MB8GA1UdIwQYMBaAFMs4ErDH
mcB4koyzIZXm9CZiwOA/MEwGA1UdIARFMEMwQQYJKwYBBAGgMgEoMDQwMgYIKwYBBQUHAgEWJmh0
dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMDsGA1UdHwQ0MDIwMKAuoCyGKmh0
dHA6Ly9jcmwuZ2xvYmFsc2lnbi5jb20vZ3NodnNtaW1lY2ExLmNybDAOBgNVHQ8BAf8EBAMCBaAw
HQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMEMA0GCSqGSIb3DQEBCwUAA4IBAQCKdekZm8Fn
LFr+VBrtMVdmg4uKT25UuNxBxtgYJNqP/hYvkbGxHZnbTeQs63W5u+DW++SIfXI0aP1Lp34TFidR
bIL+4+xzfrlWGFcPb1IBl0fdNr5mnUdluXE78N0zwUiv3qa66dwP8oVooeDmRHOHO0A20C5/24q7
GIWfW2K2CeBWRj0OI1P6XUm+unjVNzVz6fE9J91Xf13NxK9Pc647cBIP4eiHNVa7ErprHQoDevx+
OHFHle2OOiJZoAqFNvKbQSuWBg+Obv3CjPLZ7lwdB9VBg3F5qEaD+BsyHwj+kMinP7wCI+mIc1nU
PcdI0z7gBtGEit9qr9qcJrdKjDlTMYICXjCCAloCAQEwXDBMMQswCQYDVQQGEwJCRTEZMBcGA1UE
ChMQR2xvYmFsU2lnbiBudi1zYTEiMCAGA1UEAxMZR2xvYmFsU2lnbiBIViBTL01JTUUgQ0EgMQIM
TmnftMpllv264rvDMA0GCWCGSAFlAwQCAQUAoIHUMC8GCSqGSIb3DQEJBDEiBCCMpGU99sfH6SlC
TxKsCjmgCDa8ahtL1i6EIuhE/Mtc+zAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3
DQEJBTEPFw0xODEwMDMxNzE2MjJaMGkGCSqGSIb3DQEJDzFcMFowCwYJYIZIAWUDBAEqMAsGCWCG
SAFlAwQBFjALBglghkgBZQMEAQIwCgYIKoZIhvcNAwcwCwYJKoZIhvcNAQEKMAsGCSqGSIb3DQEB
BzALBglghkgBZQMEAgEwDQYJKoZIhvcNAQEBBQAEggEARW5JvZahh3yIRJWJyB811zOKdWh16/pW
1PBMVvjD4K45d/5AzlZmE/cMfyMqRCAsq7wSWaTC0xRmTPIiujoZuJhHIE+lUwCwx2CbBoysMA+f
ZvwVl1JCeOh4WmLLt0vBv14oT7NZVcWkFWB3YhQ3wPQPTqeJvaC7FXI9ZNKBCrDa6ixs5mzILwC4
7BLoJJ6IwwoRVEWF9GT/+nhx2x2W4qVSMwuQznsiKMacvqMLj4v5JqR3b5xfJCWRJQVh+2Ec1efa
Ispcor5NHZ1HOKNQaETdwvxy7cRHjZnvBZPPxen6GqHOlveQ5FQB9U/2Vz3QDqstX7iNVA3yQKOq
G5MkVw==
--0000000000009098dd05775632c3--
