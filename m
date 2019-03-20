Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD045C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:28:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 754382184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:28:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 754382184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9B966B0003; Wed, 20 Mar 2019 10:28:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4A236B0006; Wed, 20 Mar 2019 10:28:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D38F06B0007; Wed, 20 Mar 2019 10:28:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA6796B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:28:38 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t13so21155204qkm.2
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:28:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=smCGIeI6unDecV1aEBVbWWQkZNXXruDfYTpgXklMZKc=;
        b=PZuovfY3gEiAo6YlHUUhTAkq8XPCTw4dYJabsCvCvr5/vM/rVGZs0WK6+aGgwZdk4N
         jltaPcLFXm/4H8Jscs9RZUSXUofptMnUFJDD0tOT4sGXr7kPG4Xp5AgUr3/EviePMNW8
         /8AZfVeV+kiP0iYH0bs+SmNgdNvnFGhN4yCUBPa5tyJlsSDEXLu7ez4kfvNn35bGb5Ja
         ARHwas0+uDtkJ8wQ3DUi7w98p5qHU4G9U9uLrzmODtC1fpl1Xn6DNLSuaugdGfX/IxWU
         xDRl3xwiZpyXQQNMOqdCEqaCf94VDva1WmkN+gq9xdgbCOJICL4Jq3TTWe/BaarBFntc
         YzWg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVAoAgom4eTgECdAr88wMWRipr4WURQa9ipRA7YzUX4dkL2Ugr0
	+cAjMZ4T215xKeb7gIjaKuxy2S5fC0FpYkpaMnnKjer/818idZxvqHiHzER4dN5ibC80lhHOvHX
	6DQyz+ElMdorpof9mfrKjOIiRR7EBIQ2353RBN2+Lr9ijVHksbNA9YV7SzzhKnK3WFg==
X-Received: by 2002:a0c:b660:: with SMTP id q32mr6967416qvf.50.1553092118381;
        Wed, 20 Mar 2019 07:28:38 -0700 (PDT)
X-Received: by 2002:a0c:b660:: with SMTP id q32mr6967366qvf.50.1553092117688;
        Wed, 20 Mar 2019 07:28:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553092117; cv=none;
        d=google.com; s=arc-20160816;
        b=k1iDmTek0fta4e5q7QwYFpBkL4vD7wMhISKIZ0aZzQi95i+eMhTkQMRIbaeWkDIah+
         P/BDIoyaGg5gKmqsZRq+RA8rpT5UNFjuHgcBySoJ2o34GkHVlegq1et418rchcP14vDK
         9Di+z9TEEhuvRyVa0AuzCeZnLmBMJ73sRcvGw6j0zkBY8ZnN0js8gzNO2fScy6FqeHCW
         IPTmZqAdYFMDY95NunIbPfCZKALJom4kYsAG9Qalu9xHfZ00pB2rlcckeHyyLT8cb+kd
         PfIkH/h4jjAFf52rprOMaXiLrJ0WgtV486rrjYWil90FsZzan0Z2QavWaGDZvGGExamJ
         3ytw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=smCGIeI6unDecV1aEBVbWWQkZNXXruDfYTpgXklMZKc=;
        b=qWbBiByMH8UapD/MDU5znW3oVUa5uFhjRGX12oRw1nC5V83MFrcB3m/tgSFLnWfyJy
         H/fvOcW0dQKENEJR/+zgaJFzG3n2R3QMM6FfzD78HEspKKLEsu/aGS6aMTjdPHJ/Ufs4
         Uiv3YUxq368HpgK/SNvgXQyUyMGgBAPYkXytF2NKE1uFXrT6WTzgWFIh8V2/8CbdlT3d
         IQUXW67997MOBd5Jfizd4dS399TdhCST+FDIp5ZTij+wpqzlA5PelkFHVmVp5PaEyBi2
         P9qBOic87XpL92Ryeg5jFVa2F7BjqOOw2Y8QtXruiokIUBjXJyWrXziLc+wUPWvtYvv7
         jnwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o5sor3898547qtq.21.2019.03.20.07.28.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:28:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of labbott@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=labbott@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw8nqgdlvVmWGpdsXaRt8lJKqqLwoeke1NlThzqJJzb2ijpW0P2BGlHJcE72TgE2lldw3Lvow==
X-Received: by 2002:ac8:1637:: with SMTP id p52mr1634425qtj.212.1553092117360;
        Wed, 20 Mar 2019 07:28:37 -0700 (PDT)
