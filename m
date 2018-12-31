Return-Path: <SRS0=02Vf=PI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 817A9C43612
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 03:41:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39B4121019
	for <linux-mm@archiver.kernel.org>; Mon, 31 Dec 2018 03:41:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39B4121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C63B08E0076; Sun, 30 Dec 2018 22:41:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C13CF8E005B; Sun, 30 Dec 2018 22:41:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B03708E0076; Sun, 30 Dec 2018 22:41:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7D18E005B
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 22:41:06 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id y86so31043711ita.2
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 19:41:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=86AMUuzbwPhOMbCH6aZm3cGDKGCVuTQXSdj4gflnNT4=;
        b=uL+1fC+sXML2QbGxE++zrjsJWndkL3j2A11ACp9pvQ/eYYAu0s9ad596NYpDKuaJZ7
         XuNsfTYmd7NZObqqvOneRmlYYpZdkDmm1S4/0/HgFIUoI+KoX9XmUwPv/iW9t0PObYCy
         W2RpcExpgpdYURXk8zZbY711SBTIP40Ysig/8IorN2x+aaEKKSRRtaqhh4wIuljCiMZc
         0WyRW+bOl2rC5VToTwgrK7sZ09+oJv33YVS+ZYjIso80rbztJBccaFKg9Lc4ATD6qHOV
         DL2tZVkUDw0tM65f3LjWSUyej2MYZymRlfGh5LEOxu1wSe+3kM9450U6ZZrtNsGxiIuH
         BzBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 30i8pxakbah0tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=30I8pXAkbAH0tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: AJcUukfF8urMyiye1IiQMz0qYWkq/jE7Dy3xnL0ZIrSyWLb1ueZ78zlD
	+Cloq2q4bD/9XwkCUKx6QtBcPNlPm2eMdg8gInc/KkqcYrP3dD1BA/xVDq6tbPZp+9XlkJrpko/
	CVa4PrHP5BP+Zl2hAqSqY1JUdjogYWbFq+87h506tCLj2WE/61dg34hgCCC+wp0rGd752bQ7aLj
	YASEZUKKRSwlVhtuPKwdViyl9xIqNok23aX4k2QP2CMKPVYwyZwg0ALDqbQtLMwyUbGfhRwMVFF
	tbCVT8IrUTP0pwFYfIqbkVUE7JBOaIrCXJeIsN3R9xvq2kNTLmVvF0t3TxOlidWWNkbZtQIg6cp
	iW9DdompUtZJuSXk89xGNDyvL3Jy/EL27atzVSwHsrFEHWk+E8HHuHR89PwIK+5xaXntDDJgOA=
	=
X-Received: by 2002:a24:2543:: with SMTP id g64mr23277026itg.163.1546227666253;
        Sun, 30 Dec 2018 19:41:06 -0800 (PST)
X-Received: by 2002:a24:2543:: with SMTP id g64mr23277013itg.163.1546227665197;
        Sun, 30 Dec 2018 19:41:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546227664; cv=none;
        d=google.com; s=arc-20160816;
        b=DDS2EWd3viOqYZLTYr87XFrfBOteJQmcKyvquDRrHUfmPGPI8aKPDteJZNu1yK/xEw
         Htjk2igHOFzW6D+YsYIS3/YtwHVO47savJp41O/jbV1HkCrhvvUBv/r9BHAwbCJjZMK6
         K08j+Upmpsxe9H1yY2C6PT5g91dU0BWsUZpCv1iBTVsmKvbS+wOKYY+FgyXLTRgxX2+L
         Qvz+92FUvdBG5syGJGiivGK68m+0+WDBO3+uMqD32Olx7qk+SIDQfCxGK6p6OY9KQQ8/
         uOeH3/hRi3xU4QcvQHT8igaO8xVpkVg1KMAVncSk6uzizuUAWzt63pP89jzavkKgXyLj
         RDyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=86AMUuzbwPhOMbCH6aZm3cGDKGCVuTQXSdj4gflnNT4=;
        b=LEALYY3yRcuIsVnCyvEPGDKZrb5UJCjFdJEmbnz41nTRLt/FFBWnSxkvZsjlcW/sW6
         xDYRXYcYvE0mJbDiprMygU+14nmmaraVtrxLr3k3l3H99P5Nqxa4cxcVLvLVzoqGtrOQ
         eJv0Ppt209jVhBnHWvAvCEYzwjoktEM/G03Zlqpvh/h/phqc1atlURfxkpfvDWsBW7j6
         tOyhTYzoDH1CayBsr60aocJ6Dl0BX3PSZG3xd+WIqZUTnDGQrxqePdyXbzwOIQk7swwT
         cA4bMtRob7dPvePDHdAAzDAe6BGnmBHM5X2Fzq2tcdm0qkIaw8KEMyBIQ5I05FWVmcbm
         RZew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 30i8pxakbah0tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=30I8pXAkbAH0tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id c30sor71192869jak.4.2018.12.30.19.41.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 19:41:04 -0800 (PST)
