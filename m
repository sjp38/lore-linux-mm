Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B22EA6B02A4
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 01:51:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so24148472pfx.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 22:51:48 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x126si43408755pfb.249.2016.08.29.22.51.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 22:51:47 -0700 (PDT)
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
 <20160829155021.2a85910c3d6b16a7f75ffccd@linux-foundation.org>
 <36b76a95-5025-ac64-0862-b98b2ebdeaf7@intel.com>
 <20160829203916.6a2b45845e8fb0c356cac17d@linux-foundation.org>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <c628f0ed-b5e9-0dd8-8708-9f575f9c17e3@intel.com>
Date: Tue, 30 Aug 2016 13:51:37 +0800
MIME-Version: 1.0
In-Reply-To: <20160829203916.6a2b45845e8fb0c356cac17d@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On 08/30/2016 11:39 AM, Andrew Morton wrote:
> On Tue, 30 Aug 2016 11:09:15 +0800 Aaron Lu <aaron.lu@intel.com> wrote:
> 
>>>> Case used for test on Haswell EP:
>>>> usemem -n 72 --readonly -j 0x200000 100G
>>>> Which spawns 72 processes and each will mmap 100G anonymous space and
>>>> then do read only access to that space sequentially with a step of 2MB.
>>>>
>>>> perf report for base commit:
>>>>     54.03%  usemem   [kernel.kallsyms]   [k] get_huge_zero_page
>>>> perf report for this commit:
>>>>      0.11%  usemem   [kernel.kallsyms]   [k] mm_get_huge_zero_page
>>>
>>> Does this mean that overall usemem runtime halved?
>>
>> Sorry for the confusion, the above line is extracted from perf report.
>> It shows the percent of CPU cycles executed in a specific function.
>>
>> The above two perf lines are used to show get_huge_zero_page doesn't
>> consume that much CPU cycles after applying the patch.
>>
>>>
>>> Do we have any numbers for something which is more real-wordly?
>>
>> Unfortunately, no real world numbers.
>>
>> We think the global atomic counter could be an issue for performance
>> so I'm trying to solve the problem.
> 
> So, umm, we don't actually know if the patch is useful to anyone?

It should help when multiple processes are doing read only anonymous
page faults with THP enabled.

> 
> Some more measurements would help things along, please.
 
In addition to the perf cycles drop in the get_huge_zero_page function,
the throughput for the above workload also increased a lot.

usemem -n 72 --readonly -j 0x200000 100G

base commit
$ cat 7289420fc8e98999c8b7c1c2c888549ccc9aa96f/0/vm-scalability.json 
{
  "vm-scalability.throughput": [
    1784430792
  ],
}

this patch
$ cat a57acb91d1a29efc4cf34ffee09e1cebe93dcd24/0/vm-scalability.json 
{
  "vm-scalability.throughput": [
    4726928591
  ],
}

Throughput wise, it's a 164% gain.
Runtime wise, it's reduced from 707592 usecs to 303970 usecs, 50%+ drop.

Granted, real world use case may not encounter such an extreme case so
the gain would be much smaller.

Thanks,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
