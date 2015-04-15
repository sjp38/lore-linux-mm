Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f47.google.com (mail-vn0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4546B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 19:26:41 -0400 (EDT)
Received: by vnbf1 with SMTP id f1so21491130vnb.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 16:26:41 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id nr5si4023737obc.15.2015.04.15.16.26.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 16:26:40 -0700 (PDT)
Message-ID: <552EF2D7.7080705@huawei.com>
Date: Thu, 16 Apr 2015 07:23:03 +0800
From: Wang Kai <morgan.wang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kmemleak: record accurate early log buffer count and
 report when exceeded
References: <1429098563-76831-1-git-send-email-morgan.wang@huawei.com> <20150415151300.GF22741@localhost>
In-Reply-To: <20150415151300.GF22741@localhost>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Thanks a lot for the correction.

On 2015/4/15 23:13, Catalin Marinas wrote:
> (I see you corrected the LKML address; I replied to your early patch)
> 
> On Wed, Apr 15, 2015 at 12:49:23PM +0100, Wang Kai wrote:
>> In log_early function, crt_early_log should also count once when
>> 'crt_early_log >= ARRAY_SIZE(early_log)'. Otherwise the reported
>> count from kmemleak_init is one less than 'actual number'.
>>
>> Then, in kmemleak_init, if early_log buffer size equal actual
>> number, kmemleak will init sucessful, so change warning condition
>> to 'crt_early_log > ARRAY_SIZE(early_log)'.
>>
>> Signed-off-by: Wang Kai <morgan.wang@huawei.com>
>> ---
>>  mm/kmemleak.c |    5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>> index 5405aff..49956cf 100644
>> --- a/mm/kmemleak.c
>> +++ b/mm/kmemleak.c
>> @@ -814,6 +814,8 @@ static void __init log_early(int op_type, const void *ptr, size_t size,
>>  	}
>>  
>>  	if (crt_early_log >= ARRAY_SIZE(early_log)) {
>> +		/* kmemleak will stop recording, just count the requests */
> 
> You could say "just count the last request" since kmemleak_disable()
> would set kmemleak_error to 1 and you never get to this block again.
> 
>> +		crt_early_log++;
>>  		kmemleak_disable();
>>  		return;
>>  	}
>> @@ -1829,7 +1831,8 @@ void __init kmemleak_init(void)
>>  	object_cache = KMEM_CACHE(kmemleak_object, SLAB_NOLEAKTRACE);
>>  	scan_area_cache = KMEM_CACHE(kmemleak_scan_area, SLAB_NOLEAKTRACE);
>>  
>> -	if (crt_early_log >= ARRAY_SIZE(early_log))
>> +	/* Don't warning when crt_early_log == ARRAY_SIZE(early_log) */
> 
> s/warning/warn/
> 
> But I don't think this comment is needed, just add it to the commit log.
> 
>> +	if (crt_early_log > ARRAY_SIZE(early_log))
>>  		pr_warning("Early log buffer exceeded (%d), please increase "
>>  			   "DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n", crt_early_log);
> 
> Otherwise, my ack still stands:
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> .
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