Received-SPF: pass (google.com: domain of 30i8pxakbah0tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 30i8pxakbah0tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=30I8pXAkbAH0tz0lbmmfsbqqje.hpphmfvtfsdpoufou.dpn@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: AFSGD/UbTPDnfO7+7L6o/YPxEyPmWVhqw44svwzwe+4dZvoIXbGjaLf04sI83shk23K+MRPxba5b8ITkrOcZKkydFM5lego3et7d
MIME-Version: 1.0
X-Received: by 2002:a02:8ca9:: with SMTP id f38mr28307294jak.14.1546227664572;
 Sun, 30 Dec 2018 19:41:04 -0800 (PST)
Date: Sun, 30 Dec 2018 19:41:04 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000b05d0c057e492e33@google.com>
Subject: kernel panic: corrupted stack end in wb_workfn
From: syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com, guro@fb.com, 
	hannes@cmpxchg.org, jbacik@fb.com, ktkhai@virtuozzo.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, 
	mhocko@suse.com, shakeelb@google.com, syzkaller-bugs@googlegroups.com, 
	willy@infradead.org
Content-Type: text/plain; charset="UTF-8"; delsp="yes"; format="flowed"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181231034104.n_62xn_LiyQo1ejv_ED_AOiz1CBo1ZMqiWvfEBzLvWU@z>

Hello,

syzbot found the following crash on:

HEAD commit:    195303136f19 Merge tag 'kconfig-v4.21-2' of git://git.kern..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=176c0ebf400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=5e7dc790609552d7
dashboard link: https://syzkaller.appspot.com/bug?extid=ec1b7575afef85a0e5ca
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16a9a84b400000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17199bb3400000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com

Kernel panic - not syncing: corrupted stack end detected inside scheduler
CPU: 0 PID: 7 Comm: kworker/u4:0 Not tainted 4.20.0+ #396
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Workqueue: writeback wb_workfn (flush-8:0)
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1d3/0x2c6 lib/dump_stack.c:113
  panic+0x2ad/0x55f kernel/panic.c:189
  schedule_debug kernel/sched/core.c:3285 [inline]
  __schedule+0x1ec6/0x1ed0 kernel/sched/core.c:3394
  preempt_schedule_common+0x1f/0xe0 kernel/sched/core.c:3596
  preempt_schedule+0x4d/0x60 kernel/sched/core.c:3622
  ___preempt_schedule+0x16/0x18
  __raw_spin_unlock_irqrestore include/linux/spinlock_api_smp.h:161 [inline]
  _raw_spin_unlock_irqrestore+0xbb/0xd0 kernel/locking/spinlock.c:184
  spin_unlock_irqrestore include/linux/spinlock.h:384 [inline]
  __remove_mapping+0x932/0x1af0 mm/vmscan.c:967
  shrink_page_list+0x6610/0xc2e0 mm/vmscan.c:1461
  shrink_inactive_list+0x77b/0x1c60 mm/vmscan.c:1961
  shrink_list mm/vmscan.c:2273 [inline]
  shrink_node_memcg+0x7a8/0x19a0 mm/vmscan.c:2538
  shrink_node+0x3e1/0x17f0 mm/vmscan.c:2753
  shrink_zones mm/vmscan.c:2987 [inline]
  do_try_to_free_pages+0x3df/0x12a0 mm/vmscan.c:3049
  try_to_free_pages+0x4d0/0xb90 mm/vmscan.c:3265
  __perform_reclaim mm/page_alloc.c:3920 [inline]
  __alloc_pages_direct_reclaim mm/page_alloc.c:3942 [inline]
  __alloc_pages_slowpath+0xa5a/0x2db0 mm/page_alloc.c:4335
  __alloc_pages_nodemask+0xa89/0xde0 mm/page_alloc.c:4549
  alloc_pages_current+0x10c/0x210 mm/mempolicy.c:2106
  alloc_pages include/linux/gfp.h:509 [inline]
  __page_cache_alloc+0x38c/0x5b0 mm/filemap.c:924
  pagecache_get_page+0x396/0xf00 mm/filemap.c:1615
  find_or_create_page include/linux/pagemap.h:322 [inline]
  ext4_mb_load_buddy_gfp+0xddf/0x1e70 fs/ext4/mballoc.c:1158
  ext4_mb_load_buddy fs/ext4/mballoc.c:1241 [inline]
  ext4_mb_regular_allocator+0x634/0x1590 fs/ext4/mballoc.c:2190
  ext4_mb_new_blocks+0x1de3/0x4840 fs/ext4/mballoc.c:4538
  ext4_ext_map_blocks+0x2eef/0x6180 fs/ext4/extents.c:4404
  ext4_map_blocks+0x8f7/0x1b60 fs/ext4/inode.c:636
  mpage_map_one_extent fs/ext4/inode.c:2480 [inline]
  mpage_map_and_submit_extent fs/ext4/inode.c:2533 [inline]
  ext4_writepages+0x2564/0x4170 fs/ext4/inode.c:2884
  do_writepages+0x9a/0x1a0 mm/page-writeback.c:2335
  __writeback_single_inode+0x20a/0x1660 fs/fs-writeback.c:1316
  writeback_sb_inodes+0x71f/0x1210 fs/fs-writeback.c:1580
  __writeback_inodes_wb+0x1b9/0x340 fs/fs-writeback.c:1649
  wb_writeback+0xa73/0xfc0 fs/fs-writeback.c:1758
oom_reaper: reaped process 7963 (syz-executor189), now anon-rss:0kB,  
file-rss:0kB, shmem-rss:0kB
rsyslogd invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE),  
order=0, oom_score_adj=0
  wb_check_start_all fs/fs-writeback.c:1882 [inline]
  wb_do_writeback fs/fs-writeback.c:1908 [inline]
  wb_workfn+0xee9/0x1790 fs/fs-writeback.c:1942
  process_one_work+0xc90/0x1c40 kernel/workqueue.c:2153
  worker_thread+0x17f/0x1390 kernel/workqueue.c:2296
  kthread+0x35a/0x440 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
