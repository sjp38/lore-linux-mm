Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7DCA36B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 01:48:28 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id fp1so2599174pdb.7
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 22:48:28 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id th2si18033299pab.109.2014.10.15.22.48.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 15 Oct 2014 22:48:27 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NDI00HKHW4P4070@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 16 Oct 2014 14:48:25 +0900 (KST)
Message-id: <543F5C3A.1070503@samsung.com>
Date: Thu, 16 Oct 2014 14:48:42 +0900
From: Heesub Shin <heesub.shin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm/zbud: init user ops only when it is needed
References: <1413367243-23524-1-git-send-email-heesub.shin@samsung.com>
 <20141015131710.ffd6c40996cd1ce6c16dbae8@linux-foundation.org>
In-reply-to: <20141015131710.ffd6c40996cd1ce6c16dbae8@linux-foundation.org>
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sunae Seo <sunae.seo@samsung.com>

Hello,

On 10/16/2014 05:17 AM, Andrew Morton wrote:
> On Wed, 15 Oct 2014 19:00:43 +0900 Heesub Shin <heesub.shin@samsung.com> wrote:
>
>> When zbud is initialized through the zpool wrapper, pool->ops which
>> points to user-defined operations is always set regardless of whether it
>> is specified from the upper layer. This causes zbud_reclaim_page() to
>> iterate its loop for evicting pool pages out without any gain.
>>
>> This patch sets the user-defined ops only when it is needed, so that
>> zbud_reclaim_page() can bail out the reclamation loop earlier if there
>> is no user-defined operations specified.
>
> Which callsite is calling zbud_zpool_create(..., NULL)?

Currently nowhere. zswap is the only user of zbud and always passes a 
pointer to user-defined operation on pool creation. In addition, there 
may be less possibility that pool shrinking is requested by users who 
did not provide the user-defined ops. So, we may not need to worry much 
about what I wrote in the changelog. However, it is definitely weird to 
pass an argument, zpool_ops, which even will not be referenced by 
zbud_zpool_create(). Above all, it would be more useful to avoid the 
possibility in the future rather than just ignoring it.

regards,
heesub

>
>> ...
>> --- a/mm/zbud.c
>> +++ b/mm/zbud.c
>> @@ -132,7 +132,7 @@ static struct zbud_ops zbud_zpool_ops = {
>>
>>   static void *zbud_zpool_create(gfp_t gfp, struct zpool_ops *zpool_ops)
>>   {
>> -	return zbud_create_pool(gfp, &zbud_zpool_ops);
>> +	return zbud_create_pool(gfp, zpool_ops ? &zbud_zpool_ops : NULL);
>>   }
>>
>>   static void zbud_zpool_destroy(void *pool)
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
