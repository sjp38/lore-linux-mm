Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=FROM_LOCAL_DIGITS,
	FROM_LOCAL_HEX,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48DB9C4646B
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 16:27:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03A6B20673
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 16:27:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03A6B20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D8698E0002; Fri, 21 Jun 2019 12:27:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 888A98E0001; Fri, 21 Jun 2019 12:27:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 750C28E0002; Fri, 21 Jun 2019 12:27:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 555C98E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 12:27:07 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id x17so11261637iog.8
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:27:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=h+SI/Am0w+9xpzpMcK0TGxc+SX3xzBYxFkvA+riSWrA=;
        b=puSSManNOjGlw7/oe2mx+vMqZM8sBe+JeVidDNNKQln1RqgZekQ50LxpcnX+LU8hEf
         xEe9NtChr84P3pCfCmn0W03l7W34f+7iSKn4xBhPDYBpRQxq0NImahVbr7jgDI+1fMn0
         gQyHhHjHmZUn9offFiDetOwy0Xw5gsPDb5mhi7ie8EKav1gt/3BmGCZsqchgjMvgjyL4
         58h7LALZ4xwAjOfwVFnx+rY7RCllAFpfOgN019k9BfjllYmSVc3kNCziGTB4XmpglX51
         6GeMh0L1pt3vu7HDTwsVGB8hsg0bAVraX9AUV5XupXc5iNnGx+D2VKqMslI7rqyNHQKM
         NoLw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3wqunxqkbaiy289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3WQUNXQkbAIY289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAUxcmIORq/eBJOsYjF+TzrFS8nJMJAE9GHV50lSB40kFUC1JnHF
	LEKyR2Kor50dljG0oVJ4Xyrzi8b9mCG7SlQZnvzk17QX4vzDStX+KWz5V6RLCYBul10nwtmWBN8
	beTABhpQEbo/QfqatcBXTaT0o20k3ovQiVpFMVIsKIJ4WAqmYewBdBsoeuvYQmdU=
X-Received: by 2002:a5d:9bc6:: with SMTP id d6mr12747342ion.160.1561134427071;
        Fri, 21 Jun 2019 09:27:07 -0700 (PDT)
X-Received: by 2002:a5d:9bc6:: with SMTP id d6mr12747281ion.160.1561134426184;
        Fri, 21 Jun 2019 09:27:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561134426; cv=none;
        d=google.com; s=arc-20160816;
        b=jt9NEt8gQvOTYgwhEaU/mrH7nzOauDxyYaRGuk6EnHtEO+65jMhQYjzILsBxmgRuPE
         NiTt1bKg7sOUMqYfxSxDNSpTu67x8tKVYqbRtKO9iLSNBQbH2EZ78XGYObB9lCVjJm2B
         rNC0qW5ov5q+VadqnpBY71VBhbEW9LMGnp2IBdKrNeSmGoRU9EEGXF83aTn7OS1FwUf0
         hhfYZ5IMcpjfbxUIJLmsek9mF1LzHMWqj9DdjJFHR2bEgsTZFziN4H0z9QyKcAfsPrUP
         XzeJBMDM/y1dJLu75SAjvoGaVOOL29tQbXmiv/BfbyWN0jGR70HDdVwTEv2f19V5lkTN
         N72w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=h+SI/Am0w+9xpzpMcK0TGxc+SX3xzBYxFkvA+riSWrA=;
        b=U2W8k0T1Hd/z+Td79npauLUfBn8o2cMJshqW5g3JAbfPGcYNaBFKs7NfwZbEfI5QFA
         A11T5xD7Cn+iYnF/fgEFAsDAloR6YzdzbAL7qvKd730AsIwLP6TGvQQWu3gqIXNnMkjz
         b+6QEt0vO5DWHMnaBbu26gGMf5y6dCvRNqVotA8PaX3poK0EB4h9+qXTao8UHFSdJpov
         0anK0WCFx1z+GopwsBn3ompGVzFf0XIoMJ7JAzgKYFq7R80Q484SwfzU2WyYLnVWPGWn
         xPsUaOed5WTbYECnpUM584YoUajMUtAurF3lPF41XE4qABwYkBoOFtNd92vHacPPNUfl
         FpVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3wqunxqkbaiy289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3WQUNXQkbAIY289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id n20sor2726976ioj.107.2019.06.21.09.27.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 09:27:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3wqunxqkbaiy289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3wqunxqkbaiy289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3WQUNXQkbAIY289ukvvo1kzzsn.qyyqvo42o1myx3ox3.myw@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqwUx48ytk5pymdQ+l0hKlkof637MQHUQYXEPpgcT4xE0tb93h5ZehYaKcCc5x6i1/J5+QRDvg4F6hxkyMo2nSv0LBDkBo5M
