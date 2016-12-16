Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81A4C6B0253
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:26:02 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id i145so27042091qke.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:26:02 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j26si3289783qta.114.2016.12.16.06.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:26:01 -0800 (PST)
Subject: Re: crash during oom reaper
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
 <aaa788c2-7233-005d-ae7b-170cdcafc5ec@oracle.com>
 <20161216140043.GN13940@dhcp22.suse.cz>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <2d65449b-5f8a-7a29-e879-9c27bd1d4537@oracle.com>
Date: Fri, 16 Dec 2016 15:25:27 +0100
MIME-Version: 1.0
In-Reply-To: <20161216140043.GN13940@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 12/16/2016 03:00 PM, Michal Hocko wrote:
> On Fri 16-12-16 14:14:17, Vegard Nossum wrote:
> [...]
>> Out of memory: Kill process 1650 (trinity-main) score 90 or sacrifice child
>> Killed process 1724 (trinity-c14) total-vm:37280kB, anon-rss:236kB,
>> file-rss:112kB, shmem-rss:112kB
>> BUG: unable to handle kernel NULL pointer dereference at 00000000000001e8
>> IP: [<ffffffff8126b1c0>] copy_process.part.41+0x2150/0x5580
>> PGD c001067 PUD c000067
>> PMD 0
>> Oops: 0002 [#1] PREEMPT SMP KASAN
>> Dumping ftrace buffer:
>>    (ftrace buffer empty)
>> CPU: 28 PID: 1650 Comm: trinity-main Not tainted 4.9.0-rc6+ #317
>
> Hmm, so this was the oom victim initially but we have decided to kill
> its child 1724 instead.
>
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>> task: ffff88000f9bc440 task.stack: ffff88000c778000
>> RIP: 0010:[<ffffffff8126b1c0>]  [<ffffffff8126b1c0>]
>> copy_process.part.41+0x2150/0x5580
>
> Could you match this to the kernel source please?

kernel/fork.c:629 dup_mmap()

it's atomic_dec(&inode->i_writecount), it matches up with
file_inode(file) == NULL:

(gdb) p &((struct inode *)0)->i_writecount
$1 = (atomic_t *) 0x1e8 <irq_stack_union+488>

>> Killed process 1775 (trinity-c21) total-vm:37404kB, anon-rss:232kB,
>> file-rss:420kB, shmem-rss:116kB
>> oom_reaper: reaped process 1775 (trinity-c21), now anon-rss:0kB,
>> file-rss:0kB, shmem-rss:116kB
>> ==================================================================
>> BUG: KASAN: use-after-free in p9_client_read+0x8f0/0x960 at addr
>> ffff880010284d00
>> Read of size 8 by task trinity-main/1649
>> CPU: 3 PID: 1649 Comm: trinity-main Not tainted 4.9.0+ #318
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>>  ffff8800068a7770 ffffffff82012301 ffff88001100f600 ffff880010284d00
>>  ffff880010284d60 ffff880010284d00 ffff8800068a7798 ffffffff8165872c
>>  ffff8800068a7828 ffff880010284d00 ffff88001100f600 ffff8800068a7818
>> Call Trace:
>>  [<ffffffff82012301>] dump_stack+0x83/0xb2
>>  [<ffffffff8165872c>] kasan_object_err+0x1c/0x70
>>  [<ffffffff816589c5>] kasan_report_error+0x1f5/0x4e0
>>  [<ffffffff81657d92>] ? kasan_slab_alloc+0x12/0x20
>>  [<ffffffff82079357>] ? check_preemption_disabled+0x37/0x1e0
>>  [<ffffffff81658e4e>] __asan_report_load8_noabort+0x3e/0x40
>>  [<ffffffff82079300>] ? assoc_array_gc+0x1310/0x1330
>>  [<ffffffff83b84c30>] ? p9_client_read+0x8f0/0x960
>>  [<ffffffff83b84c30>] p9_client_read+0x8f0/0x960
>
> no idea how we would end up with use after here. Even if I unmapped the
> page then the read code should be able to cope with that. This smells
> like a p9 issue to me.

This is fid->clnt dereference at the top of p9_client_read().

Ah, yes, this is the one coming from a page fault:

p9_client_read
v9fs_fid_readpage
v9fs_vfs_readpage
handle_mm_fault
__do_page_fault

the bad fid pointer is filp->private_data.

Hm, so I guess the file itself was NOT freed prematurely (as otherwise
we'd probably have seen a KASAN report for the filp->private_data
dereference), but the ->private_data itself was.

Maybe the whole thing is fundamentally a 9p bug and the OOM killer just
happens to trigger it.


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
