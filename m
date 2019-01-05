Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0421CC43444
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 08:11:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ECC1218DE
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 08:11:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lQ0oaOye"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ECC1218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB5D08E011A; Sat,  5 Jan 2019 03:11:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D63138E00F9; Sat,  5 Jan 2019 03:11:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C78FA8E011A; Sat,  5 Jan 2019 03:11:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A11D28E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 03:11:09 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id h7so44178355iof.19
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 00:11:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=cIs0x50wlTwnIomvIy5lwTIVwX6fTi46qI2POylPo4s=;
        b=ApBO5LhCeZ2on09zCq3qmqJQnLxWZlQ4J9+DXjkvy73CbsUX/LftlK7UVM5lMKAZlk
         cAVY5bb5oVFND5hZ2SZaMbHYm7xbc9o9w9MmH8qTxlSCe3d9y9MARlMWcXa32JFx+1pe
         9OzmNUrlz7UV+LsPd1SCTmx217dDmb9eJvX6Zt8/Hmp4uBxX98NAv/5r49M6/yxNxUmQ
         xDQa6eeH9eORMUFu/kToj9ynbHk3x0OtTiPbKIn9mMBHsPvzFAlnEXU0eJyLSYmIg7qn
         iXKvgUz1dq0jUpZm5SFUHLCp2TH2lz49JZOouvMsOECdsOx9YnmeX+iDNfc3OETWMg3B
         zi/w==
X-Gm-Message-State: AA+aEWZwTEvPqsh+IHvQmhBNn6MT1ix0lKpseSOzRPqnphepQ4yiLAZX
	EHITRCCi7kNgukYuQVz/H5JMxoACc3eeo+YD2n8+4yvj0jrlNPZFUvdV4EQChhKNcsPD0SggzP3
	U59fyI7l1o8PgvgXCF3T3jWxE47XiruXuQCC6ATz+L0Bwvs1XRpE7mfXfOt6KYIEiyU5BQk5+Qm
	XTCOnaM/lT7HudfGJ36cl7I98l/vcq5a7RVPF9H+dVCGy0bOO4IRH6TnIkRVDeTu6OsrFrK0yue
	OhLSO2+85GBIaqzQnF6aai3PYu46JOrci821KscCBI71C3dx/3ht7/hExr4d3K7Nnpn/PR3HUol
	6R/To02L+iWxpoZCTpFXcpcPcgKNwZ8+jXdue9mYHgQJVDtRpkiMxSEKGeWFGtG7pZrdXZv/qkW
	9
X-Received: by 2002:a02:49c9:: with SMTP id p70mr36661248jad.40.1546675869331;
        Sat, 05 Jan 2019 00:11:09 -0800 (PST)
