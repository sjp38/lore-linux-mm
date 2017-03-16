Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 45CF46B038B
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 10:56:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b140so10977184wme.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 07:56:39 -0700 (PDT)
Received: from mail-wr0-x22e.google.com (mail-wr0-x22e.google.com. [2a00:1450:400c:c0c::22e])
        by mx.google.com with ESMTPS id 100si6974034wrb.160.2017.03.16.07.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 07:56:37 -0700 (PDT)
Received: by mail-wr0-x22e.google.com with SMTP id u48so33853326wrc.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 07:56:37 -0700 (PDT)
Subject: Re: MAP_POPULATE vs. MADV_HUGEPAGES
References: <e134e521-54eb-9ae0-f379-26f38703478e@scylladb.com>
 <20170316123449.GE30508@dhcp22.suse.cz>
 <4e1011d9-aef3-5cd7-1424-b81aa79128cb@scylladb.com>
 <20170316144832.GJ30501@dhcp22.suse.cz>
From: Avi Kivity <avi@scylladb.com>
Message-ID: <53e8bb71-5bf2-2690-f605-aa4d5d50eb90@scylladb.com>
Date: Thu, 16 Mar 2017 16:56:34 +0200
MIME-Version: 1.0
In-Reply-To: <20170316144832.GJ30501@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 03/16/2017 04:48 PM, Michal Hocko wrote:
> On Thu 16-03-17 15:26:54, Avi Kivity wrote:
>>
>> On 03/16/2017 02:34 PM, Michal Hocko wrote:
>>> On Wed 15-03-17 18:50:32, Avi Kivity wrote:
>>>> A user is trying to allocate 1TB of anonymous memory in parallel on 48 cores
>>>> (4 NUMA nodes).  The kernel ends up spinning in isolate_freepages_block().
>>> Which kernel version is that?
>> A good question; it was 3.10.something-el.something.  The user mentioned
>> above updated to 4.4, and the problem was gone, so it looks like it is a Red
>> Hat specific problem.  I would really like the 3.10.something kernel to
>> handle this workload well, but I understand that's not this list's concern.
>>
>>> What is the THP defrag mode
>>> (/sys/kernel/mm/transparent_hugepage/defrag)?
>> The default (always).
> the default has changed since then because the THP faul latencies were
> just too large. Currently we only allow madvised VMAs to go stall and
> even then we try hard to back off sooner rather than later. See
> 444eb2a449ef ("mm: thp: set THP defrag by default to madvise and add a
> stall-free defrag option") merged in 4.4

I see, thanks.  So the 4.4 behavior is better mostly due to not trying 
so hard.

>   
>>>> I thought to help it along by using MAP_POPULATE, but then my MADV_HUGEPAGE
>>>> won't be seen until after mmap() completes, with pages already populated.
>>>> Are MAP_POPULATE and MADV_HUGEPAGE mutually exclusive?
>>> Why do you need MADV_HUGEPAGE?
>> So that I get huge pages even if transparent_hugepage/enabled=madvise.  I'm
>> allocating almost all of the memory of that machine to be used as a giant
>> cache, so I want it backed by hugepages.
> Is there any strong reason to not use hugetlb then? You probably want
> that memory reclaimable, right?

Did you mean hugetlbfs?  It's a pain to configure, and often requires a 
reboot.

We support it via an option, but we prefer the user's first experience 
with the application not to be "configure this kernel parameter and reboot".

We don't particularly need that memory to be reclaimable (and in fact we 
have an option to mlock() it; if it gets swapped, application 
performance tanks).

>
>>>> Is my only option to serialize those memory allocations, and fault in those
>>>> pages manually?  Or perhaps use mlock()?
>>> I am still not 100% sure I see what you are trying to achieve, though.
>>> So you do not want all those processes to contend inside the compaction
>>> while still allocate as many huge pages as possible?
>> Since the process starts with all of that memory free, there should not be
>> any compaction going on (or perhaps very minimal eviction/movement of a few
>> pages here and there).  And since it's fixed in later kernels, it looks like
>> the contention was not really mandated by the workload, just an artifact of
>> the implementation.
> It is possible. A lot has changed since 3.10 times.

Like the default behavior :).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
