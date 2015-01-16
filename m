Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9476B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 20:32:37 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id h136so15279253oig.10
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 17:32:37 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k7si849790oef.90.2015.01.15.17.32.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 17:32:36 -0800 (PST)
Message-ID: <54B86A2D.50709@oracle.com>
Date: Thu, 15 Jan 2015 20:32:29 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Reclaim in the face of really fast I/O
References: <54B82A57.9060000@intel.com> <54B867A8.6050900@oracle.com>
In-Reply-To: <54B867A8.6050900@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, lsf-pc@lists.linux-foundation.org, "Reddy, Dheeraj" <dheeraj.reddy@intel.com>
Cc: "Kleen, Andi" <andi.kleen@intel.com>, Linux-MM <linux-mm@kvack.org>, "Chen, Tim C" <tim.c.chen@intel.com>

On 01/15/2015 08:21 PM, Sasha Levin wrote:
> On 01/15/2015 04:00 PM, Dave Hansen wrote:
>> I/O devices are only getting faster.  In fact, they're getting closer
>> and closer to memory in latency and bandwidth.  But the VM is still
>> designed to do very orderly and costly procedures to reclaim memory, and
>> the existing algorithms don't parallelize particularly well.  They hit
>> contention on mmap_sem or the lru locks well before all of the CPU
>> horsepower that we have can be brought to bear on reclaim.
>>
>> Once the latency to bring pages in and out of storage becomes low
>> enough, reclaiming the _right_ pages becomes much less important than
>> doing something useful with the CPU horsepower that we have.
>>
>> We need to talk about ways to do reclaim with lower CPU overhead and to
>> parallelize more effectively.
>>
>> There has been some research in this area by some folks at Intel and we
>> could quickly summarize what has been learned so far to help kick off a
>> discussion.
> 
> I was actually planning to bring that up. Trinity can cause enough stress
> to a system that the hang watchdog triggers (with a 10 minute timeout!)
> inside reclaim code.

Something like this:

[ 5412.398971] trinity-c23     R  running task    10768 29063  30295 0x10000006
[ 5412.400111]  ffff88046127b178 0000000000000ec3 0000000000000000 0000000000000000
[ 5412.401404]  ffffe8fff263cd6e 0000000000000000 0000000000000000 0000000000000000
[ 5412.402695]  0000000000000000 ffff88076bfff4c8 0000000000001099 0000000000000000
[ 5412.404084] Call Trace:
[ 5412.404495]  [<ffffffff916124f2>] ? _raw_spin_unlock_irqrestore+0xa2/0xf0
[ 5412.405611]  [<ffffffff915fbe25>] schedule+0x55/0x280
[ 5412.406435]  [<ffffffff81903e72>] throttle_direct_reclaim+0x432/0x660
[ 5412.407530]  [<ffffffff81552160>] ? __init_waitqueue_head+0xe0/0xe0
[ 5412.408565]  [<ffffffff81916007>] try_to_free_pages+0xf7/0x460
[ 5412.409528]  [<ffffffff818e25e1>] __alloc_pages_nodemask+0xc01/0x1940
[ 5412.410589]  [<ffffffff81a05646>] alloc_pages_vma+0x216/0x6f0
[ 5412.411572]  [<ffffffff8191a62a>] ? shmem_alloc_page+0x9a/0x170
[ 5412.412556]  [<ffffffff8191a62a>] shmem_alloc_page+0x9a/0x170
[ 5412.413507]  [<ffffffff818bc241>] ? find_get_entry+0x191/0x2c0
[ 5412.414475]  [<ffffffff818bc0b5>] ? find_get_entry+0x5/0x2c0
[ 5412.415513]  [<ffffffff818bd02b>] ? find_lock_entry+0x2b/0x140
[ 5412.416474]  [<ffffffff81924f16>] shmem_getpage_gfp+0xde6/0x1710
[ 5412.417461]  [<ffffffff81926eb1>] shmem_fault+0x1a1/0x7d0
[ 5412.418353]  [<ffffffff819745dd>] __do_fault+0xad/0x2a0
[ 5412.419285]  [<ffffffff8197e6c1>] handle_mm_fault+0x1331/0x5440
[ 5412.420121]  [<ffffffff812f59d3>] __do_page_fault+0x2d3/0xfb0
[ 5412.420877]  [<ffffffff81579bc7>] ? mark_held_locks+0x117/0x2b0
[ 5412.421688]  [<ffffffff81571fcd>] ? trace_hardirqs_off+0xd/0x10
[ 5412.422491]  [<ffffffff812f6828>] trace_do_page_fault+0xc8/0x420
[ 5412.423348]  [<ffffffff812da7d3>] do_async_page_fault+0x83/0x120
[ 5412.424175]  [<ffffffff91614d68>] async_page_fault+0x28/0x30
[ 5412.424920]  [<ffffffff81960e5e>] ? iov_iter_fault_in_readable+0x17e/0x280
[ 5412.425851]  [<ffffffff814a1045>] ? ___might_sleep+0x2a5/0x420
[ 5412.426645]  [<ffffffff818baa49>] generic_perform_write+0x179/0x5b0
[ 5412.427573]  [<ffffffff81b2b267>] ? __mnt_drop_write+0x57/0xa0
[ 5412.428365]  [<ffffffff818c23fc>] __generic_file_write_iter+0x59c/0x13e0
[ 5412.429292]  [<ffffffff81aa1c7c>] ? rw_copy_check_uvector+0x5c/0x470
[ 5412.430153]  [<ffffffff81a8f964>] ? kasan_poison_shadow+0x34/0x40
[ 5412.431062]  [<ffffffff818c3319>] generic_file_write_iter+0xd9/0x510
[ 5412.431892]  [<ffffffff81a9bec0>] ? new_sync_read+0x220/0x220
[ 5412.432675]  [<ffffffff81a9c17d>] do_iter_readv_writev+0x9d/0x190
[ 5412.433504]  [<ffffffff81aa22c9>] do_readv_writev+0x239/0xe10
[ 5412.434294]  [<ffffffff818c3240>] ? __generic_file_write_iter+0x13e0/0x13e0
[ 5412.435300]  [<ffffffff8174cb7e>] ? acct_account_cputime+0x6e/0xa0
[ 5412.435942]  [<ffffffff818c3240>] ? __generic_file_write_iter+0x13e0/0x13e0
[ 5412.436678]  [<ffffffff818b5fa7>] ? context_tracking_user_exit+0xc7/0x330
[ 5412.437395]  [<ffffffff8157a281>] ? trace_hardirqs_on_caller+0x521/0x850
[ 5412.438097]  [<ffffffff81aa3033>] vfs_writev+0x93/0x100
[ 5412.438632]  [<ffffffff81aa39ba>] SyS_pwritev+0x11a/0x200


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
