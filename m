Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 262006B0074
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 07:50:35 -0500 (EST)
Received: by wwg38 with SMTP id 38so5134787wwg.26
        for <linux-mm@kvack.org>; Fri, 25 Nov 2011 04:50:31 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 25 Nov 2011 18:20:31 +0530
Message-ID: <CAFPAmTQCcWf0yLm239b_fQTv9CY9t=B5gUrDO1wKM97pyrJurQ@mail.gmail.com>
Subject: linux-2.6.35.13: Schedule while atomic bug and kernel crash in kswapd.
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

I am running linux-2.6.35.31 on my ARM system and I got around 197
schedule while atomics and then finally a kernel crash.

Can anyone suggest some MMpatches to apply on this fix this problem ?

I got the following schedule while atomic log around 197 times:
------------------------------------------------------------------------------------------
Backtrace(CPU 0):
[<c00393a0>] (dump_backtrace+0x0/0x11c) from [<c0393728>] (dump_stack+0x20/0x24)
[<c0393708>] (dump_stack+0x0/0x24) from [<c0058ad0>] (__schedule_bug+0x70/0x7c)
[<c0058a60>] (__schedule_bug+0x0/0x7c) from [<c03939f8>] (schedule+0x74/0x5a4)
  r5:d2002000 r4:d1f79440
 [<c0393984>] (schedule+0x0/0x5a4) from [<c03948a0>]
(schedule_timeout+0x2c8/0x304)
 [<c03945d8>] (schedule_timeout+0x0/0x304) from [<c0393958>]
(io_schedule_timeout+0x50/0x7c)
  r7:d1f79440 r6:d2002000 r5:c04c0088 r4:c04bfc88
 [<c0393908>] (io_schedule_timeout+0x0/0x7c) from [<c0109cbc>]
(congestion_wait+0x7c/0xa0)
  r6:00000019 r5:c04c6230 r4:d2003edc r3:00000000
 [<c0109c40>] (congestion_wait+0x0/0xa0) from [<c0102268>] (kswapd+0x594/0x61c)
  r7:00000000 r6:c04d7a28 r5:00000008 r4:c04d76f4
 [<c0101cd4>] (kswapd+0x0/0x61c) from [<c007db6c>] (kthread+0x90/0x98)
 [<c007dadc>] (kthread+0x0/0x98) from [<c00642f4>] (do_exit+0x0/0x708)
  r7:00000013 r6:c00642f4 r5:c007dadc r4:d1f47f3c
 BUG: scheduling while atomic: kswapd0/16/0x00000000

Finally, I got the following kernel crash:
--------------------------------------------------------
 CPU: 0    Tainted: P             (2.6.35.13 #1)
PC is at __bug+0x2c/0x38
LR is at sub_preempt_count+0x48/0x64
pc : [<c00390dc>]    lr : [<c0398984>]    psr: 60000193
sp : d2003d78  ip : d2003cb0  fp : d2003d84
r10: 00000004  r9 : 00c83880  r8 : c0647838
r7 : c04d7960  r6 : 00000004  r5 : c0647820  r4 : d2003e64
r3 : 00000000  r2 : d2003cc8  r1 : c0398978  r0 : 00000034
Flags: nZCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 10c53c7d  Table: 7aad4059  DAC: 00000017
Process kswapd0 (pid: 16, stack limit = 0xd20022e8)
Stack: (0xd2003d78 to 0xd2004000)
3d60:                                                       d2003dd4 d2003d88
3d80: c00ffd74 c00390bc d2003e6c 00000020 00000000 000641c4 fffffffc 00000002
3da0: 000641c3 00000004 00000005 c04d76f4 d2002000 d2003f44 c04d79f4 c04d79f8
3dc0: 00000000 00000000 d2003e9c d2003dd8 c010117c c00ffc54 00000002 c04d76f4
3de0: 00000000 00000001 00000020 00000000 00000001 c04d79ac c04d79b4 00000000
3e00: 1ae147ae c04d79a8 c04d79b0 c007dadc 00000000 00000001 d2003e3c d2003e28
3e20: c00fbd50 c00ff0b4 00000000 d2003e84 d2003e7c d2003e40 c00fbde4 c00fbd3c
3e40: c0061d80 d2003e60 d2003e60 d2003eb4 00000000 00000000 00000000 00000000
3e60: 00000000 c0647858 c0647878 00000000 d2003e9c 00000002 00000002 00000008
3e80: d2003f44 c04d76f4 00000000 00000000 d2003f0c d2003ea0 c0101a68 c0100fb0
3ea0: 00000008 d2003eb0 00000000 ffffffff 00000000 00000002 d2003ed4 00000000
3ec0: 00000000 00000010 0000002a c04d76f4 00000048 00000000 0001b836 00000000
3ee0: 00000000 c04d76f4 00000008 c04d76f4 00000000 c04d76f4 00000000 00000001
3f00: d2003fc4 d2003f10 c01020fc c0101714 00000000 c0055d4c c005a728 00000002
3f20: d2003f94 00000001 d2002000 0000ffbc 00000002 00000000 00000000 c04d7d90
3f40: c0393ec4 00000000 00000000 ffffffff 00000000 000000d0 00000001 00000001
3f60: 00000001 0000003c 00000002 00000001 00000000 00000000 00000000 d1f79440
3f80: c007e048 d2003f84 d2003f84 00000008 c0393ec4 00000000 00000000 d1f47f3c
3fa0: d2003fcc c0101cd4 c04d76f4 00000000 00000000 00000000 d2003ff4 d2003fc8
3fc0: c007db6c c0101ce0 00000000 00000000 d2003fd0 d2003fd0 d1f47f3c c007dadc
3fe0: c00642f4 00000013 00000000 d2003ff8 c00642f4 c007dae8 ff7f7fff beffffff
Backtrace(CPU 0):
[<c00390b0>] (__bug+0x0/0x38) from [<c00ffd74>]
(isolate_pages_global+0x12c/0x2c0)
[<c00ffc48>] (isolate_pages_global+0x0/0x2c0) from [<c010117c>]
(shrink_list+0x1d8/0x764)
[<c0100fa4>] (shrink_list+0x0/0x764) from [<c0101a68>] (shrink_zone+0x360/0x418)
[<c0101708>] (shrink_zone+0x0/0x418) from [<c01020fc>] (kswapd+0x428/0x61c)
[<c0101cd4>] (kswapd+0x0/0x61c) from [<c007db6c>] (kthread+0x90/0x98)
[<c007dadc>] (kthread+0x0/0x98) from [<c00642f4>] (do_exit+0x0/0x708)
r7:00000013 r6:c00642f4 r5:c007dadc r4:d1f47f3c
Code: e59f0010 e1a01003 eb0d69d2 e3a03000 (e5833000)

Thanks,
Kautuk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
