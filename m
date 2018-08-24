Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B19506B304F
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 11:24:33 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d132-v6so5764201pgc.22
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 08:24:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v37-v6sor2430627plg.17.2018.08.24.08.24.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 08:24:32 -0700 (PDT)
Date: Fri, 24 Aug 2018 23:24:24 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/3] mm/sparse: expand the CONFIG_SPARSEMEM_EXTREME range
 in __nr_to_section()
Message-ID: <20180824152424.GB10093@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180823130732.9489-1-richard.weiyang@gmail.com>
 <20180823130732.9489-3-richard.weiyang@gmail.com>
 <20180823132112.GK29735@dhcp22.suse.cz>
 <ebdfe4aa-225c-8239-9f8d-065de8a5ddfc@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ebdfe4aa-225c-8239-9f8d-065de8a5ddfc@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, bob.picco@hp.com

On Thu, Aug 23, 2018 at 05:09:12PM -0700, Dave Hansen wrote:
>On 08/23/2018 06:21 AM, Michal Hocko wrote:
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -1155,9 +1155,9 @@ static inline struct mem_section *__nr_to_section(unsigned long nr)
>>  #ifdef CONFIG_SPARSEMEM_EXTREME
>>  	if (!mem_section)
>>  		return NULL;
>> -#endif
>>  	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
>>  		return NULL;
>> +#endif
>>  	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
>>  }
>
>This patch has no practical effect and only adds unnecessary churn.
>
>#ifdef CONFIG_SPARSEMEM_EXTREME
>...
>#else
>struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
>#endif
>
>The compiler knows that NR_SECTION_ROOTS==1 and that
>!mem_section[SECTION_NR_TO_ROOT(nr) is always false.  It doesn't need
>our help.
>

I didn't know the compile would optimize the code when this is a one dimension
array. Just wrote a code and their assembly looks the same.

Thanks for pointing out.

>My goal with the sparsemem code, and code in general is t avoid #ifdefs
>whenever possible and limit their scope to the smallest possible area
>whenever possible.

-- 
Wei Yang
Help you, Help me
