Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 69A4C900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 19:25:04 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p3SNP1NK025820
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:25:01 -0700
Received: from qwi4 (qwi4.prod.google.com [10.241.195.4])
	by hpaq7.eem.corp.google.com with ESMTP id p3SNOx5g027739
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:24:59 -0700
Received: by qwi4 with SMTP id 4so3272946qwi.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:24:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1304030226-19332-1-git-send-email-yinghan@google.com>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
Date: Thu, 28 Apr 2011 16:24:58 -0700
Message-ID: <BANLkTikgpyyZxcTP4f3y9XDYij_SNsng6Q@mail.gmail.com>
Subject: Re: [PATCH 0/2] memcg: add the soft_limit reclaim in global direct reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, kamezawa.hiroyuki@gmail.com
Cc: linux-mm@kvack.org

On Thu, Apr 28, 2011 at 3:37 PM, Ying Han <yinghan@google.com> wrote:
> We recently added the change in global background reclaim which counts th=
e
> return value of soft_limit reclaim. Now this patch adds the similar logic
> on global direct reclaim.
>
> We should skip scanning global LRU on shrink_zone if soft_limit reclaim d=
oes
> enough work. This is the first step where we start with counting the nr_s=
canned
> and nr_reclaimed from soft_limit reclaim into global scan_control.
>
> The patch is based on mmotm-04-14 and i triggered kernel BUG at mm/vmscan=
.c:1058!
>
> [ =A0938.242033] kernel BUG at mm/vmscan.c:1058!
> [ =A0938.242033] invalid opcode: 0000 [#1] SMP=B7
> [ =A0938.242033] last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/de=
vice
> [ =A0938.242033] Pid: 546, comm: kswapd0 Tainted: G =A0 =A0 =A0 =A0W =A0 =
2.6.39-smp-direct_reclaim
> [ =A0938.242033] RIP: 0010:[<ffffffff810ed174>] =A0[<ffffffff810ed174>] i=
solate_pages_global+0x18c/0x34f
> [ =A0938.242033] RSP: 0018:ffff88082f83bb50 =A0EFLAGS: 00010082
> [ =A0938.242033] RAX: 00000000ffffffea RBX: ffff88082f83bc90 RCX: 0000000=
000000401
> [ =A0938.242033] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffea0=
01ca653e8
> [ =A0938.242033] RBP: ffff88082f83bc20 R08: 0000000000000000 R09: ffff880=
85ffb6e00
> [ =A0938.242033] R10: ffff88085ffb73d0 R11: ffff88085ffb6e00 R12: ffff880=
85ffb6e00
> [ =A0938.242033] R13: ffffea001ca65410 R14: 0000000000000001 R15: ffffea0=
01ca653e8
> [ =A0938.242033] FS: =A00000000000000000(0000) GS:ffff88085fd00000(0000) =
knlGS:0000000000000000
> [ =A0938.242033] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ =A0938.242033] CR2: 00007f5c3405c320 CR3: 0000000001803000 CR4: 0000000=
0000006e0
> [ =A0938.242033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000=
000000000
> [ =A0938.242033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000=
000000400
> [ =A0938.242033] Process kswapd0 (pid: 546, threadinfo ffff88082f83a000, =
task ffff88082fe52080)
> [ =A0938.242033] Stack:
> [ =A0938.242033] =A0ffff88085ffb6e00 ffffea0000000002 0000000000000021 00=
00000000000000
> [ =A0938.242033] =A00000000000000000 ffff88082f83bcb8 ffffea00108eec80 ff=
ffea00108eecb8
> [ =A0938.242033] =A0ffffea00108eecf0 0000000000000004 fffffffffffffffc 00=
00000000000020
> [ =A0938.242033] Call Trace:
> [ =A0938.242033] =A0[<ffffffff810ee8a5>] shrink_inactive_list+0x185/0x418
> [ =A0938.242033] =A0[<ffffffff810366cc>] ? __switch_to+0xea/0x212
> [ =A0938.242033] =A0[<ffffffff810e8b35>] ? determine_dirtyable_memory+0x1=
a/0x2c
> [ =A0938.242033] =A0[<ffffffff810ef19b>] shrink_zone+0x380/0x44d
> [ =A0938.242033] =A0[<ffffffff810e5188>] ? zone_watermark_ok_safe+0xa1/0x=
ae
> [ =A0938.242033] =A0[<ffffffff810efbd8>] kswapd+0x41b/0x76b
> [ =A0938.242033] =A0[<ffffffff810ef7bd>] ? zone_reclaim+0x2fb/0x2fb
> [ =A0938.242033] =A0[<ffffffff81088569>] kthread+0x82/0x8a
> [ =A0938.242033] =A0[<ffffffff8141b0d4>] kernel_thread_helper+0x4/0x10
> [ =A0938.242033] =A0[<ffffffff810884e7>] ? kthread_worker_fn+0x112/0x112
> [ =A0938.242033] =A0[<ffffffff8141b0d0>] ? gs_change+0xb/0xb
>
> Thank you Minchan for the pointer. I reverted the following commit and I
> haven't seen the problem with the same operation. I haven't looked deeply
> on the patch yet, but figured it would be a good idea to post the dump.
> The dump looks not directly related to this patchset, but ppl can use it =
to
> reproduce the problem.
>
> commit 278df9f451dc71dcd002246be48358a473504ad0
> Author: Minchan Kim <minchan.kim@gmail.com>
> Date: =A0 Tue Mar 22 16:32:54 2011 -0700
>
> =A0 mm: reclaim invalidated page ASAP
>
> How to reproduce it, On my 32G of machine
> 1. I create two memcgs and set their hard_limit and soft_limit:
> $echo 20g >A/memory.limit_in_bytes
> $echo 20g >B/memory.limit_in_bytes
> $echo 3g >A/memory.soft_limit_in_bytes
> $echo 3g >B/memory.soft_limit_in_bytes
>
> 2. Reading a 20g file on each container
> $echo $$ >A/tasks
> $cat /export/hdc3/dd_A/tf0 > /dev/zero
>
> $echo $$ >B/tasks
> $cat /export/hdc3/dd_B/tf0 > /dev/zero
>
> 3. Add memory pressure by allocating anon + mlock. And trigger global
> reclaim.
>
> Ying Han (2):
> =A0Add the soft_limit reclaim in global direct reclaim.
> =A0Add stats to monitor soft_limit reclaim
>
> =A0Documentation/cgroups/memory.txt | =A0 10 ++++-
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 68 ++++++++++=
++++++++++++++++++----------
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 16 ++++++=
++-
> =A03 files changed, 72 insertions(+), 22 deletions(-)
>
> --
> 1.7.3.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