X-Received: by 2002:a02:49c9:: with SMTP id p70mr36661225jad.40.1546675868257;
        Sat, 05 Jan 2019 00:11:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546675868; cv=none;
        d=google.com; s=arc-20160816;
        b=0gs9Qy0ISM5pi1GQRiuoElEhe1Kfk8FJShe6/3MWTuYTIEN/avtd8xeyQeQKAmunIu
         xmqnjN1y8yoUZfCvWMd3rQogmbJq5z+6Cpu3//EJe1jdejJs57yi50zNimGfE36KC13u
         VbErT9TFoMwTYUCncUjPNRy6deFkHoM9Id/+jVfYfWmevpqHDn3z0/rbdERsWGxz8mvw
         BKxxRc2KIu4bx8rFKnsovTz7NRYQh9fPWhFtDmmE/z4MmQGYzfohT/r9vj4KIxCk8oDz
         BagRxQsjh9zTuUMJyT73dfJfEXqlaYo+st4dNuhdU1xq1AzdEAYum8YVaIQJeYlR8c8H
         XBLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cIs0x50wlTwnIomvIy5lwTIVwX6fTi46qI2POylPo4s=;
        b=uwBQJZ3rlveW/EEUQrT26Jr0ebn0rDk9yZLw1ezzZzivXPmbxpNHdVm6X9fCNGKv/7
         QOaCd9VQr4GhoGK+X5UeGxfOMXVTHXtMfSG9geZsyc3FBBAnnti42g/Weqzw/jP/RqfY
         V6Lw0I5d9DYyVlNKy4Z2nEss9e5aqw00d/nLSWemkNYKlHFLa0wtwCVRik+MPfzAQJ1f
         TMEurXuoOkZtquV58D/m7MfqmmjONL/HvqgJqhrtTEC2TY54R9dz81huR+PccnwaY5am
         SjebNgdoO00OmPoKkPc2XMDEOyxFuZdtOpyOK9AtYOyy2Swa+/6q8A8vVS8NpWu4f2lY
         mZew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lQ0oaOye;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r185sor5198050ita.21.2019.01.05.00.11.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 00:11:08 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=lQ0oaOye;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cIs0x50wlTwnIomvIy5lwTIVwX6fTi46qI2POylPo4s=;
        b=lQ0oaOyeEOcC0Pf8NCXim2giwyDcsUNJGrpEj5p9DC6xR3coODKIU+bVVs9iuvg2Oe
         20oNfPD03VFVyd++tIQ/XlHX6+F9nphu2ujRCgU1JRmgd49GzizQ9c4G5DYLysgndz6h
         QLtvz2UBRcJxYu03HpcYbj0PLkQfjaPXMcWHta4TbgJY9+lJqEIHpr1UUs90BMFWBKX8
         9CJ9n7N/Ilulo6mVQlumfp5Uc+S+gMUw2/m6fACiuLIAfH7AEX8yaq5RlU0YirRNi2ao
         WRiI7lcOizkk674S0TI74rvt6WqalGT3nq8pPDA7JQw+5lqUScNjprIfpl6kJHkGl3VE
         UDww==
X-Google-Smtp-Source: ALg8bN6u5n2IvXceWoXop7+MJk9u7e6s2Plf0gzsT7OprDyml/6ON/jR3JAJHPQTaNwhS6Twy5HIsvRsVEKS1SB8G3Q=
X-Received: by 2002:a24:f14d:: with SMTP id q13mr2658620iti.166.1546675867621;
 Sat, 05 Jan 2019 00:11:07 -0800 (PST)
MIME-Version: 1.0
References: <000000000000d0ce25057e75e2da@google.com> <000000000000b65931057ea9cf82@google.com>
In-Reply-To: <000000000000b65931057ea9cf82@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sat, 5 Jan 2019 09:10:56 +0100
Message-ID:
 <CACT4Y+ZsitqhD6RYxMRcwrhnevT48xgd+BU0EJo6uBc-gyT0+w@mail.gmail.com>
Subject: Re: WARNING in mem_cgroup_update_lru_size
To: syzbot <syzbot+c950a368703778078dc8@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, netdev <netdev@vger.kernel.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105081056.sAdIyw0UYDTXrEh44VcrFwRKwdv_bEDWLwVXfQQ7gEE@z>

On Fri, Jan 4, 2019 at 11:58 PM syzbot
<syzbot+c950a368703778078dc8@syzkaller.appspotmail.com> wrote:
>
> syzbot has found a reproducer for the following crash on:
>
> HEAD commit:    96d4f267e40f Remove 'type' argument from access_ok() funct..
> git tree:       net
> console output: https://syzkaller.appspot.com/x/log.txt?x=160c9a80c00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=7308e68273924137
> dashboard link: https://syzkaller.appspot.com/bug?extid=c950a368703778078dc8
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=125376bb400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=121d85ab400000
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+c950a368703778078dc8@syzkaller.appspotmail.com

Based on the repro looks like another incarnation of:
#syz dup: kernel panic: stack is corrupted in udp4_lib_lookup2
https://syzkaller.appspot.com/bug?id=4821de869e3d78a255a034bf212a4e009f6125a7



