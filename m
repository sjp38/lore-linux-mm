Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7E08B6B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 19:47:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id s6so247163pgn.3
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 16:47:43 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id v10-v6si12038633plo.61.2018.03.06.16.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 16:47:42 -0800 (PST)
Subject: Re: [RFC PATCH 0/4 v2] Define killable version for access_remote_vm()
 and use it in fs/proc
References: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180306124540.d8b5f6da97ab69a49566f950@linux-foundation.org>
 <b576e32b-9c47-ee67-a576-b5a0c05c2864@linux.alibaba.com>
 <20180306134139.375e15abab173329962f7d5a@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ae008700-3bf6-ed96-865e-5a60694db7c8@linux.alibaba.com>
Date: Tue, 6 Mar 2018 16:47:22 -0800
MIME-Version: 1.0
In-Reply-To: <20180306134139.375e15abab173329962f7d5a@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@kernel.org, adobriyan@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>



On 3/6/18 1:41 PM, Andrew Morton wrote:
> On Tue, 6 Mar 2018 13:17:37 -0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>>
>> It just mitigates the hung task warning, can't resolve the mmap_sem
>> scalability issue. Furthermore, waiting on pure uninterruptible state
>> for reading /proc sounds unnecessary. It doesn't wait for I/O completion.
> OK.

Since we already had down_read_killable() APIs available, IMHO, giving 
application a chance to abort at some circumstances sounds not bad.

>
>>> Where the heck are we holding mmap_sem for so long?  Can that be fixed?
>> The mmap_sem is held for unmapping a large map which has every single
>> page mapped. This is not a issue in real production code. Just found it
>> by running vm-scalability on a machine with ~600GB memory.
>>
>> AFAIK, I don't see any easy fix for the mmap_sem scalability issue. I
>> saw range locking patches (https://lwn.net/Articles/723648/) were
>> floating around. But, it may not help too much on the case that a large
>> map with every single page mapped.
> Well it sounds fairly simple to mitigate?  Simplistically: don't unmap
> 600G in a single hit; do it 1G at a time, dropping mmap_sem each time.
> A smarter version might only come up for air if there are mmap_sem
> waiters and if it has already done some work.  I don't think we have
> any particular atomicity requirements when unmapping?

I'm not quite sure. But, the existing applications may assume munmap is 
atomic?

Thanks,
Yang

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
