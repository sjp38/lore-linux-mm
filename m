Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 432EE6B000C
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 11:31:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id i137so5517263pfe.0
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 08:31:27 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id z16-v6si15904448pll.36.2018.03.26.08.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 08:31:26 -0700 (PDT)
Subject: Re: [PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1521851771-108673-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180324043044.GA22733@bombadil.infradead.org>
 <aed7f679-a32f-d8d7-eb59-ec05fc49a70e@linux.alibaba.com>
 <a766b98b-80b4-5f1b-9588-dd1c5506cbdc@i-love.sakura.ne.jp>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <579be4ee-58d0-1ffd-6b73-0202c7b28f08@linux.alibaba.com>
Date: Mon, 26 Mar 2018 11:31:03 -0400
MIME-Version: 1.0
In-Reply-To: <a766b98b-80b4-5f1b-9588-dd1c5506cbdc@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Matthew Wilcox <willy@infradead.org>
Cc: adobriyan@gmail.com, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/26/18 10:49 AM, Tetsuo Handa wrote:
> On 2018/03/24 9:36, Yang Shi wrote:
>> And, the mmap_sem contention may cause unexpected issue like below:
>>
>> INFO: task ps:14018 blocked for more than 120 seconds.
>>         Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>>   "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>> message.
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
> Yes, but
>
>> Both Alexey Dobriyan and Michal Hocko suggested to use dedicated lock
>> for them to mitigate the abuse of mmap_sem.
>>
>> So, introduce a new rwlock in mm_struct to protect the concurrent access
>> to arg_start|end and env_start|end.
> does arg_lock really help?
>
> I wonder whether per "struct mm_struct" granularity is needed if arg_lock
> protects only a few atomic reads. A global lock would be sufficient.

However, a global lock might be hard to know what it is used for, and 
might be abused again.

And, it may introduce unexpected contention for parallel reading for /proc

>
> Also, even if we succeeded to avoid mmap_sem contention at that location,
> won't we after all get mmap_sem contention messages a bit later, for
> access_remote_vm() holds mmap_sem which would lead to traces like above
> if mmap_sem is already contended?

Yes, definitely, this patch is aimed to remove the abuse to mmap_sem. 
The mmap_sem contention will be addressed separately.

Yang

>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> Cc: Alexey Dobriyan <adobriyan@gmail.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> ---
>>   fs/proc/base.c           | 8 ++++----
>>   include/linux/mm_types.h | 2 ++
>>   kernel/fork.c            | 1 +
>>   kernel/sys.c             | 6 ++++++
>>   mm/init-mm.c             | 1 +
>>   5 files changed, 14 insertions(+), 4 deletions(-)
