Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 60A766B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 19:52:47 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so2156432yha.0
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 16:52:47 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id y62si3690983yhc.194.2013.12.13.16.52.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 16:52:46 -0800 (PST)
Message-ID: <52ABABDA.4020808@ti.com>
Date: Fri, 13 Dec 2013 19:52:42 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 08/23] mm/memblock: Add memblock memory allocation
 apis
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com> <1386625856-12942-9-git-send-email-santosh.shilimkar@ti.com> <20131213213735.GM27070@htj.dyndns.org>
In-Reply-To: <20131213213735.GM27070@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

On Friday 13 December 2013 04:37 PM, Tejun Heo wrote:
> On Mon, Dec 09, 2013 at 04:50:41PM -0500, Santosh Shilimkar wrote:
>> Introduce memblock memory allocation APIs which allow to support
>> PAE or LPAE extension on 32 bits archs where the physical memory
>> start address can be beyond 4GB. In such cases, existing bootmem
>> APIs which operate on 32 bit addresses won't work and needs
>> memblock layer which operates on 64 bit addresses.
> 
> The overall API looks good to me.  Thanks for doing this!
> 
>> +static void * __init memblock_virt_alloc_internal(
>> +				phys_addr_t size, phys_addr_t align,
>> +				phys_addr_t min_addr, phys_addr_t max_addr,
>> +				int nid)
>> +{
>> +	phys_addr_t alloc;
>> +	void *ptr;
>> +
>> +	if (nid == MAX_NUMNODES)
>> +		pr_warn("%s: usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE\n",
>> +			__func__);
> 
> Why not use WARN_ONCE()?  Also, shouldn't nid be set to NUMA_NO_NODE
> here?
> 
You want all the users using MAX_NUMNODES to know about it so that
the wrong usage can be fixed. WARN_ONCE will hide that.

> ...
>> +	if (nid != NUMA_NO_NODE) {
> 
> Otherwise, the above test is broken.
> 
So the idea was just to warn the users and allow them to fix
the code. Well we are just allowing the existing users of using
either MAX_NUMNODES or NUMA_NO_NODE continue to work. Thats what
we discussed, right ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
