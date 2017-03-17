Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 93E2E6B038C
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:30:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y90so15050891wrb.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:30:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d1si12156286wra.198.2017.03.17.11.30.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 11:30:27 -0700 (PDT)
Subject: Re: [PATCH v3 0/8] try to reduce fragmenting fallbacks
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170308164631.GA12130@cmpxchg.org>
 <fbc47cf0-2f8f-defc-cd79-50395e9985a7@suse.cz>
 <20170316183422.GA1461@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0e01d912-9473-35df-5bc7-f080ab9c1818@suse.cz>
Date: Fri, 17 Mar 2017 19:29:54 +0100
MIME-Version: 1.0
In-Reply-To: <20170316183422.GA1461@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com

On 03/16/2017 07:34 PM, Johannes Weiner wrote:
> On Wed, Mar 08, 2017 at 08:17:39PM +0100, Vlastimil Babka wrote:
>> On 8.3.2017 17:46, Johannes Weiner wrote:
>>> Is there any other data you would like me to gather?
>>
>> If you can enable the extfrag tracepoint, it would be nice to have graphs of how
>> unmovable allocations falling back to movable pageblocks, etc.
> 
> Okay, here we go. I recorded 24 hours worth of the extfrag tracepoint,
> filtered to fallbacks from unmovable requests to movable blocks. I've
> uploaded the plot here:
> 
> http://cmpxchg.org/antifrag/fallbackrate.png
> 
> but this already speaks for itself:
> 
> 11G     alloc-mtfallback.trace
> 3.3G    alloc-mtfallback-patched.trace
> 
> ;)

Great!

>> Possibly also /proc/pagetypeinfo for numbers of pageblock types.

> After a week of uptime, the patched (b) kernel has more movable blocks
> than vanilla 4.10-rc8 (a):
> 
>    Number of blocks type     Unmovable      Movable  Reclaimable   HighAtomic          CMA      Isolate
> 
> a: Node 1, zone   Normal         2017        29763          987            1            0            0
> b: Node 1, zone   Normal         1264        30850          653            1            0            0

That's better than I expected. I wouldn't be surprised if the number of
unmovable pageblocks actually got *higher* due to the series because
previously many unmovable pages would be scattered around movable blocks.

> I sampled this somewhat sporadically over the week and it's been
> reading reliably this way.
> 
> The patched kernel also consistently beats vanilla in terms of peak
> job throughput.
> 
> Overall very cool!

Thanks a lot! So that means it's worth the increased compaction stats
you reported earlier?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
