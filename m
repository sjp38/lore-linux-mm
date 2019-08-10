Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D32D7C32756
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 18:15:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9890A2085B
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 18:15:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9890A2085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 064196B0006; Sat, 10 Aug 2019 14:15:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 013846B0008; Sat, 10 Aug 2019 14:15:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E43A26B000A; Sat, 10 Aug 2019 14:15:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB42E6B0006
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 14:15:07 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id w5so75965051otg.0
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 11:15:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=MsmEXwped4cbyL6h6bs/KZ2LTHxX7J5FpxmhjfgV7og=;
        b=kSixBSX8BFfMm01MtAdl5qcnnu9sMwewPRFq6boYvF0b3zIBFKFLMYd0491wLAP4mV
         x/2KP64jnYUerrCloajAuxAXKz4N/k5Ynxb3pcuP+ksAOKemjKI5D/Bc+t/KE03tq3ho
         8eEamF3PY6IWE24vg23np6VtAqbjHLJgv/SuwOtja2jb5EdO2OIirAWrTVCIBsZ37lAQ
         r3EWpBBxjDWzUuT8Icj693JdXfuWopw+HYUlTPROGnzpB951iAo4d/Wfyz0ERYpm9bRU
         VEjIMWWbaZCVg4IT1QugLUh7t7do4x7B/vNlAHuokDrbnklT0e2/Hl2uXUfyL6WPwDVl
         pcDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3qglpxqkbaokdjkvlwwpclaato.rzzrwpfdpcnzyepye.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3qglPXQkbAOkdjkVLWWPcLaaTO.RZZRWPfdPcNZYePYe.NZX@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAUfa1ArjbKqgV/FgCGDGSFKsLL0wyVqPem+YXk8tqGFGDto0R6u
	xRjkW+sVMHzjFkmYazNY9nUMn2z5Zhe86IK7MfVzr3hoT1sJBaqibmOX8tA1emGnbZ0dVcN59UY
	LXjD/MuWbalC02UUOorXnbzeRB+eTzAnidWFSzKhVB+kqKqDnfMZp2pMJj47ugVk=
X-Received: by 2002:a5d:8411:: with SMTP id i17mr27449027ion.83.1565460907417;
        Sat, 10 Aug 2019 11:15:07 -0700 (PDT)
X-Received: by 2002:a5d:8411:: with SMTP id i17mr27448996ion.83.1565460906568;
        Sat, 10 Aug 2019 11:15:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565460906; cv=none;
        d=google.com; s=arc-20160816;
        b=GxB/F+SLlPx59J0tXy/6y9WatS0Y+6TiEWu0UHm/1wGbf90093JVXl5Ycy4eFKeTt0
         VzHAU3I0rTt/nSQJRgkrksQoBhKubh3Kd/oavH2LQdHB2y0gc9FrL4w0fEbugJVrjdtK
         pn5hu79LkRL4G5f96U5juAadagA633Q74uWXYkSeTkVaj8VE4hppVIFl3Os1O59n+bro
         vvXLO2E8KFzpen5W3DXjXU9icd1OAGM8kfrGH4A4UWCWlLgXH5FnqTMeutJczVz48M3k
         cNgn2mxJXUT/IVsQfOn8LTAoIu3NDP6+xsMxh1GHgIkzLBdgK1xtAsK1ORTbDOtSZaxx
         O5kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=MsmEXwped4cbyL6h6bs/KZ2LTHxX7J5FpxmhjfgV7og=;
        b=q+Sw9wOCCHkgymuPCTMTIVKziS+lWWfeiVh7+9Y/KW5WrxfhmaBdZGN4i2KJFcO2AQ
         CdfNT7P/xQbSTbMawa3EC9l97GHyUc97OS+Q/NDgwIqr8bUlVtK0i6vOVRN+Kzza1rzu
         Bm7/WVQ5WThWFlqFBGXpxSo6Qu1IeWeG4wkMj1o7so4QzoYSNWcHSw/81NXA8mUZ2rKZ
         +KagFc0+x/3kO8X47Ij3xEa6Ai9o0Nkrk8AvC+ESwu53Cir7io2yjyg0xRvzdcW8EtXX
         gLBMSTwLPF9BTeg3r57KxEcH0hYeTw4mk9OWoaBgslGp0e36IT/52aCdZMsld06ShPXX
         NDjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3qglpxqkbaokdjkvlwwpclaato.rzzrwpfdpcnzyepye.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3qglPXQkbAOkdjkVLWWPcLaaTO.RZZRWPfdPcNZYePYe.NZX@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id i26sor16758045jaf.1.2019.08.10.11.15.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Aug 2019 11:15:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3qglpxqkbaokdjkvlwwpclaato.rzzrwpfdpcnzyepye.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3qglpxqkbaokdjkvlwwpclaato.rzzrwpfdpcnzyepye.nzx@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3qglPXQkbAOkdjkVLWWPcLaaTO.RZZRWPfdPcNZYePYe.NZX@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqzuX78j5MZdD9NknMDpWZDKRcpJUyudMpGZijC4CslADfAYaMDlmkJ3ExpZNosBtrPKqQzkTaBIJ6YYhsvueATdKqFCgLX8
MIME-Version: 1.0
X-Received: by 2002:a02:c6a9:: with SMTP id o9mr29951040jan.90.1565460906127;
 Sat, 10 Aug 2019 11:15:06 -0700 (PDT)
