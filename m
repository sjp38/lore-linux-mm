Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 45BE9830A8
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 20:38:57 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so93583879pfy.2
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 17:38:57 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id z73si3386861pfa.225.2016.04.21.17.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Apr 2016 17:38:56 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id fs9so34092671pac.2
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 17:38:56 -0700 (PDT)
From: "Shi, Yang" <yang.shi@linaro.org>
Subject: [BUG linux-next] kernel NULL pointer dereference on
 linux-next-20160420
Message-ID: <5719729E.7000101@linaro.org>
Date: Thu, 21 Apr 2016 17:38:54 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, sfr@canb.auug.org.au, hughd@google.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, yang.shi@linaro.org

Hi folks,

I did the below test with huge tmpfs on linux-next-20160420:

# mount -t tmpfs huge=1 tmpfs /mnt
# cd /mnt
Then clone linux kernel

Then I got the below bug, such test works well on non-huge tmpfs.

BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<ffffffff8119d2f8>] release_freepages+0x18/0xa0
PGD 0
Oops: 0000 [#1] PREEMPT SMP
Modules linked in:
CPU: 6 PID: 110 Comm: kcompactd0 Not tainted 
4.6.0-rc4-next-20160420-WR7.0.0.0_standard #4
Hardware name: Intel Corporation S5520HC/S5520HC, BIOS 
S5500.86B.01.10.0025.030220091519 03/02/2009
task: ffff880361708040 ti: ffff880361704000 task.ti: ffff880361704000
RIP: 0010:[<ffffffff8119d2f8>]  [<ffffffff8119d2f8>] 
release_freepages+0x18/0xa0
RSP: 0018:ffff880361707cf8  EFLAGS: 00010282
RAX: 0000000000000000 RBX: ffff88036ffde7c0 RCX: 0000000000000009
RDX: 0000000000001bf1 RSI: 000000000000000f RDI: ffff880361707dd0
RBP: ffff880361707d20 R08: 0000000000000007 R09: 0000160000000000
R10: ffff88036ffde7c0 R11: 0000000000000000 R12: 0000000000000000
R13: ffff880361707dd0 R14: ffff880361707dc0 R15: ffff880361707db0
FS:  0000000000000000(0000) GS:ffff880363cc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 0000000002206000 CR4: 00000000000006e0
Stack:
  ffff88036ffde7c0 0000000000000000 0000000000001a00 ffff880361707dc0
  ffff880361707db0 ffff880361707da0 ffffffff8119f13d ffffffff81196239
  0000000000000000 ffff880361708040 0000000000000001 0000000000100000
Call Trace:
  [<ffffffff8119f13d>] compact_zone+0x55d/0x9f0
  [<ffffffff81196239>] ? fragmentation_index+0x19/0x70
  [<ffffffff8119f92f>] kcompactd_do_work+0x10f/0x230
  [<ffffffff8119fae0>] kcompactd+0x90/0x1e0
  [<ffffffff810a3a40>] ? wait_woken+0xa0/0xa0
  [<ffffffff8119fa50>] ? kcompactd_do_work+0x230/0x230
  [<ffffffff810801ed>] kthread+0xdd/0x100
  [<ffffffff81be5ee2>] ret_from_fork+0x22/0x40
  [<ffffffff81080110>] ? kthread_create_on_node+0x180/0x180
Code: c1 fa 06 31 f6 e8 a9 9b fd ff eb 98 0f 1f 80 00 00 00 00 66 66 66 
66 90 55 48 89 e5 41 57 41 56 41 55 49 89 fd 41 54 53 48 8b 07 <48> 8b 
10 48 8d 78 e0 49 39 c5 4c 8d 62 e0 74 70 49 be 00 00 00
RIP  [<ffffffff8119d2f8>] release_freepages+0x18/0xa0
  RSP <ffff880361707cf8>
CR2: 0000000000000000
---[ end trace 855da7e142f7311f ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
