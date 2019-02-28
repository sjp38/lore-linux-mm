Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DDD8C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:32:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50D392171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:32:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50D392171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E62718E0003; Thu, 28 Feb 2019 05:32:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE9908E0001; Thu, 28 Feb 2019 05:32:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDA6F8E0003; Thu, 28 Feb 2019 05:32:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id A43508E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:32:05 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id g3so15115671ioh.12
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:32:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=JK81IFg0QPmqh7vyMbarPMg8i/QYg0mBKNUqOI6CU9k=;
        b=PWO3QauI12tERRNIq4khHhISGWUkwfG6G/HBQkgw+pEWmQWimeOfNDdbKb8tanUevw
         9kDefOrT4rfuFi/tprw4BWDm1pVGd/3L6dM6xeFfNqMjQigF+YgM5GVhcjycnV4xiWiJ
         DPqeUVEkshnh0nUwmb2OQW6cPjRiIQqqMLeTpvuaR+jbbLcNUtBdA5bwjuTByDeyM+W0
         4jViAVLSbm4FVqljVejRvUkoNO+zjwZDS1RY0lnSqTS/ryTgKeUmdsSX3Cbt0TqIZ22y
         oob71cQDxQ7sjz7MHcM4a/frI/Z4xt7c6K2n7lwqTBM9biJuUIfkKYV/Cd0zdIaQnGsb
         GX8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3plh3xakban0rxyj9kkdq9oohc.fnnfkdtrdqbnmsdms.bnl@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3pLh3XAkbAN0RXYJ9KKDQ9OOHC.FNNFKDTRDQBNMSDMS.BNL@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAWqzta0u+rEU9Se8QzK9B1duEJezhmLz4aQ69pn/scveEmKuemU
	3Nt0yOW+ACdv8U1VzGl//cc1vrRXRnJbi2wh+kzeDHklPmpzb5cpt65BIzZqsn1tGsuQko0T1Qd
	WMLraftpdU9DDJLGGlw/n6jPdcVeLYfSq2XF98VExM6vfMl9i2X77XIkZB/ThpusWaGoek8ccGa
	0vA77v3BT/zAiKJZbgsR+D0EwfMzZBEygm1u6IgJzdcuqe2nWmeVoA1f3yAWVU5vcuiidUZEiJI
	JMf0m/4tb+SUJ1HU7QEsotkj29KSdkTI3pDoq9Ww7jG9PFjZIpuaE1MrY+ZL08WKOScIYSZ5t6K
	Vc0vZfS54NzovyEWQq5BumDZXzkYLz+ZVXY+I9K8Bl8RFfrH7HP2clmPIY6fQeGn+Rkpz/ipwQ=
	=
X-Received: by 2002:a24:d443:: with SMTP id x64mr2496614itg.46.1551349925399;
        Thu, 28 Feb 2019 02:32:05 -0800 (PST)
X-Received: by 2002:a24:d443:: with SMTP id x64mr2496581itg.46.1551349924327;
        Thu, 28 Feb 2019 02:32:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551349924; cv=none;
        d=google.com; s=arc-20160816;
        b=XcMyrgrNy4NR9k/EeEwtLTD1t/Yj0UA0xmw5LaMx5gw/PLFqFu7RXOIGEI2D0cY/Lt
         uwigURtPmoKpdSgq7b56wsm5w7YNiCQ1YdJA4GMH0fKJPxr3QGXMDXIAM3M2V6PnPsN6
         sihjC1UQmDkpNAnubkzfp+2pPQY7ELip9gSGLbsXfqX2Q6elX+Qjf3QHDJ4Jq2+Fy1d6
         4fTrsOXg/QW4RM02pVzis6X/qD/SCsO7xKVPBxHj622+i79Rcvu+rlAkwFtCbwVSDKA0
         5eTn0GqvtwLAhh3k9AytupFGd8ppJnfRBwv9rZIXekaaq2BzHD8sq6IOm0ASWuZicffj
         FWjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=JK81IFg0QPmqh7vyMbarPMg8i/QYg0mBKNUqOI6CU9k=;
        b=zvONfMVycnCrmIYouEHMzfJ7nYbrXaHfQDqyR1UQwJhT/QaeHSm8BZtIumL7hfDvLb
         Y/GKMsCD5ksj0rA5UswFDkI1SKuuBLKP8vZ3NI0AXnr/YoAcSecm9A6jlY2mTJDaze97
         JCOhFewFwMx4GRQnjqqhmknHucFrhESTgoiRdUSDsM6Xncyh+u0TJWn1Ub8HvKNBj++9
         LghZv980FHLOstutxnkZOr4YMqT8S+zn0pjh6VXv1JSuEjGRTh4a+Za1/BCxIHX9t2Zr
         hUMY1FTNm6CLZSiVDuBxxlcrVckM3pzhleHrvBq9YSlMXMkMuZHg/QSduDJOdS5uHlOU
         Q1rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3plh3xakban0rxyj9kkdq9oohc.fnnfkdtrdqbnmsdms.bnl@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3pLh3XAkbAN0RXYJ9KKDQ9OOHC.FNNFKDTRDQBNMSDMS.BNL@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id a184sor8211370itc.31.2019.02.28.02.32.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 02:32:04 -0800 (PST)
