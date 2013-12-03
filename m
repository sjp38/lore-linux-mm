Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f42.google.com (mail-qe0-f42.google.com [209.85.128.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8D06B003B
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 19:48:53 -0500 (EST)
Received: by mail-qe0-f42.google.com with SMTP id b4so13512525qen.29
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 16:48:53 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id u8si14781632qab.119.2013.12.02.16.48.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 16:48:52 -0800 (PST)
Message-ID: <529D2A6F.5050607@ti.com>
Date: Mon, 2 Dec 2013 19:48:47 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/24] mm/memblock: Add memblock memory allocation apis
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com> <1383954120-24368-10-git-send-email-santosh.shilimkar@ti.com> <20131202163136.f31f39c5940c0ba6d20f4a00@linux-foundation.org>
In-Reply-To: <20131202163136.f31f39c5940c0ba6d20f4a00@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, Grygorii Strashko <grygorii.strashko@ti.com>

On Monday 02 December 2013 07:31 PM, Andrew Morton wrote:
> On Fri, 8 Nov 2013 18:41:45 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:
> 
>> Introduce memblock memory allocation APIs which allow to support
>> PAE or LPAE extension on 32 bits archs where the physical memory start
>> address can be beyond 4GB. In such cases, existing bootmem APIs which
>> operate on 32 bit addresses won't work and needs memblock layer which
>> operates on 64 bit addresses.
>>
>> So we add equivalent APIs so that we can replace usage of bootmem
>> with memblock interfaces. Architectures already converted to NO_BOOTMEM
>> use these new interfaces and other which still uses bootmem, these new
>> APIs just fallback to exiting bootmem APIs. So no functional change as
>> such.
>>
>> In long run, once all the achitectures moves to NO_BOOTMEM, we can get rid of
>> bootmem layer completely. This is one step to remove the core code dependency
>> with bootmem and also gives path for architectures to move away from bootmem.
>>
>> The proposed interface will became active if both CONFIG_HAVE_MEMBLOCK
>> and CONFIG_NO_BOOTMEM are specified by arch. In case !CONFIG_NO_BOOTMEM,
>> the memblock() wrappers will fallback to the existing bootmem apis so
>> that arch's not converted to NO_BOOTMEM continue to work as is.
>>
>> The meaning of MEMBLOCK_ALLOC_ACCESSIBLE and MEMBLOCK_ALLOC_ANYWHERE is
>> kept same.
>>
>> ...
>>
>> +static void * __init _memblock_virt_alloc_try_nid_nopanic(
>> +				phys_addr_t size, phys_addr_t align,
>> +				phys_addr_t from, phys_addr_t max_addr,
>> +				int nid)
>> +{
>> +	phys_addr_t alloc;
>> +	void *ptr;
>> +
>> +	if (WARN_ON_ONCE(slab_is_available())) {
>> +		if (nid == MAX_NUMNODES)
>> +			return kzalloc(size, GFP_NOWAIT);
>> +		else
>> +			return kzalloc_node(size, GFP_NOWAIT, nid);
>> +	}
> 
> The use of MAX_NUMNODES is a bit unconventional here.  I *think* we
> generally use NUMA_NO_NODE to indicate "don't care".  I Also *think*
> that if this code did s/MAX_NUMNODES/NUMA_NO_NODE/g then the above
> simply becomes
> 
> 	return kzalloc_node(size, GFP_NOWAIT, nid);
> 
> and kzalloc_node() handles NUMA_NO_NODE appropriately.
> 
> I *think* ;)  Please check all this.
> 
I guess same comment was given by Tejun as well. We didn't
address that in this series mainly because when NO_BOOTMEM
are not enabled, all calls of the new APIs will
be redirected to bootmem  where MAX_NUMNODES is used.

Also, memblock core APIs __next_free_mem_range_rev() and
__next_free_mem_range() would need to be updated, and as result
we will need to re-check/update all direct calls of
memblock_alloc_xxx() APIs (including nobootmem).

So to keep behavior consistent with and without NO_BOOTMEM, we
used MAX_NUMNODES. Once we get a stage where we can remove
the bootmem.c, it should be easy to update the code
to use NUMA_NO_NODE without too much churn.

Regards,
Santosh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
