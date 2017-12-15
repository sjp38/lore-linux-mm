Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 431376B0253
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 04:33:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id f132so3682622wmf.6
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 01:33:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor4178811edi.46.2017.12.15.01.33.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 01:33:06 -0800 (PST)
Date: Fri, 15 Dec 2017 12:33:03 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid
 long block
Message-ID: <20171215093303.seq3hinpdhqckgnk@node.shutemov.name>
References: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
 <16a06998-34ba-65d9-c6d0-8078d9ef98f9@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16a06998-34ba-65d9-c6d0-8078d9ef98f9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Yang Shi <yang.s@alibaba-inc.com>, kirill.shutemov@linux.intel.com, mhocko@suse.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 15, 2017 at 10:04:27AM +0530, Anshuman Khandual wrote:
> On 12/15/2017 01:23 AM, Yang Shi wrote:
> > In the current design, khugepaged need acquire mmap_sem before scanning
> > mm, but in some corner case, khugepaged may scan the current running
> > process which might be modifying memory mapping, so khugepaged might
> > block in uninterruptible state. But, the process might hold the mmap_sem
> > for long time when modifying a huge memory space, then it may trigger
> > the below khugepaged hung issue:
> > 
> > INFO: task khugepaged:270 blocked for more than 120 seconds. 
> > Tainted: G E 4.9.65-006.ali3000.alios7.x86_64 #1
> > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message. 
> > khugepaged D 0 270 2 0x00000000 
> > ffff883f3deae4c0 0000000000000000 ffff883f610596c0 ffff883f7d359440
> > ffff883f63818000 ffffc90019adfc78 ffffffff817079a5 d67e5aa8c1860a64
> > 0000000000000246 ffff883f7d359440 ffffc90019adfc88 ffff883f610596c0
> > Call Trace: 
> > [<ffffffff817079a5>] ? __schedule+0x235/0x6e0 
> > [<ffffffff81707e86>] schedule+0x36/0x80
> > [<ffffffff8170a970>] rwsem_down_read_failed+0xf0/0x150
> > [<ffffffff81384998>] call_rwsem_down_read_failed+0x18/0x30
> > [<ffffffff8170a1c0>] down_read+0x20/0x40
> > [<ffffffff81226836>] khugepaged+0x476/0x11d0
> > [<ffffffff810c9d0e>] ? idle_balance+0x1ce/0x300
> > [<ffffffff810d0850>] ? prepare_to_wait_event+0x100/0x100
> > [<ffffffff812263c0>] ? collapse_shmem+0xbf0/0xbf0
> > [<ffffffff810a8d46>] kthread+0xe6/0x100
> > [<ffffffff810a8c60>] ? kthread_park+0x60/0x60
> > [<ffffffff8170cd15>] ret_from_fork+0x25/0x30

What holds the lock for this long? I think the other side also worth fixing.

> > 
> > So, it sounds pointless to just block for waiting for the semaphore for
> > khugepaged, here replace down_read() to down_read_trylock() to move to
> > scan next mm quickly instead of just blocking on the semaphore so that
> > other processes can get more chances to install THP.
> > Then khugepaged can come back to scan the skipped mm when finish the
> > current round full_scan.
> 
> That may be too harsh on the process which now has to wait for a complete
> round of full scan before the khugepaged comes back. What if the mmap_sem
> contention because of VMA changes in the process was just temporary ?

It's always temporary. Unless something is very broken. :)

If the mmap_sem is taken for write, it may also mean that memory layout of the
process is not yet settled and we can just waste the time collapsing the pages
that about to go away.

And it's better for khugepaged to do the job than just waiting for the lock.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
