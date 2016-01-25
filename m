Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 10D2F6B0254
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 04:46:02 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id b14so70325622wmb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 01:46:02 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id r2si27348391wjz.116.2016.01.25.01.46.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 01:46:01 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Mon, 25 Jan 2016 09:46:00 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 647452190066
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:45:39 +0000 (GMT)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0P9jpWs8061336
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:45:51 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0P9joJ9001518
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:45:51 -0700
Subject: Re: [PATCH] mm/debug_pagealloc: Ask users for default setting of
 debug_pagealloc
References: <1453713588-119602-1-git-send-email-borntraeger@de.ibm.com>
 <20160125094132.GA4298@osiris>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56A5EECE.90607@de.ibm.com>
Date: Mon, 25 Jan 2016 10:45:50 +0100
MIME-Version: 1.0
In-Reply-To: <20160125094132.GA4298@osiris>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 01/25/2016 10:41 AM, Heiko Carstens wrote:
> On Mon, Jan 25, 2016 at 10:19:48AM +0100, Christian Borntraeger wrote:
>> since commit 031bc5743f158 ("mm/debug-pagealloc: make debug-pagealloc
>> boottime configurable") CONFIG_DEBUG_PAGEALLOC is by default a no-op.
>>
>> This resulted in several unnoticed bugs, e.g.
>>
>> https://lkml.kernel.org/g/<569F5E29.3090107@de.ibm.com>
>> or
>> https://lkml.kernel.org/g/<56A20F30.4050705@de.ibm.com>
>>
>> as this behaviour change was not even documented in Kconfig.
>>
>> Let's provide a new Kconfig symbol that allows to change the default
>> back to enabled, e.g. for debug kernels. This also makes the change
>> obvious to kernel packagers.
>>
>> Let's also change the Kconfig description for CONFIG_DEBUG_PAGEALLOC,
>> to indicate that it is ok to enable this by default.
>>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
>> ---
>>  mm/Kconfig.debug | 17 +++++++++++++++++
>>  mm/page_alloc.c  |  6 +++++-
>>  2 files changed, 22 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
>> index 957d3da..4cf1212 100644
>> --- a/mm/Kconfig.debug
>> +++ b/mm/Kconfig.debug
>> @@ -26,5 +26,22 @@ config DEBUG_PAGEALLOC
>>  	  that would result in incorrect warnings of memory corruption after
>>  	  a resume because free pages are not saved to the suspend image.
>>
>> +	  By default this option will be almost for free and can be activated
>> +	  in distribution kernels. The overhead and the debugging can be enabled
>> +	  by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc command line
>> +	  parameter.
> 
> Sorry, but it's not almost for free and should not be used by distribution
> kernels. If we have DEBUG_PAGEALLOC enabled, at least on s390 we will not
> make use of 2GB and 1MB pagetable entries for the identy mapping anymore.
> Instead we will only use 4K mappings.

Hmmm, can we change these code areas to use debug_pagealloc_enabled? I guess
this evaluated too late?


> I assume this is true for all architectures since freeing pages can happen
> in any context and therefore we can't allocate memory in order to split
> page tables.
> 
> So enabling this will cost memory and put more pressure on the TLB.

So I will change the description and drop the "if unsure" statement.

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
