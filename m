Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.4 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FCC0C00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:08:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25AEA20693
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 17:08:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25AEA20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 870866B0005; Fri,  6 Sep 2019 13:08:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 820F46B0006; Fri,  6 Sep 2019 13:08:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70F4E6B0007; Fri,  6 Sep 2019 13:08:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 507806B0005
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 13:08:12 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id F2DFD181AC9AE
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:08:11 +0000 (UTC)
X-FDA: 75905128782.22.flesh51_64a21e8535a3f
X-HE-Tag: flesh51_64a21e8535a3f
X-Filterd-Recvd-Size: 6870
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 17:08:11 +0000 (UTC)
Received: by mail-io1-f70.google.com with SMTP id z12so7599132iop.17
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 10:08:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:date:message-id:subject:from:to;
        bh=q8OkoEi+GgJ9/q6d/Q9AdtdIt7JwUh/xgslJcUrjLWU=;
        b=lYBZCeGA1IcHZShSrVLKPf0zxG6AIkNWePsH4ACqHiDencIhuMN1vyc5Fmj9yIkG9N
         vL1LfGvVzTUrj7DgJzOCAWNfYY0U7F3PUTLMJzux0Y5JnTphMeuKRwsO6j2/3tRF+F8H
         yg3N/b9nyc27b6KXmuNOhqSclUw9m6IeFKWxoC6H/BxszDiH521ju2/Fb+u7GbBDHDsr
         VVKrmepUSJmF/B05Oce5XLSXfO5igV0bXEOB0S4y7dgRwSOu3knh0f8ELjd3m80S+XZI
         ykTAQBWwsWCAvtXUvjyhnteDAWVlmZ6mp2z0kPTGh56jBr2yR2QbiQxzzwuMHtehvM+6
         6MOA==
X-Gm-Message-State: APjAAAWMpzWkZFuG3rhQJPDXcy9edEX0IvXzD4BGxEO0+bvBWCVUDqT5
	7bo2H3QXCLKNtUzHj4uLbp1IJ2N1d/sH88sm41on26SrNY40
X-Google-Smtp-Source: APXvYqxq9lFbaa7rIg62dtip3JkaDW3dot2lG41o2i7UeccV9NumUayL9rzEyecN8Uafq7zcSeGbik42IxMAYgTf+f5QLedVTxzb
MIME-Version: 1.0
X-Received: by 2002:a02:920b:: with SMTP id x11mr11516568jag.17.1567789690508;
 Fri, 06 Sep 2019 10:08:10 -0700 (PDT)
Date: Fri, 06 Sep 2019 10:08:10 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <0000000000009611470591e57be6@google.com>
Subject: possible deadlock in __mmu_notifier_invalidate_range_end
From: syzbot <syzbot+aaedc50d99a03250fe1f@syzkaller.appspotmail.com>
To: airlied@linux.ie, akpm@linux-foundation.org, bhelgaas@google.com, 
	bskeggs@redhat.com, dan.j.williams@intel.com, daniel.vetter@ffwll.ch, 
	daniel@ffwll.ch, dri-devel@lists.freedesktop.org, jean-philippe@linaro.org, 
	jgg@ziepe.ca, jglisse@redhat.com, linux-kernel@vger.kernel.org, 
	linux-mm@kvack.org, logang@deltatee.com, mhocko@suse.com, 
	nouveau@lists.freedesktop.org, rcampbell@nvidia.com, sfr@canb.auug.org.au, 
	syzkaller-bugs@googlegroups.com, tglx@linutronix.de
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

syzbot found the following crash on:

HEAD commit:    6d028043 Add linux-next specific files for 20190830
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=16cbf22a600000
kernel config:  https://syzkaller.appspot.com/x/.config?x=82a6bec43ab0cb69
dashboard link: https://syzkaller.appspot.com/bug?extid=aaedc50d99a03250fe1f
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=15269876600000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=12685092600000

The bug was bisected to:

commit e58b341134ca751d9c12bacded12a8b4dd51368d
Author: Stephen Rothwell <sfr@canb.auug.org.au>
Date:   Fri Aug 30 09:42:14 2019 +0000

     Merge remote-tracking branch 'hmm/hmm'

bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=11ea65ea600000
final crash:    https://syzkaller.appspot.com/x/report.txt?x=13ea65ea600000
console output: https://syzkaller.appspot.com/x/log.txt?x=15ea65ea600000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+aaedc50d99a03250fe1f@syzkaller.appspotmail.com
Fixes: e58b341134ca ("Merge remote-tracking branch 'hmm/hmm'")

============================================
WARNING: possible recursive locking detected
5.3.0-rc6-next-20190830 #75 Not tainted
--------------------------------------------
oom_reaper/1065 is trying to acquire lock:
ffffffff8904ff60 (mmu_notifier_invalidate_range_start){+.+.}, at:  
__mmu_notifier_invalidate_range_end+0x0/0x360 mm/mmu_notifier.c:169

but task is already holding lock:
ffffffff8904ff60 (mmu_notifier_invalidate_range_start){+.+.}, at:  
__oom_reap_task_mm+0x196/0x490 mm/oom_kill.c:542

other info that might help us debug this:
  Possible unsafe locking scenario:

        CPU0
        ----
   lock(mmu_notifier_invalidate_range_start);
   lock(mmu_notifier_invalidate_range_start);

  *** DEADLOCK ***

  May be due to missing lock nesting notation

2 locks held by oom_reaper/1065:
  #0: ffff888094ad3990 (&mm->mmap_sem#2){++++}, at: oom_reap_task_mm  
mm/oom_kill.c:570 [inline]
  #0: ffff888094ad3990 (&mm->mmap_sem#2){++++}, at: oom_reap_task  
mm/oom_kill.c:613 [inline]
  #0: ffff888094ad3990 (&mm->mmap_sem#2){++++}, at: oom_reaper+0x3a7/0x1320  
mm/oom_kill.c:651
  #1: ffffffff8904ff60 (mmu_notifier_invalidate_range_start){+.+.}, at:  
__oom_reap_task_mm+0x196/0x490 mm/oom_kill.c:542

stack backtrace:
CPU: 1 PID: 1065 Comm: oom_reaper Not tainted 5.3.0-rc6-next-20190830 #75
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  print_deadlock_bug kernel/locking/lockdep.c:2371 [inline]
  check_deadlock kernel/locking/lockdep.c:2412 [inline]
  validate_chain kernel/locking/lockdep.c:2955 [inline]
  __lock_acquire.cold+0x15d/0x385 kernel/locking/lockdep.c:3955
  lock_acquire+0x190/0x410 kernel/locking/lockdep.c:4487
  __mmu_notifier_invalidate_range_end+0x3c/0x360 mm/mmu_notifier.c:193
  mmu_notifier_invalidate_range_end include/linux/mmu_notifier.h:375 [inline]
  __oom_reap_task_mm+0x3fa/0x490 mm/oom_kill.c:552
  oom_reap_task_mm mm/oom_kill.c:589 [inline]
  oom_reap_task mm/oom_kill.c:613 [inline]
  oom_reaper+0x2b2/0x1320 mm/oom_kill.c:651
  kthread+0x361/0x430 kernel/kthread.c:255
  ret_from_fork+0x24/0x30 arch/x86/entry/entry_64.S:352
oom_reaper: reaped process 10145 (syz-executor282), now anon-rss:16480kB,  
file-rss:872kB, shmem-rss:0kB
oom_reaper: reaped process 10144 (syz-executor282), now anon-rss:0kB,  
file-rss:0kB, shmem-rss:0kB
oom_reaper: reaped process 10158 (syz-executor282), now anon-rss:16824kB,  
file-rss:872kB, shmem-rss:0kB
oom_reaper: reaped process 10187 (syz-executor282), now anon-rss:0kB,  
file-rss:0kB, shmem-rss:0kB
oom_reaper: reaped process 10173 (syz-executor282), now anon-rss:0kB,  
file-rss:0kB, shmem-rss:0kB
oom_reaper: reaped process 10139 (syz-executor282), now anon-rss:0kB,  
file-rss:0kB, shmem-rss:0kB


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
For information about bisection process see: https://goo.gl/tpsmEJ#bisection
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

