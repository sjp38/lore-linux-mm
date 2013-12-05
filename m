Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5DB6B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 10:37:07 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id c9so3620280qcz.2
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 07:37:06 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id x9si621668qat.57.2013.12.05.07.37.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 07:37:05 -0800 (PST)
Message-ID: <52A0AB34.2030703@ti.com>
Date: Thu, 5 Dec 2013 18:35:00 +0200
From: Grygorii Strashko <grygorii.strashko@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation
 apis
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com> <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com> <20131203232445.GX8277@htj.dyndns.org>
In-Reply-To: <20131203232445.GX8277@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hi Tejun,

On 12/04/2013 01:24 AM, Tejun Heo wrote:
> Hello,
> 
> On Mon, Dec 02, 2013 at 09:27:23PM -0500, Santosh Shilimkar wrote:
>> So we add equivalent APIs so that we can replace usage of bootmem
>> with memblock interfaces. Architectures already converted to NO_BOOTMEM
>> use these new interfaces and other which still uses bootmem, these new
>> APIs just fallback to exiting bootmem APIs. So no functional change as
>> such.
> 
> The last part of the second last sentence doesn't parse too well.  I
> think it'd be worthwhile to improve and preferably expand on it as
> this is a bit tricky to understand given the twisted state of early
> memory allocation.
> 
>> In long run, once all the achitectures moves to NO_BOOTMEM, we can get rid of
>> bootmem layer completely. This is one step to remove the core code dependency
>> with bootmem and also gives path for architectures to move away from bootmem.
> 
> Lines too long?
> 

[...]

> 
>> +/* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
>> +void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
>> +		phys_addr_t align, phys_addr_t from,
>> +		phys_addr_t max_addr, int nid);
> 
> Wouldn't @min_addr instead of @from make more sense?  Ditto for other
> occurrences.
> 
>> +void *memblock_virt_alloc_try_nid(phys_addr_t size, phys_addr_t align,
>> +		phys_addr_t from, phys_addr_t max_addr, int nid);
>> +void __memblock_free_early(phys_addr_t base, phys_addr_t size);
>> +void __memblock_free_late(phys_addr_t base, phys_addr_t size);
>> +
>> +#define memblock_virt_alloc(x) \
>> +	memblock_virt_alloc_try_nid(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT, \
>> +				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
> 
> The underlying function interprets 0 as the default align, so it
> probably is a better idea to just use 0 here.
> 
>> +#define memblock_virt_alloc_align(x, align) \
>> +	memblock_virt_alloc_try_nid(x, align, BOOTMEM_LOW_LIMIT, \
>> +				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
> 
> Also, do we really need this align variant separate when the caller
> can simply specify 0 for the default?

Unfortunately Yes. 
We need it to keep compatibility with bootmem/nobootmem
which don't handle 0 as default align value.

> 
>> +#define memblock_virt_alloc_nopanic(x) \
>> +	memblock_virt_alloc_try_nid_nopanic(x, SMP_CACHE_BYTES, \
>> +					     BOOTMEM_LOW_LIMIT, \
>> +					     BOOTMEM_ALLOC_ACCESSIBLE, \
>> +					     MAX_NUMNODES)
>> +#define memblock_virt_alloc_align_nopanic(x, align) \
>> +	memblock_virt_alloc_try_nid_nopanic(x, align, \
>> +					     BOOTMEM_LOW_LIMIT, \
>> +					     BOOTMEM_ALLOC_ACCESSIBLE, \
>> +					     MAX_NUMNODES)
>> +#define memblock_virt_alloc_node(x, nid) \
>> +	memblock_virt_alloc_try_nid(x, SMP_CACHE_BYTES, BOOTMEM_LOW_LIMIT, \
>> +				     BOOTMEM_ALLOC_ACCESSIBLE, nid)
>> +#define memblock_virt_alloc_node_nopanic(x, nid) \

Regards,
- grygorii

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
