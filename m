Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6A26B0006
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 19:17:44 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id b2-v6so2280133plm.23
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 16:17:44 -0800 (PST)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id f15-v6si2083136plr.336.2018.02.28.16.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 16:17:42 -0800 (PST)
Subject: Re: [RFC PATCH 0/4 v2] Define killable version for access_remote_vm()
 and use it in fs/proc
References: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.DEB.2.20.1802261656490.16999@chino.kir.corp.google.com>
 <4ec32e5b-af63-f412-2213-e52bdbcc9585@linux.alibaba.com>
 <alpine.DEB.2.20.1802261742400.24072@chino.kir.corp.google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6ee55dbd-5b06-5ae8-f16d-c58448500df1@linux.alibaba.com>
Date: Wed, 28 Feb 2018 16:17:33 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1802261742400.24072@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, adobriyan@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2/26/18 5:47 PM, David Rientjes wrote:
> On Mon, 26 Feb 2018, Yang Shi wrote:
>
>>> Rather than killable, we have patches that introduce down_read_unfair()
>>> variants for the files you've modified (cmdline and environ) as well as
>>> others (maps, numa_maps, smaps).
>> You mean you have such functionality used by google internally?
>>
> Yup, see https://lwn.net/Articles/387720.
>
>>> When another thread is holding down_read() and there are queued
>>> down_write()'s, down_read_unfair() allows for grabbing the rwsem without
>>> queueing for it.  Additionally, when another thread is holding
>>> down_write(), down_read_unfair() allows for queueing in front of other
>>> threads trying to grab it for write as well.
>> It sounds the __unfair variant make the caller have chance to jump the gun to
>> grab the semaphore before other waiters, right? But when a process holds the
>> semaphore, i.e. mmap_sem, for a long time, it still has to sleep in
>> uninterruptible state, right?
>>
> Right, it's solving two separate things which I think may be able to be
> merged together.  Killable is solving an issue where the rwsem is blocking
> for a long period of time in uninterruptible sleep, and unfair is solving
> an issue where reading the procfs files gets stalled for a long period of
> time.  We haven't run into an issue (yet) where killable would have solved
> it; we just have the unfair variants to grab the rwsem asap and then, if
> killable, gracefully return.
>
>>> Ingo would know more about whether a variant like that in upstream Linux
>>> would be acceptable.
>>>
>>> Would you be interested in unfair variants instead of only addressing
>>> killable?
>> Yes, I'm although it still looks overkilling to me for reading /proc.
>>
> We make certain inferences on the readablility of procfs files for other
> threads to determine how much its mm's mmap_sem is contended.

I see your points here for reading /proc for system monitor. However, 
I'm concerned that the _unfair APIs get the processes which read /proc 
priority elevation (not real priority change, just look like). It might 
be abused by some applications, for example:

A high priority process and a low priority process are waiting for the 
same rwsem, if the low priority process is trying to read /proc 
maliciously on purpose, it can get elevated to grap the rwsem before any 
other processes which are waiting for the same rwsem.

Yang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
