Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA285C43444
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 17:03:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A17DB214C6
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 17:03:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A17DB214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B71B8E0002; Thu, 10 Jan 2019 12:03:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 367438E0001; Thu, 10 Jan 2019 12:03:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 256148E0002; Thu, 10 Jan 2019 12:03:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2E418E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 12:03:06 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id w15so11636708ita.1
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:03:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=q3/b7ctL3EfmnlaMuYGMLe973HhALm+0afuZshfPZ3o=;
        b=faVWJyIIL/P+8HmFFHQ9qYUr+lTHhpH8wzEgdNR4PoFS8Kl/SkA3CBaJ+FAI4ssZft
         qtlQG5jiG/wDE/FrcopWtZkHiyPve+NY49/zE2jtsRiJIYATUpNb03J5D2m2Ljqg7rWt
         1etgFIdWiD0O/U6c+csqN7X34Hp8IXcAYfhCbOeFaazTHKfihTGdCq5woe4xsTdOJAzW
         6Uc1T6LVUJdIWoG8AP4IfnLv4ng+6JKbHeP7rczDFqtuFoeGTAusqT0+Z9MBT0sNcjGy
         kx2ZdhxEy4NdIsc07Q9uysiOE/Qe3V7XaRvNo9S5vHWMw5yVQnfy4fIFAi7MVXF4NQtV
         f/BA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3yho3xakbaimz56rhsslyhwwpk.nvvnsl1zlyjvu0lu0.jvt@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3yHo3XAkbAIMz56rhsslyhwwpk.nvvnsl1zlyjvu0lu0.jvt@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukfI1YMlysslLGvF3ZPI9n/fZwpr63HhoDqwrQ4h3qo8Bv3i5SZC
	Waun1c8gQsUfeesAkdcOnlhpq9+PjMbRNN5Kg7Gfm9beqOl4pTgAez6J92+Eu+HjsU0TGbIjVbN
	p+NAGVc6ZzNxRT42VVvdzRwdE2iYu1fOYTKqhfYaWiP24aiKiW6E1eaFwaYkR1qfDozDaeV4Pk1
	qOIsSl6uQy8mHJUDF+6hYEK4Lx48YOk/JA+LMuberkVWtiM4ceya8stSnQ+KNEFnsQF3ETSuQ48
	xZqSbKgflv2KjHtw1k2iUUIADtdbSupsisTv5Rh0w4bnR/K7JoVtdcxHTvBcsuqMmVZi+hNPvPS
	QAPKHWgIu5dh1pGR96rY/nYDKzQwF9zpRL7S2PpznYIAZ4auILOpQhm3w43Q8iuqyYESH6DTgw=
	=
X-Received: by 2002:a5e:c914:: with SMTP id z20mr6988047iol.72.1547139786652;
        Thu, 10 Jan 2019 09:03:06 -0800 (PST)
X-Received: by 2002:a5e:c914:: with SMTP id z20mr6988001iol.72.1547139785677;
        Thu, 10 Jan 2019 09:03:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547139785; cv=none;
        d=google.com; s=arc-20160816;
        b=yrpOk9VvnxSRKg/9y/6+iqMkx23P3nlDb8hKbKsZFhwcIZsuSocTIkYzHRC1hpIOtf
         eTM+YT7BhZ0klbFOLSZYZCkYoqvl3O0MTcFRmyRPvlmjHNnCfxryLXLIKO1lClbRXFEg
         zRbbvOXZs965tPVw97olkujLQEk7T1qGNRaA2snIby4as47Cn8jGAa9Ts3ANDKB8zlWI
         sSGwiqqaT+pLpmt7Zh+HlB+zwBCVrZnU+fQHdcPIUecBk9PNCFw74mx51in/UJQZ9FYK
         DDFfGLO/mQ8Yqlj34/f7vDUn9EN7FUdgaHel0jq0BUMVhYmvuyRQ5W6eSKETwdY8y4/6
         tltw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=q3/b7ctL3EfmnlaMuYGMLe973HhALm+0afuZshfPZ3o=;
        b=JlKNAEEaQWa6HTpbKTYLIZBL8yJv6DreqP5ZKhDOkUHgpuHX4TjCmmWfmpEKXSxyoA
         oCkBfUFZVv61BwljVVhP5/cCi6HNns9tgNw6mDPui8IePDmdq9q9o2YM+oETQOBQhcVl
         PdQ83HNC+LSjqXu/xfacGX4aSTtFnc5xDjTNfJTc22eiRJdXYLjILv7sSx5jpQ7sNBxi
         C1MIxFpk6Oux1Dcd9EXOeT6wftMrbwGDPDq3dnAHSYGshm502w8/rxybp9IM06ee3xFX
         NARW1ffKHVUBsPbB+zQEq1uk9Y+HeBEHRZl/7Nyk+Rdtb6dbsOKoHMEC74nDsJ5aFFyz
         1SQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3yho3xakbaimz56rhsslyhwwpk.nvvnsl1zlyjvu0lu0.jvt@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3yHo3XAkbAIMz56rhsslyhwwpk.nvvnsl1zlyjvu0lu0.jvt@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id 68sor29915072itu.24.2019.01.10.09.03.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 09:03:05 -0800 (PST)
