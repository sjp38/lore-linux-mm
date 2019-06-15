Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AAACC31E44
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 03:15:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0397721473
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 03:15:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jElxaVyt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0397721473
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 903606B0003; Fri, 14 Jun 2019 23:15:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B35D6B0005; Fri, 14 Jun 2019 23:15:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A2E78E0001; Fri, 14 Jun 2019 23:15:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1E26B0003
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 23:15:44 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id p18so4648323ywe.17
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 20:15:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EGZVU2UHfT+frf6XLGNU9eMMWyulkicvC237oH+s1fE=;
        b=lwFkLJ4ZLYwEcpQ2WxlXV6yn30g2H8F/mvqyfdweP49rUarBc1WsbGyZDFMY9O5lpG
         oYr+0klUVto9EuZ5mqjbEpvC1nHu6PbSO3mITU4Zm5dtSrv8Of6E1Kw0y+vNMeHetoRo
         TliSwN2LAnv5DdlmcFwBYxF9wjodsUhPkjmp/V7z+F/VD8Dgp/BdFGYdubEzAjq6vzAB
         /R4FFlcEh9qawsF0djL22UDVIuSmlFiwsJ7FsJfD/IDU7n1JOV1Q4TRUNu/2SDgt4Eiy
         V/c5Y+gRhe6P3LHD94HBgyT+XFXY9F1E505J3P8ymv/hBeOvkJHlMMaY9sYoJo+Qx5Z0
         p8qw==
X-Gm-Message-State: APjAAAXtn+uIOmiig0T55qnUwJVyM3J28WSAnwqWtv5sbcg1TFuImCnb
	O9mfhss/D5teZrSaZTfdlAeVORy3C45WaoeSq/bgkUZY0hZ50IKpln35LIN5SWHNrGZVjIRLCJ5
	D1Sj0cvY+xQFsYpZra1LAaPR+MRz//xYpLKDb4b3c4W2AuIR7uoPjptpRwtfljOlhCg==
X-Received: by 2002:a81:5cc:: with SMTP id 195mr54029000ywf.348.1560568544086;
        Fri, 14 Jun 2019 20:15:44 -0700 (PDT)
X-Received: by 2002:a81:5cc:: with SMTP id 195mr54028987ywf.348.1560568543292;
        Fri, 14 Jun 2019 20:15:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560568543; cv=none;
        d=google.com; s=arc-20160816;
        b=Ljn/Q1i4Hljq1lxcXUjZQe/GngwcaXvgKuk7VKbTnB50hS0FUIgdSPFW5N5JrsHJmc
         +ZLuoLGQUnGIFaPvZC2Bix7szoD+A2gM6iImzC//vQGN2NCUFOm66sqB9dUXwM7k65ac
         Hi17Z13giLH5EoX2P8PZBNHEqknc7pw7qZFzi11/ZZi7cBfn1hoHBfcl61uD4yKA+kEy
         39JVVdqUZ9cmNnGsshnstj0XSsTMCjIFdD2rmXwMJCan8mEYU6/X3V1ImSE/GcOotN1J
         f9XjZwM9LRfY9x8XZCkt5b6C/KL0qW+/EqS9pnbm706IAnGkECoskfixGZjD74fFyyj7
         UGtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EGZVU2UHfT+frf6XLGNU9eMMWyulkicvC237oH+s1fE=;
        b=H3XTDNsmNWekdU1XRdd3nzeji6aecdz6XayQxS82bnoDoh482XDnPczVGZquEKtWu+
         tQ0S/+Dc4XMvMMLAoj3Uga65rwoa9PnJ2OUwbK5FDtaTyc48GP63C7fUVrVZXT2/pNRe
         kAK+YX8AHWxO9vO0YdJlZSFCPzojsrOUyT44DRSL6L7EDKuaZeq0b11AQk5+7riEi2gt
         6avwRuDoTbFmFvB4MqqCAnuAx1G404fSTv3rU3mLWUk6eFmobA1FJSCsDwTdD+Yy1xSn
         38ol1glwRQFh7QB3EawQa5CiSmNlgQL0cfbIprZxcEHbmiU3JCmpn7kj4ltCpfFM41eM
         LO2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jElxaVyt;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 198sor2731854ybd.148.2019.06.14.20.15.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Jun 2019 20:15:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jElxaVyt;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EGZVU2UHfT+frf6XLGNU9eMMWyulkicvC237oH+s1fE=;
        b=jElxaVytDdFwkDPal7BkKEqoRnwimR8bJrOZ35Y0iU3yvMDGN4pCC/v5q3rasjMEPj
         avPlOVSJwNCztIJtTGaUfXsCo5hPAMtI0T6iO6Jb99+QhcZeBsTgXYgtcQQbisxtBKjK
         GhiQU62nHiiPHEx1VoR1siWfWZN0DxIK9wl1/Sjtp0qI7ishyNpWZ/iTGoUOCz3IGRLO
         72xGJKstcA/JgIuzQNR6w0vwnf5PMoWUJ4YsjeIyn6p+8VNx51KEiAljw37Xj21QosXM
         +g8kEdmQwVlwwKD0EXxTz6BUdyLWGRQcxppiBUrKTMvkbLzLsGTpci9Wc5wL0RXyved4
         Rq3A==
