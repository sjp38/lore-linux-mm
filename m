Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 547988308B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 23:18:21 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id o131so149052855ywc.2
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 20:18:21 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id t87si314556qkt.117.2016.04.20.20.18.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Apr 2016 20:18:20 -0700 (PDT)
Message-ID: <57184667.5000601@huawei.com>
Date: Thu, 21 Apr 2016 11:17:59 +0800
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
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

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

Hi Naoya,

That's right, I missed the "hwpoison entry" in try_to_unmap().

Thanks,
Xishi Qiu

> which changes the bahavior of a subsequent page fault. Then, the page fault will
> fail with VM_FAULT_HWPOISON, so finally the process will be killed without allocating
> a new page.
> 
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
