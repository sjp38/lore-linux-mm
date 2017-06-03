Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 078516B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 15:24:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id h127so119079017oic.11
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 12:24:29 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id c143si1426309oib.200.2017.06.03.12.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 12:24:28 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id o65so99374795oif.1
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 12:24:28 -0700 (PDT)
From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Sleeping BUG in khugepaged for i586
Message-ID: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
Date: Sat, 3 Jun 2017 14:24:26 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>

I recently turned on locking diagnostics for a Dell Latitude D600 laptop, which 
requires a 32-bit kernel. In the log I found the following:

BUG: sleeping function called from invalid context at mm/khugepaged.c:655
in_atomic(): 1, irqs_disabled(): 0, pid: 20, name: khugepaged
1 lock held by khugepaged/20:
  #0:  (&mm->mmap_sem){++++++}, at: [<c03d6609>] 
collapse_huge_page.isra.47+0x439/0x1240
CPU: 0 PID: 20 Comm: khugepaged Tainted: G        W 
4.12.0-rc1-wl-12125-g952a068 #80
Hardware name: Dell Computer Corporation Latitude D600 
/03U652, BIOS A05 05/29/2003
Call Trace:
  dump_stack+0x76/0xb2
  ___might_sleep+0x174/0x230
  collapse_huge_page.isra.47+0xacf/0x1240
  khugepaged_scan_mm_slot+0x41e/0xc00
  ? _raw_spin_lock+0x46/0x50
  khugepaged+0x277/0x4f0
  ? prepare_to_wait_event+0xe0/0xe0
  kthread+0xeb/0x120
  ? khugepaged_scan_mm_slot+0xc00/0xc00
  ? kthread_create_on_node+0x30/0x30
  ret_from_fork+0x21/0x30

I have no idea when this problem was introduced. Of course, I will test any 
proposed fixes.

Thanks,

Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
