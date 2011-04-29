Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF7F900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 13:17:26 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3THHLc9013124
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:17:23 -0700
Received: from qyk27 (qyk27.prod.google.com [10.241.83.155])
	by hpaq2.eem.corp.google.com with ESMTP id p3THFlWi024674
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:17:19 -0700
Received: by qyk27 with SMTP id 27so2599987qyk.6
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:17:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110429102307.GJ6547@balbir.in.ibm.com>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
	<20110429102307.GJ6547@balbir.in.ibm.com>
Date: Fri, 29 Apr 2011 10:17:19 -0700
Message-ID: <BANLkTinc-N9CuPNCiriDY+05-B3U1XuA4A@mail.gmail.com>
Subject: Re: [PATCH 0/2] memcg: add the soft_limit reclaim in global direct reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri, Apr 29, 2011 at 3:23 AM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * Ying Han <yinghan@google.com> [2011-04-28 15:37:04]:
>
>> We recently added the change in global background reclaim which counts t=
he
>> return value of soft_limit reclaim. Now this patch adds the similar logi=
c
>> on global direct reclaim.
>>
>
> Sorry, I missed much of that discussion, I was away. I'll try and
> catch up with them soon.
>
>> We should skip scanning global LRU on shrink_zone if soft_limit reclaim =
does
>> enough work. This is the first step where we start with counting the nr_=
scanned
>> and nr_reclaimed from soft_limit reclaim into global scan_control.
>>
>> The patch is based on mmotm-04-14 and i triggered kernel BUG at mm/vmsca=
n.c:1058!
>>
>> [ =A0938.242033] kernel BUG at mm/vmscan.c:1058!
>> [ =A0938.242033] invalid opcode: 0000 [#1] SMP=B7
>> [ =A0938.242033] last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/d=
evice
>> [ =A0938.242033] Pid: 546, comm: kswapd0 Tainted: G =A0 =A0 =A0 =A0W =A0=
 2.6.39-smp-direct_reclaim
>> [ =A0938.242033] RIP: 0010:[<ffffffff810ed174>] =A0[<ffffffff810ed174>] =
isolate_pages_global+0x18c/0x34f
>> [ =A0938.242033] RSP: 0018:ffff88082f83bb50 =A0EFLAGS: 00010082
>> [ =A0938.242033] RAX: 00000000ffffffea RBX: ffff88082f83bc90 RCX: 000000=
0000000401
>> [ =A0938.242033] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffea=
001ca653e8
>> [ =A0938.242033] RBP: ffff88082f83bc20 R08: 0000000000000000 R09: ffff88=
085ffb6e00
>> [ =A0938.242033] R10: ffff88085ffb73d0 R11: ffff88085ffb6e00 R12: ffff88=
085ffb6e00
>> [ =A0938.242033] R13: ffffea001ca65410 R14: 0000000000000001 R15: ffffea=
001ca653e8
>> [ =A0938.242033] FS: =A00000000000000000(0000) GS:ffff88085fd00000(0000)=
 knlGS:0000000000000000
>> [ =A0938.242033] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [ =A0938.242033] CR2: 00007f5c3405c320 CR3: 0000000001803000 CR4: 000000=
00000006e0
>> [ =A0938.242033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000=
0000000000
>> [ =A0938.242033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000=
0000000400
>> [ =A0938.242033] Process kswapd0 (pid: 546, threadinfo ffff88082f83a000,=
 task ffff88082fe52080)
>> [ =A0938.242033] Stack:
>> [ =A0938.242033] =A0ffff88085ffb6e00 ffffea0000000002 0000000000000021 0=
000000000000000
>> [ =A0938.242033] =A00000000000000000 ffff88082f83bcb8 ffffea00108eec80 f=
fffea00108eecb8
>> [ =A0938.242033] =A0ffffea00108eecf0 0000000000000004 fffffffffffffffc 0=
000000000000020
>> [ =A0938.242033] Call Trace:
>> [ =A0938.242033] =A0[<ffffffff810ee8a5>] shrink_inactive_list+0x185/0x41=
8
>> [ =A0938.242033] =A0[<ffffffff810366cc>] ? __switch_to+0xea/0x212
>> [ =A0938.242033] =A0[<ffffffff810e8b35>] ? determine_dirtyable_memory+0x=
1a/0x2c
>> [ =A0938.242033] =A0[<ffffffff810ef19b>] shrink_zone+0x380/0x44d
>> [ =A0938.242033] =A0[<ffffffff810e5188>] ? zone_watermark_ok_safe+0xa1/0=
xae
>> [ =A0938.242033] =A0[<ffffffff810efbd8>] kswapd+0x41b/0x76b
>> [ =A0938.242033] =A0[<ffffffff810ef7bd>] ? zone_reclaim+0x2fb/0x2fb
>> [ =A0938.242033] =A0[<ffffffff81088569>] kthread+0x82/0x8a
>> [ =A0938.242033] =A0[<ffffffff8141b0d4>] kernel_thread_helper+0x4/0x10
>> [ =A0938.242033] =A0[<ffffffff810884e7>] ? kthread_worker_fn+0x112/0x112
>> [ =A0938.242033] =A0[<ffffffff8141b0d0>] ? gs_change+0xb/0xb
>
> What is gs_change()?

[  938.242033] Pid: 546, comm: kswapd0 Tainted: G        W
2.6.39-smp-direct_reclaim #25 Intel Greencreek,ESB2/Ilium_IN_03
[  938.242033] RIP: 0010:[<ffffffff810ed174>]  [<ffffffff810ed174>]
isolate_pages_global+0x18c/0x34f
[  938.242033] RSP: 0018:ffff88082f83bb50  EFLAGS: 00010082
[  938.242033] RAX: 00000000ffffffea RBX: ffff88082f83bc90 RCX: 00000000000=
00401
[  938.242033] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffea001ca=
653e8
[  938.242033] RBP: ffff88082f83bc20 R08: 0000000000000000 R09: ffff88085ff=
b6e00
[  938.242033] R10: ffff88085ffb73d0 R11: ffff88085ffb6e00 R12: ffff88085ff=
b6e00
[  938.242033] R13: ffffea001ca65410 R14: 0000000000000001 R15: ffffea001ca=
653e8
[  938.242033] FS:  0000000000000000(0000) GS:ffff88085fd00000(0000)
knlGS:0000000000000000
[  938.242033] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  938.242033] CR2: 00007f5c3405c320 CR3: 0000000001803000 CR4: 00000000000=
006e0
[  938.242033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[  938.242033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[  938.242033] Process kswapd0 (pid: 546, threadinfo ffff88082f83a000,
task ffff88082fe52080)
[  938.242033] Stack:
[  938.242033]  ffff88085ffb6e00 ffffea0000000002 0000000000000021
0000000000000000
[  938.242033]  0000000000000000 ffff88082f83bcb8 ffffea00108eec80
ffffea00108eecb8
[  938.242033]  ffffea00108eecf0 0000000000000004 fffffffffffffffc
0000000000000020
[  938.242033] Call Trace:
[  938.242033]  [<ffffffff810ee8a5>] shrink_inactive_list+0x185/0x418
[  938.242033]  [<ffffffff810366cc>] ? __switch_to+0xea/0x212
[  938.242033]  [<ffffffff810e8b35>] ? determine_dirtyable_memory+0x1a/0x2c
[  938.242033]  [<ffffffff810ef19b>] shrink_zone+0x380/0x44d
[  938.242033]  [<ffffffff810e5188>] ? zone_watermark_ok_safe+0xa1/0xae
[  938.242033]  [<ffffffff810efbd8>] kswapd+0x41b/0x76b
[  938.242033]  [<ffffffff810ef7bd>] ? zone_reclaim+0x2fb/0x2fb
[  938.242033]  [<ffffffff81088569>] kthread+0x82/0x8a
[  938.242033]  [<ffffffff8141b0d4>] kernel_thread_helper+0x4/0x10
[  938.242033]  [<ffffffff810884e7>] ? kthread_worker_fn+0x112/0x112
[  938.242033]  [<ffffffff8141b0d0>] ? gs_change+0xb/0xb
[  938.242033] Code: 45 d8 25 00 00 08 00 48 83 f8 01 49 8b 45 d8 19
f6 83 e6 02 83 e0 40 48 83 f8 01 83 de ff 4c 89 ff e8 4c 15 03 00 e9
2e 01 00 00 <0f> 0b eb fe 49 8b 45 d8 48 b9 00 00 00 00 00 16 00 00 4c
8b 75=B7
[  938.242033] RIP  [<ffffffff810ed174>] isolate_pages_global+0x18c/0x34f
[  938.242033]  RSP <ffff88082f83bb50>
[  938.242033] ---[ end trace 8af2d95d2c95696c ]---
[  938.242033] Kernel panic - not syncing: Fatal exception
[  938.242033] Pid: 546, comm: kswapd0 Tainted: G      D W
2.6.39-smp-direct_reclaim #25
[  938.242033] Call Trace:
[  938.242033]  [<ffffffff814118d8>] panic+0x91/0x194
[  938.242033]  [<ffffffff81414888>] oops_end+0xae/0xbe
[  938.242033]  [<ffffffff81039906>] die+0x5a/0x63
[  938.242033]  [<ffffffff81414321>] do_trap+0x121/0x130
[  938.242033]  [<ffffffff81037e85>] do_invalid_op+0x96/0x9f
[  938.242033]  [<ffffffff810ed174>] ? isolate_pages_global+0x18c/0x34f
[  938.242033]  [<ffffffff810ed677>] ? free_page_list+0xcc/0xda
[  938.242033]  [<ffffffff8141af55>] invalid_op+0x15/0x20
[  938.242033]  [<ffffffff810ed174>] ? isolate_pages_global+0x18c/0x34f
[  938.242033]  [<ffffffff810ee8a5>] shrink_inactive_list+0x185/0x418
[  938.242033]  [<ffffffff810366cc>] ? __switch_to+0xea/0x212
[  938.242033]  [<ffffffff810e8b35>] ? determine_dirtyable_memory+0x1a/0x2c
[  938.242033]  [<ffffffff810ef19b>] shrink_zone+0x380/0x44d
[  938.242033]  [<ffffffff810e5188>] ? zone_watermark_ok_safe+0xa1/0xae
[  938.242033]  [<ffffffff810efbd8>] kswapd+0x41b/0x76b
[  938.242033]  [<ffffffff810ef7bd>] ? zone_reclaim+0x2fb/0x2fb
[  938.242033]  [<ffffffff81088569>] kthread+0x82/0x8a
[  938.242033]  [<ffffffff8141b0d4>] kernel_thread_helper+0x4/0x10
[  938.242033]  [<ffffffff810884e7>] ? kthread_worker_fn+0x112/0x112
[  938.242033]  [<ffffffff8141b0d0>] ? gs_change+0xb/0xb
[  938.242033] Rebooting in 10 seconds..


>
>>
>> Thank you Minchan for the pointer. I reverted the following commit and I
>> haven't seen the problem with the same operation. I haven't looked deepl=
y
>> on the patch yet, but figured it would be a good idea to post the dump.
>> The dump looks not directly related to this patchset, but ppl can use it=
 to
>> reproduce the problem.
>>
>> commit 278df9f451dc71dcd002246be48358a473504ad0
>> Author: Minchan Kim <minchan.kim@gmail.com>
>> Date: =A0 Tue Mar 22 16:32:54 2011 -0700
>>
>> =A0 =A0mm: reclaim invalidated page ASAP
>>
>> How to reproduce it, On my 32G of machine
>> 1. I create two memcgs and set their hard_limit and soft_limit:
>> $echo 20g >A/memory.limit_in_bytes
>> $echo 20g >B/memory.limit_in_bytes
>> $echo 3g >A/memory.soft_limit_in_bytes
>> $echo 3g >B/memory.soft_limit_in_bytes
>>
>> 2. Reading a 20g file on each container
>> $echo $$ >A/tasks
>> $cat /export/hdc3/dd_A/tf0 > /dev/zero
>>
>> $echo $$ >B/tasks
>> $cat /export/hdc3/dd_B/tf0 > /dev/zero
>>
>> 3. Add memory pressure by allocating anon + mlock. And trigger global
>> reclaim.
>>
>
> I am sorry, but the summary leaves me confused about the patchset. You
> mentioned adding memcg scan and reclaim, but then quickly shift focus
> to the stacktrace.

Sorry about the confusion. I wasn't quite sure what exactly the best
way to report the problem. I
saw the BUG while testing my patch, but didn't get time to reproduce
it w/o it. Meantime, I feel
the BUG has nothing to do with the patch itself. So I end up posting
BUG and the patch which
can help to reproduce the BUG.

--Ying
>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
