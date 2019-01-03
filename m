Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A77ABC43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 10:43:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AC832073D
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 10:43:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AC832073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4D9A8E0069; Thu,  3 Jan 2019 05:43:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFD938E0002; Thu,  3 Jan 2019 05:43:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9EB38E0069; Thu,  3 Jan 2019 05:43:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3E78E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 05:43:04 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id w68so26308398ith.0
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 02:43:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=V0j99+Hub4s7kRPs6RBQ8vZCsSukjPrjXf95nSYp5co=;
        b=m7QjgQ0mDu8TnasBjPWub1LGzbi+CmEiLc1c8QSPTceoggeF0rWv2ayGpIvfjQXmcO
         O+xCO8BnSApEFVfYOQkBBPreNSJ6O6mK7PGpvtOoyH9LWVZNcxgqR+UBqnQfkCtAjtCR
         3DnaPbM5miffzHE8pKnryY5GjLxx+o20QH8HWbkjJoKj1EAJdC8piPJA1eCq/4CrAUrE
         EdQG6SLRDaF6rK84fJ6Fq7lRIAe5vDubSWCogYc1SaBja8wnRxjRxfDBwLGdnUFZrZW0
         vknfPYhZKjHCYxKHclaJn4UTbovNUnmv3UlQYZ8gbDSvVJRVw6sciqz+CREAliIEhYjQ
         YLpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3nuctxakbakmvbcndoohudsslg.jrrjohxvhufrqwhqw.frp@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3NuctXAkbAKMVbcNDOOHUDSSLG.JRRJOHXVHUFRQWHQW.FRP@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukfS8b7PnBt74+zAWa9r0hb1gXpLh3d7kr7oxg67u8Trw8bF/Dp3
	mZ4qXdVH0ca7QNSD0v8L3tmdOZ2muwyVTjW+mJcKhty92KJm+GXUgh2/qbuZpauEFVBGpzsDoyi
	F7KHUO3Q4ZJHaYsNw7Lae0vQr/BgOo0Q2aPxwrRezFxKMa5gmgWO+BzEMTZZvCbanIlC4aGZhgI
	CXLe0NSVLp9J3gU8wqPGgSTLXnWgC1gSGFCLaksItzqJmS2WDp7t3daluylczdqaunw7ElkH0/E
	xFMstzAVqze/iFKVWSuEFOefBsnEVbGRaQpH4IWiL3lRF/2lsaZDF5gg4vK2gk5byoFPgtKFJpl
	qVTSQRlDn0HEx5vAlg02mJuJn7WpljxjOUhk2WpmU4IlLWNW75hTtj+RDCbbvWmI8Pdg3CkGLg=
	=
X-Received: by 2002:a5e:860a:: with SMTP id z10mr30415444ioj.35.1546512184121;
        Thu, 03 Jan 2019 02:43:04 -0800 (PST)
