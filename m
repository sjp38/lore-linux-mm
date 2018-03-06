Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 29CED6B002D
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 16:17:46 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id s6so30518pgn.3
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 13:17:46 -0800 (PST)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id u16si10566353pgn.488.2018.03.06.13.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 13:17:44 -0800 (PST)
Subject: Re: [RFC PATCH 0/4 v2] Define killable version for access_remote_vm()
 and use it in fs/proc
References: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180306124540.d8b5f6da97ab69a49566f950@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b576e32b-9c47-ee67-a576-b5a0c05c2864@linux.alibaba.com>
Date: Tue, 6 Mar 2018 13:17:37 -0800
MIME-Version: 1.0
In-Reply-To: <20180306124540.d8b5f6da97ab69a49566f950@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@kernel.org, adobriyan@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>



On 3/6/18 12:45 PM, Andrew Morton wrote:
> On Tue, 27 Feb 2018 08:25:47 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>> Background:
>> When running vm-scalability with large memory (> 300GB), the below hung
>> task issue happens occasionally.
>>
>> INFO: task ps:14018 blocked for more than 120 seconds.
>>         Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>>   "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>>   ps              D    0 14018      1 0x00000004
>>    ffff885582f84000 ffff885e8682f000 ffff880972943000 ffff885ebf499bc0
>>    ffff8828ee120000 ffffc900349bfca8 ffffffff817154d0 0000000000000040
>>    00ffffff812f872a ffff885ebf499bc0 024000d000948300 ffff880972943000
>>   Call Trace:
>>    [<ffffffff817154d0>] ? __schedule+0x250/0x730
>>    [<ffffffff817159e6>] schedule+0x36/0x80
>>    [<ffffffff81718560>] rwsem_down_read_failed+0xf0/0x150
>>    [<ffffffff81390a28>] call_rwsem_down_read_failed+0x18/0x30
>>    [<ffffffff81717db0>] down_read+0x20/0x40
>>    [<ffffffff812b9439>] proc_pid_cmdline_read+0xd9/0x4e0
>>    [<ffffffff81253c95>] ? do_filp_open+0xa5/0x100
>>    [<ffffffff81241d87>] __vfs_read+0x37/0x150
>>    [<ffffffff812f824b>] ? security_file_permission+0x9b/0xc0
>>    [<ffffffff81242266>] vfs_read+0x96/0x130
>>    [<ffffffff812437b5>] SyS_read+0x55/0xc0
>>    [<ffffffff8171a6da>] entry_SYSCALL_64_fastpath+0x1a/0xc5
>>
>> When manipulating a large mapping, the process may hold the mmap_sem for
>> long time, so reading /proc/<pid>/cmdline may be blocked in
>> uninterruptible state for long time.
>> We already have killable version APIs for semaphore, here use down_read_killable()
>> to improve the responsiveness.
>>
> Maybe I'm missing something, but I don't see how this solves the
> problem.  Yes, the read of /proc/pid/cmdline will be abandoned if
> someone interrupts that process.  But if nobody does that, the read
> will still just sit there for 2 minutes and the watchdog warning will
> still come out?

No, the warning will not come out since down_read_killable() puts the 
task into TASK_KILLABLE state instead of TASK_UNINTERRUPTIBLE state. The 
hung task check will skip TASK_KILLABLE tasks, please see the below code 
in (kernel/hung_task.c):

                 /* use "==" to skip the TASK_KILLABLE tasks waiting on 
NFS */
                 if (t->state == TASK_UNINTERRUPTIBLE)
                         check_hung_task(t, timeout);

It just mitigates the hung task warning, can't resolve the mmap_sem 
scalability issue. Furthermore, waiting on pure uninterruptible state 
for reading /proc sounds unnecessary. It doesn't wait for I/O completion.

>
> Where the heck are we holding mmap_sem for so long?  Can that be fixed?

The mmap_sem is held for unmapping a large map which has every single 
page mapped. This is not a issue in real production code. Just found it 
by running vm-scalability on a machine with ~600GB memory.

AFAIK, I don't see any easy fix for the mmap_sem scalability issue. I 
saw range locking patches (https://lwn.net/Articles/723648/) were 
floating around. But, it may not help too much on the case that a large 
map with every single page mapped.

Thanks,
Yang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
