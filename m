Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 61DEF6B0025
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 14:38:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j8so13445047pfh.13
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 11:38:24 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id c15si1235176pgv.251.2018.03.27.11.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 11:38:22 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180327062939.GV5652@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <95a107ac-5e5b-92d7-dbde-2e961d85de28@linux.alibaba.com>
Date: Tue, 27 Mar 2018 14:38:11 -0400
MIME-Version: 1.0
In-Reply-To: <20180327062939.GV5652@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, gorcunov@openvz.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/27/18 2:29 AM, Michal Hocko wrote:
> On Tue 27-03-18 02:20:39, Yang Shi wrote:
> [...]
> The patch looks reasonable to me. Maybe it would be better to be more
> explicit about the purpose of the patch. As others noticed, this alone
> wouldn't solve the mmap_sem contention issues. I _think_ that if you
> were more explicit about the mmap_sem abuse it would trigger less
> questions.

Yes, sure.

>
> I have just one more question. Now that you are touching this area,
> would you be willing to remove the following ugliness?
>
>> diff --git a/kernel/sys.c b/kernel/sys.c
>> index f2289de..17bddd2 100644
>> --- a/kernel/sys.c
>> +++ b/kernel/sys.c
>> @@ -1959,7 +1959,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>   			return error;
>>   	}
>>   
>> -	down_write(&mm->mmap_sem);
>> +	down_read(&mm->mmap_sem);
> Why do we need to hold mmap_sem here and call find_vma, when only
> PR_SET_MM_ENV_END: is consuming it? I guess we can replace it wit the
> new lock and take the mmap_sem only for PR_SET_MM_ENV_END.

Actually, I didn't think of why. It looks prctl_set_mm() checks if vma 
does exist when it tries to set stack_start, argv_* and env_*, btw not 
only env_end.

Cyrill may be able to give us some hint since C/R is the main user of 
this API.

Yang

>
> Thanks!
