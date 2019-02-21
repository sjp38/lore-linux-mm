Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5102C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:52:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D13C20700
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 14:52:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D13C20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17B208E008A; Thu, 21 Feb 2019 09:52:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12B0D8E0089; Thu, 21 Feb 2019 09:52:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0403F8E008A; Thu, 21 Feb 2019 09:52:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id D49B88E0089
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:52:05 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id q3so1547968ior.1
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:52:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=ZJS2VseaFwaepfUpDnWNKJKlN/YdNaSZxjKfyQ9C93g=;
        b=PI85E3T+MWYJWnWWuESv69ZmIq0jKxuotUxWirKbQx651zPtdTuBQI7pc+/uGk1HPa
         XeEK3CNV7R55BOhUPVbzm5oM50W7hJkOGVqwKv5Y3EbwbJyIo40iOAEXaFJwUhsKCofn
         1tEeL31QUWXy+OB+HyMOZaY4DB2Pxvz/zMQ1zpHNx1Vpr+hFv26Qh1JoAO5AgE1Kb7JV
         Fp91qyU4El39/WcsUmY7KyQz+q+ts4rqgWIzyCnb09c69FYj41f3YdtVVq6cv5a0w26o
         vyd6D2/O0RV3p/11MSn5MDCYgfsJbIB8j1wwTo2r16NliJMMgy2DPbKbv+M+s0I6mfQB
         v0rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3fltuxakbac8djkvlwwpclaato.rzzrwpfdpcnzyepye.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3FLtuXAkbAC8djkVLWWPcLaaTO.RZZRWPfdPcNZYePYe.NZX@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AHQUAuYgAgeCS9gkMlnblcUc6xx0Hr0z+n8FPBsz+z92OWKQihdLTVO7
	t5FUCR2RDWxy+EiQmwiWd2aZDdEzbOZFDo8hiw47A11Th59VzKIZv6EheLUu3aPdKh+QmdS4TtR
	BWYvczTzVf2irVuqEwtDTX2qjNYoKPpu7mW7IP5TzP7MadK/SHOJWJ0XphQP/fAJWMVY029wZ48
	rYcTi2Nmla7hjG36R0dn1XCii31UPc5Om/fCnjieN8K0NIbvWQO7EqO2BCLNiq2iqz1eubzgsf+
	FuG0dQY8fmv5nXub8ASqA9Ho2lfa0CGkgCKUJgLn2yYa2/f24E0OMrYYf7SH0RcpyT4Gw+/1b1T
	yxTOxyDHBvD5mmQoJUHGVKWCCgY8z9EjvhtvfL8Aw+pRzqfVHV7flicgP//RN1HpTpgTUqbVwQ=
	=
X-Received: by 2002:a02:ec4:: with SMTP id 187mr4491995jae.11.1550760725614;
        Thu, 21 Feb 2019 06:52:05 -0800 (PST)
X-Received: by 2002:a02:ec4:: with SMTP id 187mr4491932jae.11.1550760724600;
        Thu, 21 Feb 2019 06:52:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550760724; cv=none;
        d=google.com; s=arc-20160816;
        b=TzejG3CB8m3CFjv5wEgVHHlc9Lf7Dd1mTPEnbyP+FaDuNCWXHG1V/N90OhCj6WawLh
         8vhVhbaPPU+5o2A0Vj9OB7nnN5JE8x5JeC8URR/LBaawGFpL6OALURUJBY4+crJ1g7Ca
         2B/Re3/C81sTefdKEG6dTbBNshQ58NWTrb67EhNV7QiMb9hNZd7zjEFU1nis4T8RnBsk
         erj8gGzRUItpomLK0RNQy8S5guCU1TrH235QpTKmuEYS/HHJSPXKrRloatwD8alC1hUa
         dyp5itTOLG4xtkC+2ZWflpV8SLhbdRL4KTlLfrn1YGHJQSwGhssyfQAA3weyWTi1WFT9
         ZLhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=ZJS2VseaFwaepfUpDnWNKJKlN/YdNaSZxjKfyQ9C93g=;
        b=sS4Rk67QCxxRCPTTSYqK9CxIiTszWIUc86UcxpVGeZ6c7ltZ9hDR6FwnJg9qT7EgxP
         BsvKpuWDMuyVz9RNSH+hXZOe5Kv2B99BaUgR9gIMKk87YV26of2qPNPyhzp3yBsYy3me
         H5e5G5mvMIgqr/lXUQ4Gc0M7GdXOlfvWROPtWMqi6jXWPiBp7oIetrUfd8YSLAyzgKYU
         3QP+5l8OLS0FlGBPZqdnxjo/mlI9lP24rbpIr55khLtXIEtfa4Xxz1e7vy1RmVPBJpyI
         1rUCEMM9BnuHZjkZdPawz71dGmnbPsQFVE2GHDS83t5uO1+yOLGvXPlnOlfnuMLMMFVu
         s1uA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3fltuxakbac8djkvlwwpclaato.rzzrwpfdpcnzyepye.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3FLtuXAkbAC8djkVLWWPcLaaTO.RZZRWPfdPcNZYePYe.NZX@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id k4sor11659981iog.126.2019.02.21.06.52.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 06:52:04 -0800 (PST)
