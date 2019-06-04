Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00399C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:19:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5CDA2070B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:19:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5CDA2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A7736B0271; Tue,  4 Jun 2019 17:19:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 257DC6B0273; Tue,  4 Jun 2019 17:19:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 146CC6B0274; Tue,  4 Jun 2019 17:19:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id E92FF6B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 17:19:06 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id h133so144019ith.9
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 14:19:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:in-reply-to:message-id:subject:from:to;
        bh=0iJ/CisaeAFt6kjSxf0PDnzBYqaLMd8GZ6ICt72+F8c=;
        b=ABeja2Jvn0ZpGA+O698MaQcvJssUoIVNZs75v/aPrymOOZq22Ywg1EG+Uj9zpxCfrV
         Ak5DVGvmWy6VknujRt+kdz8CKurwZgRsJWr/SjTmuhgVsQUFFWY86h7MSBROJSP6DzPm
         +fFKqMwpFGvRJR5RDyChNxyDTPA8pxLzcBEeW6xmumUqeXCrGeT8Ao5tPR2tN6Ya3hVb
         TinegIEgxIZO7ojidm+c86YV+lr9yZ/V2VhJB8u6PXn1pixyD+l57Ky9h3n9agNl02Za
         Sa5tOUG/nwVq9SmcgbRX+dW5el+7ffU+No4RcJMUxbZDu5pBZlsc9FY+fULw/iaF9ab1
         OsPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3sed2xakbanigmn8y992fydd61.4cc492ig2f0cbh2bh.0ca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3SeD2XAkbANIGMN8y992FyDD61.4CC492IG2F0CBH2BH.0CA@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAXpSvQ7uYLGQTclo080UPlVcBXODklMpMLpsiisT1HJD7GHr1I4
	LIkHUwt8D9awe03qXJ8XDrEZgBLFVaku/nTz/kZ5XpLxkDGFixEVmlZRYKzYDs+FglVWPzCTWmc
	FWgJkvZnKeNsdiJ4OlHyNmhwpaan4su1vf8Ve67g5JYJmVPX2IEDTy6tQ/hpswIY=
X-Received: by 2002:a6b:c9d8:: with SMTP id z207mr20092316iof.184.1559683146724;
        Tue, 04 Jun 2019 14:19:06 -0700 (PDT)
X-Received: by 2002:a6b:c9d8:: with SMTP id z207mr20092274iof.184.1559683145860;
        Tue, 04 Jun 2019 14:19:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559683145; cv=none;
        d=google.com; s=arc-20160816;
        b=dmNvaHRvhJRuzL5zyGWsbc6k3oEXhIAsgtNDIcnC82uVQjt9OSzuzFi428pKv5zZON
         ogxQzKmjSJKgVHeFvjGBJgVdfXJ/hC22U4jxDhMF+C0NYd/i0c6QcqynusrRGaa48dEJ
         wD2IxCs8cMR6R1L2LkRRSOQRqVYZO10EC1zL3zF4q+6PEr9dtB6ll1aegpg7mbWWNSwh
         /oNqMgk3CyGjOOyO/vuxPtw6DD0FSga9ibeJ6QWbJS0jMzz9D+Jwdnm7JdG/yPO6Ffa3
         lBB7+xOMcnf2OecS9otOX6aLcBDHMJ/5iakv1T/6jfuwX6a/1g2PHLOWHG6MdyLFfNyd
         9neg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:in-reply-to:date:mime-version;
        bh=0iJ/CisaeAFt6kjSxf0PDnzBYqaLMd8GZ6ICt72+F8c=;
        b=jNBxGoQ3Zk7xndx0SOhr31EetTIJkxtyBoUNn224rPdMmPDSP9lXlUBSbgPalSRaRU
         x5r7ZOrxCsxx4ojpfZ2/EEwI4Fsl5/SI9pgBS0Fm0OKgxK8O8CCi5wNOapE1yZ5fkRr9
         Lv0sOCvmKZOvvEYvZcVqgedPlbxWsI8W/G2UQbic6JaZZnpyKAK9IQiCV9mjTdwOpn/6
         070G+TSjxthW4qPRVxsrZKQsuxwyyw3Yv6+ssZAOpirAIXO7jsUcTemx/bwo28tvE745
         jMASGvEN9+rEhqVx1aWt4s/gyWHV9Aly++mu3PauyaP1e46A/PNj182OAEPjvoLvrCHp
         t/qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3sed2xakbanigmn8y992fydd61.4cc492ig2f0cbh2bh.0ca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3SeD2XAkbANIGMN8y992FyDD61.4CC492IG2F0CBH2BH.0CA@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id n1sor3308038iom.6.2019.06.04.14.19.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 14:19:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3sed2xakbanigmn8y992fydd61.4cc492ig2f0cbh2bh.0ca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3sed2xakbanigmn8y992fydd61.4cc492ig2f0cbh2bh.0ca@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3SeD2XAkbANIGMN8y992FyDD61.4CC492IG2F0CBH2BH.0CA@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqww+IWWlnUeKm2m4DZKJtmvDhFfbtTotLDezLfaqhvRpapQUBIBo5TiP0EjNwhcIykXfggRbGqXtXWEOZsR5RvhIHP9g4NH
