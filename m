Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFEFA6B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 11:40:12 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id h42so3965630qtk.23
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 08:40:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t143sor5641732qke.143.2017.11.14.08.40.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 08:40:11 -0800 (PST)
Subject: Re: Allocation failure of ring buffer for trace
References: <9631b871-99cc-82bb-363f-9d429b56f5b9@gmail.com>
 <20171114114633.6ltw7f4y7qwipcqp@suse.de>
 <48b66fc4-ef82-983c-1b3d-b9c0a482bc51@gmail.com>
 <20171114155327.5ugozxxsofqoohv2@suse.de>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Message-ID: <8a10b9a6-dec6-1390-afac-89826758d2f5@gmail.com>
Date: Tue, 14 Nov 2017 11:40:09 -0500
MIME-Version: 1.0
In-Reply-To: <20171114155327.5ugozxxsofqoohv2@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: rostedt@goodmis.org, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, koki.sanagi@us.fujitsu.com, yasu.isimatu@gmail.com



On 11/14/2017 10:53 AM, Mel Gorman wrote:
> On Tue, Nov 14, 2017 at 10:39:19AM -0500, YASUAKI ISHIMATSU wrote:
>>
>>
>> On 11/14/2017 06:46 AM, Mel Gorman wrote:
>>> On Mon, Nov 13, 2017 at 12:48:36PM -0500, YASUAKI ISHIMATSU wrote:
>>>> When using trace_buf_size= boot option, memory allocation of ring buffer
>>>> for trace fails as follows:
>>>>
>>>> [ ] x86: Booting SMP configuration:
>>>> <SNIP>
>>>>
>>>> In my server, there are 384 CPUs, 512 GB memory and 8 nodes. And
>>>> "trace_buf_size=100M" is set.
>>>>
>>>> When using trace_buf_size=100M, kernel allocates 100 MB memory
>>>> per CPU before calling free_are_init_core(). Kernel tries to
>>>> allocates 38.4GB (100 MB * 384 CPU) memory. But available memory
>>>> at this time is about 16GB (2 GB * 8 nodes) due to the following commit:
>>>>
>>>>   3a80a7fa7989 ("mm: meminit: initialise a subset of struct pages
>>>>                  if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set")
>>>>
>>>
>>> 1. What is the use case for such a large trace buffer being allocated at
>>>    boot time?
>>
>> I'm not sure the use case. I found the following commit log:
>>
>>   commit 864b9a393dcb5aed09b8fd31b9bbda0fdda99374
>>   Author: Michal Hocko <mhocko@suse.com>
>>   Date:   Fri Jun 2 14:46:49 2017 -0700
>>
>>       mm: consider memblock reservations for deferred memory initialization sizing
>>
>> So I thought similar memory exhaustion may occurs on other boot option.
>> And I reproduced the issue.
>>
> 
> That was different, it was a premature OOM caused by reservations that
> were of a known size. It's not related to trace_buf_size in any fashion.

Yes. I know there are different bugs. I thought memory exhaustion at boot time
may occur by other boot option. So I tried trace_buf_size boot option.

> 
>>
>>> 2. Is disabling CONFIG_DEFERRED_STRUCT_PAGE_INIT at compile time an
>>>    option for you given that it's a custom-built kernel and not a
>>>    distribution kernel?
>>
>> The issue also occurred on distribution kernels. So we have to fix the issue.
>>
> 
> I'm aware of now bugs against a distribution kernel. However, does the
> patch work for you?
> 

I'll apply it.

Thanks,
Yasuaki Ishimatsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
