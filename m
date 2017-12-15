Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA0F76B0033
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 15:04:21 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z25so7665335pgu.18
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 12:04:21 -0800 (PST)
Received: from out0-250.mail.aliyun.com (out0-250.mail.aliyun.com. [140.205.0.250])
        by mx.google.com with ESMTPS id h187si5000102pgc.561.2017.12.15.12.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 12:04:20 -0800 (PST)
Subject: Re: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid
 long block
References: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
 <20171215102753.GY16951@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <13f935a9-42af-98f4-1813-456a25200d9d@alibaba-inc.com>
Date: Sat, 16 Dec 2017 04:04:10 +0800
MIME-Version: 1.0
In-Reply-To: <20171215102753.GY16951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kirill & Michal,

Since both of you raised the same question about who holds the semaphore 
for that long time, I just reply here to both of you.

The backtrace shows vm-scalability is running with 300G memory and it is 
doing munmap as below:

[188995.241865] CPU: 15 PID: 8063 Comm: usemem Tainted: G            E 
4.9.65-006.ali3000.alios7.x86_64 #1
[188995.242252] Hardware name: Huawei Technologies Co., Ltd. Tecal 
RH2288H V2-12L/BC11SRSG1, BIOS RMIBV368 11/01/2013
[188995.242637] task: ffff883f610a5b00 task.stack: ffffc90037280000
[188995.242838] RIP: 0010:[<ffffffff811e2319>] .c [<ffffffff811e2319>] 
unmap_page_range+0x619/0x940
[188995.243231] RSP: 0018:ffffc90037283c98  EFLAGS: 00000282
[188995.243429] RAX: 00002b760ac57000 RBX: 00002b760ac56000 RCX: 
0000000003eb13ca
[188995.243820] RDX: ffffea003971e420 RSI: 00002b760ac56000 RDI: 
ffff8837cb832e80
[188995.244211] RBP: ffffc90037283d78 R08: ffff883ebf8fc3c0 R09: 
0000000000008000
[188995.244600] R10: 00000000826b7e00 R11: 0000000000000000 R12: 
ffff8821e70f72b0
[188995.244993] R13: ffffea00fac4f280 R14: ffffc90037283e00 R15: 
00002b760ac57000
[188995.245390] FS:  00002b34b4861700(0000) GS:ffff883f7d3c0000(0000) 
knlGS:0000000000000000
[188995.245788] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[188995.245990] CR2: 00002b7092160fed CR3: 0000000977850000 CR4: 
00000000001406e0
[188995.246388] Stack:
[188995.246581]  00002b92f71edfff.c 00002b7fffffffff.c 
00002b92f71ee000.c ffff8809778502b0.c
[188995.246981]  00002b763fffffff.c ffff8802e1895ec0.c 
ffffc90037283d48.c ffff883f610a5b00.c
[188995.247365]  ffffc90037283d70.c 00002b8000000000.c 
ffffc00000000fff.c ffffea00879c3df0.c
[188995.247759] Call Trace:
[188995.247957]  [<ffffffff811e26bd>] unmap_single_vma+0x7d/0xe0
[188995.248161]  [<ffffffff811e2a11>] unmap_vmas+0x51/0xa0
[188995.248367]  [<ffffffff811e98ed>] unmap_region+0xbd/0x130
[188995.248571]  [<ffffffff8170b04c>] ? 
rwsem_down_write_failed_killable+0x31c/0x3f0
[188995.248961]  [<ffffffff811eb94c>] do_munmap+0x26c/0x420
[188995.249162]  [<ffffffff811ebbc0>] SyS_munmap+0x50/0x70
[188995.249361]  [<ffffffff8170cab7>] entry_SYSCALL_64_fastpath+0x1a/0xa9

By analyzing vmcore, khugepaged is waiting for vm-scalability process's 
mmap_sem.

unmap_vmas will unmap every vma in the memory space, it sounds the test 
generated huge amount of vmas.

Shall we add "cond_resched()" in unmap_vmas(), i.e for every 100 vmas? 
It may improve the responsiveness a little bit for non-preempt kernel, 
although it still can't release the semaphore.