> ------------[ cut here ]------------
> kasan: CONFIG_KASAN_INLINE enabled
> mem_cgroup_update_lru_size(00000000d6ca43c5, 1, 1): lru_size -2032898272
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> WARNING: CPU: 0 PID: 11430 at mm/memcontrol.c:1160
> mem_cgroup_update_lru_size+0xb2/0xe0 mm/memcontrol.c:1160
> general protection fault: 0000 [#1] PREEMPT SMP KASAN
> Kernel panic - not syncing: panic_on_warn set ...
> CPU: 1 PID: 4 Comm:  Not tainted 4.20.0+ #8
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:__read_once_size include/linux/compiler.h:191 [inline]
> RIP: 0010:get_running_cputimer include/linux/sched/cputime.h:85 [inline]
> RIP: 0010:account_group_system_time include/linux/sched/cputime.h:149
> [inline]
> RIP: 0010:account_system_index_time+0xe8/0x5f0 kernel/sched/cputime.c:168
> Code: 04 00 00 49 8b 84 24 00 07 00 00 48 ba 00 00 00 00 00 fc ff df 48 8d
> b8 40 01 00 00 48 8d 88 28 01 00 00 48 89 fe 48 c1 ee 03 <0f> b6 14 16 48
> 89 fe 83 e6 07 40 38 f2 7f 08 84 d2 0f 85 93 03 00
> RSP: 0018:ffff8880ae707a80 EFLAGS: 00010006
> RAX: 0000000041b58ab3 RBX: 1ffff11015ce0f54 RCX: 0000000041b58bdb
> RDX: dffffc0000000000 RSI: 000000000836b17e RDI: 0000000041b58bf3
> RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: ffffffff8a9a805d
> R10: ffffffff8a9a8050 R11: 0000000000000001 R12: ffff8880a94bc440
> R13: 0000000000981859 R14: 0000000000000003 R15: ffff8880ae707b20
> FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000006dae70 CR3: 0000000086205000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
>   <IRQ>
>   irqtime_account_process_tick.isra.0+0x3a2/0x490 kernel/sched/cputime.c:380
>   account_process_tick+0x27f/0x350 kernel/sched/cputime.c:483
>   update_process_times+0x25/0x80 kernel/time/timer.c:1633
>   tick_sched_handle+0xa2/0x190 kernel/time/tick-sched.c:161
>   tick_sched_timer+0x47/0x130 kernel/time/tick-sched.c:1271
>   __run_hrtimer kernel/time/hrtimer.c:1389 [inline]
>   __hrtimer_run_queues+0x3a7/0x1050 kernel/time/hrtimer.c:1451
>   hrtimer_interrupt+0x314/0x770 kernel/time/hrtimer.c:1509
>   local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1035 [inline]
>   smp_apic_timer_interrupt+0x18d/0x760 arch/x86/kernel/apic/apic.c:1060
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:807
>   </IRQ>
> Modules linked in:
> ---[ end trace 42848964955b563b ]---
> RIP: 0010:__read_once_size include/linux/compiler.h:191 [inline]
> RIP: 0010:get_running_cputimer include/linux/sched/cputime.h:85 [inline]
> RIP: 0010:account_group_system_time include/linux/sched/cputime.h:149
> [inline]
> RIP: 0010:account_system_index_time+0xe8/0x5f0 kernel/sched/cputime.c:168
> Code: 04 00 00 49 8b 84 24 00 07 00 00 48 ba 00 00 00 00 00 fc ff df 48 8d
> b8 40 01 00 00 48 8d 88 28 01 00 00 48 89 fe 48 c1 ee 03 <0f> b6 14 16 48
> 89 fe 83 e6 07 40 38 f2 7f 08 84 d2 0f 85 93 03 00
> RSP: 0018:ffff8880ae707a80 EFLAGS: 00010006
> RAX: 0000000041b58ab3 RBX: 1ffff11015ce0f54 RCX: 0000000041b58bdb
> RDX: dffffc0000000000 RSI: 000000000836b17e RDI: 0000000041b58bf3
> RBP: ffff8880ae707b48 R08: ffff8880ae71f5f0 R09: ffffffff8a9a805d
> R10: ffffffff8a9a8050 R11: 0000000000000001 R12: ffff8880a94bc440
> R13: 0000000000981859 R14: 0000000000000003 R15: ffff8880ae707b20
> FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000006dae70 CR3: 0000000086205000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Shutting down cpus with NMI
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/000000000000b65931057ea9cf82%40google.com.
> For more options, visit https://groups.google.com/d/optout.

