Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBFF0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 16:21:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77BFF21902
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 16:21:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77BFF21902
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA2566B0005; Thu, 21 Mar 2019 12:21:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E514E6B0006; Thu, 21 Mar 2019 12:21:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D413F6B0007; Thu, 21 Mar 2019 12:21:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2506B0005
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 12:21:48 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id n62so2753789oib.10
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:21:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=b8Zgym0D5AYyANBHphUVwtjKCFEgbr4PEB4Rd1oZyYE=;
        b=VpdcuCDmGXJ792xdlf3CYhVM0csRgI7/JDKc8W68day+rAZMNB+pMj7t2Jgk4V0/bd
         U8XeEecCStUn0TgIz13nCvldu3lYl9NFDcD90aMEJHUfGqiR3apYs2Y9HMeriZJ9f4c5
         w+kSBAS+RRaAmXDZHqFiihwMaRj6XexhBp35aCZVvv86ShQ0nsn3adh4ABlwAb7JMbIs
         SKOTCm7bH7JB+0iPRE9/j9+8JZ66zFK74XnsWHI1Z0Tep3DG7/xR0MHTCGCQwW7I2koP
         chqabMvasESJ3In2w9+4D+my/VGENaYgvpteca6WrEHGGTA+PwGnW24u0Jui7vydvyrp
         eBqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV9p6xDjsINAw7gZH6OWkkhdzfQI3Qq4tPsoSzvYp4jiWRysEwQ
	6X99MtxFapkOvRfTuV+w/W3d2kaZtyEnFei/It4ghNKrqsxIvI+s926IFKAkQYnwNu/J9zJzJd5
	LIDLTsznnv5JEFjKW+9S15JDHa2NvnroOBDotdqwctn0blbcbMu649l27VtonaxR+5Q==
X-Received: by 2002:aca:c483:: with SMTP id u125mr79790oif.148.1553185308274;
        Thu, 21 Mar 2019 09:21:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5gb7TDvrXHgYUu8eNs6dRyyjQ4F4NnBnvt033IXIc4nET9+x0lHQQBI1b7JMliUOBEVp4
X-Received: by 2002:aca:c483:: with SMTP id u125mr79720oif.148.1553185307345;
        Thu, 21 Mar 2019 09:21:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553185307; cv=none;
        d=google.com; s=arc-20160816;
        b=dWZZJ986OKp9JNJsvIOlr3lgcA7JMm7YbGjBLWZIXWZ4sB4zuz8ElQ63qCVA9HVAKZ
         WEklCz8qUFj71LvIq8+oVYLAQUnGJ7G43Wdxa2kNKN1HCEQiR3n5NaVxb8djmh4zdXhZ
         hCbpVUQw1tmk4nOS2mWMVvMNKcbOHGN4Tkg+VJ4ajcbIbNtke5yJmkI2a2VqbRL+FcIG
         fh7UMKjwfMrmuV1+L3ZfjH1N6VpOW5iOLV49XoLuDdUTvVzAZrqPaDE4QjLF4buaHAqC
         0xOFv8hEW3BW6wcWjCVKq4KfeWU3PtbtTHqRrhWrxSfm7jAOvCLoRm7kLeklUNw8MhXj
         aNyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=b8Zgym0D5AYyANBHphUVwtjKCFEgbr4PEB4Rd1oZyYE=;
        b=vsmMwrdoJmxqG4eSlbFs/NUkaJoqz3GZZPdwwLK+vcI1iWXX/m2viUHhMnNO9/Yi57
         oBK1N/p4t+OBVp5dlYbIeZWwnQvJBbStpAvIVF75vVHwIH6x8XYRPGeITvs8DUWWmzKy
         m3KFf38mWoejatJybHXcZvu6ZcG7UKbjXxaNDkVQ3t6dN4Y6C33wikU9UDOfJEsxkRLR
         9gMeIriKOmnaqhkXr9Bo3wqtZcqIkyFZAHsSr6LPebVQYJmmwsyT9vadPrg/pcuLAPQZ
         N7ZzM+60panoUh4qQBkUxZNydAsgfabUQTJuNpT5piFsqeaUYbRGtI0ytX0oeOTR2+GU
         4iKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id i21si2345559otp.60.2019.03.21.09.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 09:21:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04455;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TNI4zah_1553185300;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNI4zah_1553185300)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 22 Mar 2019 00:21:42 +0800