Received: from ?IPv6:2601:602:9800:dae6::c6a6? ([2601:602:9800:dae6::c6a6])
        by smtp.gmail.com with ESMTPSA id q75sm1200600qke.17.2019.03.20.07.28.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 07:28:36 -0700 (PDT)
Subject: Re: [PATCH] driver : staging : ion: optimization for decreasing
 memory fragmentaion
To: Vlastimil Babka <vbabka@suse.cz>, Zhaoyang Huang
 <huangzhaoyang@gmail.com>, Chintan Pandya <cpandya@codeaurora.org>,
 David Rientjes <rientjes@google.com>, Joe Perches <joe@perches.com>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Sumit Semwal <sumit.semwal@linaro.org>, devel@driverdev.osuosl.org,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>
References: <1552561599-23662-1-git-send-email-huangzhaoyang@gmail.com>
 <ca8bb8d0-3252-f9a7-3bf7-98d5a97e40cf@suse.cz>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <73eb235f-9515-916e-ff20-0491fe2e107e@redhat.com>
Date: Wed, 20 Mar 2019 07:28:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <ca8bb8d0-3252-f9a7-3bf7-98d5a97e40cf@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/20/19 7:23 AM, Vlastimil Babka wrote:
> You should have CC'd the ION maintainers/lists per
> ./scripts/get_maintainer.pl - CCing now.
> 
> On 3/14/19 12:06 PM, Zhaoyang Huang wrote:
>> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
>>
>> Two action for this patch:
>> 1. set a batch size for system heap's shrinker, which can have it buffer
>> reasonable page blocks in pool for future allocation.
>> 2. reverse the order sequence when free page blocks, the purpose is also
>> to have system heap keep as more big blocks as it can.
>>
>> By testing on an android system with 2G RAM, the changes with setting
>> batch = 48MB can help reduce the fragmentation obviously and improve
>> big block allocation speed for 15%.
>>
>> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
>> ---
>>   drivers/staging/android/ion/ion_heap.c        | 12 +++++++++++-
>>   drivers/staging/android/ion/ion_system_heap.c |  2 +-
>>   2 files changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
>> index 31db510..9e9caf2 100644
>> --- a/drivers/staging/android/ion/ion_heap.c
>> +++ b/drivers/staging/android/ion/ion_heap.c
>> @@ -16,6 +16,8 @@
>>   #include <linux/vmalloc.h>
>>   #include "ion.h"
>>   
>> +unsigned long ion_heap_batch = 0;
>> +
>>   void *ion_heap_map_kernel(struct ion_heap *heap,
>>   			  struct ion_buffer *buffer)
>>   {
>> @@ -303,7 +305,15 @@ int ion_heap_init_shrinker(struct ion_heap *heap)
>>   	heap->shrinker.count_objects = ion_heap_shrink_count;
>>   	heap->shrinker.scan_objects = ion_heap_shrink_scan;
>>   	heap->shrinker.seeks = DEFAULT_SEEKS;
>> -	heap->shrinker.batch = 0;
>> +	heap->shrinker.batch = ion_heap_batch;
>>   
>>   	return register_shrinker(&heap->shrinker);
>>   }
>> +
>> +static int __init ion_system_heap_batch_init(char *arg)
>> +{
>> +	 ion_heap_batch = memparse(arg, NULL);
>> +
>> +	return 0;
>> +}
>> +early_param("ion_batch", ion_system_heap_batch_init);
>> diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
>> index 701eb9f..d249f8d 100644
>> --- a/drivers/staging/android/ion/ion_system_heap.c
>> +++ b/drivers/staging/android/ion/ion_system_heap.c
>> @@ -182,7 +182,7 @@ static int ion_system_heap_shrink(struct ion_heap *heap, gfp_t gfp_mask,
>>   	if (!nr_to_scan)
>>   		only_scan = 1;
>>   
>> -	for (i = 0; i < NUM_ORDERS; i++) {
>> +	for (i = NUM_ORDERS - 1; i >= 0; i--) {
>>   		pool = sys_heap->pools[i];
>>   
>>   		if (only_scan) {
>>
> 

We're in the process of significantly reworking Ion so I
don't think it makes sense to take these as we work to
get things out of staging. You can resubmit this later,
but when you do please split this into two separate
patches since it's actually two independent changes.

Thanks,
Laura

