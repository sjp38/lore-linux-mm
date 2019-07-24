Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,LONGWORDS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C9FEC41517
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CCAC21951
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 19:18:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CCAC21951
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B30506B0006; Wed, 24 Jul 2019 15:18:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE12C8E0003; Wed, 24 Jul 2019 15:18:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F5738E0002; Wed, 24 Jul 2019 15:18:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 803996B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:18:09 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z19so52176311ioi.15
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 12:18:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=WTTYbLE73AWlaT+4DUpRkatPF3o10cRfnbNcZrdiW7k=;
        b=UhfEf7nr1m0DqED0DLDvvfxvYZxbW8DqEBCTlb/NTuitrE7msw14N64eR02Sre5171
         hmWQSoI2iSAMiJhqXeJPMuQ5Z6VWgUD6PvswJC3H67MBg69CbLVFZCHuuUORIWAbqgv7
         zgkB7sSWR1AXijgK/ovyKiLeQGyTm8nyascc3px+us82uD9LGgdyFxQ1xDaISjGJYa3R
         lvwjnxnQX+MDvgaSi+Yk7HXuOe272yh4C+vfmWkYFQb+VRTRMsZnr9AoREq5e8XxCRmD
         P9wU/x86DAWbCi52FFZBV6TmdaSX/d4anafv/ZcrHAsUXIbLdrbk5euzyIKO9Ju+JUGV
         IC2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 37644xqkbacaouvg6hhan6lle9.ckkchaqoan8kjpajp.8ki@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=37644XQkbACAOUVG6HHAN6LLE9.CKKCHAQOAN8KJPAJP.8KI@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAWfQZ/KagzjTti52J8s26/0LWHSE7xXJsOiuB0pXr/7eNzy0rJl
	UDyQPkGPjvh2or6FszgW21YFtqYhXjhYp55FxdxpvSveZB70WLBTBiKArJToCBStQ/7264Ql/P2
	YQCFHGeZsTfW/Ob3ws33fKN+KT7zHuTqyvUHyUiso07Qxg1ENdLT5S1yYu5xJtUw=
X-Received: by 2002:a02:a90a:: with SMTP id n10mr54866579jam.61.1563995889282;
        Wed, 24 Jul 2019 12:18:09 -0700 (PDT)
X-Received: by 2002:a02:a90a:: with SMTP id n10mr54866504jam.61.1563995888070;
        Wed, 24 Jul 2019 12:18:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563995888; cv=none;
        d=google.com; s=arc-20160816;
        b=A9l/JrG1BMBfpT0Eyn/uoj7xR7TVd8ziNEjuvqVsEDIIge5XoHBsW2NPjyfGCIw3bJ
         DxPNU2ShH/dnIiArfoM2ev6C55wHuiiTypQjOkdD3+AR4PiZWzA71YBUunlmZK0f0D3/
         EiM1Dj9M/7Pgnwbcc0bfnt/lazYA0hyg1TipnsV6Xc7MOxQ5v/wa7f54mBnEEn76UIPV
         ITm5NnnR42MIyq9+0P80twlkFVJvBVBRivbyr8ARkWXVE8zi4S3BdIHw/idqs4FZM74F
         DM35YfOO2eRt8Wk5diPKUmjNZIZ/zZqKn0K/iihp06gxZwOc9st2fQJm1RSCBpuRAJMP
         VScQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=WTTYbLE73AWlaT+4DUpRkatPF3o10cRfnbNcZrdiW7k=;
        b=rGJDWwL8EZjDqoO9+SVGzE16EBFrnY8EXa3Qgrq6BH1whSXlWVHdMrQgELUv+W/vMZ
         97+uOldg3NuSBaMnC98PRsuOlGqapWG5kcURdLZKUV1F+RSkyg9c7jwXJ/LcmCYoq+qc
         cDea6N2WfoyHFG41VcrBCPrpnjr2g7oIZQBoMboIExs54YNMy+CSO+R+TFAu66CnbsKM
         bIZjPWSD0JIUjYtqF2g9D/dwt1jeO6FLpI2Q90dzWVShgpqFehu5rn5AH2Qx2FXLte4Y
         msOqdFi2Q5c1t25PtOfiNKq0QWsfHC+iSlTdpSiSRebGczL93zdwUq4bzYOIL4sfrjNl
         sA7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 37644xqkbacaouvg6hhan6lle9.ckkchaqoan8kjpajp.8ki@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=37644XQkbACAOUVG6HHAN6LLE9.CKKCHAQOAN8KJPAJP.8KI@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id w11sor31215643iot.14.2019.07.24.12.18.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 12:18:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of 37644xqkbacaouvg6hhan6lle9.ckkchaqoan8kjpajp.8ki@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 37644xqkbacaouvg6hhan6lle9.ckkchaqoan8kjpajp.8ki@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=37644XQkbACAOUVG6HHAN6LLE9.CKKCHAQOAN8KJPAJP.8KI@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqzfdGDIebjboIFMguNwKODZmojQT3sEkbs06YCmnVrHK53S2FZaVnW2oYYy9NsTU9Yqk2XE2ERshhGzs9H51ajBfjEKzgop
