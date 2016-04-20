Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 046FD6B0272
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 07:05:36 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so59523147pad.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 04:05:35 -0700 (PDT)
Received: from szxga01-in.huawei.com ([58.251.152.64])
        by mx.google.com with ESMTPS id zm6si1615622pab.108.2016.04.20.04.05.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Apr 2016 04:05:35 -0700 (PDT)
Message-ID: <571760F3.2040305@huawei.com>
Date: Wed, 20 Apr 2016 18:58:59 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mce: a question about memory_failure_early_kill in memory_failure()
References: <571612DE.8020908@huawei.com> <20160420070735.GA10125@hori1.linux.bs1.fc.nec.co.jp> <57175F30.6050300@huawei.com>
In-Reply-To: <57175F30.6050300@huawei.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/4/20 18:51, Xishi Qiu wrote:

> On 2016/4/20 15:07, Naoya Horiguchi wrote:
> 
>> On Tue, Apr 19, 2016 at 07:13:34PM +0800, Xishi Qiu wrote:
>>> /proc/sys/vm/memory_failure_early_kill
>>>
>>> 1: means kill all processes that have the corrupted and not reloadable page mapped.
>>> 0: means only unmap the corrupted page from all processes and only kill a process
>>> who tries to access it.
>>>
>>> If set memory_failure_early_kill to 0, and memory_failure() has been called.
>>> memory_failure()
>>> 	hwpoison_user_mappings()
>>> 		collect_procs()  // the task(with no PF_MCE_PROCESS flag) is not in the tokill list
>>> 			try_to_unmap()
>>>
>>> If the task access the memory, there will be a page fault,
>>> so the task can not access the original page again, right?
>>
>> Yes, right. That's the behavior in default "late kill" case.
>>
> 
> Hi Naoya,
> 
> Thanks for your reply, my confusion is that after try_to_unmap(), there will be a
> page fault if the task access the memory, and we will alloc a new page for it.
> 

Hi Naoya,

If we alloc a new page, the task won't access the poisioned page again, so it won't be
killed by mce(late kill), right?
If the poisioned page is anon, we will lost data, right?

Thanks,
Xishi Qiu

> So how the hardware(mce) know this page fault is relate to the poisioned page which
> is unmapped from the task? 
> 
> Will we record something in pte when after try_to_unmap() in memory_failure()?
> 
> Thanks,
> Xishi Qiu
> 

>> I'm guessing that you might have a more specific problem around this code.
>> If so, please feel free to ask with detail.
>>
>> Thanks,
>> Naoya Horiguchi
>>
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
