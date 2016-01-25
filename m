Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 81A1A6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:10:22 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id n5so73957960wmn.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 03:10:22 -0800 (PST)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id 65si23796468wmg.21.2016.01.25.03.10.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 03:10:21 -0800 (PST)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 25 Jan 2016 11:10:20 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 814022190023
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:10:04 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0PBAG5O6357454
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:10:17 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0PAAITJ001244
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 03:10:18 -0700
Subject: Re: [PATCH] mm/debug_pagealloc: Ask users for default setting of
 debug_pagealloc
References: <1453713588-119602-1-git-send-email-borntraeger@de.ibm.com>
 <20160125094132.GA4298@osiris> <56A5EECE.90607@de.ibm.com>
 <20160125100248.GB4298@osiris> <56A5F3C8.4050202@de.ibm.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56A60297.4050501@de.ibm.com>
Date: Mon, 25 Jan 2016 12:10:15 +0100
MIME-Version: 1.0
In-Reply-To: <56A5F3C8.4050202@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On 01/25/2016 11:07 AM, Christian Borntraeger wrote:
> On 01/25/2016 11:02 AM, Heiko Carstens wrote:
>> On Mon, Jan 25, 2016 at 10:45:50AM +0100, Christian Borntraeger wrote:
>>>>> +	  By default this option will be almost for free and can be activated
>>>>> +	  in distribution kernels. The overhead and the debugging can be enabled
>>>>> +	  by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc command line
>>>>> +	  parameter.
>>>>
>>>> Sorry, but it's not almost for free and should not be used by distribution
>>>> kernels. If we have DEBUG_PAGEALLOC enabled, at least on s390 we will not
>>>> make use of 2GB and 1MB pagetable entries for the identy mapping anymore.
>>>> Instead we will only use 4K mappings.
>>>
>>> Hmmm, can we change these code areas to use debug_pagealloc_enabled? I guess
>>> this evaluated too late?
>>
>> Yes, that should be possible. "debug_pagealloc" is an early_param, which
>> will be evaluated before we call paging_init() (both in
>> arch/s390/kernel/setup.c).
>>
>> So it looks like this can be trivially changed. (replace the ifdefs in
>> arch/s390/mm/vmem.c with debug_pagealloc_enabled()).
>>
>>>> I assume this is true for all architectures since freeing pages can happen
>>>> in any context and therefore we can't allocate memory in order to split
>>>> page tables.
>>>>
>>>> So enabling this will cost memory and put more pressure on the TLB.
>>>
>>> So I will change the description and drop the "if unsure" statement.
>>
>> Well, given that we can change it like above... I don't care anymore ;)
> 
> Ok, I will give it a try, and come back with a rewording or an s390 patch.

I have a patch for x86 and s390. powerpc should also be possible.

Now it seems that sparc already defines the TSB very early in head.S. 
Unless we find a solution for sparc to use debug_pagealloc_enabled()
I will modify the patch description and resend the patch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
