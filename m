Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3873C6B0003
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 13:32:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q13so5848194pgt.17
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 10:32:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r3-v6sor2239008plb.68.2018.02.26.10.32.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 10:32:41 -0800 (PST)
Subject: Re: [PATCH 7/7] Documentation for Pmalloc
References: <20180223144807.1180-1-igor.stoppa@huawei.com>
 <20180223144807.1180-8-igor.stoppa@huawei.com>
 <98b2fecf-c1b3-aa5e-ba70-2770940bb965@gmail.com>
 <181b20bb-b0ae-c337-d4bd-03b6ddfed749@huawei.com>
From: J Freyensee <why2jjj.linux@gmail.com>
Message-ID: <79cfdcc9-9073-3270-25cc-4835675386b0@gmail.com>
Date: Mon, 26 Feb 2018 10:32:37 -0800
MIME-Version: 1.0
In-Reply-To: <181b20bb-b0ae-c337-d4bd-03b6ddfed749@huawei.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>, david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

[...]

On 2/26/18 7:39 AM, Igor Stoppa wrote:
>
> On 24/02/18 02:26, J Freyensee wrote:
>>
>> On 2/23/18 6:48 AM, Igor Stoppa wrote:
> [...]
>
>>> +- Before destroying a pool, all the memory allocated from it must be
>>> +  released.
>> Is that true?A  pmalloc_destroy_pool() has:
>>
>> .
>> .
>> +A A A  pmalloc_pool_set_protection(pool, false);
>> +A A A  gen_pool_for_each_chunk(pool, pmalloc_chunk_free, NULL);
>> +A A A  gen_pool_destroy(pool);
>> +A A A  kfree(data);
>>
>> which to me looks like is the opposite, the data (ie, "memory") is being
>> released first, then the pool is destroyed.
> well, this is embarrassing ... yes I had this prototype code, because I
> was wondering if it wouldn't make more sense to tear down the pool as
> fast as possible. It slipped in, apparently.
>
> I'm actually tempted to leave it in and fix the comment.

Sure, one or the other.

>
> [...]
>
>>> +
>>> +- pmalloc does not provide locking support with respect to allocating vs
>>> +  protecting an individual pool, for performance reasons.
>> What is the recommendation to using locks then, as the computing
>> real-world mainly operates in multi-threaded/process world?
> How common are multi-threaded allocations of write-once memory?
> Here we are talking exclusively about the part of the memory life-cycle
> where it is allocated (from pmalloc).

Yah, that's true, good point.

>
>> Maybe show
>> an example of an issue that occur if locks aren't used and give a coding
>> example.
> An example of how to use a mutex to access a shared resource? :-O
>
> This part below, under your question, was supposed to be the answer :-(
>
>>> +  It is recommended not to share the same pool between unrelated functions.
>>> +  Should sharing be a necessity, the user of the shared pool is expected
>>> +  to implement locking for that pool.

My bad, I was suggesting a code sample, if there was a simple code 
sample to provide (like 5-10 lines?).A  If it's a lot of code to write, 
no bother.

> [...]
>
>>> +- pmalloc uses genalloc to optimize the use of the space it allocates
>>> +  through vmalloc. Some more TLB entries will be used, however less than
>>> +  in the case of using vmalloc directly. The exact number depends on the
>>> +  size of each allocation request and possible slack.
>>> +
>>> +- Considering that not much data is supposed to be dynamically allocated
>>> +  and then marked as read-only, it shouldn't be an issue that the address
>>> +  range for pmalloc is limited, on 32-bit systems.
>> Why is 32-bit systems mentioned and not 64-bit?
> Because, as written, on 32 bit system the vmalloc range is relatively
> small, so one might wonder if there are enough addresses.
>
>>  A  Is there a problem with 64-bit here?
> Quite the opposite.
> I thought it was clear, but obviously it isn't, I'll reword this.

Sounds good, thank you,
Jay

>
> -igor
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
