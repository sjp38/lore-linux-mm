Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37AB16B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 22:31:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id b28so102907wrb.2
        for <linux-mm@kvack.org>; Wed, 03 May 2017 19:31:29 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id i130si530237wme.115.2017.05.03.19.31.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 May 2017 19:31:27 -0700 (PDT)
Message-ID: <590A91DF.8030004@huawei.com>
Date: Thu, 4 May 2017 10:28:47 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [RESENT PATCH] x86/mem: fix the offset overflow when read/write
 mem
References: <1493293775-57176-1-git-send-email-zhongjiang@huawei.com>  <alpine.DEB.2.10.1705021350510.116499@chino.kir.corp.google.com> <1493837167.20270.8.camel@redhat.com>
In-Reply-To: <1493837167.20270.8.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Andrew Morton <akpm@linux-foundation.org>, arnd@arndb.de, hannes@cmpxchg.org, kirill@shutemov.name, mgorman@techsingularity.net, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>

On 2017/5/4 2:46, Rik van Riel wrote:
> On Tue, 2017-05-02 at 13:54 -0700, David Rientjes wrote:
>
>>> diff --git a/drivers/char/mem.c b/drivers/char/mem.c
>>> index 7e4a9d1..3a765e02 100644
>>> --- a/drivers/char/mem.c
>>> +++ b/drivers/char/mem.c
>>> @@ -55,7 +55,7 @@ static inline int
>> valid_phys_addr_range(phys_addr_t addr, size_t count)
>>>   
>>>   static inline int valid_mmap_phys_addr_range(unsigned long pfn,
>> size_t size)
>>>   {
>>> -     return 1;
>>> +     return (pfn << PAGE_SHIFT) + size <= __pa(high_memory);
>>>   }
>>>   #endif
>>>   
>> I suppose you are correct that there should be some sanity checking
>> on the 
>> size used for the mmap().
> My apologies for not responding earlier. It may
> indeed make sense to have a sanity check here.
>
> However, it is not as easy as simply checking the
> end against __pa(high_memory). Some systems have
> non-contiguous physical memory ranges, with gaps
> of invalid addresses in-between.
 The invalid physical address means that it is used as
 io mapped. not in system ram region. /dev/mem is not
 access to them , is it right?
> You would have to make sure that both the beginning
> and the end are valid, and that there are no gaps of
> invalid pfns in the middle...
 If it is limited in system ram, we can walk the resource
 to exclude them. or adding pfn_valid further to optimize.
 whether other situation should be consider ? I am not sure.
> At that point, is the complexity so much that it no
> longer makes sense to try to protect against root
> crashing the system?
>
 your suggestion is to let the issue along without any protection.
 just root user know what they are doing.
 
 Thanks
 zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