CPU: 1 PID: 7840 Comm: rsyslogd Not tainted 4.20.0+ #396
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x1d3/0x2c6 lib/dump_stack.c:113
  dump_header+0x253/0x1239 mm/oom_kill.c:451
  oom_kill_process.cold.27+0x10/0x903 mm/oom_kill.c:966
  out_of_memory+0x8ba/0x1480 mm/oom_kill.c:1133
  __alloc_pages_may_oom mm/page_alloc.c:3666 [inline]
  __alloc_pages_slowpath+0x230c/0x2db0 mm/page_alloc.c:4379
  __alloc_pages_nodemask+0xa89/0xde0 mm/page_alloc.c:4549
  alloc_pages_current+0x10c/0x210 mm/mempolicy.c:2106
  alloc_pages include/linux/gfp.h:509 [inline]
  __page_cache_alloc+0x38c/0x5b0 mm/filemap.c:924
  page_cache_read mm/filemap.c:2373 [inline]
  filemap_fault+0x1595/0x25f0 mm/filemap.c:2557
  ext4_filemap_fault+0x82/0xad fs/ext4/inode.c:6317
  __do_fault+0x100/0x6b0 mm/memory.c:2997
  do_read_fault mm/memory.c:3409 [inline]
  do_fault mm/memory.c:3535 [inline]
  handle_pte_fault mm/memory.c:3766 [inline]
  __handle_mm_fault+0x392f/0x5630 mm/memory.c:3890
  handle_mm_fault+0x54f/0xc70 mm/memory.c:3927
  do_user_addr_fault arch/x86/mm/fault.c:1475 [inline]
  __do_page_fault+0x5f6/0xd70 arch/x86/mm/fault.c:1541
  do_page_fault+0xf2/0x7e0 arch/x86/mm/fault.c:1572
  page_fault+0x1e/0x30 arch/x86/entry/entry_64.S:1143
RIP: 0033:0x7f00f990e1fd
Code: Bad RIP value.
RSP: 002b:00007f00f6eade30 EFLAGS: 00010293
RAX: 0000000000000fd2 RBX: 000000000111f170 RCX: 00007f00f990e1fd
RDX: 0000000000000fff RSI: 00007f00f86e25a0 RDI: 0000000000000004
RBP: 0000000000000000 R08: 000000000110a260 R09: 0000000000000000
R10: 74616c7567657227 R11: 0000000000000293 R12: 000000000065e420
R13: 00007f00f6eae9c0 R14: 00007f00f9f53040 R15: 0000000000000003
Kernel Offset: disabled
Rebooting in 86400 seconds..


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
syzbot can test patches for this bug, for details see:
https://goo.gl/tpsmEJ#testing-patches

