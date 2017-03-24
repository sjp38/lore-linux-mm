Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 374476B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 02:48:41 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c23so11557044pfj.0
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 23:48:41 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id v198si1475777pgb.216.2017.03.23.23.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 23:48:40 -0700 (PDT)
Subject: Re: [PATCH -v2 1/2] mm, swap: Use kvzalloc to allocate some swap data
 structure
References: <20170320084732.3375-1-ying.huang@intel.com>
 <alpine.DEB.2.10.1703201430550.24991@chino.kir.corp.google.com>
 <8737e3z992.fsf@yhuang-dev.intel.com>
 <f17cb7e4-4d47-4aed-6fdb-cda5c5d47fa4@nvidia.com>
 <87poh7xoms.fsf@yhuang-dev.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2d55e06d-a0b6-771a-bba0-f9517d422789@nvidia.com>
Date: Thu, 23 Mar 2017 23:48:35 -0700
MIME-Version: 1.0
In-Reply-To: <87poh7xoms.fsf@yhuang-dev.intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Aaron Lu <aaron.lu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill
 A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/23/2017 09:52 PM, Huang, Ying wrote:
> John Hubbard <jhubbard@nvidia.com> writes:
>
>> On 03/23/2017 07:41 PM, Huang, Ying wrote:
>>> David Rientjes <rientjes@google.com> writes:
>>>
>>>> On Mon, 20 Mar 2017, Huang, Ying wrote:
>>>>
>>>>> From: Huang Ying <ying.huang@intel.com>
>>>>>
>>>>> Now vzalloc() is used in swap code to allocate various data
>>>>> structures, such as swap cache, swap slots cache, cluster info, etc.
>>>>> Because the size may be too large on some system, so that normal
>>>>> kzalloc() may fail.  But using kzalloc() has some advantages, for
>>>>> example, less memory fragmentation, less TLB pressure, etc.  So change
>>>>> the data structure allocation in swap code to use kvzalloc() which
>>>>> will try kzalloc() firstly, and fallback to vzalloc() if kzalloc()
>>>>> failed.
>>>>>
>>>>
>>>> As questioned in -v1 of this patch, what is the benefit of directly
>>>> compacting and reclaiming memory for high-order pages by first preferring
>>>> kmalloc() if this does not require contiguous memory?
>>>
>>> The memory allocation here is only for swap on time, not for swap out/in
>>> time.  The performance of swap on is not considered critical.  But if
>>> the kmalloc() is used instead of the vmalloc(), the swap out/in
>>> performance could be improved (marginally).  More importantly, the
>>> interference for the other activity on the system could be reduced, For
>>> example, less memory fragmentation, less TLB usage of swap subsystem,
>>> etc.
>>
>> Hi Ying,
>>
>> I'm a little surprised to see vmalloc calls replaced with
>> kmalloc-then-vmalloc calls, because that actually makes fragmentation
>> worse (contrary to the above claim). That's because you will consume
>> contiguous memory (even though you don't need it to be contiguous),
>> whereas before, you would have been able to get by with page-at-a-time
>> for vmalloc.
>>
>> So, things like THP will find fewer contiguous chunks, as a result of patches such as this.
>
> Hi, John,
>
> I don't think so.  The pages allocated by vmalloc() cannot be moved
> during de-fragment.  For example, if 512 dis-continuous physical pages
> are allocated via vmalloc(), at worst, one page will be allocate from
> one distinct 2MB continous physical pages.  This makes 512 * 2MB = 1GB
> memory cannot be used for THP allocation.  Because these pages cannot be
> defragmented until vfree().

kmalloc requires a resource that vmalloc does not: contiguous pages. Therefore, 
given the same mix of pages (some groups of contiguous pages, and a scattering of 
isolated single-page, or too-small-to-satisfy-entire-alloc groups of pages, and the 
same underlying page allocator, kmalloc *must* consume the more valuable contiguous 
pages. However, vmalloc *may* consume those same pages.

So, if you run kmalloc a bunch of times, with higher-order requests, you *will* run 
out of contiguous pages (until more are freed up). If you run vmalloc with the same 
initial conditions and the same requests, you may not necessary use up those 
contiguous pages.

It's true that there are benefits to doing a kmalloc-then-vmalloc, of course: if the 
pages are available, it's faster and uses less resources. Yes. I just don't think 
"less fragmentation" should be listed as a benefit, because you can definitely cause 
*more* fragmentation if you use up contiguous blocks unnecessarily.

--
thanks,
john h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
