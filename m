Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9E71F6B004F
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 09:14:04 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n98DAV8Y030992
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 09:10:31 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n98DDvsn193898
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 09:13:57 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n98DDuwD001317
	for <linux-mm@kvack.org>; Thu, 8 Oct 2009 09:13:57 -0400
Date: Thu, 8 Oct 2009 08:13:56 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2][v2] powerpc: Make the CMM memory hotplug aware
Message-ID: <20091008131355.GA22118@austin.ibm.com>
References: <20091002184458.GC4908@austin.ibm.com> <20091002185248.GD4908@austin.ibm.com> <4ACDD71D.30809@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ACDD71D.30809@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: gerald.schaefer@de.ibm.com
Cc: Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

* Gerald Schaefer (geralds@linux.vnet.ibm.com) wrote:
> Hi,
>
> I am currently working on the s390 port for the cmm + hotplug
> patch, and I'm a little confused about the memory allocation
> policy, see below. Is it correct that the balloon cannot grow
> into ZONE_MOVABLE, while the pages for the balloon page list
> can?
>
> Robert Jennings wrote:
>> @@ -110,6 +125,9 @@ static long cmm_alloc_pages(long nr)
>>  	cmm_dbg("Begin request for %ld pages\n", nr);
>>
>>  	while (nr) {
>> +		if (atomic_read(&hotplug_active))
>> +			break;
>> +
>>  		addr = __get_free_page(GFP_NOIO | __GFP_NOWARN |
>>  				       __GFP_NORETRY | __GFP_NOMEMALLOC);
>>  		if (!addr)
>> @@ -119,8 +137,10 @@ static long cmm_alloc_pages(long nr)
>>  		if (!pa || pa->index >= CMM_NR_PAGES) {
>>  			/* Need a new page for the page list. */
>>  			spin_unlock(&cmm_lock);
>> -			npa = (struct cmm_page_array *)__get_free_page(GFP_NOIO | __GFP_NOWARN |
>> -								       __GFP_NORETRY | __GFP_NOMEMALLOC);
>> +			npa = (struct cmm_page_array *)__get_free_page(
>> +					GFP_NOIO | __GFP_NOWARN |
>> +					__GFP_NORETRY | __GFP_NOMEMALLOC |
>> +					__GFP_MOVABLE);
>>  			if (!npa) {
>>  				pr_info("%s: Can not allocate new page list\n", __func__);
>>  				free_page(addr);
>
> Why is the __GFP_MOVABLE added here, for the page list alloc, and not
> above for the balloon page alloc?

The pages allocated as __GFP_MOVABLE are used to store the list of pages
allocated by the balloon.  They reference virtual addresses and it would
be fine for the kernel to migrate the physical pages for those, the
balloon would not notice this.

The pages loaned by the balloon are not allocated with __GFP_MOVABLE
because we will inform the hypervisor which page has been loaned by
Linux according to the physical address.  Migration of those physical
pages would invalidate the loan, so we do not mark them as movable.

Regards,
Robert Jennings

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
