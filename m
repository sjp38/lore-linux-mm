Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D1BA76B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 12:01:56 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w63so9274484qkd.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 09:01:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id j184si6876897qkc.92.2017.10.03.09.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 09:01:55 -0700 (PDT)
Subject: Re: [PATCH v9 03/12] mm: deferred_init_memmap improvements
From: Pasha Tatashin <pasha.tatashin@oracle.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-4-pasha.tatashin@oracle.com>
 <20171003125754.2kuqzkstywg7axhd@dhcp22.suse.cz>
 <fc4ef789-d9a8-5dab-6508-f0fe8751b462@oracle.com>
Message-ID: <d81baa49-b796-7130-4ace-0f14ed59be46@oracle.com>
Date: Tue, 3 Oct 2017 12:01:08 -0400
MIME-Version: 1.0
In-Reply-To: <fc4ef789-d9a8-5dab-6508-f0fe8751b462@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Michal,

Are you OK, if I replace DEFERRED_FREE() macro with a function like this:

/*
  * Helper for deferred_init_range, free the given range, and reset the
  * counters
  */
static inline unsigned long __def_free(unsigned long *nr_free,
                                        unsigned long *free_base_pfn,
                                        struct page **page)
{
         unsigned long nr = *nr_free;

         deferred_free_range(*free_base_pfn, nr);
         *free_base_pfn = 0;
         *nr_free = 0;
         *page = NULL;

         return nr;
}

Since it is inline, and we operate with non-volatile counters, compiler 
will be smart enough to remove all the unnecessary de-references. As a 
plus, we won't be adding any new branches, and the code is still going 
to stay compact.

Pasha

On 10/03/2017 11:15 AM, Pasha Tatashin wrote:
> Hi Michal,
> 
>>
>> Please be explicit that this is possible only because we discard
>> memblock data later after 3010f876500f ("mm: discard memblock data
>> later"). Also be more explicit how the new code works.
> 
> OK
> 
>>
>> I like how the resulting code is more compact and smaller.
> 
> That was the goal :)
> 
>> for_each_free_mem_range also looks more appropriate but I really detest
>> the DEFERRED_FREE thingy. Maybe we can handle all that in a single goto
>> section. I know this is not an art but manipulating variables from
>> macros is more error prone and much more ugly IMHO.
> 
> Sure, I can re-arrange to have a goto place. Function won't be as small, 
> and if compiler is not smart enough we might end up with having more 
> branches than what my current code has.
> 
>>
>> please do not use macros. Btw. this deserves its own fix. I suspect that
>> no CONFIG_HOLES_IN_ZONE arch enables DEFERRED_STRUCT_PAGE_INIT but
>> purely from the review point of view it should be its own patch.
> 
> Sure, I will submit this patch separately from the rest of the project. 
> In my opinion DEFERRED_STRUCT_PAGE_INIT is the way of the future, so we 
> should make sure it is working with as many configs as possible.
> 
> Thank you,
> Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
