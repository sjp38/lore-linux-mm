Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id CB5676B005A
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 15:35:12 -0500 (EST)
Date: Mon, 10 Dec 2012 21:35:06 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org> <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to> <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com> <50C32D32.6040800@iskon.hr> <50C3AF80.8040700@iskon.hr> <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org> <20121210110337.GH1009@suse.de> <20121210163904.GA22101@cmpxchg.org> <20121210180141.GK1009@suse.de> <50C62AE6.3030000@iskon.hr> <CA+55aFwNE2y5t2uP3esCnHsaNo0NTDnGvzN6KF0qTw_y+QbtFA@mail.gmail.com>
In-Reply-To: <CA+55aFwNE2y5t2uP3esCnHsaNo0NTDnGvzN6KF0qTw_y+QbtFA@mail.gmail.com>
Message-ID: <50C6477A.4090005@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Subject: Re: kswapd craziness in 3.7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 10.12.2012 20:13, Linus Torvalds wrote:
> 
> It's worth giving this as much testing as is at all possible, but at
> the same time I really don't think I can delay 3.7 any more without
> messing up the holiday season too much. So unless something obvious
> pops up, I will do the release tonight. So testing will be minimal -
> but it's not like we haven't gone back-and-forth on this several times
> already, and we revert to *mostly* the same old state as 3.6 anyway,
> so it should be fairly safe.
> 

It compiles and boots without a hitch, so it must be perfect. :)

Seriously, a few more hours need to pass, until I can provide more convincing data. That's how long it takes on this particular machine for memory pressure to build up and memory fragmentation to ensue. Only then I'll be able to tell how it really behaves. I promise to get back as soon as I can.

And funny thing that you mention i915, because yesterday my daughter managed to lock up our laptop hard (that was a first), and this is what I found in kern.log after restart:

Dec  9 21:29:42 titan vmunix: general protection fault: 0000 [#1] PREEMPT SMP 
Dec  9 21:29:42 titan vmunix: Modules linked in: vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) [last unloaded: microcode]
Dec  9 21:29:42 titan vmunix: CPU 2 
Dec  9 21:29:42 titan vmunix: Pid: 2523, comm: Xorg Tainted: G           O 3.7.0-rc8 #1 Hewlett-Packard HP Pavilion dv7 Notebook PC/144B
Dec  9 21:29:42 titan vmunix: RIP: 0010:[<ffffffff81090b9c>]  [<ffffffff81090b9c>] find_get_page+0x3c/0x90
Dec  9 21:29:42 titan vmunix: RSP: 0018:ffff88014d9f7928  EFLAGS: 00010246
Dec  9 21:29:42 titan vmunix: RAX: ffff880052594bc8 RBX: 0200000000000000 RCX: 00000000fffffffa
Dec  9 21:29:42 titan vmunix: RDX: 0000000000000001 RSI: ffff880052594bc8 RDI: 0000000000000000
Dec  9 21:29:42 titan vmunix: RBP: ffff88014d9f7948 R08: 0200000000000000 R09: ffff880052594b18
Dec  9 21:29:42 titan vmunix: R10: 57ffe4cbb74d1280 R11: 0000000000000000 R12: ffff88011c959a90
Dec  9 21:29:42 titan vmunix: R13: 0000000000000053 R14: 0000000000000000 R15: 0000000000000053
Dec  9 21:29:42 titan vmunix: FS:  00007fcd8d413880(0000) GS:ffff880157c80000(0000) knlGS:0000000000000000
Dec  9 21:29:42 titan vmunix: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Dec  9 21:29:42 titan vmunix: CR2: ffffffffff600400 CR3: 000000014d937000 CR4: 00000000000007e0
Dec  9 21:29:42 titan vmunix: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Dec  9 21:29:42 titan vmunix: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Dec  9 21:29:42 titan vmunix: Process Xorg (pid: 2523, threadinfo ffff88014d9f6000, task ffff88014d9c1260)
Dec  9 21:29:42 titan vmunix: Stack:
Dec  9 21:29:42 titan vmunix:  ffff88014d9f7958 ffff88011c959a88 0000000000000053 ffff88011c959a88
Dec  9 21:29:42 titan vmunix:  ffff88014d9f7978 ffffffff81090e21 0000000000000001 ffffea00014d1280
Dec  9 21:29:42 titan vmunix:  ffff88011c959960 0000000000000001 ffff88014d9f7a28 ffffffff810a1b60
Dec  9 21:29:42 titan vmunix: Call Trace:
Dec  9 21:29:42 titan vmunix:  [<ffffffff81090e21>] find_lock_page+0x21/0x80
Dec  9 21:29:42 titan vmunix:  [<ffffffff810a1b60>] shmem_getpage_gfp+0xa0/0x620
Dec  9 21:29:42 titan vmunix:  [<ffffffff810a224c>] shmem_read_mapping_page_gfp+0x2c/0x50
Dec  9 21:29:42 titan vmunix:  [<ffffffff812b3611>] i915_gem_object_get_pages_gtt+0xe1/0x270
Dec  9 21:29:42 titan vmunix:  [<ffffffff812b127f>] i915_gem_object_get_pages+0x4f/0x90
Dec  9 21:29:42 titan vmunix:  [<ffffffff812b1383>] i915_gem_object_bind_to_gtt+0xc3/0x4c0
Dec  9 21:29:42 titan vmunix:  [<ffffffff812b4413>] i915_gem_object_pin+0x123/0x190
Dec  9 21:29:42 titan vmunix:  [<ffffffff812b7d97>] i915_gem_execbuffer_reserve_object.isra.13+0x77/0x190
Dec  9 21:29:42 titan vmunix:  [<ffffffff812b8171>] i915_gem_execbuffer_reserve.isra.14+0x2c1/0x320
Dec  9 21:29:42 titan vmunix:  [<ffffffff812b87b2>] i915_gem_do_execbuffer.isra.17+0x5e2/0x11b0
Dec  9 21:29:42 titan vmunix:  [<ffffffff812b9894>] i915_gem_execbuffer2+0x94/0x280
Dec  9 21:29:42 titan vmunix:  [<ffffffff81287de3>] drm_ioctl+0x493/0x530
Dec  9 21:29:42 titan vmunix:  [<ffffffff812b9800>] ? i915_gem_execbuffer+0x480/0x480
Dec  9 21:29:42 titan vmunix:  [<ffffffff810d9cbf>] do_vfs_ioctl+0x8f/0x530
Dec  9 21:29:42 titan vmunix:  [<ffffffff810da1ab>] sys_ioctl+0x4b/0x90
Dec  9 21:29:42 titan vmunix:  [<ffffffff810c9e2d>] ? sys_read+0x4d/0xa0
Dec  9 21:29:42 titan vmunix:  [<ffffffff8154a4d2>] system_call_fastpath+0x16/0x1b
Dec  9 21:29:42 titan vmunix: Code: 63 08 48 83 ec 08 e8 84 9c fb ff 4c 89 ee 4c 89 e7 e8 89 b7 15 00 48 85 c0 48 89 c6 74 41 48 8b 18 48 85 db 74 1f f6 c3 03 75 3c <8b> 53 1c 85 d2 74 d9 8d 7a 01 89 d0 f0 0f b1 7b 1c 39 c2 75 23 
Dec  9 21:29:42 titan vmunix: RIP  [<ffffffff81090b9c>] find_get_page+0x3c/0x90
Dec  9 21:29:42 titan vmunix:  RSP <ffff88014d9f7928>

It seems that whenever (if ever?) GFP_NO_KSWAPD removal is attempted again, the i915 driver will need to be taken better care of.
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
