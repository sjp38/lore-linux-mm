Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0E4BB6B0010
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:00:12 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g61-v6so10593745plb.10
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:00:12 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id s9si10750357pgr.708.2018.03.26.15.00.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 15:00:10 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180326183725.GB27373@bombadil.infradead.org>
 <20180326192132.GE2236@uranus>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <aef52c2a-4b75-f8a7-2083-f53f42bddab8@linux.alibaba.com>
Date: Mon, 26 Mar 2018 17:59:49 -0400
MIME-Version: 1.0
In-Reply-To: <20180326192132.GE2236@uranus>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: adobriyan@gmail.com, mhocko@kernel.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/26/18 3:21 PM, Cyrill Gorcunov wrote:
> On Mon, Mar 26, 2018 at 11:37:25AM -0700, Matthew Wilcox wrote:
>> On Tue, Mar 27, 2018 at 02:20:39AM +0800, Yang Shi wrote:
>>> +++ b/kernel/sys.c
>>> @@ -1959,7 +1959,7 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>>   			return error;
>>>   	}
>>>   
>>> -	down_write(&mm->mmap_sem);
>>> +	down_read(&mm->mmap_sem);
>>>   
>>>   	/*
>>>   	 * We don't validate if these members are pointing to
>>> @@ -1980,10 +1980,13 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>>>   	mm->start_brk	= prctl_map.start_brk;
>>>   	mm->brk		= prctl_map.brk;
>>>   	mm->start_stack	= prctl_map.start_stack;
>>> +
>>> +	spin_lock(&mm->arg_lock);
>>>   	mm->arg_start	= prctl_map.arg_start;
>>>   	mm->arg_end	= prctl_map.arg_end;
>>>   	mm->env_start	= prctl_map.env_start;
>>>   	mm->env_end	= prctl_map.env_end;
>>> +	spin_unlock(&mm->arg_lock);
>>>   
>>>   	/*
>>>   	 * Note this update of @saved_auxv is lockless thus
>> I see the argument for the change to a write lock was because of a BUG
>> validating arg_start and arg_end, but more generally, we are updating these
>> values, so a write-lock is probably a good idea, and this is a very rare
>> operation to do, so we don't care about making this more parallel.  I would
>> not make this change (but if other more knowledgable people in this area
>> disagree with me, I will withdraw my objection to this part).
> Say we've two syscalls running prctl_set_mm_map in parallel, and imagine
> one have @start_brk = 20 @brk = 10 and second caller has @start_brk = 30
> and @brk = 20. Since now the call is guarded by _read_ the both calls
> unlocked and due to OO engine it may happen then when both finish
> we have @start_brk = 30 and @brk = 10. In turn "write" semaphore
> has been take to have consistent data on exit, either you have [20;10]
> or [30;20] assigned not something mixed.
>
> That said I think using read-lock here would be a bug.

Yes it sounds so. However, it was down_read before 
ddf1d398e517e660207e2c807f76a90df543a217 ("prctl: take mmap sem for 
writing to protect against others"). And, that commit is for fixing the 
concurrent writing to arg_* and env_*. I just checked that commit, but 
omitted the brk part. The potential issue mentioned by you should exist 
before that commit, but might be just not discovered or very rare to hit.

I will change it back to down_write.

Thanks,
Yang

>
> 	Cyrill