X-Google-Smtp-Source: APXvYqwvAbSgnUbbYd2Wl1gThveaWDEuxbGa3aaKiaQzDRDl2yMrSJtEopfO/lZ07Bj5dDyoxRTwGtfTAh5ke9umVBQ=
X-Received: by 2002:a25:a107:: with SMTP id z7mr576369ybh.165.1560568542572;
 Fri, 14 Jun 2019 20:15:42 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000004143a5058b526503@google.com>
In-Reply-To: <0000000000004143a5058b526503@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 14 Jun 2019 20:15:31 -0700
Message-ID: <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
Subject: Re: general protection fault in oom_unkillable_task
To: syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, yuzhoujian@didichuxing.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 6:08 PM syzbot
<syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    3f310e51 Add linux-next specific files for 20190607
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=15ab8771a00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=5d176e1849bbc45
> dashboard link: https://syzkaller.appspot.com/bug?extid=d0fc9d3c166bc5e4a94b
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com
>
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] PREEMPT SMP KASAN
> CPU: 0 PID: 28426 Comm: syz-executor.5 Not tainted 5.2.0-rc3-next-20190607
> #11
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]

It seems like oom_unkillable_task() is broken for memcg OOMs. It
should not be calling has_intersects_mems_allowed() for memcg OOMs.

> RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
> RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
> Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 00
> 00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
> 85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
> RSP: 0018:ffff888000127490 EFLAGS: 00010a03
> RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
> RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
> RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
> R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
> R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
> FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000607304 CR3: 000000009237e000 CR4: 00000000001426f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
> Call Trace:
>   oom_evaluate_task+0x49/0x520 mm/oom_kill.c:321
>   mem_cgroup_scan_tasks+0xcc/0x180 mm/memcontrol.c:1169
>   select_bad_process mm/oom_kill.c:374 [inline]
>   out_of_memory mm/oom_kill.c:1088 [inline]
>   out_of_memory+0x6b2/0x1280 mm/oom_kill.c:1035
>   mem_cgroup_out_of_memory+0x1ca/0x230 mm/memcontrol.c:1573
>   mem_cgroup_oom mm/memcontrol.c:1905 [inline]
>   try_charge+0xfbe/0x1480 mm/memcontrol.c:2468
>   mem_cgroup_try_charge+0x24d/0x5e0 mm/memcontrol.c:6073
>   mem_cgroup_try_charge_delay+0x1f/0xa0 mm/memcontrol.c:6088
>   do_huge_pmd_wp_page_fallback+0x24f/0x1680 mm/huge_memory.c:1201
>   do_huge_pmd_wp_page+0x7fc/0x2160 mm/huge_memory.c:1359
>   wp_huge_pmd mm/memory.c:3793 [inline]
>   __handle_mm_fault+0x164c/0x3eb0 mm/memory.c:4006
>   handle_mm_fault+0x3b7/0xa90 mm/memory.c:4053
>   do_user_addr_fault arch/x86/mm/fault.c:1455 [inline]
>   __do_page_fault+0x5ef/0xda0 arch/x86/mm/fault.c:1521
>   do_page_fault+0x71/0x57d arch/x86/mm/fault.c:1552
>   page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1156
> RIP: 0033:0x400590
> Code: 06 e9 49 01 00 00 48 8b 44 24 10 48 0b 44 24 28 75 1f 48 8b 14 24 48
> 8b 7c 24 20 be 04 00 00 00 e8 f5 56 00 00 48 8b 74 24 08 <89> 06 e9 1e 01
> 00 00 48 8b 44 24 08 48 8b 14 24 be 04 00 00 00 8b
> RSP: 002b:00007fff7bc49780 EFLAGS: 00010206
> RAX: 0000000000000001 RBX: 0000000000760000 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 000000002000cffc RDI: 0000000000000001
> RBP: fffffffffffffffe R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000075 R11: 0000000000000246 R12: 0000000000760008
> R13: 00000000004c55f2 R14: 0000000000000000 R15: 00007fff7bc499b0
> Modules linked in:
> ---[ end trace a65689219582ffff ]---
> RIP: 0010:__read_once_size include/linux/compiler.h:194 [inline]
> RIP: 0010:has_intersects_mems_allowed mm/oom_kill.c:84 [inline]
> RIP: 0010:oom_unkillable_task mm/oom_kill.c:168 [inline]
> RIP: 0010:oom_unkillable_task+0x180/0x400 mm/oom_kill.c:155
> Code: c1 ea 03 80 3c 02 00 0f 85 80 02 00 00 4c 8b a3 10 07 00 00 48 b8 00
> 00 00 00 00 fc ff df 4d 8d 74 24 10 4c 89 f2 48 c1 ea 03 <80> 3c 02 00 0f
> 85 67 02 00 00 49 8b 44 24 10 4c 8d a0 68 fa ff ff
> RSP: 0018:ffff888000127490 EFLAGS: 00010a03
> RAX: dffffc0000000000 RBX: ffff8880a4cd5438 RCX: ffffffff818dae9c
> RDX: 100000000c3cc602 RSI: ffffffff818dac8d RDI: 0000000000000001
> RBP: ffff8880001274d0 R08: ffff888000086180 R09: ffffed1015d26be0
> R10: ffffed1015d26bdf R11: ffff8880ae935efb R12: 8000000061e63007
> R13: 0000000000000000 R14: 8000000061e63017 R15: 1ffff11000024ea6
> FS:  00005555561f5940(0000) GS:ffff8880ae800000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000001b2f823000 CR3: 000000009237e000 CR4: 00000000001426f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000600
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

