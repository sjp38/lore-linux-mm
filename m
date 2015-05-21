Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAFE82966
	for <linux-mm@kvack.org>; Thu, 21 May 2015 19:48:56 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so3530468pdb.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 16:48:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f4si534153pas.118.2015.05.21.16.48.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 16:48:55 -0700 (PDT)
Message-ID: <555E6D99.7070200@oracle.com>
Date: Thu, 21 May 2015 16:43:21 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm/hugetlb: compute/return the number of regions
 added by region_add()
References: <1431971349-6668-1-git-send-email-mike.kravetz@oracle.com>	<1431971349-6668-2-git-send-email-mike.kravetz@oracle.com> <20150521163027.566f3f0fd82801f2140a420d@linux-foundation.org>
In-Reply-To: <20150521163027.566f3f0fd82801f2140a420d@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>

On 05/21/2015 04:30 PM, Andrew Morton wrote:
> On Mon, 18 May 2015 10:49:08 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>> Modify region_add() to keep track of regions(pages) added to the
>> reserve map and return this value.  The return value can be
>> compared to the return value of region_chg() to determine if the
>> map was modified between calls.  Make vma_commit_reservation()
>> also pass along the return value of region_add().  The special
>> case return values of vma_needs_reservation() should also be
>> taken into account when determining the return value of
>> vma_commit_reservation().
>
> Could we please get this code slightly documented while it's hot in
> your mind?

Will do.  I'll provide an updated patch to address your questions and
better document this whole region/reserve map stuff.  It took me a few
days to wrap my head around how it actually works.

-- 
Mike Kravetz

> - One has to do an extraordinary amount of reading to discover that
>    the units of file_region.from and .to are "multiples of
>    1<<huge_page_order(h)" (where "h" is imponderable).
>
>    Let's get this written down?
>
> - Is file_region.to inclusive or exclusive?
>
> - What are they called "from" and "to" anyway?  We usually use
>    "start" and "end" for such things.
>
>
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -156,6 +156,7 @@ static long region_add(struct resv_map *resv, long f, long t)
>>   {
>>   	struct list_head *head = &resv->regions;
>>   	struct file_region *rg, *nrg, *trg;
>> +	long chg = 0;
>>
>>   	spin_lock(&resv->lock);
>>   	/* Locate the region we are either in or before. */
>> @@ -181,14 +182,17 @@ static long region_add(struct resv_map *resv, long f, long t)
>>   		if (rg->to > t)
>>   			t = rg->to;
>>   		if (rg != nrg) {
>> +			chg -= (rg->to - rg->from);
>>   			list_del(&rg->link);
>>   			kfree(rg);
>>   		}
>>   	}
>> +	chg += (nrg->from - f);
>>   	nrg->from = f;
>> +	chg += t - nrg->to;
>>   	nrg->to = t;
>>   	spin_unlock(&resv->lock);
>> -	return 0;
>> +	return chg;
>>   }
>
> Let's document the return value.  It appears that this function is
> designed to return a negative number (units?) on a successful addition.
> Why, and what does that number represent.
>
>
>>   static long region_chg(struct resv_map *resv, long f, long t)
>> @@ -1349,18 +1353,25 @@ static long vma_needs_reservation(struct hstate *h,
>>   	else
>>   		return chg < 0 ? chg : 0;
>>   }
>> -static void vma_commit_reservation(struct hstate *h,
>> +
>> +static long vma_commit_reservation(struct hstate *h,
>>   			struct vm_area_struct *vma, unsigned long addr)
>>   {
>>   	struct resv_map *resv;
>>   	pgoff_t idx;
>> +	long add;
>>
>>   	resv = vma_resv_map(vma);
>>   	if (!resv)
>> -		return;
>> +		return 1;
>>
>>   	idx = vma_hugecache_offset(h, vma, addr);
>> -	region_add(resv, idx, idx + 1);
>> +	add = region_add(resv, idx, idx + 1);
>> +
>> +	if (vma->vm_flags & VM_MAYSHARE)
>> +		return add;
>> +	else
>> +		return 0;
>>   }
>
> Let's document the return value here as well please.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
