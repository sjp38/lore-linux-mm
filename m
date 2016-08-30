Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E8AD28308C
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 01:54:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so23664911pfd.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 22:54:31 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z3si43384589pav.257.2016.08.29.22.54.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 22:54:31 -0700 (PDT)
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
 <20160829155021.2a85910c3d6b16a7f75ffccd@linux-foundation.org>
 <36b76a95-5025-ac64-0862-b98b2ebdeaf7@intel.com>
 <20160829203916.6a2b45845e8fb0c356cac17d@linux-foundation.org>
 <57C50F29.4070309@linux.vnet.ibm.com>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <0342377a-26b8-16b9-5817-1964fac0e12d@intel.com>
Date: Tue, 30 Aug 2016 13:54:27 +0800
MIME-Version: 1.0
In-Reply-To: <57C50F29.4070309@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On 08/30/2016 12:44 PM, Anshuman Khandual wrote:
> On 08/30/2016 09:09 AM, Andrew Morton wrote:
>> On Tue, 30 Aug 2016 11:09:15 +0800 Aaron Lu <aaron.lu@intel.com> wrote:
>>
>>>>> Case used for test on Haswell EP:
>>>>> usemem -n 72 --readonly -j 0x200000 100G
>>>>> Which spawns 72 processes and each will mmap 100G anonymous space and
>>>>> then do read only access to that space sequentially with a step of 2MB.
>>>>>
>>>>> perf report for base commit:
>>>>>     54.03%  usemem   [kernel.kallsyms]   [k] get_huge_zero_page
>>>>> perf report for this commit:
>>>>>      0.11%  usemem   [kernel.kallsyms]   [k] mm_get_huge_zero_page
>>>>
>>>> Does this mean that overall usemem runtime halved?
>>>
>>> Sorry for the confusion, the above line is extracted from perf report.
>>> It shows the percent of CPU cycles executed in a specific function.
>>>
>>> The above two perf lines are used to show get_huge_zero_page doesn't
>>> consume that much CPU cycles after applying the patch.
>>>
>>>>
>>>> Do we have any numbers for something which is more real-wordly?
>>>
>>> Unfortunately, no real world numbers.
>>>
>>> We think the global atomic counter could be an issue for performance
>>> so I'm trying to solve the problem.
>>
>> So, umm, we don't actually know if the patch is useful to anyone?
> 
> On a POWER system it improves the CPU consumption of the above mentioned
> function a little bit. Dont think its going to improve actual throughput
> of the workload substantially.
> 
> 0.07%  usemem  [kernel.vmlinux]  [k] mm_get_huge_zero_page

I guess this is the base commit? But there shouldn't be the new
mm_get_huge_zero_page symbol before this patch. A typo perhaps?

Regards,
Aaron

> to
> 
> 0.01%  usemem  [kernel.vmlinux]  [k] mm_get_huge_zero_page
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
