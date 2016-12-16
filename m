Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6DC6B02C4
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:53:46 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id j49so58763607qta.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:53:46 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j14si3334865qta.217.2016.12.16.06.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:53:45 -0800 (PST)
Subject: Re: crash during oom reaper
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
 <aaa788c2-7233-005d-ae7b-170cdcafc5ec@oracle.com>
 <20161216140043.GN13940@dhcp22.suse.cz>
 <2d65449b-5f8a-7a29-e879-9c27bd1d4537@oracle.com>
 <20161216143235.GO13940@dhcp22.suse.cz>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <53b709f5-c560-a8ae-616f-cc7a64ff536c@oracle.com>
Date: Fri, 16 Dec 2016 15:53:11 +0100
MIME-Version: 1.0
In-Reply-To: <20161216143235.GO13940@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 12/16/2016 03:32 PM, Michal Hocko wrote:
> On Fri 16-12-16 15:25:27, Vegard Nossum wrote:
>> On 12/16/2016 03:00 PM, Michal Hocko wrote:
>>> On Fri 16-12-16 14:14:17, Vegard Nossum wrote:
>>> [...]
>>>> Out of memory: Kill process 1650 (trinity-main) score 90 or sacrifice child
>>>> Killed process 1724 (trinity-c14) total-vm:37280kB, anon-rss:236kB,
>>>> file-rss:112kB, shmem-rss:112kB
>>>> BUG: unable to handle kernel NULL pointer dereference at 00000000000001e8
>>>> IP: [<ffffffff8126b1c0>] copy_process.part.41+0x2150/0x5580
>>>> PGD c001067 PUD c000067
>>>> PMD 0
>>>> Oops: 0002 [#1] PREEMPT SMP KASAN
>>>> Dumping ftrace buffer:
>>>>    (ftrace buffer empty)
>>>> CPU: 28 PID: 1650 Comm: trinity-main Not tainted 4.9.0-rc6+ #317
>>>
>>> Hmm, so this was the oom victim initially but we have decided to kill
>>> its child 1724 instead.
>>>
>>>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>>>> Ubuntu-1.8.2-1ubuntu1 04/01/2014
>>>> task: ffff88000f9bc440 task.stack: ffff88000c778000
>>>> RIP: 0010:[<ffffffff8126b1c0>]  [<ffffffff8126b1c0>]
>>>> copy_process.part.41+0x2150/0x5580
>>>
>>> Could you match this to the kernel source please?
>>
>> kernel/fork.c:629 dup_mmap()
>
> Ok, so this is before the child is made visible so the oom reaper
> couldn't have seen it.
>
>> it's atomic_dec(&inode->i_writecount), it matches up with
>> file_inode(file) == NULL:
>>
>> (gdb) p &((struct inode *)0)->i_writecount
>> $1 = (atomic_t *) 0x1e8 <irq_stack_union+488>
>
> is this a p9 inode?

When I looked at this before it always crashed in this spot for the very
first VMA in the mm (which happens to be the exe, which is on a 9p root fs).

I added a trace_printk() to dup_mmap() to print inode->i_sb->s_type and
the last thing I see for a new crash in the same place is:

trinity--9280   28.... 136345090us : copy_process.part.41: ffffffff8485ec40
---------------------------------
CPU: 0 PID: 9302 Comm: trinity-c0 Not tainted 4.9.0-rc8+ #332
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 
Ubuntu-1.8.2-1ubuntu1 04/01/2014
task: ffff880000070000 task.stack: ffff8800099e0000
RIP: 0010:[<ffffffff8126c7c9>]  [<ffffffff8126c7c9>] 
copy_process.part.41+0x22c9/0x55b0

As you can see, the addresses match:

(gdb) p &v9fs_fs_type
$1 = (struct file_system_type *) 0xffffffff8485ec40 <v9fs_fs_type>

So I think we can safely say that yes, it's a p9 inode.


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
