Return-Path: <SRS0=02Vf=PI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA9ACC43387
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 07:44:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59B4820685
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 07:44:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59B4820685
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0143D8E0081; Mon, 31 Dec 2018 02:44:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F06C18E005B; Mon, 31 Dec 2018 02:44:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1D518E0081; Mon, 31 Dec 2018 02:44:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA50B8E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:44:04 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id o205so28861250itc.2
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:44:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=bdv1sMha03ld56n5Bzq8LTNotz/c69p/Y4Dv55035EY=;
        b=Tz1AY0dAMy//OigJ1hFFxDkaz97bSRoi08wZFN3I95Pbr6VntUavZxe12bG57ZCmUV
         2YXI66WAPbucHcwyz0C3fs/tebwP42twyCBMqYGK6/1aZT6fTrh6egykpKy1+OeQEpZq
         Vy3RUzEMhBGdjGQCMyFnNfITg50O6Jh+qKIT9rnn45gLSwCfo5DVTtcCo2ZlCRInCO4o
         Dhp4HnDBleiVSKXYdMR3UWbUVF5/PxbyhBy5ra6bKzanDu1LpjhQErUJaB/ZGaNClaz/
         JJO/MfL+pnYv0wnaVLlcT5EXe3JOdV8gSijxkDNFGXQbsJ0Jn8ZqbiN2UjiFsb7hi27/
         zXwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3w8gpxakbaoiwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3w8gpXAkbAOIWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukcz/95wKXSImGBwWASAjgpLGx3aiUOl8aiAKIrYimlXk4rQ5oX7
	HazvSFxfMDeNjuFX9OdQbEe9oKqpjVJfBqhcQ3733sFD1BtpC2xaod8IA3tZhEXVpuje4cnWAKi
	aIEw9vEyXHWn19DYcyxmZy/xqb+Rzxr6CM7Mf8K4lc51LhQ0au99kmrSdz7UPJTfEbr6HCqp83f
	PlGsyayaS4f77mpEoeJHBa3oO9OouP3PhpMRQyyMCTdN+KHV0VMuzFv685rFtmrYKLE6dNMdDiw
	XlK/XzKu7uXDvphgL6ZnWahihz6o3MIdgHcR+clIdb1wvaX0awyXnEoc3CxqK8lyLPc6XUpQ0/1
	8rfQDPEMTYUqDZbtpsfSgU6fOdBo68JcYPD1RNAYIQV+8sDPp+GJyHBNBUYi4t//ONTKyYETCw=
	=
X-Received: by 2002:a5e:8b05:: with SMTP id g5mr20776391iok.144.1546242244527;
        Sun, 30 Dec 2018 23:44:04 -0800 (PST)
X-Received: by 2002:a5e:8b05:: with SMTP id g5mr20776373iok.144.1546242243781;
        Sun, 30 Dec 2018 23:44:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546242243; cv=none;
        d=google.com; s=arc-20160816;
        b=0FOe6EVpUDKaPZSN5mBL4+2/1F68xST5l9SRZs4/OPyc8QRHiOUW3AXA2iKeSj01yP
         5McplQuRMK7yOEoD01U27QCBi7KgGOAREgf4FdVbnmEOHR6DyRvDCAw6XvhX4ocKMTvQ
         MrfDCPTODSczmeWsqTZSkjsMWJdkbumDlVDtQnJfYSk+ba3QjW/FspGxXWwdJg5QNcEn
         pR1+C0QghFsKf1kc+kbvTUIOWvZ/on9vbADBUQk0F3DN3Php3OAb0WLZObLSTzcf9aeg
         46HW5+rL6FAtgdfgmVkAddBRcyUxsKmUNsed3jst3nU/FBSkFF5I74vcaoksVZ6L2diK
         jC2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=bdv1sMha03ld56n5Bzq8LTNotz/c69p/Y4Dv55035EY=;
        b=ohGZ+n62f9ijXGz709+zNHduBdB1Hhzgmg4a6et9Ia8ZxR+tvi/r0ludu/8NzbvsD5
         OlZCqyiJb/FMxqnwqd5/GjkUbAOG9QVCEi/L2MruYXZ+Ql8vE8cvfBxFvTRSQOKS0YSf
         V/biAYGLvhsLIxlQWWNYnu1CF/XjF0q8rh7v2bcRzOlpnOR356druwhuPlQtf5s04yHl
         IoMV8ikY3wyRvfMozU6CasZZ5GIrJqzNTnp6SXgNgC4y2L652Sy9SXmbIqGcC3rih5jW
         tETPDVW9SkfE9eoyrRR43jKb+mw9im9/sjEiB1dwFjDT8G3rYlzq8zBzMAFqn+YtShDu
         YeFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3w8gpxakbaoiwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3w8gpXAkbAOIWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id p14sor14674230iob.11.2018.12.30.23.44.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:44:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3w8gpxakbaoiwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3w8gpxakbaoiwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3w8gpXAkbAOIWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN6ljpzf6Bk9HOR2acmNUfHXUnALkJoJSyeOnA7XBkmTCVhAk4vDiSSo1bU5TqNG0odbOy0PXab9oSTs+bHIyJl/7AQi83do
MIME-Version: 1.0
X-Received: by 2002:a5d:9683:: with SMTP id m3mr10213833ion.28.1546242243367;
 Sun, 30 Dec 2018 23:44:03 -0800 (PST)
Date: Sun, 30 Dec 2018 23:44:03 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000a72593057e4c934d@google.com>
Subject: BUG: unable to handle kernel NULL pointer dereference in unlink_file_vma
From: syzbot <syzbot+4cbac4707f8e5215007b@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, dwmw@amazon.co.uk, 
	jrdr.linux@gmail.com, kirill.shutemov@linux.intel.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, 
	mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181231074403.X1ghtyAFzhs1rWOL9U2pQ3-GJi24Lm80JH6t8UTM-QA@z>

