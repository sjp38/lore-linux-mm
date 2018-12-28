Return-Path: <SRS0=dGUi=PF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D337C43612
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 20:51:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA4FC2148E
	for <linux-mm@archiver.kernel.org>; Fri, 28 Dec 2018 20:51:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA4FC2148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4055F8E004D; Fri, 28 Dec 2018 15:51:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B4B38E0001; Fri, 28 Dec 2018 15:51:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A3EB8E004D; Fri, 28 Dec 2018 15:51:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 038AC8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 15:51:06 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id j3so24670385itf.5
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 12:51:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=7GJPd699T2OEUSyjv/HWkvMwOUS9VoGfRBEouY+TfYg=;
        b=SjhVkUkODOM8TA0bxUo4GI6ppZ+QmfeXZUCSgBPN2poLjDCk+vv0RTRumHr/FJkHUQ
         hi8E+eFYyTAKZW96tV71icqQV8k/sfiDUwFNKyQ4RwS3polDitjSCSqd5AL9pICHdMGZ
         Z8sAj0vvMUAqDFXFX//fcBhJm5YzUFYohmygIPwiIPxor/g3prHmvB6Y5Vjr2L496jws
         ix4rXFbLtNTB1z/f/SAkvoaz9tVrSFYXi9nW0op9cz8Mow+zMfd6Zk9r3al3616lT+u7
         6gLst2S3FgHDC6foKuvLcXa3MQtXHL8qIIfFBPhHEPeLD3aJfHe8vMDG+nX2QBWjAqvF
         oGww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3uiwmxakbafmdjk5v66zcvaa3y.19916zfdzcx98ez8e.x97@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3uIwmXAkbAFMDJK5v66zCvAA3y.19916zFDzCx98Ez8E.x97@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AA+aEWZ/k5Rm2uxq8VQDU7bdlZlibtn1g3VyVHahtRdnbdzyqqts+Trf
	7rx2fVhBLB/gnePE5RY12SDmwU6qtsnAlPdcIuMtcbGmD6QlnVFU62qr9Fe5DOhyRXuOWFWyn1O
	LJNZ64sy3IKEffHAJDmfTw+X5Q+tDZQhQ41D4wzcDuNQ7NWjUa7gXdQSeor9PmAo7uvximdxpId
	HZohUGO8pf+0TzoAsbm0jF5dvmyU/0R2GR4IxlamU39a/jXC2kginx+sJfKmz+pBG9d2dvgFdwX
	9+BrRQnbVv3Pv4ZNgj/IntuCU80+VWfuwVPD91gb33Dktfl7uN20xnFUdNsmDQyGVe+F1FAOnuE
	aF5JJllWyEKaiU1HGgz+K0j4Lm4UCs7MP3vJCyCHlG5SZ2GfifShIxSWp2vvovIosMgPKKVtdg=
	=
X-Received: by 2002:a24:3987:: with SMTP id l129mr17721858ita.45.1546030265680;
        Fri, 28 Dec 2018 12:51:05 -0800 (PST)
X-Received: by 2002:a24:3987:: with SMTP id l129mr17721817ita.45.1546030264540;
        Fri, 28 Dec 2018 12:51:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546030264; cv=none;
        d=google.com; s=arc-20160816;
        b=AwHW4oUx3qAtE/IlOAwVj6mGiTr0TdEJVHVFC6z52GZ69O7IUsAK2yOr4zQvp9kZNg
         LzOsfWek2xqei6UkGzPIdqW94ntjG5lUKd8uoHaFuaSfMSgHhYEec5/CR4L3w0ob2DHV
         TYOxH149Y563k2ywWPBE3fZnvXFhyta8HzQLcvQIluuJ6vXKkoztDdeHOrPLcTiNy56B
         j3+jaeawhmdmpUwse4XrlJcupNSKenErDQuX1JHclF4iyoWfdYjrHP1S7Iqs27NTKleh
         tBjC7RIxDjKF8FjfVIXq8W+IB8GmBckghiwaiLWOS0MwLtzjFUFqZqS5wtuCs96tEck2
         AOyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=7GJPd699T2OEUSyjv/HWkvMwOUS9VoGfRBEouY+TfYg=;
        b=y55FMHwCkKjqlg2plNa3aIAJaaj76fXCc9I5mpPdMF1Y06BT/UZIGnVB8weGa77rOz
         eLjehNRbq4csH8urBNC+4OwbUPyN37DHDGriKMbldgSBbZic0lNVc1/mX+NC288VhuCk
         yV4aPjhKfl8VCINS/dR7cGihlOM9zL51ruon4+UOheE0AlVJiAst9V+gkcE4q7qSycV8
         EynmyO4LdXxUUm+T1Fu08xGsGbWA2JhwLgtA89FehkIcBmOGF3pN0KEXFziMPS43oe1F
         DI2/ZlGqe3nD8JsKjhdewOnbO+Z92AGDIyTfgXqA2v3PUBliEAxYqsMu6PsW7uk7Gmap
         OBrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3uiwmxakbafmdjk5v66zcvaa3y.19916zfdzcx98ez8e.x97@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3uIwmXAkbAFMDJK5v66zCvAA3y.19916zFDzCx98Ez8E.x97@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id v20sor23634487ita.10.2018.12.28.12.51.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 12:51:04 -0800 (PST)
