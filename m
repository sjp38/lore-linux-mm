Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D622A44040A
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 17:22:46 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j3so10324515pfh.16
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 14:22:46 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id s59si7067920plb.276.2017.12.16.14.22.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Dec 2017 14:22:45 -0800 (PST)
Subject: Re: [PATCH] mm: thp: use down_read_trylock in khugepaged to avoid
 long block
References: <1513281203-54878-1-git-send-email-yang.s@alibaba-inc.com>
 <20171215102753.GY16951@dhcp22.suse.cz>
 <13f935a9-42af-98f4-1813-456a25200d9d@alibaba-inc.com>
 <20171216114525.GH16951@dhcp22.suse.cz>
 <20171216200925.kxvkuqoyhkonj7m6@node.shutemov.name>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <6624c1ea-1321-d999-fc77-3c5010f7bdd5@alibaba-inc.com>
Date: Sun, 17 Dec 2017 06:22:20 +0800
MIME-Version: 1.0
In-Reply-To: <20171216200925.kxvkuqoyhkonj7m6@node.shutemov.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 12/16/17 12:09 PM, Kirill A. Shutemov wrote:
> On Sat, Dec 16, 2017 at 12:45:25PM +0100, Michal Hocko wrote:
>> On Sat 16-12-17 04:04:10, Yang Shi wrote:
>>> Hi Kirill & Michal,
>>>
>>> Since both of you raised the same question about who holds the semaphore for
>>> that long time, I just reply here to both of you.
>>>
>>> The backtrace shows vm-scalability is running with 300G memory and it is
>>> doing munmap as below:
>>>
>>> [188995.241865] CPU: 15 PID: 8063 Comm: usemem Tainted: G            E
>>> 4.9.65-006.ali3000.alios7.x86_64 #1
>>> [188995.242252] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2288H
>>> V2-12L/BC11SRSG1, BIOS RMIBV368 11/01/2013
>>> [188995.242637] task: ffff883f610a5b00 task.stack: ffffc90037280000
>>> [188995.242838] RIP: 0010:[<ffffffff811e2319>] .c [<ffffffff811e2319>]
>>> unmap_page_range+0x619/0x940
>>> [188995.243231] RSP: 0018:ffffc90037283c98  EFLAGS: 00000282
>>> [188995.243429] RAX: 00002b760ac57000 RBX: 00002b760ac56000 RCX:
>>> 0000000003eb13ca
>>> [188995.243820] RDX: ffffea003971e420 RSI: 00002b760ac56000 RDI:
>>> ffff8837cb832e80
>>> [188995.244211] RBP: ffffc90037283d78 R08: ffff883ebf8fc3c0 R09:
>>> 0000000000008000
>>> [188995.244600] R10: 00000000826b7e00 R11: 0000000000000000 R12:
>>> ffff8821e70f72b0
>>> [188995.244993] R13: ffffea00fac4f280 R14: ffffc90037283e00 R15:
>>> 00002b760ac57000
>>> [188995.245390] FS:  00002b34b4861700(0000) GS:ffff883f7d3c0000(0000)
>>> knlGS:0000000000000000
>>> [188995.245788] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> [188995.245990] CR2: 00002b7092160fed CR3: 0000000977850000 CR4:
>>> 00000000001406e0
>>> [188995.246388] Stack:
>>> [188995.246581]  00002b92f71edfff.c 00002b7fffffffff.c 00002b92f71ee000.c
>>> ffff8809778502b0.c
>>> [188995.246981]  00002b763fffffff.c ffff8802e1895ec0.c ffffc90037283d48.c
>>> ffff883f610a5b00.c
>>> [188995.247365]  ffffc90037283d70.c 00002b8000000000.c ffffc00000000fff.c
>>> ffffea00879c3df0.c
>>> [188995.247759] Call Trace:
>>> [188995.247957]  [<ffffffff811e26bd>] unmap_single_vma+0x7d/0xe0
>>> [188995.248161]  [<ffffffff811e2a11>] unmap_vmas+0x51/0xa0
>>> [188995.248367]  [<ffffffff811e98ed>] unmap_region+0xbd/0x130
>>> [188995.248571]  [<ffffffff8170b04c>] ?
>>> rwsem_down_write_failed_killable+0x31c/0x3f0
>>> [188995.248961]  [<ffffffff811eb94c>] do_munmap+0x26c/0x420
>>> [188995.249162]  [<ffffffff811ebbc0>] SyS_munmap+0x50/0x70
>>> [188995.249361]  [<ffffffff8170cab7>] entry_SYSCALL_64_fastpath+0x1a/0xa9
>>>
>>> By analyzing vmcore, khugepaged is waiting for vm-scalability process's
>>> mmap_sem.
>>
>> OK, I see.
>>   
>>> unmap_vmas will unmap every vma in the memory space, it sounds the test
>>> generated huge amount of vmas.
>>
>> I would expect that it just takes some time to munmap 300G address
>> range.
>>
>>> Shall we add "cond_resched()" in unmap_vmas(), i.e for every 100 vmas? It
>>> may improve the responsiveness a little bit for non-preempt kernel, although
>>> it still can't release the semaphore.
>>
>> We already do, once per pmd (see zap_pmd_range).
> 
> It doesn't help. We would need to find a way to drop mmap_sem, if we're
> holding it way too long. And doing it on per-vma count basis is not right
> call. It won't address issue with single huge vma.

Yes, I agree. We have to find a way to release the semaphore at some 
point instead of holding it for the whole unmap.

> 
> Do we have any instrumentation that would help detect starvation on a
> rw_semaphore?

ebpf might help?

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
