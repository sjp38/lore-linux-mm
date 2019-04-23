Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 841E7C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:13:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B5E8208E4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:13:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B5E8208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D35FC6B0003; Tue, 23 Apr 2019 12:13:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE53F6B0005; Tue, 23 Apr 2019 12:13:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD4376B0007; Tue, 23 Apr 2019 12:13:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0E66B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:13:08 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id h69so462552itb.5
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:13:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=TsBpmWJ2BE859RBEAtZU1hf2lp7jmv5EzAmOLfO0OnE=;
        b=Y2LPoufaEEPYOAZIYNlJuT/+wTT9nuM3ZT7GBt/sTqUQ67TFrQi9QgvPaD7TeiNQIF
         VsKTaEqkJ9YLBni66W3CSBMtOaHhyZFyYCiAjGE0eeg9EZ1fFv6AjzaizlLLiRYL4Bhw
         2V9iZaRRP+p+g/XMlumd4A/FqbAjPg27jJkJ4+21h/sIQtme6SRY5i5oDbwLq1S3VgV0
         3LAU4LRqav7YvjERBjVuO+O37M7ESvT817cbqlbNUif+8T1Q+XgsO5CmZcYAz06YNLfN
         9NN9rcUkUSj4U2lIXx6hiTIb5DeFcUVU/N24zBxO6Ezott8eJZV7nK8I5Cy80W+VxOtG
         mB3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3kjm_xakbao0hnozpaatgpeexs.vddvatjhtgrdcitci.rdb@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3kjm_XAkbAO0hnoZPaaTgPeeXS.VddVaTjhTgRdciTci.Rdb@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAVw+LMnNpCaFjB84T1SQEwjEb1oAXdqx3VW5BWzYh7GY7TblKr3
	YKLXsf4eugy8YksCVsbcsbJ96gHn4Eq1Yi71Dici/zhGaMXsFSj3h4OBZ89Bczs0s4by9DpfI85
	tcZ0/ts6luFMgpPaTBtI2fPdkqrXQR5Ba2/dfnGc7BeCWLQTi+pKk3R12PTnY+NA=
X-Received: by 2002:a02:b819:: with SMTP id o25mr18663451jam.69.1556035988260;
        Tue, 23 Apr 2019 09:13:08 -0700 (PDT)
X-Received: by 2002:a02:b819:: with SMTP id o25mr18663336jam.69.1556035986806;
        Tue, 23 Apr 2019 09:13:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556035986; cv=none;
        d=google.com; s=arc-20160816;
        b=S/UGxAvpnn7clMSIIA+SM0x4jm5wIG3bXyMqGW73lI6YeM1rMxCIFMTBCOy1/kNMI+
         IR1lVGHRObnC4AvaKn8iLnGhB9+nFr2FplrF+Y8MD4lFN8TuH0+rdNAUhEIGlpEKc7wl
         8yhB7VSZ1fduSTIRp1v9x+gnkNuP55xihso+RPXKc3WR13pxKPwPRo+ZAFOXZfY8unWv
         4Ly8jSRJyRYPWni+Qu0eiY+edrrghXPGvbpoeXzGwLD0ntKTknQe44c27xskB7Bz7g26
         HnL2dzL6OkPyq5AfRrxqrTQSdxX4Hry7YbAzJR1UN9CtKcJX5v6YREw4iNwqS0t4tMbG
         OBRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=TsBpmWJ2BE859RBEAtZU1hf2lp7jmv5EzAmOLfO0OnE=;
        b=tD0HMJ4fHXpl3zwpDZmODWNVecYYdGWembUo+AgO4u5Q/dnN0tihDmUWKCenWJj3e+
         goLzcltTUl/uPdHOwUiC6/XhvybabPgAzupZaj/uLbKF1Uujy4LD1Y00zvvlPbLad9a/
         H2HVbU5VfvhSCgQSjxTkSccQM+gSpTA2CF83pyF5tI6dqo1lJluREKOwoFzsq3T+YMEg
         eytV242xxMZCHn6PfsNsidQDW74+kG0PwKqu/vXk0x6WD+uegcD94EKgvmT96B/ppH5p
         yDGGCRrkNJ9MpjQhyLB8Y+PhRQpM4FqtANrjNUa4UKlwycclGb7GfUhMxcRSw7cA4Qz/
         Zb6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3kjm_xakbao0hnozpaatgpeexs.vddvatjhtgrdcitci.rdb@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3kjm_XAkbAO0hnoZPaaTgPeeXS.VddVaTjhTgRdciTci.Rdb@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id v199sor23198776ita.14.2019.04.23.09.13.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 09:13:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3kjm_xakbao0hnozpaatgpeexs.vddvatjhtgrdcitci.rdb@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3kjm_xakbao0hnozpaatgpeexs.vddvatjhtgrdcitci.rdb@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3kjm_XAkbAO0hnoZPaaTgPeeXS.VddVaTjhTgRdciTci.Rdb@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqzIw+qJYoBa2d5BBqGlKr84pDJX0ldn6kQyGtIn9iH5nKs5vaN6KyrIn+bBYM1v7YiT4NgV/R+ECA7Wbzz4kIEei2JKLqUe
