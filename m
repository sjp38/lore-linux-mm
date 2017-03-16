Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2EB6B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 09:26:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x124so6567034wmf.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:26:59 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id e68si4560814wmd.118.2017.03.16.06.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 06:26:57 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id u132so35133204wmg.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 06:26:57 -0700 (PDT)
Subject: Re: MAP_POPULATE vs. MADV_HUGEPAGES
References: <e134e521-54eb-9ae0-f379-26f38703478e@scylladb.com>
 <20170316123449.GE30508@dhcp22.suse.cz>
From: Avi Kivity <avi@scylladb.com>
Message-ID: <4e1011d9-aef3-5cd7-1424-b81aa79128cb@scylladb.com>
Date: Thu, 16 Mar 2017 15:26:54 +0200
MIME-Version: 1.0
In-Reply-To: <20170316123449.GE30508@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 03/16/2017 02:34 PM, Michal Hocko wrote:
> On Wed 15-03-17 18:50:32, Avi Kivity wrote:
>> A user is trying to allocate 1TB of anonymous memory in parallel on 48 cores
>> (4 NUMA nodes).  The kernel ends up spinning in isolate_freepages_block().
> Which kernel version is that?

A good question; it was 3.10.something-el.something.  The user mentioned 
above updated to 4.4, and the problem was gone, so it looks like it is a 
Red Hat specific problem.  I would really like the 3.10.something kernel 
to handle this workload well, but I understand that's not this list's 
concern.

> What is the THP defrag mode
> (/sys/kernel/mm/transparent_hugepage/defrag)?

The default (always).

>   
>> I thought to help it along by using MAP_POPULATE, but then my MADV_HUGEPAGE
>> won't be seen until after mmap() completes, with pages already populated.
>> Are MAP_POPULATE and MADV_HUGEPAGE mutually exclusive?
> Why do you need MADV_HUGEPAGE?

So that I get huge pages even if transparent_hugepage/enabled=madvise.  
I'm allocating almost all of the memory of that machine to be used as a 
giant cache, so I want it backed by hugepages.

>   
>> Is my only option to serialize those memory allocations, and fault in those
>> pages manually?  Or perhaps use mlock()?
> I am still not 100% sure I see what you are trying to achieve, though.
> So you do not want all those processes to contend inside the compaction
> while still allocate as many huge pages as possible?

Since the process starts with all of that memory free, there should not 
be any compaction going on (or perhaps very minimal eviction/movement of 
a few pages here and there).  And since it's fixed in later kernels, it 
looks like the contention was not really mandated by the workload, just 
an artifact of the implementation.

To explain the workload again, the process starts, clones as many 
threads as there are logical processors, and each of those threads 
mmap()s (and mbind()s) a chunk of memory and then proceeds to touch it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