MIME-Version: 1.0
X-Received: by 2002:a5e:8209:: with SMTP id l9mr1896385iom.303.1561134425860;
 Fri, 21 Jun 2019 09:27:05 -0700 (PDT)
Date: Fri, 21 Jun 2019 09:27:05 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000e672c6058bd7ee45@google.com>
Subject: KASAN: slab-out-of-bounds Write in validate_chain
From: syzbot <syzbot+8893700724999566d6a9@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, cai@lca.pw, crecklin@redhat.com, 
	keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    abf02e29 Merge tag 'pm-5.2-rc6' of git://git.kernel.org/pu..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=16894709a00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=28ec3437a5394ee0
dashboard link: https://syzkaller.appspot.com/bug?extid=8893700724999566d6a9
compiler:       clang version 9.0.0 (/home/glider/llvm/clang  
80fee25776c2fb61e74c1ecb1a523375c2500b69)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=167098b2a00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+8893700724999566d6a9@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: slab-out-of-bounds in check_prev_add  
kernel/locking/lockdep.c:2298 [inline]
BUG: KASAN: slab-out-of-bounds in check_prevs_add  
kernel/locking/lockdep.c:2418 [inline]
BUG: KASAN: slab-out-of-bounds in validate_chain+0x1a35/0x84f0  
kernel/locking/lockdep.c:2800
Write of size 8 at addr ffff88807aeb00d0 by task syz-executor.5/8425

CPU: 0 PID: 8425 Comm: syz-executor.5 Not tainted 5.2.0-rc5+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:

Allocated by task 2062228080:
usercopy: Kernel memory overwrite attempt detected to SLAB  
object 'kmalloc-4k' (offset 4112, size 1)!
------------[ cut here ]------------
kernel BUG at mm/usercopy.c:102!
invalid opcode: 0000 [#1] PREEMPT SMP KASAN
CPU: 0 PID: 8425 Comm: syz-executor.5 Not tainted 5.2.0-rc5+ #4
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
RIP: 0010:usercopy_abort+0x8d/0x90 mm/usercopy.c:90
Code: 84 5e 88 48 0f 44 de 48 c7 c7 7e a3 5d 88 4c 89 ce 4c 89 d1 4d 89 d8  
49 89 c1 31 c0 41 57 41 56 53 e8 3a 92 a8 ff 48 83 c4 18 <0f> 0b 90 55 48  
89 e5 41 57 41 56 41 55 41 54 53 48 83 ec 30 41 89
RSP: 0018:ffff88807aeaf648 EFLAGS: 00010086
RAX: 0000000000000068 RBX: ffffffff885e841b RCX: defe62446f204b00
RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000000
RBP: ffff88807aeaf660 R08: ffffffff817fec49 R09: ffffed1015d444c6
R10: ffffed1015d444c6 R11: 1ffff11015d444c5 R12: ffff88807aeaf7d1
R13: 0000000000000200 R14: 0000000000001010 R15: 0000000000000001
FS:  0000555556495940(0000) GS:ffff8880aea00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffff8adaea30 CR3: 00000000a0d73000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
Modules linked in:
---[ end trace e8702886173758cd ]---
RIP: 0010:usercopy_abort+0x8d/0x90 mm/usercopy.c:90
Code: 84 5e 88 48 0f 44 de 48 c7 c7 7e a3 5d 88 4c 89 ce 4c 89 d1 4d 89 d8  
49 89 c1 31 c0 41 57 41 56 53 e8 3a 92 a8 ff 48 83 c4 18 <0f> 0b 90 55 48  
89 e5 41 57 41 56 41 55 41 54 53 48 83 ec 30 41 89
RSP: 0018:ffff88807aeaf648 EFLAGS: 00010086
RAX: 0000000000000068 RBX: ffffffff885e841b RCX: defe62446f204b00
RDX: 0000000000000000 RSI: 0000000000000001 RDI: 0000000000000000
RBP: ffff88807aeaf660 R08: ffffffff817fec49 R09: ffffed1015d444c6
R10: ffffed1015d444c6 R11: 1ffff11015d444c5 R12: ffff88807aeaf7d1
R13: 0000000000000200 R14: 0000000000001010 R15: 0000000000000001
FS:  0000555556495940(0000) GS:ffff8880aea00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffffff8adaea30 CR3: 00000000a0d73000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

