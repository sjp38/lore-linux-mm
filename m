Return-Path: <SRS0=B01V=PM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_DIGITS,
	FROM_LOCAL_HEX,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C746FC43387
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 22:58:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70098218D3
	for <linux-mm@archiver.kernel.org>; Fri,  4 Jan 2019 22:58:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70098218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C88538E010C; Fri,  4 Jan 2019 17:58:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C36A58E00F9; Fri,  4 Jan 2019 17:58:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4CB58E010C; Fri,  4 Jan 2019 17:58:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4958E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 17:58:04 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id f24so42641924ioh.21
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 14:58:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=SeiH3J+aOSGkexNtniuPt8RsV+JvKhn/e9162U4u8M8=;
        b=D7IqlLP3JWJJgcviqqrl1Kgh8r1I6FCVBd8mekfUDmmSdLmmdpIiNDEIxuKh4VN7La
         FnWgxCbA3Ftn5bm2teo8WiF5Cyt2TwUnWgEfIRQCRfdjGMiNvQofmkSnwtM1pPUNMQJV
         YvRI/XJHurduwtnIOFzX58YX/HhtJG5iejCay9A5G5xUgkmRs1C1rEg1PHjpYN/gKZ1o
         EVjP1OU7bY5NpcI6hf+/PTwv+Ce75SJ/h6PAY5L0Ef1p11m2A0zXUDwB/8hssOQRfpqS
         2/Mtk8Oiw73sUsPct33Q+ob1w9wNjdeLp+1WRoEY4DIkzk4gSXX9J7x60sSYa88XNxXf
         oWdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3-uqvxakbagsbhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3-uQvXAkbAGsbhiTJUUNaJYYRM.PXXPUNdbNaLXWcNWc.LXV@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukcLOtvUUMYdekPRcbhsBYGVFR+n5yhDvjwiWsuq67Fl49qwqvTd
	Badryw63OmwZyOjHGfMRCHFnKW5kOtKA2j4C3ICq8g63fQ7cGiPgkLXVrw4nK0KyEXBh2IW0ZQG
	xtQ+dKG2Y0zRKBFAGer/aA5DX5+3XFAjrDe+vZnbCoSBix4JTBKjPiBxNWvcJKVlpqw4rsO0PTw
	itFgUojQvjzX2107p40PzBlpJ0Pirtp6TrdlUZYWqJDLn8kR09dm2FB/FoQj7UAgIZQlB+ZVktN
	kM4REgE6mr0l3D4EuGh+XxTrJUxq2mrsPFhGkmhQQQPPAK8scnQHhDfykV4TSjeCKwTVbrB8Cqb
	oVkHHet2tQjneiNvZIX8cPHfEe9JA9u44sPWCFqOuOOJ5BFsjUPvgOz6kixOLBcKR37qLxBggg=
	=
X-Received: by 2002:a5e:de01:: with SMTP id e1mr35670380iok.137.1546642684282;
        Fri, 04 Jan 2019 14:58:04 -0800 (PST)
