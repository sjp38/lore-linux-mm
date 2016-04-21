Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2296382F6B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 04:22:20 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so99766341pad.0
        for <linux-mm@kvack.org>; Thu, 21 Apr 2016 01:22:20 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id l74si20913931pfb.194.2016.04.21.01.21.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Apr 2016 01:22:19 -0700 (PDT)
Message-ID: <57188D3B.6080807@huawei.com>
Date: Thu, 21 Apr 2016 16:20:11 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mce: a question about memory_failure_early_kill in memory_failure()
References: <571612DE.8020908@huawei.com> <20160420070735.GA10125@hori1.linux.bs1.fc.nec.co.jp> <57175F30.6050300@huawei.com> <571760F3.2040305@huawei.com> <20160420231506.GA18729@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20160420231506.GA18729@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>

On 2016/4/21 7:15, Naoya Horiguchi wrote:

> On Wed, Apr 20, 2016 at 06:58:59PM +0800, Xishi Qiu wrote:
>> On 2016/4/20 18:51, Xishi Qiu wrote:
>>
>>> On 2016/4/20 15:07, Naoya Horiguchi wrote:
>>>
>>>> On Tue, Apr 19, 2016 at 07:13:34PM +0800, Xishi Qiu wrote:
>>>>> /proc/sys/vm/memory_failure_early_kill
>>>>>
>>>>> 1: means kill all processes that have the corrupted and not reloadable page mapped.
>>>>> 0: means only unmap the corrupted page from all processes and only kill a process
>>>>> who tries to access it.
>>>>>
>>>>> If set memory_failure_early_kill to 0, and memory_failure() has been called.
>>>>> memory_failure()
>>>>> 	hwpoison_user_mappings()
>>>>> 		collect_procs()  // the task(with no PF_MCE_PROCESS flag) is not in the tokill list
>>>>> 			try_to_unmap()
>>>>>
>>>>> If the task access the memory, there will be a page fault,
>>>>> so the task can not access the original page again, right?
>>>>
>>>> Yes, right. That's the behavior in default "late kill" case.
>>>>
>>>
>>> Hi Naoya,
>>>
>>> Thanks for your reply, my confusion is that after try_to_unmap(), there will be a
>>> page fault if the task access the memory, and we will alloc a new page for it.
> 
> When try_to_unmap() is called for PageHWPoison(page) without TTU_IGNORE_HWPOISON,
> page table entries mapping the error page are replaced with hwpoison entries,
> which changes the bahavior of a subsequent page fault. Then, the page fault will
> fail with VM_FAULT_HWPOISON, so finally the process will be killed without allocating
> a new page.
> 

Hi Naoya,

One more question, can we add some code like x86(do_page_fault() -> mm_fault_error()),
then this new arch(e.g. arm64) could support late kill too?

I mean can we add config to support soft_offline_page/hard_offline_page on arm64?

Thanks,
Xishi Qiu

>>
>> Hi Naoya,
>>
>> If we alloc a new page, the task won't access the poisioned page again, so it won't be
>> killed by mce(late kill), right?
> 
> Allocating a new page for virtual address affected by memory error is dangerous
> because if the error page was dirty (or anonymous as you mentioned), the data
> is lost and new page allocation means that the data lost is ignored. The first
> priority of hwpoison mechanism is to avoid consuming corrupted data.
> 
>> If the poisioned page is anon, we will lost data, right?
> 
> Yes, that's the idea.
> 
>>
>>> So how the hardware(mce) know this page fault is relate to the poisioned page which
>>> is unmapped from the task? 
>>>
>>> Will we record something in pte when after try_to_unmap() in memory_failure()?
> 
> As mentioned above, hwpoison entry does this job.
> 
> Thanks,
> Naoya Horiguchi
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