MIME-Version: 1.0
X-Received: by 2002:a6b:6f0e:: with SMTP id k14mr22747234ioc.257.1559683145579;
 Tue, 04 Jun 2019 14:19:05 -0700 (PDT)
Date: Tue, 04 Jun 2019 14:19:05 -0700
In-Reply-To: <000000000000543e45058a3cf40b@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000dac5a0058a860712@google.com>
Subject: Re: possible deadlock in get_user_pages_unlocked (2)
From: syzbot <syzbot+e1374b2ec8f6a25ab2e5@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, aneesh.kumar@linux.ibm.com, 
	dan.j.williams@intel.com, ira.weiny@intel.com, jhubbard@nvidia.com, 
	keith.busch@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	rppt@linux.ibm.com, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

syzbot has found a reproducer for the following crash on:

HEAD commit:    56b697c6 Add linux-next specific files for 20190604
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=13241716a00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4248d6bc70076f7d
dashboard link: https://syzkaller.appspot.com/bug?extid=e1374b2ec8f6a25ab2e5
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=165757eea00000
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=10dd3e86a00000

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+e1374b2ec8f6a25ab2e5@syzkaller.appspotmail.com

IPVS: ftp: loaded support on port[0] = 21
======================================================
WARNING: possible circular locking dependency detected
5.2.0-rc3-next-20190604 #8 Not tainted
------------------------------------------------------
syz-executor842/8767 is trying to acquire lock:
00000000badb3a6d (&mm->mmap_sem#2){++++}, at:  
get_user_pages_unlocked+0xfc/0x4a0 mm/gup.c:1174

but task is already holding lock:
0000000052562d44 (&sb->s_type->i_mutex_key#10){+.+.}, at: inode_trylock  
include/linux/fs.h:798 [inline]
0000000052562d44 (&sb->s_type->i_mutex_key#10){+.+.}, at:  
ext4_file_write_iter+0x246/0x1070 fs/ext4/file.c:232

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&sb->s_type->i_mutex_key#10){+.+.}:
        down_write+0x38/0xa0 kernel/locking/rwsem.c:66
        inode_lock include/linux/fs.h:778 [inline]
        process_measurement+0x15ae/0x15e0  
security/integrity/ima/ima_main.c:228
        ima_file_mmap+0x11a/0x130 security/integrity/ima/ima_main.c:370
        security_file_mprotect+0xd5/0x100 security/security.c:1426
        do_mprotect_pkey+0x537/0xa30 mm/mprotect.c:550
        __do_sys_mprotect mm/mprotect.c:582 [inline]
        __se_sys_mprotect mm/mprotect.c:579 [inline]
        __x64_sys_mprotect+0x78/0xb0 mm/mprotect.c:579
        do_syscall_64+0xfd/0x680 arch/x86/entry/common.c:301
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

-> #0 (&mm->mmap_sem#2){++++}:
        lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:4300
        down_read+0x3f/0x1e0 kernel/locking/rwsem.c:24
        get_user_pages_unlocked+0xfc/0x4a0 mm/gup.c:1174
        __gup_longterm_unlocked mm/gup.c:2193 [inline]
        get_user_pages_fast+0x43f/0x530 mm/gup.c:2245
        iov_iter_get_pages+0x2c2/0xf80 lib/iov_iter.c:1287
        dio_refill_pages fs/direct-io.c:171 [inline]
        dio_get_page fs/direct-io.c:215 [inline]
        do_direct_IO fs/direct-io.c:983 [inline]
        do_blockdev_direct_IO+0x3f7b/0x8e00 fs/direct-io.c:1336
        __blockdev_direct_IO+0xa1/0xca fs/direct-io.c:1422
        ext4_direct_IO_write fs/ext4/inode.c:3782 [inline]
        ext4_direct_IO+0xaa7/0x1bb0 fs/ext4/inode.c:3909
        generic_file_direct_write+0x20a/0x4a0 mm/filemap.c:3110
        __generic_file_write_iter+0x2ee/0x630 mm/filemap.c:3293
        ext4_file_write_iter+0x332/0x1070 fs/ext4/file.c:266
        call_write_iter include/linux/fs.h:1870 [inline]
        new_sync_write+0x4d3/0x770 fs/read_write.c:483
        __vfs_write+0xe1/0x110 fs/read_write.c:496
        vfs_write+0x268/0x5d0 fs/read_write.c:558
        ksys_write+0x14f/0x290 fs/read_write.c:611
        __do_sys_write fs/read_write.c:623 [inline]
        __se_sys_write fs/read_write.c:620 [inline]
        __x64_sys_write+0x73/0xb0 fs/read_write.c:620
        do_syscall_64+0xfd/0x680 arch/x86/entry/common.c:301
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

other info that might help us debug this:

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&sb->s_type->i_mutex_key#10);
                                lock(&mm->mmap_sem#2);
                                lock(&sb->s_type->i_mutex_key#10);
   lock(&mm->mmap_sem#2);

  *** DEADLOCK ***

2 locks held by syz-executor842/8767:
  #0: 0000000065e8e19a (sb_writers#3){.+.+}, at: file_start_write  
include/linux/fs.h:2836 [inline]
  #0: 0000000065e8e19a (sb_writers#3){.+.+}, at: vfs_write+0x485/0x5d0  
fs/read_write.c:557
  #1: 0000000052562d44 (&sb->s_type->i_mutex_key#10){+.+.}, at:  
inode_trylock include/linux/fs.h:798 [inline]
  #1: 0000000052562d44 (&sb->s_type->i_mutex_key#10){+.+.}, at:  
ext4_file_write_iter+0x246/0x1070 fs/ext4/file.c:232

stack backtrace:
CPU: 0 PID: 8767 Comm: syz-executor842 Not tainted 5.2.0-rc3-next-20190604  
#8
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x172/0x1f0 lib/dump_stack.c:113
  print_circular_bug.cold+0x1cc/0x28f kernel/locking/lockdep.c:1566
  check_prev_add kernel/locking/lockdep.c:2311 [inline]
  check_prevs_add kernel/locking/lockdep.c:2419 [inline]
  validate_chain kernel/locking/lockdep.c:2801 [inline]
  __lock_acquire+0x3755/0x5490 kernel/locking/lockdep.c:3790
  lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:4300
  down_read+0x3f/0x1e0 kernel/locking/rwsem.c:24
  get_user_pages_unlocked+0xfc/0x4a0 mm/gup.c:1174
  __gup_longterm_unlocked mm/gup.c:2193 [inline]
  get_user_pages_fast+0x43f/0x530 mm/gup.c:2245
  iov_iter_get_pages+0x2c2/0xf80 lib/iov_iter.c:1287
  dio_refill_pages fs/direct-io.c:171 [inline]
  dio_get_page fs/direct-io.c:215 [inline]
  do_direct_IO fs/direct-io.c:983 [inline]
  do_blockdev_direct_IO+0x3f7b/0x8e00 fs/direct-io.c:1336
  ? 0xffffffff81000000
  __blockdev_direct_IO+0xa1/0xca fs/direct-io.c:1422
  ext4_direct_IO_write fs/ext4/inode.c:3782 [inline]
  ext4_direct_IO+0xaa7/0x1bb0 fs/ext4/inode.c:3909
  generic_file_direct_write+0x20a/0x4a0 mm/filemap.c:3110
  __generic_file_write_iter+0x2ee/0x630 mm/filemap.c:3293
  ext4_file_write_iter+0x332/0x1070 fs/ext4/file.c:266
  call_write_iter include/linux/fs.h:1870 [inline]
  new_sync_write+0x4d3/0x770 fs/read_write.c:483
  __vfs_write+0xe1/0x110 fs/read_write.c:496
  vfs_write+0x268/0x5d0 fs/read_write.c:558
  ksys_write+0x14f/0x290 fs/read_write.c:611
  __do_sys_write fs/read_write.c:623 [inline]
  __se_sys_write fs/read_write.c:620 [inline]
  __x64_sys_write+0x73/0xb0 fs/read_write.c:620
  do_syscall_64+0xfd/0x680 arch/x86/entry/common.c:301
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x440a49
Code: 18 89 d0 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 bb 10 fc ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007ffc18e28968 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00000000004a22e0 RCX: 0000000000440a49
RDX: 0000000020000012 RSI: 0000000020000000 RDI: 0000000000000005
RBP: 00000000004a2370 R08: 0000000000000012 R09: 0000000000000100
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000401f90
R13: 0000000000402020 R14: 0000000000000000 R15: 0000000000000000

