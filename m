Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA3B6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 03:19:05 -0400 (EDT)
Received: by pdbfa8 with SMTP id fa8so77539130pdb.1
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 00:19:05 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id hj4si34766893pbb.12.2015.08.19.00.19.04
        for <linux-mm@kvack.org>;
        Wed, 19 Aug 2015 00:19:04 -0700 (PDT)
Subject: Re: [Patch V3 2/9] kernel/profile.c: Replace cpu_to_mem() with
 cpu_to_node()
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com>
 <1439781546-7217-3-git-send-email-jiang.liu@linux.intel.com>
 <alpine.DEB.2.10.1508171730260.5527@chino.kir.corp.google.com>
From: Jiang Liu <jiang.liu@linux.intel.com>
Message-ID: <55D42DE3.2040506@linux.intel.com>
Date: Wed, 19 Aug 2015 15:18:59 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1508171730260.5527@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On 2015/8/18 8:31, David Rientjes wrote:
> On Mon, 17 Aug 2015, Jiang Liu wrote:
> 
>> Function profile_cpu_callback() allocates memory without specifying
>> __GFP_THISNODE flag, so replace cpu_to_mem() with cpu_to_node()
>> because cpu_to_mem() may cause suboptimal memory allocation if
>> there's no free memory on the node returned by cpu_to_mem().
>>
> 
> Why is cpu_to_node() better with regard to free memory and NUMA locality?
Hi David,
	Thanks for review. This is a special case pointed out by Tejun.
For the imagined topology, A<->B<->X<->C<->D, where A, B, C, D has
memory and X is memoryless.
Possible fallback lists are:
B: [ B, A, C, D]
X: [ B, C, A, D]
C: [ C, D, B, A]

cpu_to_mem(X) will either return B or C. Let's assume it returns B.
Then we will use "B: [ B, A, C, D]" to allocate memory for X, which
is not the optimal fallback list for X. And cpu_to_node(X) returns
X, and "X: [ B, C, A, D]" is the optimal fallback list for X.
Thanks!
Gerry

> 
>> It's safe to use cpu_to_mem() because build_all_zonelists() also
>> builds suitable fallback zonelist for memoryless node.
>>
> 
> Why reference that cpu_to_mem() is safe if you're changing away from it?
Sorry, it should be cpu_to_node() instead of cpu_to_mem().

> 
>> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
>> ---
>>  kernel/profile.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/kernel/profile.c b/kernel/profile.c
>> index a7bcd28d6e9f..d14805bdcc4c 100644
>> --- a/kernel/profile.c
>> +++ b/kernel/profile.c
>> @@ -336,7 +336,7 @@ static int profile_cpu_callback(struct notifier_block *info,
>>  	switch (action) {
>>  	case CPU_UP_PREPARE:
>>  	case CPU_UP_PREPARE_FROZEN:
>> -		node = cpu_to_mem(cpu);
>> +		node = cpu_to_node(cpu);
>>  		per_cpu(cpu_profile_flip, cpu) = 0;
>>  		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
>>  			page = alloc_pages_exact_node(node,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
