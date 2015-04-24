Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 97CD86B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:35:57 -0400 (EDT)
Received: by oblw8 with SMTP id w8so39136071obl.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:35:57 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id h139si8409763oib.70.2015.04.24.07.35.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 07:35:56 -0700 (PDT)
Message-ID: <553A54C5.3060106@hp.com>
Date: Fri, 24 Apr 2015 10:35:49 -0400
From: Waiman Long <waiman.long@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/13] x86: mm: Enable deferred struct page initialisation
 on x86-64
References: <1429722473-28118-1-git-send-email-mgorman@suse.de> <1429722473-28118-11-git-send-email-mgorman@suse.de> <20150422164500.121a355e6b578243cb3650e3@linux-foundation.org> <20150423092327.GJ14842@suse.de>
In-Reply-To: <20150423092327.GJ14842@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On 04/23/2015 05:23 AM, Mel Gorman wrote:
> On Wed, Apr 22, 2015 at 04:45:00PM -0700, Andrew Morton wrote:
>> On Wed, 22 Apr 2015 18:07:50 +0100 Mel Gorman<mgorman@suse.de>  wrote:
>>
>>> --- a/arch/x86/Kconfig
>>> +++ b/arch/x86/Kconfig
>>> @@ -32,6 +32,7 @@ config X86
>>>   	select HAVE_UNSTABLE_SCHED_CLOCK
>>>   	select ARCH_SUPPORTS_NUMA_BALANCING if X86_64
>>>   	select ARCH_SUPPORTS_INT128 if X86_64
>>> +	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT if X86_64&&  NUMA
>> Put this in the "config X86_64" section and skip the "X86_64&&"?
>>
> Done.
>
>> Can we omit the whole defer_meminit= thing and permanently enable the
>> feature?  That's simpler, provides better test coverage and is, we
>> hope, faster.
>>
> Yes. The intent was to have a workaround if there were any failures like
> Waiman's vmalloc failures in an earlier version but they are bugs that
> should be fixed.
>
>> And can this be used on non-NUMA?  Presumably that won't speed things
>> up any if we're bandwidth limited but again it's simpler and provides
>> better coverage.
> Nothing prevents it. There is less opportunity for parallelism but
> improving coverage is desirable.
>

Memory access latency can be more than double for local vs. remote node 
memory. Bandwidth can also be much lower depending on what kind of 
interconnect is between the 2 nodes. So it is better to do it in a 
NUMA-aware way. Within a NUMA node, however, we can split the memory 
initialization to 2 or more local CPUs if the memory size is big enough.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
