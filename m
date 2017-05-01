Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72A3F6B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 16:41:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b67so26117787pfk.0
        for <linux-mm@kvack.org>; Mon, 01 May 2017 13:41:58 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id n128si15199982pga.108.2017.05.01.13.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 13:41:57 -0700 (PDT)
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
References: <20170419075242.29929-1-bsingharora@gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <91272c14-81df-9529-f0ae-6abb17a694ea@nvidia.com>
Date: Mon, 1 May 2017 13:41:55 -0700
MIME-Version: 1.0
In-Reply-To: <20170419075242.29929-1-bsingharora@gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On 04/19/2017 12:52 AM, Balbir Singh wrote:
> This is a request for comments on the discussed approaches
> for coherent memory at mm-summit (some of the details are at
> https://lwn.net/Articles/717601/). The latest posted patch
> series is at https://lwn.net/Articles/713035/. I am reposting
> this as RFC, Michal Hocko suggested using HMM for CDM, but
> we believe there are stronger reasons to use the NUMA approach.
> The earlier patches for Coherent Device memory were implemented
> and designed by Anshuman Khandual.
> 

Hi Balbir,

Although I think everyone agrees that in the [very] long term, these 
hardware-coherent nodes probably want to be NUMA nodes, in order to decide what to 
code up over the next few years, we need to get a clear idea of what has to be done 
for each possible approach.

Here, the CDM discussion is falling just a bit short, because it does not yet 
include the whole story of what we would need to do. Earlier threads pointed this 
out: the idea started as a large patchset RFC, but then, "for ease of review", it 
got turned into a smaller RFC, which loses too much context.

So, I'd suggest putting together something more complete, so that it can be fairly 
compared against the HMM-for-hardware-coherent-nodes approach.


> Jerome posted HMM-CDM at https://lwn.net/Articles/713035/.
> The patches do a great deal to enable CDM with HMM, but we
> still believe that HMM with CDM is not a natural way to
> represent coherent device memory and the mm will need
> to be audited and enhanced for it to even work.

That is also true for the CDM approach. Specifically, in order for this to be of any 
use to device drivers, we'll need the following:

1. A way to move pages between NUMA nodes, both virtual address and physical 
address-based, from kernel mode.

2. A way to provide reverse mapping information to device drivers, even if 
indirectly. (I'm not proposing exposing rmap, but this has to be thought through, 
because at some point, a device will need to do something with a physical page.)

This strikes me as the hardest part of the problem.

3. Detection and mitigation of page thrashing between NUMA nodes (shared 
responsibility between core -mm and device driver, but probably missing some APIs 
today).

4. Handling of oversubscription (allocating more memory than is physically on a NUMA 
node, by evicting "LRU-like" pages, rather than the current fallback to other NUMA 
nodes). Similar to (3) with respect to where we're at today.

5. Something to handle the story of bringing NUMA nodes online and putting them back 
offline, given that they require a device driver that may not yet have been loaded. 
There are a few minor missing bits there.

thanks,

--
John Hubbard
NVIDIA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
