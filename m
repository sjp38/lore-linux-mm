Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7700C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 09:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4FBA204FD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 09:50:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4FBA204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5269D6B000A; Tue,  7 May 2019 05:50:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FDB16B000C; Tue,  7 May 2019 05:50:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ECC26B000D; Tue,  7 May 2019 05:50:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC116B000A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 05:50:07 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id t7so10776527iod.17
        for <linux-mm@kvack.org>; Tue, 07 May 2019 02:50:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=In9eC4eti/TKqtsCxDxB3bSkibZhF83sxRlbVPMNKKs=;
        b=InXUpeGITu2TNg3+APE5VIhflEnFK9PjbbqRYli7FOFsgSUrVz4BvsQvr/GIJ7N5MS
         /UwcONwVCjGMa5McKgVDmzAwDWTFIubgnn0Cm4gtB/dd93/A2An68fmt08YkZg/Fq3N3
         L15rMP7Tqq32rL12+cpDOF0iXXxADtMgz2z4y9H6fzO2yLNTYikUBlzie86GZhigX0bJ
         79XRvg2q0KL0sYCq30JTLUms4EDKtHvj3Mn6OhmTEJck9LX0tblpcoZ2BpqTFF0LHpgX
         /ekSJIr3Pt5wRWnNVKBJu3CGc1QaCBT1g6EokZ9Lk5sAdY03VZOXVKDBJZuqAj/Iy8yb
         MXtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3zvtrxakbakgaghsittmzixxql.owwotmcamzkwvbmvb.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3zVTRXAkbAKgaghSITTMZIXXQL.OWWOTMcaMZKWVbMVb.KWU@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAVO9fFQ08AI1gF98wHYhBHu6fEfhHUFyoXszj4HMbPUNozmOLAE
	2zM5weYvJTRYzEAH32XVwFLs4H77DstZmOJiadgH7bBgrJGYm/ZYorvB/pyIiMNMyi9h8nycHlF
	B72gB6JiYMvdUVMVRftu65JzC2sgHHERopLOSUe8Xabh40aOnTXG8f7M+EkVyxas=
X-Received: by 2002:a24:1486:: with SMTP id 128mr3123734itg.68.1557222606690;
        Tue, 07 May 2019 02:50:06 -0700 (PDT)
X-Received: by 2002:a24:1486:: with SMTP id 128mr3123690itg.68.1557222605731;
        Tue, 07 May 2019 02:50:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557222605; cv=none;
        d=google.com; s=arc-20160816;
        b=Xtwn5/jNK6PusPa/VLxsGtFB/52dCee3TGXOIape6Wah2rnodLmzK1dIMNEqSPSQQ1
         lZt51jjOQ/XpWFyaNNZllnC77auGoAYYUc6KOzyPjZEzPLQ6pYYNO4Nt0QQNvuZZ5gbn
         el3Ti6KbJGsZKwoJvb685uFRCCytcdAem6ERjoNzFDvA+0S4+znRMMY3A20beymU+AOW
         Jf0ievcOQ1zjm8uxHvw0kg80gdiYd77AbxedF8DrHHYn3J93eCbBN2oErzgbkmINx6PK
         DUSUYBQvy7oAgr+EMzXa+MamZKZiHRC22EexC6qjDLa/Uf6pxx33qaLUGgknHttw1zMZ
         NJRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=In9eC4eti/TKqtsCxDxB3bSkibZhF83sxRlbVPMNKKs=;
        b=mY1fIaa3wi1EeGMwL5L0YneapnYIqPuQcZEVN2iLj+7UjFBaFI1dNBSAOS/DJzLvYf
         hnTJanFb87F1wfOu8HBelaCMIJT+K5I/igGALajjHn+l55+Cavq0urFhKT0OIs7RryI9
         T4H2TFLCzf7lAN5TcbmDp4e5O3darJYizD/L/9+IyjqCkYYqbQlA1H4z1EFNLwrHON9k
         BC6uqNsVaTri3ZZ1Ve5JqlYHhyckaA/5bBwpg4VBntLlIvYID25qSsMD1TricyHd6ZPm
         CghzAZdVRBdivDvTbvvMMfZj5pcjhJQ2kBBKaY0aAf4vH826cfHPuDkK2aalrFVsuwGQ
         BH3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3zvtrxakbakgaghsittmzixxql.owwotmcamzkwvbmvb.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3zVTRXAkbAKgaghSITTMZIXXQL.OWWOTMcaMZKWVbMVb.KWU@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id v6sor17192186itv.20.2019.05.07.02.50.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 02:50:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3zvtrxakbakgaghsittmzixxql.owwotmcamzkwvbmvb.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3zvtrxakbakgaghsittmzixxql.owwotmcamzkwvbmvb.kwu@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3zVTRXAkbAKgaghSITTMZIXXQL.OWWOTMcaMZKWVbMVb.KWU@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqz5oZLbzxieR3XewvUgqCbVWsX+G/dqraDdBRj+/m1v9eWEBPaA80I266jr7RQGFGMpYCWR6r+PJx61EYf7JQEfDdP60h7i