Received-SPF: pass (google.com: domain of 3plh3xakban0rxyj9kkdq9oohc.fnnfkdtrdqbnmsdms.bnl@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3plh3xakban0rxyj9kkdq9oohc.fnnfkdtrdqbnmsdms.bnl@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3pLh3XAkbAN0RXYJ9KKDQ9OOHC.FNNFKDTRDQBNMSDMS.BNL@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqxfRs2VVyEeQVLCM7MVHNfnNYG8+VxwPX5JyMjGCNiHDsQz5kX0nkDY6nMWyIWPndxNkqPJ03/dwGdMzYQ8dWIdZCK0HuiT
MIME-Version: 1.0
X-Received: by 2002:a24:5a04:: with SMTP id v4mr2594190ita.37.1551349924014;
 Thu, 28 Feb 2019 02:32:04 -0800 (PST)
Date: Thu, 28 Feb 2019 02:32:04 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000024b3aa0582f1cde7@google.com>
Subject: BUG: Bad page state (6)
From: syzbot <syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, arunks@codeaurora.org, dan.j.williams@intel.com, 
	ldr709@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	mhocko@suse.com, nborisov@suse.com, rppt@linux.vnet.ibm.com, 
	syzkaller-bugs@googlegroups.com, vbabka@suse.cz, willy@infradead.org, 
	yuehaibing@huawei.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    42fd8df9d1d9 Add linux-next specific files for 20190228
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=179ba9e0c00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=c0f38652d28b522f
dashboard link: https://syzkaller.appspot.com/bug?extid=6f5a9b79b75b66078bf0
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=12ed6bd0c00000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10690c8ac00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+6f5a9b79b75b66078bf0@syzkaller.appspotmail.com

BUG: Bad page state in process syz-executor193  pfn:9225a
page:ffffea0002489680 count:0 mapcount:0 mapping:ffff88808652fd80 index:0x81
shmem_aops
name:"memfd:cgroup2"
flags: 0x1fffc000008000e(referenced|uptodate|dirty|swapbacked)
raw: 01fffc000008000e ffff88809277fac0 ffff88809277fac0 ffff88808652fd80
raw: 0000000000000081 0000000000000000 00000000ffffffff 0000000000000000
page dumped because: non-NULL mapping
Modules linked in:
CPU: 0 PID: 7659 Comm: syz-executor193 Not tainted 5.0.0-rc8-next-20190228  
#45
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  bad_page.cold+0xda/0xff mm/page_alloc.c:586
  free_pages_check_bad+0x142/0x1a0 mm/page_alloc.c:1013
  free_pages_check mm/page_alloc.c:1022 [inline]
  free_pages_prepare mm/page_alloc.c:1112 [inline]
  free_pcp_prepare mm/page_alloc.c:1137 [inline]
  free_unref_page_prepare mm/page_alloc.c:3001 [inline]
  free_unref_page_list+0x31d/0xc40 mm/page_alloc.c:3070
  release_pages+0x60d/0x1940 mm/swap.c:794
  pagevec_lru_move_fn+0x218/0x2a0 mm/swap.c:213
  activate_page_drain mm/swap.c:297 [inline]
  lru_add_drain_cpu+0x3b1/0x520 mm/swap.c:596
  lru_add_drain+0x20/0x60 mm/swap.c:647
  exit_mmap+0x290/0x530 mm/mmap.c:3134
  __mmput kernel/fork.c:1047 [inline]
  mmput+0x15f/0x4c0 kernel/fork.c:1068
  exit_mm kernel/exit.c:546 [inline]
  do_exit+0x816/0x2fa0 kernel/exit.c:863
  do_group_exit+0x135/0x370 kernel/exit.c:980
  __do_sys_exit_group kernel/exit.c:991 [inline]
  __se_sys_exit_group kernel/exit.c:989 [inline]
  __x64_sys_exit_group+0x44/0x50 kernel/exit.c:989
  do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x442a58
Code: 00 00 be 3c 00 00 00 eb 19 66 0f 1f 84 00 00 00 00 00 48 89 d7 89 f0  
0f 05 48 3d 00 f0 ff ff 77 21 f4 48 89 d7 44 89 c0 0f 05 <48> 3d 00 f0 ff  
ff 76 e0 f7 d8 64 41 89 01 eb d8 0f 1f 84 00 00 00
RSP: 002b:00007ffe99e2faf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000442a58
RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
RBP: 00000000004c2468 R08: 00000000000000e7 R09: ffffffffffffffd0
R10: 0000000002000005 R11: 0000000000000246 R12: 0000000000000001
R13: 00000000006d4180 R14: 0000000000000000 R15: 0000000000000000


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