Hello,

syzbot found the following crash on:

HEAD commit:    3d647e62686f Merge tag 's390-4.19-4' of git://git.kernel.o..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1316f4a5400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=88e9a8a39dc0be2d
dashboard link: https://syzkaller.appspot.com/bug?extid=4cbac4707f8e5215007b
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+4cbac4707f8e5215007b@syzkaller.appspotmail.com

RAX: 0000000000000002 RBX: 00000000ffffffff RCX: 000000000045df89
RDX: 0000000000000080 RSI: 000000c420033890 RDI: 0000000000000004
RBP: 000000c420033e90 R08: 0000000000000003 R09: 000000c420000d80
R10: 00000000ffffffff R11: 0000000000000246 R12: 0000000000000001
R13: 000000c42f90d718 R14: 0000000000000066 R15: 000000c42f90d708
BUG: unable to handle kernel NULL pointer dereference at 0000000000000068
PGD 1d85b1067 P4D 1d85b1067 PUD 1cd360067 PMD 0
Oops: 0002 [#1] PREEMPT SMP KASAN
CPU: 1 PID: 2748 Comm: syz-executor0 Not tainted 4.19.0-rc7+ #55
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:__down_write arch/x86/include/asm/rwsem.h:142 [inline]
RIP: 0010:down_write+0x97/0x130 kernel/locking/rwsem.c:72
Code: a5 f9 31 d2 45 31 c9 41 b8 01 00 00 00 ff 75 08 48 8d 7b 60 31 c9 31  
f6 e8 c6 01 b1 f9 48 89 d8 48 ba 01 00 00 00 ff ff ff ff <f0> 48 0f c1 10  
85 d2 74 05 e8 3b 29 fe ff 48 8d 7d a0 5a 48 89 f8
RSP: 0000:ffff880128396ff0 EFLAGS: 00010246
RAX: 0000000000000068 RBX: 0000000000000068 RCX: 0000000000000000
RDX: ffffffff00000001 RSI: 0000000000000000 RDI: 0000000000000286
RBP: ffff880128397078 R08: 0000000000000001 R09: 0000000000000000
R10: ffff8801ce8da278 R11: 0000000000000000 R12: 1ffff10025072dff
R13: 0000000000000068 R14: dffffc0000000000 R15: 00007fca701da000
FS:  00007fca6ebd9700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000068 CR3: 00000001d88cd000 CR4: 00000000001406e0
kobject: 'syz_tun' (00000000bb2f2151): kobject_cleanup, parent            
(null)
Call Trace:
  i_mmap_lock_write include/linux/fs.h:482 [inline]
  unlink_file_vma+0x75/0xb0 mm/mmap.c:166
  free_pgtables+0x279/0x380 mm/memory.c:641
  exit_mmap+0x2cd/0x590 mm/mmap.c:3094
  __mmput kernel/fork.c:1001 [inline]
  mmput+0x247/0x610 kernel/fork.c:1022
  exit_mm kernel/exit.c:545 [inline]
  do_exit+0xe6f/0x2610 kernel/exit.c:854
  do_group_exit+0x177/0x440 kernel/exit.c:970
  get_signal+0x8b0/0x1980 kernel/signal.c:2513
  do_signal+0x9c/0x21e0 arch/x86/kernel/signal.c:816
  exit_to_usermode_loop+0x2e5/0x380 arch/x86/entry/common.c:162
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x6be/0x820 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457579
Code: 24 08 48 89 01 e8 d7 2d fc ff e8 22 7a fc ff b8 02 00 00 00 48 8d 0d  
6a 60 09 01 87 01 8b 05 62 60 09 01 83 f8 01 0f 85 8a 00 <00> 00 b8 01 00  
00 00 88 05 9e 65 09 01 84 c0 74 72 b8 01 00 00 00
RSP: 002b:00007fca6ebd8cf8 EFLAGS: 00000246 ORIG_RAX: 00000000000000ca
RAX: fffffffffffffe00 RBX: 000000000072bf08 RCX: 0000000000457579
RDX: 0000000000000000 RSI: 0000000000000080 RDI: 000000000072bf08
RBP: 000000000072bf00 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 000000000072bf0c
R13: 00007ffd2b23c63f R14: 00007fca6ebd99c0 R15: 0000000000000000
Modules linked in:
CR2: 0000000000000068
---[ end trace ea9ba926f44bc95e ]---
RIP: 0010:__down_write arch/x86/include/asm/rwsem.h:142 [inline]
RIP: 0010:down_write+0x97/0x130 kernel/locking/rwsem.c:72
Code: a5 f9 31 d2 45 31 c9 41 b8 01 00 00 00 ff 75 08 48 8d 7b 60 31 c9 31  
f6 e8 c6 01 b1 f9 48 89 d8 48 ba 01 00 00 00 ff ff ff ff <f0> 48 0f c1 10  
85 d2 74 05 e8 3b 29 fe ff 48 8d 7d a0 5a 48 89 f8
RSP: 0000:ffff880128396ff0 EFLAGS: 00010246
RAX: 0000000000000068 RBX: 0000000000000068 RCX: 0000000000000000
RDX: ffffffff00000001 RSI: 0000000000000000 RDI: 0000000000000286
RBP: ffff880128397078 R08: 0000000000000001 R09: 0000000000000000
R10: ffff8801ce8da278 R11: 0000000000000000 R12: 1ffff10025072dff
R13: 0000000000000068 R14: dffffc0000000000 R15: 00007fca701da000
FS:  00007fca6ebd9700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000068 CR3: 00000001d88cd000 CR4: 00000000001406e0


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.