Received-SPF: pass (google.com: domain of 3yho3xakbaimz56rhsslyhwwpk.nvvnsl1zlyjvu0lu0.jvt@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3yho3xakbaimz56rhsslyhwwpk.nvvnsl1zlyjvu0lu0.jvt@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3yHo3XAkbAIMz56rhsslyhwwpk.nvvnsl1zlyjvu0lu0.jvt@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: ALg8bN5S1Gqk1xvS8TeAi0E79BDxF/BPl2kRDAyq52cNGYKNbpWaSnHMDRipQXXzLCAPHF5nKDS+mTWX6JiYBqwWHmVGcudKDGdD
MIME-Version: 1.0
X-Received: by 2002:a24:4ac3:: with SMTP id k186mr4745912itb.37.1547139784707;
 Thu, 10 Jan 2019 09:03:04 -0800 (PST)
Date: Thu, 10 Jan 2019 09:03:04 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000491844057f1d8d2f@google.com>
Subject: KASAN: null-ptr-deref Read in reclaim_high
From: syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>
To: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, mhocko@kernel.org, syzkaller-bugs@googlegroups.com, 
	vdavydov.dev@gmail.com
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110170304.TOjATNd9BU4NqM_Afca6hNkEz8D5BCWGLwJ4xXPXpgE@z>

Hello,

syzbot found the following crash on:

HEAD commit:    6cab33afc3dd Add linux-next specific files for 20190110
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=178b287b400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: null-ptr-deref in atomic64_read  
include/generated/atomic-instrumented.h:836 [inline]
BUG: KASAN: null-ptr-deref in atomic_long_read  
include/generated/atomic-long.h:28 [inline]
BUG: KASAN: null-ptr-deref in page_counter_read  
include/linux/page_counter.h:47 [inline]
BUG: KASAN: null-ptr-deref in reclaim_high.constprop.0+0xa6/0x1e0  
mm/memcontrol.c:2149
Read of size 8 at addr 0000000000000138 by task syz-executor037/7964

CPU: 1 PID: 7964 Comm: syz-executor037 Not tainted 5.0.0-rc1-next-20190110  
#9
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1db/0x2d0 lib/dump_stack.c:113
  kasan_report.cold+0x5/0x40 mm/kasan/report.c:321
  check_memory_region_inline mm/kasan/generic.c:185 [inline]
  check_memory_region+0x123/0x190 mm/kasan/generic.c:191
  kasan_check_read+0x11/0x20 mm/kasan/common.c:100
  atomic64_read include/generated/atomic-instrumented.h:836 [inline]
  atomic_long_read include/generated/atomic-long.h:28 [inline]
  page_counter_read include/linux/page_counter.h:47 [inline]
  reclaim_high.constprop.0+0xa6/0x1e0 mm/memcontrol.c:2149
  mem_cgroup_handle_over_high+0xc1/0x180 mm/memcontrol.c:2178
  tracehook_notify_resume include/linux/tracehook.h:190 [inline]
  exit_to_usermode_loop+0x299/0x3b0 arch/x86/entry/common.c:166
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath+0x519/0x5f0 arch/x86/entry/common.c:268
  ret_from_fork+0x15/0x50 arch/x86/entry/entry_64.S:344
RIP: 0033:0x44034a
Code: Bad RIP value.
RSP: 002b:00007ffc31cd3040 EFLAGS: 00000246 ORIG_RAX: 0000000000000038
RAX: 0000000000000000 RBX: 0000000000000000 RCX: 000000000044034a
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000001200011
RBP: 00007ffc31cd3060 R08: 0000000000000001 R09: 0000000002027880
R10: 0000000002027b50 R11: 0000000000000246 R12: 0000000000000001
R13: 000000000000cc59 R14: 0000000000000000 R15: 0000000000000000
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