X-Received: by 2002:a5e:860a:: with SMTP id z10mr30415419ioj.35.1546512183208;
        Thu, 03 Jan 2019 02:43:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546512183; cv=none;
        d=google.com; s=arc-20160816;
        b=FPLIgjj04g4rqNkXBCszADeAqXgPz1CwOJYNWz3vH3EnX5TfmA1YwLoTpUg0F5rYzu
         L9f8Smq2bepI3bqMytkdVNeLMv+wj6Ba6wZTqwYLyy3YYj4nmV3PlFmYd3fGAOutiqZa
         teSkDjLWYfpJ1uisH4jJnWXb4FrdH1PEA/e3YKRQqc51ro4k/HgQ9W/ILTtyzjgDG0Au
         dpGNwVjA+1V4J6UnSl9qV5ZTPUrc+5zrK63Lk0jS6dWbgj6JRFRGmyiaCoG3Yd+rk5q+
         DQ/wbH3LCKQCz10a3BsgLiYu5eet4VbXcriyn73YFHTrZd9Kp0vN/V7G8cq4MVALOSlN
         rZww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=V0j99+Hub4s7kRPs6RBQ8vZCsSukjPrjXf95nSYp5co=;
        b=dedf8wo7ejlC6LW4ZvC9sA1RETiC21xZdYv5ueUAPSECz8MyM2FPQDKXKK8WDLwaHv
         3lV4vRvSzcX56SF4nRhZOzNOAymgqWfCWUqv8/C14kLJPMMSu+BiIb55WJJQTePqw9Ta
         gNwr3znd9dJGZUBzguM370b2iHX5coGAy93ESmPtPtgcPQgJIdE1uatp+PTA3UmPo6u7
         SGRPgNwt9zm3ljNHXLQo12fIQIO9yYOVeks2vdaOvuuKieiGZ6Hhkeb9oxoEh+n7sHd0
         mrJJlk2qvpWNNUIhABBT47+22Ddo0AnwxSjvocUvCUHKj7BdoV9aO449k1/38cYMCHjc
         iAkg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3nuctxakbakmvbcndoohudsslg.jrrjohxvhufrqwhqw.frp@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3NuctXAkbAKMVbcNDOOHUDSSLG.JRRJOHXVHUFRQWHQW.FRP@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id h3sor3145445jaa.13.2019.01.03.02.43.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 02:43:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3nuctxakbakmvbcndoohudsslg.jrrjohxvhufrqwhqw.frp@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3nuctxakbakmvbcndoohudsslg.jrrjohxvhufrqwhqw.frp@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3NuctXAkbAKMVbcNDOOHUDSSLG.JRRJOHXVHUFRQWHQW.FRP@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: AFSGD/VPDITGcFF58V1KD9Ffb6MQMte+tc5QCezBsbFMXPMInydGetzkh/mMrq+AEj8BGXWvlZ4HOfBbOZLubYijH0oVmdZjn72i
MIME-Version: 1.0
X-Received: by 2002:a02:b5e5:: with SMTP id y34mr36739548jaj.21.1546512182878;
 Thu, 03 Jan 2019 02:43:02 -0800 (PST)
Date: Thu, 03 Jan 2019 02:43:02 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000004d2e19057e8b6d78@google.com>
Subject: kernel BUG at mm/huge_memory.c:LINE!
From: syzbot <syzbot+8e075128f7db8555391a@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, 
	hughd@google.com, jglisse@redhat.com, khlebnikov@yandex-team.ru, 
	kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, mhocko@suse.com, rientjes@google.com, 
	syzkaller-bugs@googlegroups.com, vbabka@suse.cz, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103104302.nqwdOoFhbofAXkHPpR8ibCn8tUeZYmdvmPWcJkgyHcE@z>

Hello,

syzbot found the following crash on:

HEAD commit:    4cd1b60def51 Add linux-next specific files for 20190102
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=147760d3400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=e8ea56601353001c
dashboard link: https://syzkaller.appspot.com/bug?extid=8e075128f7db8555391a
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+8e075128f7db8555391a@syzkaller.appspotmail.com