Received-SPF: pass (google.com: domain of 3uiwmxakbafmdjk5v66zcvaa3y.19916zfdzcx98ez8e.x97@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3uiwmxakbafmdjk5v66zcvaa3y.19916zfdzcx98ez8e.x97@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3uIwmXAkbAFMDJK5v66zCvAA3y.19916zFDzCx98Ez8E.x97@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN49GFz+DPyXTiISRhP81qeKhmQ+Q7sXplWZBqXwahqFKgNwb6tLVK7I0hKaoOU0jv6yLHnYh2rjNCL3RNDWzpI7D0IWiBnM
MIME-Version: 1.0
X-Received: by 2002:a24:138f:: with SMTP id 137mr21331000itz.18.1546030264185;
 Fri, 28 Dec 2018 12:51:04 -0800 (PST)
Date: Fri, 28 Dec 2018 12:51:04 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000b57d19057e1b383d@google.com>
Subject: KASAN: use-after-free Read in filemap_fault
From: syzbot <syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, darrick.wong@oracle.com, hannes@cmpxchg.org, 
	hughd@google.com, jack@suse.cz, josef@toxicpanda.com, jrdr.linux@gmail.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, sfr@canb.auug.org.au, 
	syzkaller-bugs@googlegroups.com, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181228205104.RuJCepQ-gUlRNkXV0gTKCkON6OTxtlffCLnWyRO85T0@z>

Hello,

syzbot found the following crash on:

HEAD commit:    6a1d293238c1 Add linux-next specific files for 20181224
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=102ca567400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=f9369d117d073843
dashboard link: https://syzkaller.appspot.com/bug?extid=b437b5a429d680cf2217
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=15f059b3400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12ac602d400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+b437b5a429d680cf2217@syzkaller.appspotmail.com

sshd (8177) used greatest stack depth: 15720 bytes left
hrtimer: interrupt took 27544 ns
==================================================================
BUG: KASAN: use-after-free in filemap_fault+0x2818/0x2a70 mm/filemap.c:2559
Read of size 8 at addr ffff8881b15026b0 by task syz-executor997/8196

CPU: 0 PID: 8196 Comm: syz-executor997 Not tainted 4.20.0-rc7-next-20181224  
#188
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1d3/0x2c6 lib/dump_stack.c:113
  print_address_description.cold.5+0x9/0x1ff mm/kasan/report.c:187
  kasan_report.cold.6+0x1b/0x39 mm/kasan/report.c:317
  __asan_report_load8_noabort+0x14/0x20 mm/kasan/generic_report.c:135
  filemap_fault+0x2818/0x2a70 mm/filemap.c:2559
  ext4_filemap_fault+0x82/0xad fs/ext4/inode.c:6326
  __do_fault+0x176/0x6f0 mm/memory.c:3013
  do_shared_fault mm/memory.c:3479 [inline]
  do_fault mm/memory.c:3554 [inline]
  handle_pte_fault mm/memory.c:3781 [inline]
  __handle_mm_fault+0x373b/0x55f0 mm/memory.c:3905
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3942
  do_user_addr_fault arch/x86/mm/fault.c:1475 [inline]
  __do_page_fault+0x5f6/0xd70 arch/x86/mm/fault.c:1541
  do_page_fault+0xf2/0x7e0 arch/x86/mm/fault.c:1572
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1143
RIP: 0033:0x400a57
Code: 00 00 00 00 e8 ba 59 04 00 8b 03 85 c0 74 d8 c7 45 08 00 00 00 00 83  
7d 04 05 0f 87 49 02 00 00 8b 45 04 ff 24 c5 e8 e4 4a 00 <c7> 04 25 fa ff  
00 20 2e 2f 62 75 66 c7 04 25 fe ff 00 20 73 00 b9
RSP: 002b:00007f48cd9c0dc0 EFLAGS: 00010293
RAX: 0000000000000000 RBX: 00000000006dbc28 RCX: 0000000000446409
RDX: 0000000000446409 RSI: 0000000000000081 RDI: 00000000006dbc2c
RBP: 00000000006dbc20 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00000000006dbc2c
R13: 00007ffd0bb6676f R14: 00007f48cd9c19c0 R15: 00000000006dbd2c

Allocated by task 8196:
  save_stack+0x43/0xd0 mm/kasan/common.c:73
  set_track mm/kasan/common.c:85 [inline]
  kasan_kmalloc+0xcb/0xd0 mm/kasan/common.c:482
  kasan_slab_alloc+0x12/0x20 mm/kasan/common.c:397
  kmem_cache_alloc+0x130/0x730 mm/slab.c:3541
  vm_area_alloc+0x7a/0x1d0 kernel/fork.c:331
  mmap_region+0x9d7/0x1cd0 mm/mmap.c:1756
  do_mmap+0xa22/0x1230 mm/mmap.c:1559
  do_mmap_pgoff include/linux/mm.h:2421 [inline]
  vm_mmap_pgoff+0x213/0x2c0 mm/util.c:350
  ksys_mmap_pgoff+0x4da/0x660 mm/mmap.c:1609
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:90 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:90
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

Freed by task 8197:
  save_stack+0x43/0xd0 mm/kasan/common.c:73
  set_track mm/kasan/common.c:85 [inline]
  __kasan_slab_free+0x102/0x150 mm/kasan/common.c:444
  kasan_slab_free+0xe/0x10 mm/kasan/common.c:452
  __cache_free mm/slab.c:3485 [inline]
  kmem_cache_free+0x83/0x290 mm/slab.c:3747
  vm_area_free+0x1c/0x20 kernel/fork.c:350
  remove_vma+0x13a/0x180 mm/mmap.c:185
  remove_vma_list mm/mmap.c:2585 [inline]
  __do_munmap+0x729/0xf50 mm/mmap.c:2822
  do_munmap mm/mmap.c:2830 [inline]
  mmap_region+0x6a7/0x1cd0 mm/mmap.c:1729
  do_mmap+0xa22/0x1230 mm/mmap.c:1559
  do_mmap_pgoff include/linux/mm.h:2421 [inline]
  vm_mmap_pgoff+0x213/0x2c0 mm/util.c:350
  ksys_mmap_pgoff+0x4da/0x660 mm/mmap.c:1609
  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:90 [inline]
  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:90
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

The buggy address belongs to the object at ffff8881b1502670
  which belongs to the cache vm_area_struct of size 200
The buggy address is located 64 bytes inside of
  200-byte region [ffff8881b1502670, ffff8881b1502738)
The buggy address belongs to the page:
page:ffffea0006c54080 count:1 mapcount:0 mapping:ffff8881da9827c0  
index:0xffff8881b1502eb0
flags: 0x2fffc0000000200(slab)
raw: 02fffc0000000200 ffffea0007477408 ffffea0006c5ec48 ffff8881da9827c0
raw: ffff8881b1502eb0 ffff8881b1502040 0000000100000004 0000000000000000
page dumped because: kasan: bad access detected

Memory state around the buggy address:
  ffff8881b1502580: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
  ffff8881b1502600: fb fb fb fb fb fb fc fc fc fc fc fc fc fc fb fb
> ffff8881b1502680: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                      ^
  ffff8881b1502700: fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc fb
  ffff8881b1502780: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

