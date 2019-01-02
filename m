Return-Path: <SRS0=6aBQ=PK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_DIGITS,
	FROM_LOCAL_HEX,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD64FC43387
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 09:01:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C29A21871
	for <linux-mm@archiver.kernel.org>; Wed,  2 Jan 2019 09:01:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C29A21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B1B58E0014; Wed,  2 Jan 2019 04:01:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 461748E0002; Wed,  2 Jan 2019 04:01:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3795B8E0014; Wed,  2 Jan 2019 04:01:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1022A8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 04:01:07 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id m128so35562086itd.3
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 01:01:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=+ZeU2Loj3fiRgLYzKIr7VX4i2u1TwHYv2Zointt6598=;
        b=D//fD2l8SYohZQ0GPjsUzug11lD8FmVOfSp8hR3pBEgJ1AIpeUfkZgE21NODK9TCGE
         yo4Wmj9RJ6stZlO9FKiroQVE20dzDpm+YfagRjXATe19FKBs7obyI8+vNpTZAo3AK76q
         9XL5PEXxQT+7L6H/q2sLh57di+G3Ev6NFYFhAPvGgYkjVtyp0VvwCAgeffPhablPViso
         IIENGbQePQps9Ki0cZ7Yue8qiYJm7fanaDFOnRA6tw1tcED9a4ugF6T44htXHx+FCfKk
         IjPqHLx6qykELzj7YVApBOoMLkm70U31vqpbvuhcmZrxXgTrP7OoFHio+snVUYahR4t9
         SZ5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 30x0sxakbagywcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=30X0sXAkbAGYWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukcBlGsBfKDdjrnHNMNd4uLyl8lJuyQds6E/5dbdlu81qPXaIVRA
	H9WWhdgQfuyq0xsARpXFSzGnsRzyEzXRuqsvLcBYoEU9TTZWFWZkk47sk95r2ziZ7IoxoCdWk05
	TTBcTNEnYRo+L/cmIC6wsDiZYZhgbzaFEooNW8JUZyHtjUjrrT9wSrEEGt5Sx3aRcnx/JSTGXTB
	XszETEsNIDWhmqCiQFCuewJbJH3MnwL9EtwGlQspicwMz+egP8kejpjRAnoEakmuljarC+xChC1
	Z0HmePsQ+5morVc/Wik84KoyBc4K9YBj3GwnIYPFHm5reZHf97KhbnEIbxccESaR3q3BROXDATA
	rW+GBZsuL7znW7gSUQuDuvGj1C/cG/AMWhElEa2G/QSLD1s/dDO743VpeUEv9Yl6GrjT8nRCcg=
	=
X-Received: by 2002:a24:ac65:: with SMTP id m37mr24905233iti.49.1546419666789;
        Wed, 02 Jan 2019 01:01:06 -0800 (PST)
X-Received: by 2002:a24:ac65:: with SMTP id m37mr24905184iti.49.1546419665824;
        Wed, 02 Jan 2019 01:01:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546419665; cv=none;
        d=google.com; s=arc-20160816;
        b=LF7aN3y0NWgjfn4SSU0zdKTwqddrgpqhJ99oO8uMVxSZYGcyq/rQFeXQI7O21zPPb3
         GdxB6VWUFYRhkJSWRfZPdwG8AIDA5CFQhM6c9BVZyoOdR2gnydswqgqBa2ZZUgBNDe+/
         KTypfO9ivaD0PKkyOlTY8ObVQYbrEQChGrbFdkuu7JU1bDYiiAzoJKckldL2XBXikfiK
         FEOPit9fEEh9l2gXAb9mRDKBeSFG9jrg1d7boIX896LzEg6Fp1HEUcCDpg5HFzGhJaxE
         by3TzXhcV3YLTbt/KRliKQJZTBI2N+k3H5zB4+GzCw0u3bCjqKLWMVHxX5uIYFOiX7xm
         wVcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=+ZeU2Loj3fiRgLYzKIr7VX4i2u1TwHYv2Zointt6598=;
        b=fmPpDyZ4r/7W6o5N0WF2bYpbqDZcd0WQQ3gFEEA8kg4kW0rDrXDLcrVcrOGSKt/YGd
         rCSY1TIdiEv3Wow2ObJl5Z/8ook4E2ZewvJgQTd5hXqcaOqKsb8rpKbU+Lq/8dnzghTw
         D+7F52V+AGAIsRc8VbyADCxzRgeDBdFWRFjJkrXmzbEvoYMD9WoCtop+VFeJ06CwZo+j
         z+FJDIK3CRX1GEzryfXT59mioWReA8xm/oYyZBT9wEzz9I0ebgt8CmVrludvhsEbiJ9G
         /baPg+PTh15SBgMqzxkzv/4C9gRK/X0Po0cg7/Z4ffodZPfurYDuSWS5xhghrFgnYbXk
         MRgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 30x0sxakbagywcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=30X0sXAkbAGYWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id v134sor31684110itb.19.2019.01.02.01.01.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 01:01:05 -0800 (PST)