raw: 01fffc000009000d dead000000000100 dead000000000200 ffff88809a33f5b1
raw: 0000000000020000 0000000000000000 0000020000000000 ffff888095368000
page dumped because: VM_BUG_ON_PAGE(compound_mapcount(head))
page->mem_cgroup:ffff888095368000
------------[ cut here ]------------
kernel BUG at mm/huge_memory.c:2683!
invalid opcode: 0000 [#1] PREEMPT SMP KASAN
CPU: 0 PID: 1551 Comm: kswapd0 Not tainted 4.20.0-next-20190102 #3
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:split_huge_page_to_list+0x2161/0x2ac0 mm/huge_memory.c:2683
Code: ff e8 33 35 b8 ff 48 8b 85 10 fc ff ff 4c 8d 70 ff e9 1e ea ff ff e8  
1e 35 b8 ff 48 c7 c6 a0 a3 54 88 4c 89 ef e8 0f 15 ea ff <0f> 0b 48 89 85  
10 fc ff ff e8 01 35 b8 ff 48 8b 85 10 fc ff ff 4c
RSP: 0018:ffff8880a5f36de8 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8880a5f371d8 RCX: 0000000000000000
RDX: ffffed1014be6d6e RSI: ffffffff81b3831e RDI: ffffed1014be6dae
RBP: ffff8880a5f37200 R08: 0000000000000021 R09: ffffed1015cc5021
R10: ffffed1015cc5020 R11: ffff8880ae628107 R12: ffffea0000e80080
R13: ffffea0000e80000 R14: 00000000fffffffe R15: 01fffc000009000d
FS:  0000000000000000(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020003030 CR3: 0000000219267000 CR4: 00000000001426f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  split_huge_page include/linux/huge_mm.h:148 [inline]
  deferred_split_scan+0xa47/0x11d0 mm/huge_memory.c:2820
  do_shrink_slab+0x4e5/0xd30 mm/vmscan.c:561
  shrink_slab mm/vmscan.c:710 [inline]
  shrink_slab+0x6bb/0x8c0 mm/vmscan.c:690
  shrink_node+0x61a/0x17e0 mm/vmscan.c:2776
  kswapd_shrink_node mm/vmscan.c:3535 [inline]
  balance_pgdat+0xb00/0x18b0 mm/vmscan.c:3693
  kswapd+0x839/0x1330 mm/vmscan.c:3948
  kthread+0x357/0x430 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
Modules linked in:
kobject: 'loop1' (000000002d2ad2ad): kobject_uevent_env
kobject: 'loop1' (000000002d2ad2ad): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (000000003c94a079): kobject_uevent_env
kobject: 'loop3' (000000003c94a079): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (0000000000e89d9d): kobject_uevent_env
kobject: 'loop5' (0000000000e89d9d): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop2' (000000001a685ee7): kobject_uevent_env
kobject: 'loop2' (000000001a685ee7): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop3' (000000003c94a079): kobject_uevent_env
kobject: 'loop3' (000000003c94a079): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
---[ end trace a543f5c1741fca97 ]---
kobject: 'loop0' (00000000aa59ea1f): kobject_uevent_env
RIP: 0010:split_huge_page_to_list+0x2161/0x2ac0 mm/huge_memory.c:2683
Code: ff e8 33 35 b8 ff 48 8b 85 10 fc ff ff 4c 8d 70 ff e9 1e ea ff ff e8  
1e 35 b8 ff 48 c7 c6 a0 a3 54 88 4c 89 ef e8 0f 15 ea ff <0f> 0b 48 89 85  
10 fc ff ff e8 01 35 b8 ff 48 8b 85 10 fc ff ff 4c
kobject: 'loop0' (00000000aa59ea1f): fill_kobj_path: path  
= '/devices/virtual/block/loop0'
RSP: 0018:ffff8880a5f36de8 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8880a5f371d8 RCX: 0000000000000000
RDX: ffffed1014be6d6e RSI: ffffffff81b3831e RDI: ffffed1014be6dae
RBP: ffff8880a5f37200 R08: 0000000000000021 R09: ffffed1015cc5021
netlink: 'syz-executor0': attribute type 22 has an invalid length.
R10: ffffed1015cc5020 R11: ffff8880ae628107 R12: ffffea0000e80080
R13: ffffea0000e80000 R14: 00000000fffffffe R15: 01fffc000009000d
FS:  0000000000000000(0000) GS:ffff8880ae700000(0000) knlGS:0000000000000000
kobject: 'loop1' (000000002d2ad2ad): kobject_uevent_env
kobject: 'loop1' (000000002d2ad2ad): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000004efb18 CR3: 00000000702a7000 CR4: 00000000001426e0
kobject: 'loop5' (0000000000e89d9d): kobject_uevent_env
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kobject: 'loop5' (0000000000e89d9d): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
kobject: 'loop3' (000000003c94a079): kobject_uevent_env


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.

