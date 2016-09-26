Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05987280273
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:33:18 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n4so101578779lfb.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 10:33:17 -0700 (PDT)
Received: from albireo.enyo.de (albireo.enyo.de. [5.158.152.32])
        by mx.google.com with ESMTPS id m10si20293505wja.285.2016.09.26.10.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 10:33:16 -0700 (PDT)
From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Excessive xfs_inode allocations trigger OOM killer
References: <87a8f2pd2d.fsf@mid.deneb.enyo.de> <20160920203039.GI340@dastard>
	<87mvj2mgsg.fsf@mid.deneb.enyo.de> <20160920214612.GJ340@dastard>
	<20160921080425.GC10300@dhcp22.suse.cz>
Date: Mon, 26 Sep 2016 19:33:09 +0200
In-Reply-To: <20160921080425.GC10300@dhcp22.suse.cz> (Michal Hocko's message
	of "Wed, 21 Sep 2016 10:04:25 +0200")
Message-ID: <878tuetvl6.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

* Michal Hocko:

> On Wed 21-09-16 07:46:12, Dave Chinner wrote:
>> [cc Michal, linux-mm@kvack.org]
>> 
>> On Tue, Sep 20, 2016 at 10:56:31PM +0200, Florian Weimer wrote:
> [...]
>> > [51669.515086] make invoked oom-killer:
>> > gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2,
>> > oom_score_adj=0
>> > [51669.515092] CPU: 1 PID: 1202 Comm: make Tainted: G I 4.7.1fw #1
>> > [51669.515093] Hardware name: System manufacturer System Product
>> > Name/P6X58D-E, BIOS 0701 05/10/2011
>> > [51669.515095] 0000000000000000 ffffffff812a7d39 0000000000000000
>> > 0000000000000000
>> > [51669.515098] ffffffff8114e4da ffff880018707d98 0000000000000000
>> > 000000000066ca81
>> > [51669.515100] ffffffff8170e88d ffffffff810fe69e ffff88033fc38728
>> > 0000000200000006
>> > [51669.515102] Call Trace:
>> > [51669.515108]  [<ffffffff812a7d39>] ? dump_stack+0x46/0x5d
>> > [51669.515113]  [<ffffffff8114e4da>] ? dump_header.isra.12+0x51/0x176
>> > [51669.515116]  [<ffffffff810fe69e>] ? oom_kill_process+0x32e/0x420
>> > [51669.515119]  [<ffffffff811003a0>] ? page_alloc_cpu_notify+0x40/0x40
>> > [51669.515120]  [<ffffffff810fdcdc>] ? find_lock_task_mm+0x2c/0x70
>> > [51669.515122]  [<ffffffff810fea6d>] ? out_of_memory+0x28d/0x2d0
>> > [51669.515125]  [<ffffffff81103137>] ? __alloc_pages_nodemask+0xb97/0xc90
>> > [51669.515128]  [<ffffffff81076d9c>] ? copy_process.part.54+0xec/0x17a0
>> > [51669.515131]  [<ffffffff81123318>] ? handle_mm_fault+0xaa8/0x1900
>> > [51669.515133]  [<ffffffff81078614>] ? _do_fork+0xd4/0x320
>> > [51669.515137]  [<ffffffff81084ecc>] ? __set_current_blocked+0x2c/0x40
>> > [51669.515140]  [<ffffffff810013ce>] ? do_syscall_64+0x3e/0x80
>> > [51669.515144]  [<ffffffff8151433c>] ? entry_SYSCALL64_slow_path+0x25/0x25
>> .....
>> > [51669.515194] DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB
>> > (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M)
>> > 3*4096kB (M) = 15900kB
>> > [51669.515202] DMA32: 45619*4kB (UME) 73*8kB (UM) 0*16kB 0*32kB
>> > 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =
>> > 183060kB
>> > [51669.515209] Normal: 39979*4kB (UE) 0*8kB 0*16kB 0*32kB 0*64kB
>> > 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 159916kB
>> .....
>> 
>> Alright, that's what I suspected. high order allocation for a new
>> kernel stack and memory is so fragmented that a contiguous
>> allocation fails. Really, this is a memory reclaim issue, not an XFS
>> issue.  There is lots of reclaimable memory available, but memory
>> reclaim is:
>> 
>> 	a) not trying hard enough to reclaim reclaimable memory; and
>> 	b) not waiting for memory compaction to rebuild contiguous
>> 	   memory regions for high order allocations.
>> 
>> Instead, it is declaring OOM and kicking the killer to free memory
>> held busy userspace.
>
> Yes this was the case with 4.7 kernel. There is a workaround sitting in
> the linus tree 6b4e3181d7bd ("mm, oom: prevent premature OOM killer
> invocation for high order request") which should get to stable
> eventually. More approapriate fix is currently in the linux-next.
>
> Testing the same workload with linux-next would be very helpful.

I'm not sure if I can reproduce this issue in a sufficiently reliable
way, but I can try.  (I still have not found the process which causes
the xfs_inode allocations go up.)

Is linux-next still the tree to test?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