MIME-Version: 1.0
X-Received: by 2002:a24:a946:: with SMTP id x6mr6213890iti.136.1557222605448;
 Tue, 07 May 2019 02:50:05 -0700 (PDT)
Date: Tue, 07 May 2019 02:50:05 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000003beebd0588492456@google.com>
Subject: BUG: unable to handle kernel paging request in isolate_freepages_block
From: syzbot <syzbot+d84c80f9fe26a0f7a734@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com, cai@lca.pw, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, 
	mhocko@suse.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    baf76f0c slip: make slhc_free() silently accept an error p..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=16dbe6cca00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=a42d110b47dd6b36
dashboard link: https://syzkaller.appspot.com/bug?extid=d84c80f9fe26a0f7a734
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+d84c80f9fe26a0f7a734@syzkaller.appspotmail.com

BUG: unable to handle kernel paging request at ffffea0003348000
#PF error: [normal kernel read fault]
PGD 12c3f9067 P4D 12c3f9067 PUD 12c3f8067 PMD 0
Oops: 0000 [#1] PREEMPT SMP KASAN
CPU: 1 PID: 28916 Comm: syz-executor.2 Not tainted 5.1.0-rc6+ #89
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:constant_test_bit arch/x86/include/asm/bitops.h:314 [inline]
RIP: 0010:PageCompound include/linux/page-flags.h:186 [inline]
RIP: 0010:isolate_freepages_block+0x1c0/0xd40 mm/compaction.c:579
Code: 01 d8 ff 4d 85 ed 0f 84 ef 07 00 00 e8 29 00 d8 ff 4c 89 e0 83 85 38  
ff ff ff 01 48 c1 e8 03 42 80 3c 38 00 0f 85 31 0a 00 00 <4d> 8b 2c 24 31  
ff 49 c1 ed 10 41 83 e5 01 44 89 ee e8 3a 01 d8 ff
RSP: 0018:ffff88802b31eab8 EFLAGS: 00010246
RAX: 1ffffd4000669000 RBX: 00000000000cd200 RCX: ffffc9000a235000
RDX: 000000000001ca5e RSI: ffffffff81988cc7 RDI: 0000000000000001
RBP: ffff88802b31ebd8 R08: ffff88805af700c0 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffffea0003348000
R13: 0000000000000000 R14: ffff88802b31f030 R15: dffffc0000000000
FS:  00007f61648dc700(0000) GS:ffff8880ae900000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffea0003348000 CR3: 0000000037c64000 CR4: 00000000001426e0
Call Trace:
  fast_isolate_around mm/compaction.c:1243 [inline]
  fast_isolate_freepages mm/compaction.c:1418 [inline]
  isolate_freepages mm/compaction.c:1438 [inline]
  compaction_alloc+0x1aee/0x22e0 mm/compaction.c:1550
  unmap_and_move mm/migrate.c:1180 [inline]
  migrate_pages+0x484/0x2cd0 mm/migrate.c:1431
  compact_zone+0x1b4f/0x38f0 mm/compaction.c:2181
  compact_zone_order+0x1af/0x2a0 mm/compaction.c:2306
  try_to_compact_pages+0x268/0xaf0 mm/compaction.c:2358
  __alloc_pages_direct_compact+0x154/0x460 mm/page_alloc.c:3786
  __alloc_pages_slowpath+0xb14/0x28b0 mm/page_alloc.c:4425
  __alloc_pages_nodemask+0x602/0x8d0 mm/page_alloc.c:4633
  __alloc_pages include/linux/gfp.h:473 [inline]
  __alloc_pages_node include/linux/gfp.h:486 [inline]
  alloc_pages_vma+0x39a/0x540 mm/mempolicy.c:2088
  do_huge_pmd_anonymous_page+0x509/0x1730 mm/huge_memory.c:740
  create_huge_pmd mm/memory.c:3701 [inline]
  __handle_mm_fault+0x2d5e/0x3ec0 mm/memory.c:3905
  handle_mm_fault+0x43f/0xb30 mm/memory.c:3971
  faultin_page mm/gup.c:548 [inline]
  __get_user_pages+0x7b6/0x1a40 mm/gup.c:751
  __get_user_pages_locked mm/gup.c:927 [inline]
  get_user_pages_remote+0x21d/0x440 mm/gup.c:1119
  process_vm_rw_single_vec mm/process_vm_access.c:113 [inline]
  process_vm_rw_core.isra.0+0x464/0xb10 mm/process_vm_access.c:220
  process_vm_rw+0x21f/0x240 mm/process_vm_access.c:288
  __do_sys_process_vm_writev mm/process_vm_access.c:310 [inline]
  __se_sys_process_vm_writev mm/process_vm_access.c:305 [inline]
  __x64_sys_process_vm_writev+0xe3/0x1a0 mm/process_vm_access.c:305
  do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x458da9
Code: ad b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 7b b8 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f61648dbc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000137
RAX: ffffffffffffffda RBX: 0000000000000006 RCX: 0000000000458da9
RDX: 0000000000000001 RSI: 0000000020000000 RDI: 0000000000004a77
RBP: 000000000073bf00 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000020000040 R11: 0000000000000246 R12: 00007f61648dc6d4
R13: 00000000004c5b1e R14: 00000000004d9e90 R15: 00000000ffffffff
Modules linked in:
CR2: ffffea0003348000
---[ end trace 50f8738754fa12f3 ]---
RIP: 0010:constant_test_bit arch/x86/include/asm/bitops.h:314 [inline]
RIP: 0010:PageCompound include/linux/page-flags.h:186 [inline]
RIP: 0010:isolate_freepages_block+0x1c0/0xd40 mm/compaction.c:579
Code: 01 d8 ff 4d 85 ed 0f 84 ef 07 00 00 e8 29 00 d8 ff 4c 89 e0 83 85 38  
ff ff ff 01 48 c1 e8 03 42 80 3c 38 00 0f 85 31 0a 00 00 <4d> 8b 2c 24 31  
ff 49 c1 ed 10 41 83 e5 01 44 89 ee e8 3a 01 d8 ff
RSP: 0018:ffff88802b31eab8 EFLAGS: 00010246
RAX: 1ffffd4000669000 RBX: 00000000000cd200 RCX: ffffc9000a235000
RDX: 000000000001ca5e RSI: ffffffff81988cc7 RDI: 0000000000000001
RBP: ffff88802b31ebd8 R08: ffff88805af700c0 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffffea0003348000
R13: 0000000000000000 R14: ffff88802b31f030 R15: dffffc0000000000
FS:  00007f61648dc700(0000) GS:ffff8880ae900000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffea0003348000 CR3: 0000000037c64000 CR4: 00000000001426e0


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

