Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 40FCD6B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 03:00:14 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so9816037wib.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 00:00:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gm10si2296266wib.11.2015.08.06.00.00.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Aug 2015 00:00:12 -0700 (PDT)
Subject: Re: [PATCH v3 3/3] mm: use numa_mem_id() in alloc_pages_node()
References: <1438274071-22551-1-git-send-email-vbabka@suse.cz>
 <1438274071-22551-3-git-send-email-vbabka@suse.cz>
 <20150730174112.GC15257@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55C305F5.8050005@suse.cz>
Date: Thu, 6 Aug 2015 09:00:05 +0200
MIME-Version: 1.0
In-Reply-To: <20150730174112.GC15257@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, cbe-oss-dev@lists.ozlabs.org, kvm@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On 07/30/2015 07:41 PM, Johannes Weiner wrote:
> On Thu, Jul 30, 2015 at 06:34:31PM +0200, Vlastimil Babka wrote:
>> numa_mem_id() is able to handle allocation from CPUs on memory-less nodes,
>> so it's a more robust fallback than the currently used numa_node_id().
>
> Won't it fall through to the next closest memory node in the zonelist
> anyway?

Right, I would expect the zonelist of memoryless node to be the same as 
of the closest node. Documentation/vm/numa seems to agree.

Is this for callers doing NUMA_NO_NODE with __GFP_THISZONE?

I guess that's the only scenario where that matters, yeah. And there 
might well be no such caller now, but maybe some will sneak in without 
the author testing on a system with memoryless node.

Note that with !CONFIG_HAVE_MEMORYLESS_NODES, numa_mem_id() just does 
numa_node_id().

So yeah I think "a more robust fallback" is correct :) But let's put it 
explicitly in changelog then:

----8<----

alloc_pages_node() might fail when called with NUMA_NO_NODE and 
__GFP_THISNODE on a CPU belonging to a memoryless node. To make the 
local-node fallback more robust and prevent such situations, use 
numa_mem_id(), which was introduced for similar scenarios in the slab 
context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