X-Received: by 2002:a5e:de01:: with SMTP id e1mr35670352iok.137.1546642683212;
        Fri, 04 Jan 2019 14:58:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546642683; cv=none;
        d=google.com; s=arc-20160816;
        b=ogGEIYse/eLBCN5kI4zKhCh6IYa8x3BMVbxxo75S7FbkHn+k7SMsScQ2PEnfWJM/qL
         21UMNopuqBRxmISrynqx/15TUdR8qj1exgVWZUexQolYHJ1BtBb/vB0pBhd2hUNB9+xY
         A/xn9CO2WV+9LnZjgYZfchlzGVGVR2zhQopDeY3j9wRpO+NZEtv27lur8TCWrkV7JVKD
         FqEhUxvNRnhNeJ31UtbJLARFzyrpnBI/nfxXz7887vFffPP2oarVImnZenK3cfNuJ6ai
         Kgdkmj5zPylVndwrgMIXG7+W4j5CNTqrJ+Zsqzk8gaFHgNU5RVgpm/UEckutdT0XNPAH
         B0/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=SeiH3J+aOSGkexNtniuPt8RsV+JvKhn/e9162U4u8M8=;
        b=e5huCuvPd/uJN7Id3iPiTucSRK8wIQNnDsoI9KZ/JQmG82zitK0xv0fM/JLeuFVbg0
         7TDwDYZ6Q536vKSsfzPG9E+XlWneGVj4O3+IqGEB6ixWG9MaVerIhuArQOflhxYnBMIa
         IiENSw0BngF1FppJ03ON4+WYt2M02uWqyl7ahXoZp1LE2LQZ7zSsO6EtDG+0zvDUaZfV
         Vm7ESLtVTL6dqWt8bzOPyYtTPaIIyzbrUXIdLxUM50OQuhnUgM+HgSs84ryz16dXQQhf
         EAHF0xykgToBPZXwCE7jikj4nGWSEXgAVNdwJqXEosn8XoCvWVLE5jNEXmcF68WlCx2F
         UJUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3-uqvxakbagsbhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3-uQvXAkbAGsbhiTJUUNaJYYRM.PXXPUNdbNaLXWcNWc.LXV@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 139sor4304273ity.22.2019.01.04.14.58.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 14:58:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3-uqvxakbagsbhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3-uqvxakbagsbhitjuunajyyrm.pxxpundbnalxwcnwc.lxv@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3-uQvXAkbAGsbhiTJUUNaJYYRM.PXXPUNdbNaLXWcNWc.LXV@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN5YnutGnfi2QnbRzhcX+IzuaIKLSffbG85A8hQfGU2wAoggEnBJ66zX5WCWzU1dmWPx5BygwQ4gXgDXi4kN+bfLo+axZkpb
MIME-Version: 1.0
X-Received: by 2002:a24:5f93:: with SMTP id r141mr2423529itb.4.1546642682957;
 Fri, 04 Jan 2019 14:58:02 -0800 (PST)
Date: Fri, 04 Jan 2019 14:58:02 -0800
In-Reply-To: <000000000000d0ce25057e75e2da@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000b65931057ea9cf82@google.com>
Subject: Re: WARNING in mem_cgroup_update_lru_size
From: syzbot <syzbot+c950a368703778078dc8@syzkaller.appspotmail.com>
To: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, mhocko@kernel.org, netdev@vger.kernel.org, 
	syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190104225802.tlb5ve9zC9UH5WvhgkmuyEGuST8mAlsyywtMuErQ-Pg@z>

syzbot has found a reproducer for the following crash on:

HEAD commit:    96d4f267e40f Remove 'type' argument from access_ok() funct..
git tree:       net
console output: https://syzkaller.appspot.com/x/log.txt?x=160c9a80c00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=7308e68273924137
dashboard link: https://syzkaller.appspot.com/bug?extid=c950a368703778078dc8
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=125376bb400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=121d85ab400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+c950a368703778078dc8@syzkaller.appspotmail.com

------------[ cut here ]------------
kasan: CONFIG_KASAN_INLINE enabled
mem_cgroup_update_lru_size(00000000d6ca43c5, 1, 1): lru_size -2032898272
kasan: GPF could be caused by NULL-ptr deref or user memory access
WARNING: CPU: 0 PID: 11430 at mm/memcontrol.c:1160  
mem_cgroup_update_lru_size+0xb2/0xe0 mm/memcontrol.c:1160
general protection fault: 0000 [#1] PREEMPT SMP KASAN
Kernel panic - not syncing: panic_on_warn set ...
CPU: 1 PID: 4 Comm:  Not tainted 4.20.0+ #8
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
RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: ffffffff8a9a805d
R10: ffffffff8a9a8050 R11: 0000000000000001 R12: ffff8880a94bc440
R13: 0000000000981859 R14: 0000000000000003 R15: ffff8880ae707b20
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000006dae70 CR3: 0000000086205000 CR4: 00000000001406e0
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
---[ end trace 42848964955b563b ]---
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
RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: ffffffff8a9a805d
R10: ffffffff8a9a8050 R11: 0000000000000001 R12: ffff8880a94bc440
R13: 0000000000981859 R14: 0000000000000003 R15: ffff8880ae707b20
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000006dae70 CR3: 0000000086205000 CR4: 00000000001406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Shutting down cpus with NMI
Kernel Offset: disabled
Rebooting in 86400 seconds..

