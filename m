Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECDE6B3040
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 11:07:27 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x19-v6so6358742pfh.15
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 08:07:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t23-v6sor2144945pgi.180.2018.08.24.08.07.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 08:07:25 -0700 (PDT)
Date: Fri, 24 Aug 2018 23:07:17 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/3] mm/sparse: add likely to mem_section[root] check in
 sparse_index_init()
Message-ID: <20180824150717.GA10093@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-2-richard.weiyang@gmail.com>
 <cc817bc8-bced-fb07-cb2d-c122463380a7@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cc817bc8-bced-fb07-cb2d-c122463380a7@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu, Aug 23, 2018 at 05:11:48PM -0700, Dave Hansen wrote:
>On 08/23/2018 06:07 AM, Wei Yang wrote:
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -78,7 +78,7 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>>  	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
>>  	struct mem_section *section;
>>  
>> -	if (mem_section[root])
>> +	if (likely(mem_section[root]))
>>  		return -EEXIST;
>
>We could add likely()/unlikely() to approximately a billion if()s around
>the kernel if we felt like it.  We don't because it's messy and it
>actually takes away choices from the compiler.
>
>Please don't send patches like this unless you have some *actual*
>analysis that shows the benefit of the patch.  Performance numbers are best.

Thanks all for your comments, Michal, Dave and Oscar.

Well, maybe I took it for granted, so let me put more words on this. To be
honest, my analysis maybe partially effective, so if the cost is higher than
the gain, please let me know.

Below is my analysis and test result for this patch.
------------------------------------------------------

During bootup, the call flow looks like this.

    sparse_memory_present_with_active_regions()
        memory_present()
            sparse_index_init()

sparse_memory_present_with_active_regions() iterates on pfn continuously for
the whole system RAM, which leads to sparse_index_init() will iterate
section_nr continuously. Usually, we don't expect many large holes, right?

Each time when mem_section[root] is null, SECTIONS_PER_ROOT number of
mem_section will be allocated. This means, for SECTIONS_PER_ROOT number of
check, only the first check is false. So the possibility to be false is 
(1 / SECTIONS_PER_ROOT).

SECTIONS_PER_ROOT is defined as (PAGE_SIZE / sizeof (struct mem_section)).

On my x86_64 machine, PAGE_SIZE is 4KB and mem_section is 16B.

    SECTIONS_PER_ROOT = 4K / 16 = 256.

So the check for mem_section[root] is (1 / 256) chance to be invalid and
(255 / 256) valid. In theory, this value seems to be a "likely" to me.

In practice, when the system RAM is multiple times of
((1 << SECTION_SIZE_BITS) * SECTIONS_PER_ROOT), the "likely" chance is
(255 / 256), otherwise the chance would be less. 

On my x86_64 machine, SECTION_SIZE_BITS is defined to 27.

    ((1 << SECTION_SIZE_BITS) * SECTIONS_PER_ROOT) = 32GB

          System RAM size       32G         16G        8G         4G
      Possibility          (255 / 256) (127 / 128) (63 / 64)  (31 / 32)

Generally, in my mind, if we iterate pfn continuously and there is no large
holes, the check on mem_section[root] is likely to be true.

At last, here is the test result on my 4G virtual machine. I added printk
before and after sparse_memory_present_with_active_regions() and tested three
times with/without "likely".

                without      with
     Elapsed   0.000252     0.000250   -0.8%

The benefit seems to be too small on a 4G virtual machine or even this is not
stable. Not sure we can see some visible effect on a 32G machine.


Well, above is all my analysis and test result. I did the optimization based
on my own experience and understanding. If this is not qualified, I am very
glad to hear from your statement, so that I would learn more from your
experience.

Thanks all for your comments again :-)
 

-- 
Wei Yang
Help you, Help me
