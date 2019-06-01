Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=FROM_LOCAL_HEX,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74E8DC28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 06:08:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E403270BE
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 06:08:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E403270BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ED9E6B0008; Sat,  1 Jun 2019 02:08:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5771E6B000A; Sat,  1 Jun 2019 02:08:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43D876B000C; Sat,  1 Jun 2019 02:08:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 249016B0008
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 02:08:09 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id m188so10153904ita.0
        for <linux-mm@kvack.org>; Fri, 31 May 2019 23:08:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :date:message-id:subject:from:to;
        bh=8UTTULkwtsMoOI/rW0r8zzkuES3tsjU/CYGnZsvOq0A=;
        b=kTiJ+8Ca7sqQZONytJl1wi3ubgQ3LvpBB2hagl+tbT9jGxDXP0Gjzdg/ju5CyCS5m/
         Nini7FZRTijhetRr2BRNUXaN48H+pDtFhKQ46yJDJdMKHHWy4pvgzM2jPIGoA5r1C9GC
         fCkLTTfBN1yv4U7dDEZdB8fqzd0VJFNIXUXaphuCGb98IQr4wp57HYdeNwRWMycKOtsW
         GY1hIS6O61nxj0XaV7nls3rMs7pUFT+aZYMsI1Ro6i5avsGT7AYaQ7elNZOG8KkdBFWz
         SVaz1dgM8MXo1akNn5dYYwMpDKIipLCigVBLWHutcFEyT9YCKUm0Y7qpgHfnrolfa1GA
         P5JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of 3rrbyxakbacgwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3RRbyXAkbACgWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Gm-Message-State: APjAAAVFYpa/LouFCtqBt7y2VQQVElz5DlYyfjnzRim7BxtgputWLzWB
	XxYMndJJrp+ADINIYEFwPrM82t5VpULtxlJ1RaPQNrvXt8F9WPeN7kzo9kxALvAFWHuc+o4W0PW
	wQUnzOxgi6D9kEIEef+A5VrRfffQsiQvqKk6Tk6vrHHPnV8IOY9jBuYK3lztScKU=
X-Received: by 2002:a05:6602:211a:: with SMTP id x26mr9255109iox.202.1559369288795;
        Fri, 31 May 2019 23:08:08 -0700 (PDT)
X-Received: by 2002:a05:6602:211a:: with SMTP id x26mr9255073iox.202.1559369287358;
        Fri, 31 May 2019 23:08:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559369287; cv=none;
        d=google.com; s=arc-20160816;
        b=wFHrMR8ZGB0qr2AYRZ0p8ZwYqmEZk2Z3oQf/NHMMCLrU1Y4it2pzWYlIR1XWNNuRG1
         luNQAqKB4jTjf6JVtCx/Y3koV+tre4hrHG0i+G0pfOS76OlQCZ94Sqq9ktwxp0kN3S51
         A1+yr2hB9eBk1miQDPZ0v/OJfsclcQp/bY/JUoE3twSzPpcGKc7zJo7jevvadK0LoJwK
         Lr6Pr/M9hDfHH3dfb5DJr/P054/QnXcibSyV1PPHamNnq6ZstzzjMLMvydlRrPw39fS3
         7Ha/+Ad3kZ+XO6MpCiKTnEvPxxOSYS7b51w9l+GHg15IyqMX+9vryEa5SPWJRGQQQb82
         yr7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:from:subject:message-id:date:mime-version;
        bh=8UTTULkwtsMoOI/rW0r8zzkuES3tsjU/CYGnZsvOq0A=;
        b=od+ZRtb++U7wiOXBER0dJNJVGjtEoj52q6FAjMUybqux1nLJPe0vhv3EoKnLRzbKJ2
         btayB0bYE0IKW+udBX/StM9VqepZR+hDlPoo0ZWYTTvfIIm+04YpE9e932d3cTMLoCFU
         VPBQ62PULNYxUFMV2xKj5AsfV/yoUVvmEACQU7nN+iC6Nopg19ywBBCgipea759EuDGw
         /KSPo5jWt2JNj1eFKlTMBn8ZLUzNrOKRmCO77cFDVVqIpIpMq5Va0MRH7WpNC37LHPtU
         week1nIZsIrrWJ1+Xl/kniSrKbqH2L0fT1VFyWLgHaeojl6/uD5kJ/NtljrHms7kkA2q
         Pb5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of 3rrbyxakbacgwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3RRbyXAkbACgWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id e13sor4477973ioh.112.2019.05.31.23.08.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 23:08:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3rrbyxakbacgwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) client-ip=209.85.220.69;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of 3rrbyxakbacgwcdoeppivettmh.ksskpiywivgsrxirx.gsq@m3kw2wvrgufz5godrsrytgd7.apphosting.bounces.google.com designates 209.85.220.69 as permitted sender) smtp.mailfrom=3RRbyXAkbACgWcdOEPPIVETTMH.KSSKPIYWIVGSRXIRX.GSQ@M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=appspotmail.com
