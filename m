Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id DB5236B003A
	for <linux-mm@kvack.org>; Thu, 15 May 2014 12:10:41 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id w61so1323450wes.12
        for <linux-mm@kvack.org>; Thu, 15 May 2014 09:10:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t4si6393743wiy.14.2014.05.15.09.10.39
        for <linux-mm@kvack.org>;
        Thu, 15 May 2014 09:10:40 -0700 (PDT)
Message-ID: <5374E631.30208@redhat.com>
Date: Thu, 15 May 2014 12:07:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6] mm: support madvise(MADV_FREE)
References: <1399857988-2880-1-git-send-email-minchan@kernel.org> <20140515154657.GA2720@cmpxchg.org>
In-Reply-To: <20140515154657.GA2720@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, John Stultz <john.stultz@linaro.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>

On 05/15/2014 11:46 AM, Johannes Weiner wrote:

>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index bf9811e1321a..c69594c141a9 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1082,6 +1082,8 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
>>   		unsigned long size);
>>   void zap_page_range(struct vm_area_struct *vma, unsigned long address,
>>   		unsigned long size, struct zap_details *);
>> +int lazyfree_single_vma(struct vm_area_struct *vma, unsigned long start_addr,
>> +		unsigned long end_addr);
>
> madvise_free_single_vma?

Or just madvise_free_vma ?

>> @@ -251,6 +252,14 @@ static long madvise_willneed(struct vm_area_struct *vma,
>>   	return 0;
>>   }
>>
>> +static long madvise_lazyfree(struct vm_area_struct *vma,
>
> madvise_free?

Agreed.

It is encouraging that the review has reached nit picking
level :)

>> diff --git a/mm/memory.c b/mm/memory.c
>> index 037b812a9531..0516c94da1a4 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1284,6 +1284,112 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
>>   	return addr;
>>   }
>>
>> +static unsigned long lazyfree_pte_range(struct mmu_gather *tlb,
>
> I'd prefer to have all this code directly where it's used, which is in
> madvise.c, and also be named accordingly.  We can always rename and
> move it later on should other code want to reuse it.

Agreed.

I like your other suggestions too, Johannes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