Thanks,
Yang

On 12/15/17 2:27 AM, Michal Hocko wrote:
> On Fri 15-12-17 03:53:23, Yang Shi wrote:
>> In the current design, khugepaged need acquire mmap_sem before scanning
>> mm, but in some corner case, khugepaged may scan the current running
>> process which might be modifying memory mapping, so khugepaged might
>> block in uninterruptible state. But, the process might hold the mmap_sem
>> for long time when modifying a huge memory space, then it may trigger
>> the below khugepaged hung issue:
>>
>> INFO: task khugepaged:270 blocked for more than 120 seconds.
>> Tainted: G E 4.9.65-006.ali3000.alios7.x86_64 #1
>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
>> khugepaged D 0 270 2 0x00000000
>> ffff883f3deae4c0 0000000000000000 ffff883f610596c0 ffff883f7d359440
>> ffff883f63818000 ffffc90019adfc78 ffffffff817079a5 d67e5aa8c1860a64
>> 0000000000000246 ffff883f7d359440 ffffc90019adfc88 ffff883f610596c0
>> Call Trace:
>> [<ffffffff817079a5>] ? __schedule+0x235/0x6e0
>> [<ffffffff81707e86>] schedule+0x36/0x80
>> [<ffffffff8170a970>] rwsem_down_read_failed+0xf0/0x150
>> [<ffffffff81384998>] call_rwsem_down_read_failed+0x18/0x30
>> [<ffffffff8170a1c0>] down_read+0x20/0x40
>> [<ffffffff81226836>] khugepaged+0x476/0x11d0
>> [<ffffffff810c9d0e>] ? idle_balance+0x1ce/0x300
>> [<ffffffff810d0850>] ? prepare_to_wait_event+0x100/0x100
>> [<ffffffff812263c0>] ? collapse_shmem+0xbf0/0xbf0
>> [<ffffffff810a8d46>] kthread+0xe6/0x100
>> [<ffffffff810a8c60>] ? kthread_park+0x60/0x60
>> [<ffffffff8170cd15>] ret_from_fork+0x25/0x30
> 
> I am definitely interested in what the holder of the write lock does
> here for such a long time.
>   
>> So, it sounds pointless to just block for waiting for the semaphore for
>> khugepaged, here replace down_read() to down_read_trylock() to move to
>> scan next mm quickly instead of just blocking on the semaphore so that
>> other processes can get more chances to install THP.
>> Then khugepaged can come back to scan the skipped mm when finish the
>> current round full_scan.
>>
>> And, it soudns the change can improve khugepaged efficiency a little
>> bit.
>>
>> The below is the test result with running LTP on a 24 cores 4GB memory 2
>> nodes NUMA VM:
>>
>> 				pristine	 w/ trylock
>> full_scan                         197               187
>> pages_collapsed                   21                26
>> thp_fault_alloc                   40818             44466
>> thp_fault_fallback                18413             16679
>> thp_collapse_alloc                21                150
>> thp_collapse_alloc_failed         14                16
>> thp_file_alloc                    369               369
>>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> The patch makes sense to me
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
>> ---
>>   mm/khugepaged.c | 7 ++++++-
>>   1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>> index ea4ff25..ecc2b68 100644
>> --- a/mm/khugepaged.c
>> +++ b/mm/khugepaged.c
>> @@ -1674,7 +1674,12 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>>   	spin_unlock(&khugepaged_mm_lock);
>>   
>>   	mm = mm_slot->mm;
>> -	down_read(&mm->mmap_sem);
>> +	/*
>> + 	 * Not wait for semaphore to avoid long time waiting, just move
>> + 	 * to the next mm on the list.
>> + 	 */
>> +	if (unlikely(!down_read_trylock(&mm->mmap_sem)))
>> +		goto breakouterloop_mmap_sem;
>>   	if (unlikely(khugepaged_test_exit(mm)))
>>   		vma = NULL;
>>   	else
>> -- 
>> 1.8.3.1
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
