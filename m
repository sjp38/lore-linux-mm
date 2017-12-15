Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAD8F6B0038
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 23:34:38 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id 12so4950035qkf.23
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 20:34:38 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j185si6186980qka.259.2017.12.14.20.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 20:34:38 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBF4YQKg049165
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 23:34:36 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ev31582vt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 23:34:36 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 15 Dec 2017 04:34:33 -0000
Subject: Re: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid
 long block
References: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 15 Dec 2017 10:04:27 +0530
MIME-Version: 1.0
In-Reply-To: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <16a06998-34ba-65d9-c6d0-8078d9ef98f9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>, kirill.shutemov@linux.intel.com, mhocko@suse.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/15/2017 01:23 AM, Yang Shi wrote:
> In the current design, khugepaged need acquire mmap_sem before scanning
> mm, but in some corner case, khugepaged may scan the current running
> process which might be modifying memory mapping, so khugepaged might
> block in uninterruptible state. But, the process might hold the mmap_sem
> for long time when modifying a huge memory space, then it may trigger
> the below khugepaged hung issue:
> 
> INFO: task khugepaged:270 blocked for more than 120 seconds. 
> Tainted: G E 4.9.65-006.ali3000.alios7.x86_64 #1
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message. 
> khugepaged D 0 270 2 0x00000000 
> ffff883f3deae4c0 0000000000000000 ffff883f610596c0 ffff883f7d359440
> ffff883f63818000 ffffc90019adfc78 ffffffff817079a5 d67e5aa8c1860a64
> 0000000000000246 ffff883f7d359440 ffffc90019adfc88 ffff883f610596c0
> Call Trace: 
> [<ffffffff817079a5>] ? __schedule+0x235/0x6e0 
> [<ffffffff81707e86>] schedule+0x36/0x80
> [<ffffffff8170a970>] rwsem_down_read_failed+0xf0/0x150
> [<ffffffff81384998>] call_rwsem_down_read_failed+0x18/0x30
> [<ffffffff8170a1c0>] down_read+0x20/0x40
> [<ffffffff81226836>] khugepaged+0x476/0x11d0
> [<ffffffff810c9d0e>] ? idle_balance+0x1ce/0x300
> [<ffffffff810d0850>] ? prepare_to_wait_event+0x100/0x100
> [<ffffffff812263c0>] ? collapse_shmem+0xbf0/0xbf0
> [<ffffffff810a8d46>] kthread+0xe6/0x100
> [<ffffffff810a8c60>] ? kthread_park+0x60/0x60
> [<ffffffff8170cd15>] ret_from_fork+0x25/0x30
> 
> So, it sounds pointless to just block for waiting for the semaphore for
> khugepaged, here replace down_read() to down_read_trylock() to move to
> scan next mm quickly instead of just blocking on the semaphore so that
> other processes can get more chances to install THP.
> Then khugepaged can come back to scan the skipped mm when finish the
> current round full_scan.

That may be too harsh on the process which now has to wait for a complete
round of full scan before the khugepaged comes back. What if the mmap_sem
contention because of VMA changes in the process was just temporary ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
