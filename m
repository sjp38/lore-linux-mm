Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 124226B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 08:40:52 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k123so9672355qke.5
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 05:40:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y32si4437611qtd.554.2017.10.04.05.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Oct 2017 05:40:51 -0700 (PDT)
Subject: Re: [PATCH v9 08/12] mm: zero reserved and unavailable struct pages
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-9-pasha.tatashin@oracle.com>
 <20171003131817.omzbam3js67edp3s@dhcp22.suse.cz>
 <691dba28-718c-e9a9-d006-88505eb5cd7e@oracle.com>
 <20171004085636.w2rnwf5xxhahzuy7@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <9198a33d-cd40-dd70-4823-7f70c57ef9a2@oracle.com>
Date: Wed, 4 Oct 2017 08:40:11 -0400
MIME-Version: 1.0
In-Reply-To: <20171004085636.w2rnwf5xxhahzuy7@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

>>> Could you be more specific where is such a memory reserved?
>>>
>>
>> I know of one example: trim_low_memory_range() unconditionally reserves from
>> pfn 0, but e820__memblock_setup() might provide the exiting memory from pfn
>> 1 (i.e. KVM).
> 
> Then just initialize struct pages for that mapping rigth there where a
> special API is used.
> 
>> But, there could be more based on this comment from linux/page-flags.h:
>>
>>   19  * PG_reserved is set for special pages, which can never be swapped out.
>> Some
>>   20  * of them might not even exist (eg empty_bad_page)...
> 
> I have no idea wht empty_bad_page is but a quick grep shows that this is
> never used. I might be wrong here but if somebody is reserving a memory
> in a special way then we should handle the initialization right there.
> E.g. create an API for special memblock reservations.
> 

Hi Michal,

The reservations happen before struct pages are allocated and mapped. 
So, it is not always possible to do it at call sites.

Previously, I have solved this problem like this:

https://patchwork.kernel.org/patch/9886163

But, I was not too happy with that approach, so I replaced it with the 
current approach as it is more generic, and solves similar issues if 
they happen in other places. Also, the comment in page-flags got me 
scared that there are probably other places perhaps on other 
architectures that can have the similar issue.

In addition, I did not like my solution, I was simply shrinking the low 
reservation from:
[0 - reserve_low) to [min_pfn - reserve_low), but if min_pfn > 
reserve_low can we skip low reservation entirely? I was not sure.

The current approach notifies us if there are such pages, and we can 
fix/remove them in the future without crashing kernel in the meantime.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