Subject: Re: [RFC PATCH] mm: mempolicy: remove MPOL_MF_LAZY
To: Michal Hocko <mhocko@kernel.org>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, akpm@linux-foundation.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190321145745.GS8696@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <75059b39-dbc4-3649-3e6b-7bdf282e3f53@linux.alibaba.com>
Date: Thu, 21 Mar 2019 09:21:39 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190321145745.GS8696@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/21/19 7:57 AM, Michal Hocko wrote:
> On Wed 20-03-19 08:27:39, Yang Shi wrote:
>> MPOL_MF_LAZY was added by commit b24f53a0bea3 ("mm: mempolicy: Add
>> MPOL_MF_LAZY"), then it was disabled by commit a720094ded8c ("mm:
>> mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")
>> right away in 2012.  So, it is never ever exported to userspace.
>>
>> And, it looks nobody is interested in revisiting it since it was
>> disabled 7 years ago.  So, it sounds pointless to still keep it around.
> The above changelog owes us a lot of explanation about why this is
> safe and backward compatible. I am also not sure you can change
> MPOL_MF_INTERNAL because somebody still might use the flag from
> userspace and we want to guarantee it will have the exact same semantic.

Since MPOL_MF_LAZY is never exported to userspace (Mel helped to confirm 
this in the other thread), so I'm supposed it should be safe and 
backward compatible to userspace.

I'm also not sure if anyone use MPOL_MF_INTERNAL or not and how they use 
it in their applications, but how about keeping it unchanged?

Thanks,
Yang

>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>> Hi folks,
>> I'm not sure if you still would like to revisit it later. And, I may be
>> not the first one to try to remvoe it. IMHO, it sounds pointless to still
>> keep it around if nobody is interested in it.
>>
>>   include/uapi/linux/mempolicy.h |  3 +--
>>   mm/mempolicy.c                 | 13 -------------
>>   2 files changed, 1 insertion(+), 15 deletions(-)
>>
>> diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
>> index 3354774..eb52a7a 100644
>> --- a/include/uapi/linux/mempolicy.h
>> +++ b/include/uapi/linux/mempolicy.h
>> @@ -45,8 +45,7 @@ enum {
>>   #define MPOL_MF_MOVE	 (1<<1)	/* Move pages owned by this process to conform
>>   				   to policy */
>>   #define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
>> -#define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
>> -#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
>> +#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
>>   
>>   #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
>>   			 MPOL_MF_MOVE     | 	\
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index af171cc..67886f4 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -593,15 +593,6 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>>   
>>   	qp->prev = vma;
>>   
>> -	if (flags & MPOL_MF_LAZY) {
>> -		/* Similar to task_numa_work, skip inaccessible VMAs */
>> -		if (!is_vm_hugetlb_page(vma) &&
>> -			(vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE)) &&
>> -			!(vma->vm_flags & VM_MIXEDMAP))
>> -			change_prot_numa(vma, start, endvma);
>> -		return 1;
>> -	}
>> -
>>   	/* queue pages from current vma */
>>   	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
>>   		return 0;
>> @@ -1181,9 +1172,6 @@ static long do_mbind(unsigned long start, unsigned long len,
>>   	if (IS_ERR(new))
>>   		return PTR_ERR(new);
>>   
>> -	if (flags & MPOL_MF_LAZY)
>> -		new->flags |= MPOL_F_MOF;
>> -
>>   	/*
>>   	 * If we are using the default policy then operation
>>   	 * on discontinuous address spaces is okay after all
>> @@ -1226,7 +1214,6 @@ static long do_mbind(unsigned long start, unsigned long len,
>>   		int nr_failed = 0;
>>   
>>   		if (!list_empty(&pagelist)) {
>> -			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
>>   			nr_failed = migrate_pages(&pagelist, new_page, NULL,
>>   				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
>>   			if (nr_failed)
>> -- 
>> 1.8.3.1
>>