Received-SPF: pass (google.com: domain of 30x0sxakbagywcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 30x0sxakbagywcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=30X0sXAkbAGYWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: AFSGD/XUm43d/ocziucXig0rdvdIkCOVb+ZGzaZX/ZMOb1FUtCVLKobGHiBfCyKqPtPaFiWA9UyPMBWyMEjCwyhFaLOq3M/Kyvwk
MIME-Version: 1.0
X-Received: by 2002:a24:46d5:: with SMTP id j204mr31854914itb.38.1546419665159;
 Wed, 02 Jan 2019 01:01:05 -0800 (PST)
Date: Wed, 02 Jan 2019 01:01:05 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000d0ce25057e75e2da@google.com>
Subject: WARNING in mem_cgroup_update_lru_size
From: syzbot <syzbot+c950a368703778078dc8@syzkaller.appspotmail.com>
To: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, mhocko@kernel.org, syzkaller-bugs@googlegroups.com, 
	vdavydov.dev@gmail.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190102090105.bh0aY9N6QPfEq9KKYNuKcuOq7Fy1-ElfoZGgFuddGeE@z>

Hello,

syzbot found the following crash on:

HEAD commit:    8e143b90e4d4 Merge tag 'iommu-updates-v4.21' of git://git...
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1250f377400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c2ab9708c613a224
dashboard link: https://syzkaller.appspot.com/bug?extid=c950a368703778078dc8
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
userspace arch: i386
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14e063fd400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+c950a368703778078dc8@syzkaller.appspotmail.com

8021q: adding VLAN 0 to HW filter on device batadv0
------------[ cut here ]------------
kasan: CONFIG_KASAN_INLINE enabled
mem_cgroup_update_lru_size(00000000e4dac0d9, 1, 1): lru_size -2032989456
kasan: GPF could be caused by NULL-ptr deref or user memory access
WARNING: CPU: 0 PID: 9560 at mm/memcontrol.c:1160  
mem_cgroup_update_lru_size+0xb2/0xe0 mm/memcontrol.c:1160
general protection fault: 0000 [#1] PREEMPT SMP KASAN
Kernel panic - not syncing: panic_on_warn set ...
CPU: 1 PID: 3 Comm:  Not tainted 4.20.0+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__read_once_size include/linux/compiler.h:191 [inline]
RIP: 0010:get_running_cputimer include/linux/sched/cputime.h:85 [inline]
RIP: 0010:account_group_system_time include/linux/sched/cputime.h:149  
[inline]
RIP: 0010:account_system_index_time+0xe8/0x5f0 kernel/sched/cputime.c:168
Code: 04 00 00 49 8b 84 24 00 07 00 00 48 ba 00 00 00 00 00 fc ff df 48 8d  
b8 40 01 00 00 48 8d 88 28 01 00 00 48 89 fe 48 c1 ee 03 <0f> b6 14 16 48  
89 fe 83 e6 07 40 38 f2 7f 08 84 d2 0f 85 93 03 00
RSP: 0018:ffff8880ae707a80 EFLAGS: 00010006
RAX: 0000000041b58ab3 RBX: 1ffff11015ce0f54 RCX: 0000000041b58bdb
RDX: dffffc0000000000 RSI: 000000000836b17e RDI: 0000000041b58bf3
RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: fffffbfff1335af5
R10: fffffbfff1301b45 R11: ffffffff899ad7a3 R12: ffff8880a94bc440
R13: 0000000000286ccf R14: 0000000000000003 R15: ffff8880ae707b20
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000008462a98 CR3: 00000000903b3000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  <IRQ>
  irqtime_account_process_tick.isra.0+0x3a2/0x490 kernel/sched/cputime.c:380
  account_process_tick+0x27f/0x350 kernel/sched/cputime.c:483
  update_process_times+0x25/0x80 kernel/time/timer.c:1633
  tick_sched_handle+0xa2/0x190 kernel/time/tick-sched.c:161
  tick_sched_timer+0x47/0x130 kernel/time/tick-sched.c:1271
  __run_hrtimer kernel/time/hrtimer.c:1389 [inline]
  __hrtimer_run_queues+0x3a7/0x1050 kernel/time/hrtimer.c:1451
  hrtimer_interrupt+0x314/0x770 kernel/time/hrtimer.c:1509
  local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1035 [inline]
  smp_apic_timer_interrupt+0x18d/0x760 arch/x86/kernel/apic/apic.c:1060
  apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
  </IRQ>
Modules linked in:
---[ end trace 29e64cfc002b0004 ]---
RIP: 0010:__read_once_size include/linux/compiler.h:191 [inline]
RIP: 0010:get_running_cputimer include/linux/sched/cputime.h:85 [inline]
RIP: 0010:account_group_system_time include/linux/sched/cputime.h:149  
[inline]
RIP: 0010:account_system_index_time+0xe8/0x5f0 kernel/sched/cputime.c:168
Code: 04 00 00 49 8b 84 24 00 07 00 00 48 ba 00 00 00 00 00 fc ff df 48 8d  
b8 40 01 00 00 48 8d 88 28 01 00 00 48 89 fe 48 c1 ee 03 <0f> b6 14 16 48  
89 fe 83 e6 07 40 38 f2 7f 08 84 d2 0f 85 93 03 00
RSP: 0018:ffff8880ae707a80 EFLAGS: 00010006
RAX: 0000000041b58ab3 RBX: 1ffff11015ce0f54 RCX: 0000000041b58bdb
RDX: dffffc0000000000 RSI: 000000000836b17e RDI: 0000000041b58bf3
RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: fffffbfff1335af5
R10: fffffbfff1301b45 R11: ffffffff899ad7a3 R12: ffff8880a94bc440
R13: 0000000000286ccf R14: 0000000000000003 R15: ffff8880ae707b20
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000008462a98 CR3: 00000000903b3000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Shutting down cpus with NMI
Kernel Offset: disabled
Rebooting in 86400 seconds..


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

