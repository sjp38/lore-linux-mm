Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0AAE66B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 14:28:49 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x17so32430209pgi.3
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:28:49 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id p1si15885162pga.393.2017.02.27.11.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 11:28:48 -0800 (PST)
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH] mm,x86: fix SMP x86 32bit build for native_pud_clear()
Date: Mon, 27 Feb 2017 14:29:36 -0500
Message-Id: <1488223776-10326-1-git-send-email-boris.ostrovsky@oracle.com>
In-Reply-To: <078cfd81-12d4-285e-d80d-7afd0f2e7e6d@redhat.com>
References: <078cfd81-12d4-285e-d80d-7afd0f2e7e6d@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: labbott@redhat.com
Cc: dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>

> On 02/15/2017 12:31 PM, Dave Jiang wrote:
>> The fix introduced by e4decc90 to fix the UP case for 32bit x86, however
>> that broke the SMP case that was working previously. Add ifdef so the dummy
>> function only show up for 32bit UP case only.
>> 
>> Fix: e4decc90 mm,x86: native_pud_clear missing on i386 build
>> 
>> Reported-by: Alexander Kapshuk <alexander.kapshuk@gmail.com>
>> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
>> ---
>>  arch/x86/include/asm/pgtable-3level.h |    2 ++
>>  1 file changed, 2 insertions(+)
>> 
>> diff --git a/arch/x86/include/asm/pgtable-3level.h b/arch/x86/include/asm/pgtable-3level.h
>> index 50d35e3..8f50fb3 100644
>> --- a/arch/x86/include/asm/pgtable-3level.h
>> +++ b/arch/x86/include/asm/pgtable-3level.h
>> @@ -121,9 +121,11 @@ static inline void native_pmd_clear(pmd_t *pmd)
>>  	*(tmp + 1) = 0;
>>  }
>>  
>> +#ifndef CONFIG_SMP
>>  static inline void native_pud_clear(pud_t *pudp)
>>  {
>>  }
>> +#endif
>>  
>>  static inline void pud_clear(pud_t *pudp)
>>  {
>> 

> 
> This breaks one of the Fedora configurations as of 
> e5d56efc97f8240d0b5d66c03949382b6d7e5570
> 
> In file included from ./include/linux/mm.h:68:0,
>                  from ./include/linux/highmem.h:7,
>                  from ./include/linux/bio.h:21,
>                  from ./include/linux/writeback.h:205,
>                  from ./include/linux/memcontrol.h:30,
>                  from ./include/linux/swap.h:8,
>                  from ./include/linux/suspend.h:4,
>                  from arch/x86/kernel/asm-offsets.c:12:
> ./arch/x86/include/asm/pgtable.h: In function 'native_local_pudp_get_and_clear':
> ./arch/x86/include/asm/pgtable.h:888:2: error: implicit declaration of function 'native_pud_clear';did you mean 'native_pmd_clear'? [-Werror=implicit-function-declaration]
>   native_pud_clear(pudp);
>   ^~~~~~~~~~~~~~~~
> 
> Kernel configuration attached. I'm probably just going to revert
> this part unless someone sends me a better fix.


This breakage happens when CONFIG_HIGHMEM64G (i.e. CONFIG_X86_PAE) and CONFIG_PARAVIRT.

-boris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
