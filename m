Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E5F8B6B0253
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 22:35:55 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so13257682pab.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 19:35:55 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id qd10si71060998pac.116.2015.10.08.19.35.54
        for <linux-mm@kvack.org>;
        Thu, 08 Oct 2015 19:35:55 -0700 (PDT)
Subject: Re: [Patch V3 2/9] kernel/profile.c: Replace cpu_to_mem() with
 cpu_to_node()
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <1439781546-7217-3-git-send-email-jiang.liu@linux.intel.com>
 <alpine.DEB.2.10.1508171730260.5527@chino.kir.corp.google.com>
 <55D42DE3.2040506@linux.intel.com>
 <alpine.DEB.2.10.1508191657330.30666@chino.kir.corp.google.com>
From: Jiang Liu <jiang.liu@linux.intel.com>
Message-ID: <56172807.4090906@linux.intel.com>
Date: Fri, 9 Oct 2015 10:35:51 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1508191657330.30666@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On 2015/8/20 8:00, David Rientjes wrote:
> On Wed, 19 Aug 2015, Jiang Liu wrote:
> 
>> On 2015/8/18 8:31, David Rientjes wrote:
>>> On Mon, 17 Aug 2015, Jiang Liu wrote:
>>>
>>>> Function profile_cpu_callback() allocates memory without specifying
>>>> __GFP_THISNODE flag, so replace cpu_to_mem() with cpu_to_node()
>>>> because cpu_to_mem() may cause suboptimal memory allocation if
>>>> there's no free memory on the node returned by cpu_to_mem().
>>>>
>>>
>>> Why is cpu_to_node() better with regard to free memory and NUMA locality?
>> Hi David,
>> 	Thanks for review. This is a special case pointed out by Tejun.
>> For the imagined topology, A<->B<->X<->C<->D, where A, B, C, D has
>> memory and X is memoryless.
>> Possible fallback lists are:
>> B: [ B, A, C, D]
>> X: [ B, C, A, D]
>> C: [ C, D, B, A]
>>
>> cpu_to_mem(X) will either return B or C. Let's assume it returns B.
>> Then we will use "B: [ B, A, C, D]" to allocate memory for X, which
>> is not the optimal fallback list for X. And cpu_to_node(X) returns
>> X, and "X: [ B, C, A, D]" is the optimal fallback list for X.
> 
> Ok, that makes sense, but I would prefer that this 
> alloc_pages_exact_node() change to alloc_pages_node() since, as you 
> mention in your commit message, __GFP_THISNODE is not set.
Hi David,
	Sorry for slow response due to personal reasons!
	Function alloc_pages_exact_node() has been renamed as
__alloc_pages_node() by commit 96db800f5d73, and __alloc_pages_node()
is a slightly optimized version of alloc_pages_node() which doesn't
fallback to current node for nid == NUMA_NO_NODE case. So it would
be better to keep using __alloc_pages_node() because cpu_to_node()
always returns valid node id.
Thanks!
Gerry

> 
> In the longterm, if we setup both zonelists correctly (no __GFP_THISNODE 
> and with __GFP_THISNODE), then I'm not sure there's any reason to ever use 
> cpu_to_mem() for alloc_pages().
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