MIME-Version: 1.0
X-Received: by 2002:a24:36d4:: with SMTP id l203mr2742100itl.143.1556035986559;
 Tue, 23 Apr 2019 09:13:06 -0700 (PDT)
Date: Tue, 23 Apr 2019 09:13:06 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000003c9bea058734dc28@google.com>
Subject: WARNING: locking bug in split_huge_page_to_list
From: syzbot <syzbot+35a50f1f6dfd5a0d7378@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, aneesh.kumar@linux.ibm.com, 
	dave.jiang@intel.com, hughd@google.com, jglisse@redhat.com, 
	jrdr.linux@gmail.com, kirill.shutemov@linux.intel.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, 
	rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, 
	willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    e53f31bf Merge tag '5.1-rc5-smb3-fixes' of git://git.samba..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=14ecb7e3200000
kernel config:  https://syzkaller.appspot.com/x/.config?x=856fc6d0fbbeede9
dashboard link: https://syzkaller.appspot.com/bug?extid=35a50f1f6dfd5a0d7378
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+35a50f1f6dfd5a0d7378@syzkaller.appspotmail.com

------------[ cut here ]------------
DEBUG_LOCKS_WARN_ON(class_idx > MAX_LOCKDEP_KEYS)
WARNING: CPU: 0 PID: 1553 at kernel/locking/lockdep.c:3673  
__lock_acquire+0x1887/0x3fb0 kernel/locking/lockdep.c:3673
Kernel panic - not syncing: panic_on_warn set ...
CPU: 0 PID: 1553 Comm: kswapd0 Not tainted 5.1.0-rc5+ #74
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  panic+0x2cb/0x65c kernel/panic.c:214
  __warn.cold+0x20/0x45 kernel/panic.c:571
  report_bug+0x263/0x2b0 lib/bug.c:186
  fixup_bug arch/x86/kernel/traps.c:179 [inline]
  fixup_bug arch/x86/kernel/traps.c:174 [inline]
  do_error_trap+0x11b/0x200 arch/x86/kernel/traps.c:272
  do_invalid_op+0x37/0x50 arch/x86/kernel/traps.c:291
  invalid_op+0x14/0x20 arch/x86/entry/entry_64.S:973
RIP: 0010:__lock_acquire+0x1887/0x3fb0 kernel/locking/lockdep.c:3673
Code: d2 0f 85 7b 1f 00 00 44 8b 3d 29 0d 07 08 45 85 ff 0f 85 20 f3 ff ff  
48 c7 c6 80 3f 6b 87 48 c7 c7 c0 15 6b 87 e8 67 e3 eb ff <0f> 0b e9 09 f3  
ff ff 0f 0b e9 41 f1 ff ff 8b 1d c5 32 05 09 85 db
RSP: 0018:ffff8880a621f448 EFLAGS: 00010086
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000000 RSI: ffffffff815afcb6 RDI: ffffed1014c43e7b
RBP: ffff8880a621f580 R08: ffff8880a625e440 R09: fffffbfff11335fd
R10: fffffbfff11335fc R11: ffffffff8899afe3 R12: 00000000692b29d5
R13: 0000000000000009 R14: 00000000000409d5 R15: 0000000000000000
  lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:4211
  down_write+0x38/0x90 kernel/locking/rwsem.c:70
  anon_vma_lock_write include/linux/rmap.h:120 [inline]
  split_huge_page_to_list+0x5d7/0x2de0 mm/huge_memory.c:2682
  split_huge_page include/linux/huge_mm.h:148 [inline]
  deferred_split_scan+0x64b/0xa60 mm/huge_memory.c:2853
  do_shrink_slab+0x400/0xa80 mm/vmscan.c:551
  shrink_slab mm/vmscan.c:700 [inline]
  shrink_slab+0x4be/0x5e0 mm/vmscan.c:680
  shrink_node+0x552/0x1570 mm/vmscan.c:2724
  kswapd_shrink_node mm/vmscan.c:3482 [inline]
  balance_pgdat+0x56c/0xe80 mm/vmscan.c:3640
  kswapd+0x5f4/0xfd0 mm/vmscan.c:3895
  kthread+0x357/0x430 kernel/kthread.c:253
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
Kernel Offset: disabled
Rebooting in 86400 seconds..


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

