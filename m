Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 170886B0253
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 18:45:44 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id b202so256887984oii.3
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 15:45:44 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 31si8213517oty.58.2016.12.18.15.45.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 15:45:43 -0800 (PST)
Subject: Re: [RFC PATCH 02/14] sparc64: add new fields to mmu context for
 shared context support
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-3-git-send-email-mike.kravetz@oracle.com>
 <20161217073813.GB23567@ravnborg.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a38312fe-27ed-56c6-862e-8bb53b929f2b@oracle.com>
Date: Sun, 18 Dec 2016 15:45:31 -0800
MIME-Version: 1.0
In-Reply-To: <20161217073813.GB23567@ravnborg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S . Miller" <davem@davemloft.net>, Bob Picco <bob.picco@oracle.com>, Nitin Gupta <nitin.m.gupta@oracle.com>, Vijay Kumar <vijay.ac.kumar@oracle.com>, Julian Calaby <julian.calaby@gmail.com>, Adam Buchbinder <adam.buchbinder@gmail.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

On 12/16/2016 11:38 PM, Sam Ravnborg wrote:
> Hi Mike
> 
>> diff --git a/arch/sparc/include/asm/mmu_context_64.h b/arch/sparc/include/asm/mmu_context_64.h
>> index b84be67..d031799 100644
>> --- a/arch/sparc/include/asm/mmu_context_64.h
>> +++ b/arch/sparc/include/asm/mmu_context_64.h
>> @@ -35,15 +35,15 @@ void __tsb_context_switch(unsigned long pgd_pa,
>>  static inline void tsb_context_switch(struct mm_struct *mm)
>>  {
>>  	__tsb_context_switch(__pa(mm->pgd),
>> -			     &mm->context.tsb_block[0],
>> +			     &mm->context.tsb_block[MM_TSB_BASE],
>>  #if defined(CONFIG_HUGETLB_PAGE) || defined(CONFIG_TRANSPARENT_HUGEPAGE)
>> -			     (mm->context.tsb_block[1].tsb ?
>> -			      &mm->context.tsb_block[1] :
>> +			     (mm->context.tsb_block[MM_TSB_HUGE].tsb ?
>> +			      &mm->context.tsb_block[MM_TSB_HUGE] :
>>  			      NULL)
>>  #else
>>  			     NULL
>>  #endif
>> -			     , __pa(&mm->context.tsb_descr[0]));
>> +			     , __pa(&mm->context.tsb_descr[MM_TSB_BASE]));
>>  }
>>  
> This is a nice cleanup that has nothing to do with your series.
> Could you submit this as a separate patch so we can get it applied.
> 
> This is the only place left where the array index for tsb_block
> and tsb_descr uses hardcoded values. And it would be good to get
> rid of these.

Sure, I will submit a separate cleanup patch for this.

However, do note that in my series if CONFIG_SHARED_MMU_CTX is defined,
then MM_TSB_HUGE_SHARED is index 0, instead of MM_TSB_BASE being 0 in
the case where CONFIG_SHARED_MMU_CTX is not defined.  This may seem
'strange' and the obvious question would be 'why not put CONFIG_SHARED_MMU_CTX
at the end of the existing array (index 2)?'.  The reason is that tsb_descr
array can not have any 'holes' when passed to the hypervisor.  Since there
will always be a MM_TSB_BASE tsb, with MM_TSB_HUGE_SHARED before and
MM_TSB_HUGE after MM_TSB_BASE, few tricks are necessary to ensure no holes
are in the array passed to the hypervisor.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
