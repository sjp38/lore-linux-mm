Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 202506B0006
	for <linux-mm@kvack.org>; Sun,  1 Apr 2018 21:58:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c65so11629522pfa.5
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 18:58:33 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id z123si3841240pgz.332.2018.04.01.18.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Apr 2018 18:58:31 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180327062939.GV5652@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <df28d1cb-0d43-1c40-9c24-c1abf1b9889a@linux.alibaba.com>
Date: Sun, 1 Apr 2018 18:58:07 -0700
MIME-Version: 1.0
In-Reply-To: <20180327062939.GV5652@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, gorcunov@openvz.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/26/18 11:29 PM, Michal Hocko wrote:
> On Tue 27-03-18 02:20:39, Yang Shi wrote:
> [...]
> The patch looks reasonable to me. Maybe it would be better to be more
> explicit about the purpose of the patch. As others noticed, this alone
> wouldn't solve the mmap_sem contention issues. I _think_ that if you
> were more explicit about the mmap_sem abuse it would trigger less
> questions.
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

Sorry for taking a little bit longer to get back since I was traveling. 
I think all the stuff can be protected by the new arg_lock except 
mm->brk since arg_lock can't prevent from concurrent writing from sys_brk().

We may use arg_lock to protect everything else other than mm->brk. The 
complexity sounds acceptable.

Of course, as Cyrill mentioned, he prefers to deprecating prctl_set_mm 
since C/R is the only user of it. We may wait until he is done?

Thanks,
Yang

>
> Thanks!
