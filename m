Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2AFC26B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 23:17:05 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t194so4492774oif.8
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 20:17:05 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id p204si597303oif.1.2017.06.29.20.17.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 20:17:04 -0700 (PDT)
Subject: Re: [PATCH v4 2/2] fs/dcache.c: fix spin lockup issue on nlru->lock
References: <20170628171854.t4sjyjv55j673qzv@esperanza>
 <1498707575-2472-1-git-send-email-stummala@codeaurora.org>
 <20170629154828.5b4877348470c42352620f41@linux-foundation.org>
From: Sahitya Tummala <stummala@codeaurora.org>
Message-ID: <ec645d13-5a25-0eaa-963b-3c3c3b2a72a2@codeaurora.org>
Date: Fri, 30 Jun 2017 08:46:57 +0530
MIME-Version: 1.0
In-Reply-To: <20170629154828.5b4877348470c42352620f41@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Polakov <apolyakov@beget.ru>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org


On 6/30/2017 4:18 AM, Andrew Morton wrote:
>
>> --- a/fs/dcache.c
>> +++ b/fs/dcache.c
>> @@ -1133,11 +1133,12 @@ void shrink_dcache_sb(struct super_block *sb)
>>   		LIST_HEAD(dispose);
>>   
>>   		freed = list_lru_walk(&sb->s_dentry_lru,
>> -			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
>> +			dentry_lru_isolate_shrink, &dispose, 1024);
>>   
>>   		this_cpu_sub(nr_dentry_unused, freed);
>>   		shrink_dentry_list(&dispose);
>> -	} while (freed > 0);
>> +		cond_resched();
>> +	} while (list_lru_count(&sb->s_dentry_lru) > 0);
>>   }
>>   EXPORT_SYMBOL(shrink_dcache_sb);
> I'll add a cc:stable to this one - a large dentry list is a relatively
> common thing.
>
> I'm assumng that [1/2] does not need to be backported, OK?

I think we should include [1/2] as well along with this patch, as this patch
is using list_lru_count(), which can return incorrect count if [1/2] is 
not included.

Also, all the previous patches submitted for fixing this issue must be 
dropped i.e,
mm/list_lru.c: use cond_resched_lock() for nlru->lock must be dropped.

-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
