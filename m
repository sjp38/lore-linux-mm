Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86BD36B0333
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 19:47:55 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 20so13489899iod.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 16:47:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c13si189603iti.88.2017.03.23.16.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 16:47:54 -0700 (PDT)
Subject: Re: [v1 0/5] parallelized "struct page" zeroing
References: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
 <20170323232638.GB29134@bombadil.infradead.org>
 <20170323.163520.123614131649571916.davem@davemloft.net>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <c399ad8b-32d8-09d7-bb47-dd6bc528b133@oracle.com>
Date: Thu, 23 Mar 2017 19:47:23 -0400
MIME-Version: 1.0
In-Reply-To: <20170323.163520.123614131649571916.davem@davemloft.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>, willy@infradead.org
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.or



On 03/23/2017 07:35 PM, David Miller wrote:
> From: Matthew Wilcox <willy@infradead.org>
> Date: Thu, 23 Mar 2017 16:26:38 -0700
>
>> On Thu, Mar 23, 2017 at 07:01:48PM -0400, Pavel Tatashin wrote:
>>> When deferred struct page initialization feature is enabled, we get a
>>> performance gain of initializing vmemmap in parallel after other CPUs are
>>> started. However, we still zero the memory for vmemmap using one boot CPU.
>>> This patch-set fixes the memset-zeroing limitation by deferring it as well.
>>>
>>> Here is example performance gain on SPARC with 32T:
>>> base
>>> https://hastebin.com/ozanelatat.go
>>>
>>> fix
>>> https://hastebin.com/utonawukof.go
>>>
>>> As you can see without the fix it takes: 97.89s to boot
>>> With the fix it takes: 46.91 to boot.
>>
>> How long does it take if we just don't zero this memory at all?  We seem
>> to be initialising most of struct page in __init_single_page(), so it
>> seems like a lot of additional complexity to conditionally zero the rest
>> of struct page.
>
> Alternatively, just zero out the entire vmemmap area when it is setup
> in the kernel page tables.

Hi Dave,

I can do this, either way is fine with me. It would be a little slower 
compared to the current approach where we benefit from having memset() 
to work as prefetch. But that would become negligible, once in the 
future we will increase the granularity of multi-threading, currently it 
is only one thread per-mnode to multithread vmemamp. Your call.

Thank  you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
