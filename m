Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 738546B0007
	for <linux-mm@kvack.org>; Sat, 20 Oct 2018 12:33:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c26-v6so21791934eda.7
        for <linux-mm@kvack.org>; Sat, 20 Oct 2018 09:33:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o16-v6sor9369205ejc.45.2018.10.20.09.33.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Oct 2018 09:33:20 -0700 (PDT)
Date: Sat, 20 Oct 2018 16:33:18 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC] put page to pcp->lists[] tail if it is not on the same node
Message-ID: <20181020163318.72oqszgdtqfafycu@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181019043303.s5axhjfb2v2lzsr3@master>
 <20181019083818.GQ5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181019083818.GQ5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Wei Yang <richard.weiyang@gmail.com>, willy@infradead.org, mhocko@suse.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, Oct 19, 2018 at 09:38:18AM +0100, Mel Gorman wrote:
>On Fri, Oct 19, 2018 at 04:33:03AM +0000, Wei Yang wrote:
>> node
>> Reply-To: Wei Yang <richard.weiyang@gmail.com>
>> 
>> Masters,
>> 
>> During the code reading, I pop up this idea.
>> 
>>     In case we put some intelegence of NUMA node to pcp->lists[], we may
>>     get a better performance.
>> 
>
>Why?
>
>> The idea is simple:
>> 
>>     Put page on other nodes to the tail of pcp->lists[], because we
>>     allocate from head and free from tail.
>> 
>
>Pages from remote nodes are not placed on local lists. Even in the slab
>context, such objects are placed on alien caches which have special
>handling.
>

Hmm... I am not sure get your point correctly.

As I mentioned in the reply to Vlastimil, every zone has a
per_cpu_pageset for each cpu. For those per_cpu_pageset of one zone, it
will only contains pages from this zone. This means, some of
per_cpu_pageset will have the pages with the same node id, while others
not.

I don't get your point for the slab context. They use a different list
instead of pcp->lists[]? If you could give me some hint, I may catch up.

>> Since my desktop just has one numa node, I couldn't test the effect.
>
>I suspect it would eventually cause a crash or at least weirdness as the
>page zone ids would not match due to different nodes.
>

If my analysis is correct, there are only two relationship between page
node_id of those pages in pcp and the pcp's node_id, either the same or
not.

Let me have a try with qemu emulated numa system. :-)

>> Sorry for sending this without a real justification. Hope this will not
>> make you uncomfortable. I would be very glad if you suggest some
>> verifications that I could do.
>> 
>> Below is my testing patch, look forward your comments.
>> 
>
>I commend you trying to understand how the page allocator works but I
>suggest you take a step back, pick a workload that is of interest and
>profile it to see where hot spots are that may pinpoint where an
>improvement can be made.
>
>-- 
>Mel Gorman
>SUSE Labs

-- 
Wei Yang
Help you, Help me
