Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E67716B0012
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:31:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y19so2619348pgv.18
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 09:31:42 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id b59-v6si810650plb.530.2018.03.21.09.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 09:31:41 -0700 (PDT)
Subject: Re: [RFC PATCH 1/8] mm: mmap: unmap large mapping by section
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
 <1521581486-99134-2-git-send-email-yang.shi@linux.alibaba.com>
 <20180321130833.GM23100@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <f88deb20-bcce-939f-53a6-1061c39a9f6c@linux.alibaba.com>
Date: Wed, 21 Mar 2018 09:31:22 -0700
MIME-Version: 1.0
In-Reply-To: <20180321130833.GM23100@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/21/18 6:08 AM, Michal Hocko wrote:
> On Wed 21-03-18 05:31:19, Yang Shi wrote:
>> When running some mmap/munmap scalability tests with large memory (i.e.
>>> 300GB), the below hung task issue may happen occasionally.
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
>>
>> It is because munmap holds mmap_sem from very beginning to all the way
>> down to the end, and doesn't release it in the middle. When unmapping
>> large mapping, it may take long time (take ~18 seconds to unmap 320GB
>> mapping with every single page mapped on an idle machine).
> Yes, this definitely sucks. One way to work that around is to split the
> unmap to two phases. One to drop all the pages. That would only need
> mmap_sem for read and then tear down the mapping with the mmap_sem for
> write. This wouldn't help for parallel mmap_sem writers but those really
> need a different approach (e.g. the range locking).

page fault might sneak in to map a page which has been unmapped before?

range locking should help a lot on manipulating small sections of a 
large mapping in parallel or multiple small mappings. It may not achieve 
too much for single large mapping.

>
>> Since unmapping does't require any atomicity, so here unmap large
> How come? Could you be more specific why? Once you drop the lock the
> address space might change under your feet and you might be unmapping a
> completely different vma. That would require userspace doing nasty
> things of course (e.g. MAP_FIXED) but I am worried that userspace really
> depends on mmap/munmap atomicity these days.

Sorry for the ambiguity. The statement does look misleading. munmap does 
need certain atomicity, particularly for the below sequence:

splitting vma
unmap region
free pagetables
free vmas

Otherwise it may run into the below race condition:

           CPU A                             CPU B
        ----------                     ----------
        do_munmap
      zap_pmd_range
        up_write                        do_munmap
                                             down_write
                                             ......
                                             remove_vma_list
                                             up_write
       down_write
      access vmas  <-- use-after-free bug

This is why I do the range unmap in do_munmap() rather than doing it in 
deeper location, i.e. zap_pmd_range(). I elaborated this in the cover 
letter.

Thanks,
Yang
