Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 87E936B0333
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 21:15:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r89so1307473pfi.1
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 18:15:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p19si574367pgj.167.2017.03.23.18.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 18:15:56 -0700 (PDT)
Subject: Re: [v1 0/5] parallelized "struct page" zeroing
References: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
 <20170323232638.GB29134@bombadil.infradead.org>
 <20170323.163520.123614131649571916.davem@davemloft.net>
 <c399ad8b-32d8-09d7-bb47-dd6bc528b133@oracle.com>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <9726f05e-7752-0214-1661-f69a689d8d46@oracle.com>
Date: Thu, 23 Mar 2017 21:15:19 -0400
MIME-Version: 1.0
In-Reply-To: <c399ad8b-32d8-09d7-bb47-dd6bc528b133@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, willy@infradead.org
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.or


On 03/23/2017 07:47 PM, Pasha Tatashin wrote:
>>>
>>> How long does it take if we just don't zero this memory at all?  We seem
>>> to be initialising most of struct page in __init_single_page(), so it
>>> seems like a lot of additional complexity to conditionally zero the rest
>>> of struct page.
>>
>> Alternatively, just zero out the entire vmemmap area when it is setup
>> in the kernel page tables.
>
> Hi Dave,
>
> I can do this, either way is fine with me. It would be a little slower
> compared to the current approach where we benefit from having memset()
> to work as prefetch. But that would become negligible, once in the
> future we will increase the granularity of multi-threading, currently it
> is only one thread per-mnode to multithread vmemamp. Your call.
>
> Thank  you,
> Pasha

Hi Dave and Matthew,

I've been thinking about it some more, and figured that the current 
approach is better:

1. Most importantly: Part of the vmemmap is initialized early during 
boot to support Linux to get to the multi-CPU environment. This means 
that we would need to figure out what part of vmemmap will need to be 
zeroed before hand in single thread, than zero the rest in multi-thread. 
This will be very awkward architecturally and error prone.

2. As I already showed, the current approach is significantly faster. 
So, perhaps it should be the default behavior even for non-deferred 
"struct page" initialization: unconditionally do not zero vmemmap in 
memblock allocator, and always zero in __init_single_page(). But, I am 
afraid it could cause boot time regressions on some platforms where 
memset() is not optimized, so I would not do it in this patchset. But, 
hopefully, gradually more platforms will support deferred struct page 
initialization, and this would become the default behavior.

3. By zeroing "struct page" in  __init_single_page(), we set every byte 
of "struct page" in one place instead of scattering it across different 
places. So, it could help in the future when we will multi-thread 
addition of hotplugged memory.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
