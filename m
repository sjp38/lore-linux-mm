Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id C1DA96B4D47
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 08:59:05 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id r194so1030165ywg.12
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 05:59:05 -0800 (PST)
Received: from p3plsmtpa06-07.prod.phx3.secureserver.net (p3plsmtpa06-07.prod.phx3.secureserver.net. [173.201.192.108])
        by mx.google.com with ESMTPS id p15-v6si4873445ybg.427.2018.11.28.05.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 05:59:04 -0800 (PST)
Subject: Re: [PATCH v2 0/6] RFC: gup+dma: tracking dma-pinned pages
References: <20181110085041.10071-1-jhubbard@nvidia.com>
 <942cb823-9b18-69e7-84aa-557a68f9d7e9@talpey.com>
 <97934904-2754-77e0-5fcb-83f2311362ee@nvidia.com>
 <5159e02f-17f8-df8b-600c-1b09356e46a9@talpey.com>
 <c1ba07d6-ebfa-ddb9-c25e-e5c1bfbecf74@nvidia.com>
 <15e4a0c0-cadd-e549-962f-8d9aa9fc033a@talpey.com>
 <313bf82d-cdeb-8c75-3772-7a124ecdfbd5@nvidia.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <2aa422df-d5df-5ddb-a2e4-c5e5283653b5@talpey.com>
Date: Wed, 28 Nov 2018 08:59:01 -0500
MIME-Version: 1.0
In-Reply-To: <313bf82d-cdeb-8c75-3772-7a124ecdfbd5@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 11/27/2018 9:52 PM, John Hubbard wrote:
> On 11/27/18 5:21 PM, Tom Talpey wrote:
>> On 11/21/2018 5:06 PM, John Hubbard wrote:
>>> On 11/21/18 8:49 AM, Tom Talpey wrote:
>>>> On 11/21/2018 1:09 AM, John Hubbard wrote:
>>>>> On 11/19/18 10:57 AM, Tom Talpey wrote:
> [...]
>>>>
>>>> What I'd really like to see is to go back to the original fio parameters
>>>> (1 thread, 64 iodepth) and try to get a result that gets at least close
>>>> to the speced 200K IOPS of the NVMe device. There seems to be something
>>>> wrong with yours, currently.
>>>
>>> I'll dig into what has gone wrong with the test. I see fio putting data files
>>> in the right place, so the obvious "using the wrong drive" is (probably)
>>> not it. Even though it really feels like that sort of thing. We'll see.
>>>
>>>>
>>>> Then of course, the result with the patched get_user_pages, and
>>>> compare whichever of IOPS or CPU% changes, and how much.
>>>>
>>>> If these are within a few percent, I agree it's good to go. If it's
>>>> roughly 25% like the result just above, that's a rocky road.
>>>>
>>>> I can try this after the holiday on some basic hardware and might
>>>> be able to scrounge up better. Can you post that github link?
>>>>
>>>
>>> Here:
>>>
>>>      git@github.com:johnhubbard/linux (branch: gup_dma_testing)
>>
>> I'm super-limited here this week hardware-wise and have not been able
>> to try testing with the patched kernel.
>>
>> I was able to compare my earlier quick test with a Bionic 4.15 kernel
>> (400K IOPS) against a similar 4.20rc3 kernel, and the rate dropped to
>> ~_375K_ IOPS. Which I found perhaps troubling. But it was only a quick
>> test, and without your change.
>>
> 
> So just to double check (again): you are running fio with these parameters,
> right?
> 
> [reader]
> direct=1
> ioengine=libaio
> blocksize=4096
> size=1g
> numjobs=1
> rw=read
> iodepth=64

Correct, I copy/pasted these directly. I also ran with size=10g because
the 1g provides a really small sample set.

There was one other difference, your results indicated fio 3.3 was used.
My Bionic install has fio 3.1. I don't find that relevant because our
goal is to compare before/after, which I haven't done yet.

Tom.

> 
> 
> 
>> Say, that branch reports it has not had a commit since June 30. Is that
>> the right one? What about gup_dma_for_lpc_2018?
>>
> 
> That's the right branch, but the AuthorDate for the head commit (only) somehow
> got stuck in the past. I just now amended that patch with a new date and pushed
> it, so the head commit now shows Nov 27:
> 
>     https://github.com/johnhubbard/linux/commits/gup_dma_testing
> 
> 
> The actual code is the same, though. (It is still based on Nov 19th's f2ce1065e767
> commit.)
> 
> 
> thanks,
> 