Date: Sat, 10 Aug 2019 11:15:06 -0700
In-Reply-To: <0000000000005c056c058f9a5437@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000383acd058fc745d8@google.com>
Subject: Re: BUG: bad usercopy in ld_usb_read
From: syzbot <syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, allison@lohutok.net, andreyknvl@google.com, 
	cai@lca.pw, gregkh@linuxfoundation.org, keescook@chromium.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-usb@vger.kernel.org, 
	mhund@ld-didactic.de, stern@rowland.harvard.edu, 
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has found a reproducer for the following crash on:

HEAD commit:    e96407b4 usb-fuzzer: main usb gadget fuzzer driver
git tree:       https://github.com/google/kasan.git usb-fuzzer
console output: https://syzkaller.appspot.com/x/log.txt?x=17cf0b16600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=cfa2c18fb6a8068e
dashboard link: https://syzkaller.appspot.com/bug?extid=45b2f40f0778cfa7634e
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=151bab16600000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=148f8cd2600000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+45b2f40f0778cfa7634e@syzkaller.appspotmail.com

ldusb 4-1:0.28: Read buffer overflow, -3222596215958809898 bytes dropped
usercopy: Kernel memory exposure attempt detected from process stack  
(offset 0, size 2147479552)!
------------[ cut here ]------------
kernel BUG at mm/usercopy.c:98!
invalid opcode: 0000 [#1] SMP KASAN
CPU: 1 PID: 2023 Comm: syz-executor861 Not tainted 5.3.0-rc2+ #25
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:usercopy_abort+0xb9/0xbb mm/usercopy.c:98
Code: e8 c1 f7 d6 ff 49 89 d9 4d 89 e8 4c 89 e1 41 56 48 89 ee 48 c7 c7 e0  
f3 cd 85 ff 74 24 08 41 57 48 8b 54 24 20 e8 15 98 c1 ff <0f> 0b e8 95 f7  
d6 ff e8 80 9f fd ff 8b 54 24 04 49 89 d8 4c 89 e1
RSP: 0018:ffff8881cbda7c40 EFLAGS: 00010282
RAX: 0000000000000061 RBX: ffffffff85cdf100 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff8128a0fd RDI: ffffed10397b4f7a
RBP: ffffffff85cdf2c0 R08: 0000000000000061 R09: fffffbfff11acda1
R10: fffffbfff11acda0 R11: ffffffff88d66d07 R12: ffffffff85cdf4e0
R13: ffffffff85cdf100 R14: 000000007ffff000 R15: ffffffff85cdf100
FS:  00007f10bb76a700(0000) GS:ffff8881db300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f7135a49000 CR3: 00000001d20e8000 CR4: 00000000001406e0
Call Trace:
  __check_object_size mm/usercopy.c:276 [inline]
  __check_object_size.cold+0x91/0xba mm/usercopy.c:250
  check_object_size include/linux/thread_info.h:119 [inline]
  check_copy_size include/linux/thread_info.h:150 [inline]
  copy_to_user include/linux/uaccess.h:151 [inline]
  ld_usb_read+0x304/0x780 drivers/usb/misc/ldusb.c:495
  __vfs_read+0x76/0x100 fs/read_write.c:425
  vfs_read+0x1ea/0x430 fs/read_write.c:461
  ksys_read+0x1e8/0x250 fs/read_write.c:587
  do_syscall_64+0xb7/0x580 arch/x86/entry/common.c:296
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x446e19
Code: e8 ec e7 ff ff 48 83 c4 18 c3 0f 1f 80 00 00 00 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 3b 07 fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f10bb769d98 EFLAGS: 00000246 ORIG_RAX: 0000000000000000
RAX: ffffffffffffffda RBX: 00000000006dbc38 RCX: 0000000000446e19
RDX: 00000000ffffffbc RSI: 0000000020000040 RDI: 0000000000000004
RBP: 00000000006dbc30 R08: 0000000000000000 R09: 0000000000000000
R10: 000000000000000f R11: 0000000000000246 R12: 00000000006dbc3c
R13: 0001002402090100 R14: 000048c920200f11 R15: 08983baa00000112
Modules linked in:
---[ end trace 93f3613883c53c00 ]---
RIP: 0010:usercopy_abort+0xb9/0xbb mm/usercopy.c:98
Code: e8 c1 f7 d6 ff 49 89 d9 4d 89 e8 4c 89 e1 41 56 48 89 ee 48 c7 c7 e0  
f3 cd 85 ff 74 24 08 41 57 48 8b 54 24 20 e8 15 98 c1 ff <0f> 0b e8 95 f7  
d6 ff e8 80 9f fd ff 8b 54 24 04 49 89 d8 4c 89 e1
RSP: 0018:ffff8881cbda7c40 EFLAGS: 00010282
RAX: 0000000000000061 RBX: ffffffff85cdf100 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff8128a0fd RDI: ffffed10397b4f7a
RBP: ffffffff85cdf2c0 R08: 0000000000000061 R09: fffffbfff11acda1
R10: fffffbfff11acda0 R11: ffffffff88d66d07 R12: ffffffff85cdf4e0
R13: ffffffff85cdf100 R14: 000000007ffff000 R15: ffffffff85cdf100
FS:  00007f10bb76a700(0000) GS:ffff8881db300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f7135a49000 CR3: 00000001d20e8000 CR4: 00000000001406e0

