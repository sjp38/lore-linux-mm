Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0B81B6B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 14:53:51 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a10so4885053pgq.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:53:51 -0800 (PST)
Received: from out0-205.mail.aliyun.com (out0-205.mail.aliyun.com. [140.205.0.205])
        by mx.google.com with ESMTPS id a33si3645615plc.187.2017.12.14.11.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 11:53:49 -0800 (PST)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid long block
Date: Fri, 15 Dec 2017 03:53:23 +0800
Message-Id: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, mhocko@suse.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In the current design, khugepaged need acquire mmap_sem before scanning
mm, but in some corner case, khugepaged may scan the current running
process which might be modifying memory mapping, so khugepaged might
block in uninterruptible state. But, the process might hold the mmap_sem
for long time when modifying a huge memory space, then it may trigger
the below khugepaged hung issue:

INFO: task khugepaged:270 blocked for more than 120 seconds.A 
Tainted: G E 4.9.65-006.ali3000.alios7.x86_64 #1
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.A 
khugepaged D 0 270 2 0x00000000A 
ffff883f3deae4c0 0000000000000000 ffff883f610596c0 ffff883f7d359440
ffff883f63818000 ffffc90019adfc78 ffffffff817079a5 d67e5aa8c1860a64
0000000000000246 ffff883f7d359440 ffffc90019adfc88 ffff883f610596c0
Call Trace:A 
[<ffffffff817079a5>] ? __schedule+0x235/0x6e0A 
[<ffffffff81707e86>] schedule+0x36/0x80
[<ffffffff8170a970>] rwsem_down_read_failed+0xf0/0x150
[<ffffffff81384998>] call_rwsem_down_read_failed+0x18/0x30
[<ffffffff8170a1c0>] down_read+0x20/0x40
[<ffffffff81226836>] khugepaged+0x476/0x11d0
[<ffffffff810c9d0e>] ? idle_balance+0x1ce/0x300
[<ffffffff810d0850>] ? prepare_to_wait_event+0x100/0x100
[<ffffffff812263c0>] ? collapse_shmem+0xbf0/0xbf0
[<ffffffff810a8d46>] kthread+0xe6/0x100
[<ffffffff810a8c60>] ? kthread_park+0x60/0x60
[<ffffffff8170cd15>] ret_from_fork+0x25/0x30

So, it sounds pointless to just block for waiting for the semaphore for
khugepaged, here replace down_read() to down_read_trylock() to move to
scan next mm quickly instead of just blocking on the semaphore so that
other processes can get more chances to install THP.
Then khugepaged can come back to scan the skipped mm when finish the
current round full_scan.

And, it soudns the change can improve khugepaged efficiency a little
bit.

The below is the test result with running LTP on a 24 cores 4GB memory 2
nodes NUMA VM:

				pristine	 w/ trylock
full_scan                         197               187
pages_collapsed                   21                26
thp_fault_alloc                   40818             44466
thp_fault_fallback                18413             16679
thp_collapse_alloc                21                150
thp_collapse_alloc_failed         14                16
thp_file_alloc                    369               369

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/khugepaged.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index ea4ff25..ecc2b68 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1674,7 +1674,12 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 	spin_unlock(&khugepaged_mm_lock);
 
 	mm = mm_slot->mm;
-	down_read(&mm->mmap_sem);
+	/*
+ 	 * Not wait for semaphore to avoid long time waiting, just move
+ 	 * to the next mm on the list.
+ 	 */
+	if (unlikely(!down_read_trylock(&mm->mmap_sem)))
+		goto breakouterloop_mmap_sem;
 	if (unlikely(khugepaged_test_exit(mm)))
 		vma = NULL;
 	else
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
