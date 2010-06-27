Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4570D6B01AD
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 04:22:27 -0400 (EDT)
Message-ID: <4C270A09.3070305@kernel.org>
Date: Sun, 27 Jun 2010 10:21:29 +0200
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [S+Q 02/16] [PATCH 1/2] percpu: make @dyn_size always mean min
 dyn_size in first chunk init functions
References: <20100625212026.810557229@quilx.com> <20100625212102.196049458@quilx.com> <alpine.DEB.2.00.1006262155260.12531@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1006262155260.12531@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

Hello,

On 06/27/2010 07:06 AM, David Rientjes wrote:
> On Fri, 25 Jun 2010, Christoph Lameter wrote:
> 
>> In pcpu_alloc_info()
> 
> You mean pcpu_build_alloc_info()?

Yeap.

>> @@ -105,7 +105,7 @@ extern struct pcpu_alloc_info * __init p
>>  extern void __init pcpu_free_alloc_info(struct pcpu_alloc_info *ai);
>>  
>>  extern struct pcpu_alloc_info * __init pcpu_build_alloc_info(
>> -				size_t reserved_size, ssize_t dyn_size,
>> +				size_t reserved_size, size_t dyn_size,
>>  				size_t atom_size,
>>  				pcpu_fc_cpu_distance_fn_t cpu_distance_fn);
>>  
> 
> This can just be removed entirely, it's unnecessarily global.

Oh yeah, it's not used outside mm/percpu.c anymore.  I'll make it
static.

>>  /**
>>   * pcpu_alloc_alloc_info - allocate percpu allocation info
>>   * @nr_groups: the number of groups
>> @@ -1060,7 +1046,7 @@ void __init pcpu_free_alloc_info(struct 
>>  /**
>>   * pcpu_build_alloc_info - build alloc_info considering distances between CPUs
>>   * @reserved_size: the size of reserved percpu area in bytes
>> - * @dyn_size: free size for dynamic allocation in bytes, -1 for auto
>> + * @dyn_size: free size for dynamic allocation in bytes
> 
> It's the minimum free size, it's not necessarily the exact size due to 
> round-up.

Will update.

>>  struct pcpu_alloc_info * __init pcpu_build_alloc_info(
>> -				size_t reserved_size, ssize_t dyn_size,
>> +				size_t reserved_size, size_t dyn_size,
>>  				size_t atom_size,
>>  				pcpu_fc_cpu_distance_fn_t cpu_distance_fn)
>>  {
>> @@ -1098,13 +1084,15 @@ struct pcpu_alloc_info * __init pcpu_bui
>>  	memset(group_map, 0, sizeof(group_map));
>>  	memset(group_cnt, 0, sizeof(group_map));
>>  
>> +	size_sum = PFN_ALIGN(static_size + reserved_size + dyn_size);
>> +	dyn_size = size_sum - static_size - reserved_size;
> 
> Ok, so the only purpose of "dyn_size" is to store in the struct 
> pcpu_alloc_info later.  Before this patch, ai->dyn_size would always be 0 
> if that's what was passed to pcpu_build_alloc_info(), but due to this 
> arithmetic it now requires that static_size + reserved_size to be pfn 
> aligned.  Where is that enforced or do we not care?

I'm not really following you, but

* Nobody called pcpu_build_alloc_info() w/ zero dyn_size.  It was
  either -1 or positive minimum size.

* None of static_size, reserved_size or dyn_size needs to be page
  aligned.

Thanks for the review.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