MIME-Version: 1.0
X-Received: by 2002:a6b:6d08:: with SMTP id a8mr69580148iod.191.1563995887803;
 Wed, 24 Jul 2019 12:18:07 -0700 (PDT)
Date: Wed, 24 Jul 2019 12:18:07 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <00000000000052ad6b058e722ba4@google.com>
Subject: memory leak in vq_meta_prefetch
From: syzbot <syzbot+a871c1e6ea00685e73d7@syzkaller.appspotmail.com>
To: alexandre.belloni@free-electrons.com, catalin.marinas@arm.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, nicolas.ferre@atmel.com, 
	robh@kernel.org, sre@kernel.org, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=15fffef4600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
dashboard link: https://syzkaller.appspot.com/bug?extid=a871c1e6ea00685e73d7
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=127b0334600000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12609e94600000

The bug was bisected to:

commit 0e5f7d0b39e1f184dc25e3adb580c79e85332167
Author: Nicolas Ferre <nicolas.ferre@atmel.com>
Date:   Wed Mar 16 13:19:49 2016 +0000

     ARM: dts: at91: shdwc binding: add new shutdown controller documentation

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=16c6d53fa00000
final crash:    https://syzkaller.appspot.com/x/report.txt?x=15c6d53fa00000
console output: https://syzkaller.appspot.com/x/log.txt?x=11c6d53fa00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+a871c1e6ea00685e73d7@syzkaller.appspotmail.com
Fixes: 0e5f7d0b39e1 ("ARM: dts: at91: shdwc binding: add new shutdown  
controller documentation")

executing program
executing program
executing program
executing program
executing program
BUG: memory leak
unreferenced object 0xffff88811b327cc0 (size 32):
   comm "vhost-7201", pid 7205, jiffies 4294952492 (age 19.700s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<000000009e106308>] kmemleak_alloc_recursive  
/./include/linux/kmemleak.h:43 [inline]
     [<000000009e106308>] slab_post_alloc_hook /mm/slab.h:522 [inline]
     [<000000009e106308>] slab_alloc /mm/slab.c:3319 [inline]
     [<000000009e106308>] kmem_cache_alloc_trace+0x145/0x280 /mm/slab.c:3548
     [<00000000ed2eec2d>] kmalloc /./include/linux/slab.h:552 [inline]
     [<00000000ed2eec2d>] vhost_map_prefetch /drivers/vhost/vhost.c:877  
[inline]
     [<00000000ed2eec2d>] vhost_vq_map_prefetch /drivers/vhost/vhost.c:1838  
[inline]
     [<00000000ed2eec2d>] vq_meta_prefetch+0x18e/0x350  
/drivers/vhost/vhost.c:1849
     [<000000009d9c11b8>] handle_rx+0x9d/0xc00 /drivers/vhost/net.c:1128
     [<000000008f883d86>] handle_rx_net+0x19/0x20 /drivers/vhost/net.c:1270
     [<00000000577ffdd8>] vhost_worker+0xc6/0x120 /drivers/vhost/vhost.c:519
     [<000000001201f3db>] kthread+0x13e/0x160 /kernel/kthread.c:255
     [<00000000093cd85a>] ret_from_fork+0x1f/0x30  
/arch/x86/entry/entry_64.S:352

BUG: memory leak
unreferenced object 0xffff88811b327cc0 (size 32):
   comm "vhost-7201", pid 7205, jiffies 4294952492 (age 20.600s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
   backtrace:
     [<000000009e106308>] kmemleak_alloc_recursive  
/./include/linux/kmemleak.h:43 [inline]
     [<000000009e106308>] slab_post_alloc_hook /mm/slab.h:522 [inline]
     [<000000009e106308>] slab_alloc /mm/slab.c:3319 [inline]
     [<000000009e106308>] kmem_cache_alloc_trace+0x145/0x280 /mm/slab.c:3548
     [<00000000ed2eec2d>] kmalloc /./include/linux/slab.h:552 [inline]
     [<00000000ed2eec2d>] vhost_map_prefetch /drivers/vhost/vhost.c:877  
[inline]
     [<00000000ed2eec2d>] vhost_vq_map_prefetch /drivers/vhost/vhost.c:1838  
[inline]
     [<00000000ed2eec2d>] vq_meta_prefetch+0x18e/0x350  
/drivers/vhost/vhost.c:1849
     [<000000009d9c11b8>] handle_rx+0x9d/0xc00 /drivers/vhost/net.c:1128
     [<000000008f883d86>] handle_rx_net+0x19/0x20 /drivers/vhost/net.c:1270
     [<00000000577ffdd8>] vhost_worker+0xc6/0x120 /drivers/vhost/vhost.c:519
     [<000000001201f3db>] kthread+0x13e/0x160 /kernel/kthread.c:255
     [<00000000093cd85a>] ret_from_fork+0x1f/0x30  
/arch/x86/entry/entry_64.S:352



---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
For information about bisection process see: https://goo.gl/tpsmEJ#bisection
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

