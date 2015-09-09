Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 60F1A6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 05:33:32 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so147305199wic.0
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 02:33:31 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id il8si11385180wjb.130.2015.09.09.02.33.17
        for <linux-mm@kvack.org>;
        Wed, 09 Sep 2015 02:33:30 -0700 (PDT)
Message-ID: <55EFFB16.5080606@huawei.com>
Date: Wed, 9 Sep 2015 17:25:42 +0800
From: "long.wanglong" <long.wanglong@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] kasan: Fix a type conversion error
References: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com> <1441771180-206648-3-git-send-email-long.wanglong@huawei.com> <55EFF585.80603@arm.com>
In-Reply-To: <55EFF585.80603@arm.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: "ryabinin.a.a@gmail.com" <ryabinin.a.a@gmail.com>, "adech.fo@gmail.com" <adech.fo@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "wanglong@laoqinren.net" <wanglong@laoqinren.net>, "peifeiyue@huawei.com" <peifeiyue@huawei.com>, "morgan.wang@huawei.com" <morgan.wang@huawei.com>

On 2015/9/9 17:01, Vladimir Murzin wrote:
> On 09/09/15 04:59, Wang Long wrote:
>> The current KASAN code can find the following out-of-bounds
> 
> Should it be "cannot"?
> 
> Vladimir
> 
sorry for that mistake, it should be "cannot".

>> bugs:
>> 	char *ptr;
>> 	ptr = kmalloc(8, GFP_KERNEL);
>> 	memset(ptr+7, 0, 2);
>>
>> the cause of the problem is the type conversion error in
>> *memory_is_poisoned_n* function. So this patch fix that.
>>
>> Signed-off-by: Wang Long <long.wanglong@huawei.com>
>> ---
>>  mm/kasan/kasan.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index 7b28e9c..5d65d06 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -204,7 +204,7 @@ static __always_inline bool memory_is_poisoned_n(unsigned long addr,
>>  		s8 *last_shadow = (s8 *)kasan_mem_to_shadow((void *)last_byte);
>>  
>>  		if (unlikely(ret != (unsigned long)last_shadow ||
>> -			((last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))
>> +			((long)(last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))
>>  			return true;
>>  	}
>>  	return false;
>>
> 
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