Received-SPF: pass (google.com: domain of 3fltuxakbac8djkvlwwpclaato.rzzrwpfdpcnzyepye.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3fltuxakbac8djkvlwwpclaato.rzzrwpfdpcnzyepye.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3FLtuXAkbAC8djkVLWWPcLaaTO.RZZRWPfdPcNZYePYe.NZX@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: AHgI3IYYYLJ55AAXJQMTHm/wFxozI21cq9PtW+0rU2zQ7iIk7+aBh7YUOsgoqtbqXovYRV2HSIO9DYrzXfD8BV6nkcCOY34KOljX
MIME-Version: 1.0
X-Received: by 2002:a6b:c707:: with SMTP id x7mr27774925iof.5.1550760724309;
 Thu, 21 Feb 2019 06:52:04 -0800 (PST)
Date: Thu, 21 Feb 2019 06:52:04 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000001aab8b0582689e11@google.com>
Subject: BUG: unable to handle kernel NULL pointer dereference in __generic_file_write_iter
From: syzbot <syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, amir73il@gmail.com, darrick.wong@oracle.com, 
	david@fromorbit.com, hannes@cmpxchg.org, hughd@google.com, 
	jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	syzkaller-bugs@googlegroups.com, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    4aa9fc2a435a Revert "mm, memory_hotplug: initialize struct..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1101382f400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4fceea9e2d99ac20
dashboard link: https://syzkaller.appspot.com/bug?extid=ca95b2b7aef9e7cbd6ab
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+ca95b2b7aef9e7cbd6ab@syzkaller.appspotmail.com

BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
#PF error: [INSTR]
PGD a7ea0067 P4D a7ea0067 PUD 81535067 PMD 0
Oops: 0010 [#1] PREEMPT SMP KASAN
CPU: 0 PID: 15924 Comm: syz-executor0 Not tainted 5.0.0-rc4+ #50
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:          (null)
Code: Bad RIP value.
RSP: 0018:ffff88804c3d7858 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffffff885aeb60 RCX: 000000000000005b
RDX: 0000000000000000 RSI: ffff88807ec22930 RDI: ffff8880a59bdcc0
RBP: ffff88804c3d79b8 R08: 0000000000000000 R09: ffff88804c3d7910
R10: ffff8880835ca200 R11: 0000000000000000 R12: 000000000000005b
R13: ffff88804c3d7c98 R14: dffffc0000000000 R15: 0000000000000000
FS:  00007f3456db4700(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffffffffffd6 CR3: 00000000814ac000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
  __generic_file_write_iter+0x25e/0x630 mm/filemap.c:3333
  ext4_file_write_iter+0x37a/0x1410 fs/ext4/file.c:266
  call_write_iter include/linux/fs.h:1862 [inline]
  new_sync_write fs/read_write.c:474 [inline]
  __vfs_write+0x764/0xb40 fs/read_write.c:487
  vfs_write+0x20c/0x580 fs/read_write.c:549
  ksys_write+0x105/0x260 fs/read_write.c:598
  __do_sys_write fs/read_write.c:610 [inline]
  __se_sys_write fs/read_write.c:607 [inline]
  __x64_sys_write+0x73/0xb0 fs/read_write.c:607
  do_syscall_64+0x1a3/0x800 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x458089
Code: 6d b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 3b b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f3456db3c78 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000458089
RDX: 000000000000005b RSI: 0000000020000240 RDI: 0000000000000003
RBP: 000000000073bf00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007f3456db46d4
R13: 00000000004c7450 R14: 00000000004dce68 R15: 00000000ffffffff
Modules linked in:
CR2: 0000000000000000
---[ end trace 5cac9d2c75a59916 ]---
kobject: 'loop5' (000000004426a409): kobject_uevent_env
RIP: 0010:          (null)
Code: Bad RIP value.
RSP: 0018:ffff88804c3d7858 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffffff885aeb60 RCX: 000000000000005b
kobject: 'loop5' (000000004426a409): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
RDX: 0000000000000000 RSI: ffff88807ec22930 RDI: ffff8880a59bdcc0
kobject: 'loop2' (00000000b82e0c58): kobject_uevent_env
kobject: 'loop2' (00000000b82e0c58): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
RBP: ffff88804c3d79b8 R08: 0000000000000000 R09: ffff88804c3d7910
R10: ffff8880835ca200 R11: 0000000000000000 R12: 000000000000005b
R13: ffff88804c3d7c98 R14: dffffc0000000000 R15: 0000000000000000
kobject: 'loop5' (000000004426a409): kobject_uevent_env
FS:  00007f3456db4700(0000) GS:ffff8880ae600000(0000) knlGS:0000000000000000
kobject: 'loop5' (000000004426a409): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000022029a0 CR3: 00000000814ac000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.

