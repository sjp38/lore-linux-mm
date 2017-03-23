Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 814906B0333
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 19:37:24 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 187so2100477itk.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 16:37:24 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l128si459755iof.235.2017.03.23.16.37.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 16:37:23 -0700 (PDT)
Subject: Re: [v1 0/5] parallelized "struct page" zeroing
References: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
 <20170323232638.GB29134@bombadil.infradead.org>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <6c6b6203-4ffe-6c7b-974a-b73533881674@oracle.com>
Date: Thu, 23 Mar 2017 19:36:44 -0400
MIME-Version: 1.0
In-Reply-To: <20170323232638.GB29134@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.or

Hi Matthew,

Thank you for your comment. If you look at the data, having memset() 
actually benefits initializing data.

With base it takes:
[   66.148867] node 0 initialised, 128312523 pages in 7200ms

With fix:
[   15.260634] node 0 initialised, 128312523 pages in 4190ms

So 4.19s vs 7.2s for the same number of "struct page". This is because 
memset() actually brings "struct page" into cache with efficient  block 
initializing store instruction. I have not tested if there is the same 
effect on Intel.

Pasha

On 03/23/2017 07:26 PM, Matthew Wilcox wrote:
> On Thu, Mar 23, 2017 at 07:01:48PM -0400, Pavel Tatashin wrote:
>> When deferred struct page initialization feature is enabled, we get a
>> performance gain of initializing vmemmap in parallel after other CPUs are
>> started. However, we still zero the memory for vmemmap using one boot CPU.
>> This patch-set fixes the memset-zeroing limitation by deferring it as well.
>>
>> Here is example performance gain on SPARC with 32T:
>> base
>> https://hastebin.com/ozanelatat.go
>>
>> fix
>> https://hastebin.com/utonawukof.go
>>
>> As you can see without the fix it takes: 97.89s to boot
>> With the fix it takes: 46.91 to boot.
>
> How long does it take if we just don't zero this memory at all?  We seem
> to be initialising most of struct page in __init_single_page(), so it
> seems like a lot of additional complexity to conditionally zero the rest
> of struct page.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
