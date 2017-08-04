Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5432803E9
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 09:51:38 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p135so8884876qke.0
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 06:51:38 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p64si1622639qkf.274.2017.08.04.06.51.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 06:51:37 -0700 (PDT)
Subject: Re: [v5 09/15] sparc64: optimized struct page zeroing
References: <1501795433-982645-1-git-send-email-pasha.tatashin@oracle.com>
 <1501795433-982645-10-git-send-email-pasha.tatashin@oracle.com>
 <20170804053701.GA30068@ravnborg.org>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <4d98e852-15c0-1b66-a472-776ba1d51a6b@oracle.com>
Date: Fri, 4 Aug 2017 09:50:57 -0400
MIME-Version: 1.0
In-Reply-To: <20170804053701.GA30068@ravnborg.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org

Hi Sam,

Thank you for looking at this. I will update patch description, and as 
you suggested replace memset() via static assert in next iteration.

Pasha

On 08/04/2017 01:37 AM, Sam Ravnborg wrote:
> Hi Pavel.
> 
> On Thu, Aug 03, 2017 at 05:23:47PM -0400, Pavel Tatashin wrote:
>> Add an optimized mm_zero_struct_page(), so struct page's are zeroed without
>> calling memset(). We do eight regular stores, thus avoid cost of membar.
> 
> The commit message does no longer reflect the implementation,
> and should be updated.
> 
>>
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
>> Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>> Reviewed-by: Bob Picco <bob.picco@oracle.com>
>> ---
>>   arch/sparc/include/asm/pgtable_64.h | 32 ++++++++++++++++++++++++++++++++
>>   1 file changed, 32 insertions(+)
>>
>> diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
>> index 6fbd931f0570..be47537e84c5 100644
>> --- a/arch/sparc/include/asm/pgtable_64.h
>> +++ b/arch/sparc/include/asm/pgtable_64.h
>> @@ -230,6 +230,38 @@ extern unsigned long _PAGE_ALL_SZ_BITS;
>>   extern struct page *mem_map_zero;
>>   #define ZERO_PAGE(vaddr)	(mem_map_zero)
>>   
>> +/* This macro must be updated when the size of struct page grows above 80
>> + * or reduces below 64.
>> + * The idea that compiler optimizes out switch() statement, and only
>> + * leaves clrx instructions or memset() call.
>> + */
>> +#define	mm_zero_struct_page(pp) do {					\
>> +	unsigned long *_pp = (void *)(pp);				\
>> +									\
>> +	/* Check that struct page is 8-byte aligned */			\
>> +	BUILD_BUG_ON(sizeof(struct page) & 7);				\
> Would also be good to catch if sizeof > 80 so we do not silently
> migrate to the suboptimal version (silent at build time).
> Can you at build time catch if size is no any of: 64, 72, 80
> and simplify the below a little?
> 
> 	Sam
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
