Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5881E6B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 21:49:57 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id k190so7209845pgk.8
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:49:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a2si617323pgd.191.2017.07.17.18.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 18:49:56 -0700 (PDT)
Subject: Re: [RFC PATCH v1 5/6] mm: parallelize clear_gigantic_page
References: <1500070573-3948-1-git-send-email-daniel.m.jordan@oracle.com>
 <1500070573-3948-6-git-send-email-daniel.m.jordan@oracle.com>
 <398e9887-6d6e-e1d3-abcf-43a6d7496bc8@intel.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <c73eabca-4c8c-8fb1-36c7-1f887f56689a@oracle.com>
Date: Mon, 17 Jul 2017 21:49:51 -0400
MIME-Version: 1.0
In-Reply-To: <398e9887-6d6e-e1d3-abcf-43a6d7496bc8@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/17/2017 12:02 PM, Dave Hansen wrote:
> On 07/14/2017 03:16 PM, daniel.m.jordan@oracle.com wrote:
>> Machine:  Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz, 288 cpus, 1T memory
>> Test:    Clear a range of gigantic pages
>> nthread   speedup   size (GiB)   min time (s)   stdev
>>        1                    100          41.13    0.03
>>        2     2.03x          100          20.26    0.14
>>        4     4.28x          100           9.62    0.09
>>        8     8.39x          100           4.90    0.05
>>       16    10.44x          100           3.94    0.03
> ...
>>        1                    800         434.91    1.81
>>        2     2.54x          800         170.97    1.46
>>        4     4.98x          800          87.38    1.91
>>        8    10.15x          800          42.86    2.59
>>       16    12.99x          800          33.48    0.83
> What was the actual test here?  Did you just use sysfs to allocate 800GB
> of 1GB huge pages?

I used fallocate(1) on a hugetlbfs, so this test is similar to the 6th 
patch in the series, but here we parallelize only the page clearing 
function since gigantic pages are large enough to benefit from multiple 
threads, whereas we parallelize at the level of hugetlbfs_fallocate in 
patch 6 for smaller page sizes (e.g. 2M on x86).

> This test should be entirely memory-bandwidth-limited, right?

That's right, the page clearing function dominates the test, so it's 
memory-bandwidth-limited.

> Are you
> contending here that a single core can only use 1/10th of the memory
> bandwidth when clearing a page?

Yes, this is the biggest factor here.  More threads can use more memory 
bandwidth.

And yes, in the page clearing loop exercised in the test, a single 
thread can use only a fraction of the chip's theoretical memory 
bandwidth.  This is the page clearing loop I'm stressing:

ENTRY(clear_page_erms)
movl $4096,%ecx
xorl %eax,%eax
rep stosb
ret

On my test machine, it tops out at around 2550 MiB/s with 1 thread, and 
I get that same rate for each of 2, 4, or 8 threads when running on the 
same chip (i.e. group of 18 cores for this machine).  It's only at 16 
threads on the same chip that it starts to drop, falling to something 
around 1420 MiB/s.

> Or, does all the gain here come because we are round-robin-allocating
> the pages across all 8 NUMA nodes' memory controllers and the speedup
> here is because we're not doing the clearing across the interconnect?

The default NUMA policy was used for all results shown, so there was no 
round-robin'ing at small sizes.  For example, in the 100 GiB case, all 
pages were allocated from the same node.  But when it gets up to 800 
GiB, obviously we're allocating from many nodes so that we get a sort of 
round-robin effect and NUMA starts to matter.  For instance, the 
1-thread case does better on 100 GiB with all local accesses than on 800 
GiB with mostly remote accesses.

ktask's ability to run NUMA-aware threads helps out here so that we're 
not clearing across the interconnect, which is why the speedups get 
better as the sizes get larger.

Thanks for your questions.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