X-Google-Smtp-Source: APXvYqyoP4KycHe/yLu9ubg6c4LS27pyf8cjRjLpGHwo+8mvuKiQmLRx52XI1LxAUJBaatKAcf/+leBPrwwYQyNHEWI8payr2RHU
MIME-Version: 1.0
X-Received: by 2002:a5e:961a:: with SMTP id a26mr8752787ioq.125.1559369285382;
 Fri, 31 May 2019 23:08:05 -0700 (PDT)
Date: Fri, 31 May 2019 23:08:05 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <000000000000543e45058a3cf40b@google.com>
Subject: possible deadlock in get_user_pages_unlocked (2)
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

Hello,

syzbot found the following crash on:

HEAD commit:    3c09c195 Add linux-next specific files for 20190531
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=13b36b9aa00000
kernel config:  https://syzkaller.appspot.com/x/.config?x=6cfb24468280cd5c
dashboard link: https://syzkaller.appspot.com/bug?extid=e1374b2ec8f6a25ab2e5
compiler:       gcc (GCC) 9.0.0 20181231 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+e1374b2ec8f6a25ab2e5@syzkaller.appspotmail.com

======================================================
WARNING: possible circular locking dependency detected
5.2.0-rc2-next-20190531 #4 Not tainted
------------------------------------------------------
syz-executor.5/29536 is trying to acquire lock:
0000000031b33a56 (&mm->mmap_sem#2){++++}, at:  
get_user_pages_unlocked+0xfc/0x4a0 mm/gup.c:1174

but task is already holding lock:
00000000e8d693f5 (&sb->s_type->i_mutex_key#10){++++}, at: inode_trylock  
include/linux/fs.h:798 [inline]
00000000e8d693f5 (&sb->s_type->i_mutex_key#10){++++}, at:  
ext4_file_write_iter+0x246/0x1070 fs/ext4/file.c:232

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&sb->s_type->i_mutex_key#10){++++}:
        down_write+0x38/0xa0 kernel/locking/rwsem.c:66
        inode_lock include/linux/fs.h:778 [inline]
        process_measurement+0x15ae/0x15e0  
security/integrity/ima/ima_main.c:228
        ima_file_mmap+0x11a/0x130 security/integrity/ima/ima_main.c:370
        security_file_mprotect+0xd5/0x100 security/security.c:1430
        do_mprotect_pkey+0x537/0xa30 mm/mprotect.c:550
        __do_sys_pkey_mprotect mm/mprotect.c:590 [inline]
        __se_sys_pkey_mprotect mm/mprotect.c:587 [inline]
        __x64_sys_pkey_mprotect+0x97/0xf0 mm/mprotect.c:587
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

3 locks held by syz-executor.5/29536:
  #0: 000000007070e315 (&f->f_pos_lock){+.+.}, at: __fdget_pos+0xee/0x110  
fs/file.c:801
  #1: 000000001278f3d0 (sb_writers#3){.+.+}, at: file_start_write  
include/linux/fs.h:2836 [inline]
  #1: 000000001278f3d0 (sb_writers#3){.+.+}, at: vfs_write+0x485/0x5d0  
fs/read_write.c:557
  #2: 00000000e8d693f5 (&sb->s_type->i_mutex_key#10){++++}, at:  
inode_trylock include/linux/fs.h:798 [inline]
  #2: 00000000e8d693f5 (&sb->s_type->i_mutex_key#10){++++}, at:  
ext4_file_write_iter+0x246/0x1070 fs/ext4/file.c:232

stack backtrace:
CPU: 0 PID: 29536 Comm: syz-executor.5 Not tainted 5.2.0-rc2-next-20190531  
#4
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
RIP: 0033:0x459279
Code: fd b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b7 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f65e9a0fc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000459279
RDX: 000000010000000d RSI: 0000000020000000 RDI: 0000000000000004
RBP: 000000000075bfc0 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007f65e9a106d4
R13: 00000000004c8e8a R14: 00000000004dfae0 R15: 00000000ffffffff


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

