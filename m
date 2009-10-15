Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 33D456B004F
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 14:22:36 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.1/8.13.1) with ESMTP id n9FILVYx015215
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 18:21:31 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9FILPCO1237092
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 20:21:31 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9FILMIO014677
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 20:21:25 +0200
Message-ID: <4AD7681C.7060800@linux.vnet.ibm.com>
Date: Thu, 15 Oct 2009 20:21:16 +0200
From: Gerald Schaefer <geralds@linux.vnet.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/2][v2] powerpc: Make the CMM memory hotplug aware
References: <20091002184458.GC4908@austin.ibm.com> <20091002185248.GD4908@austin.ibm.com> <4ACDD71D.30809@linux.vnet.ibm.com> <20091008131355.GA22118@austin.ibm.com>
In-Reply-To: <20091008131355.GA22118@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Robert Jennings <rcj@linux.vnet.ibm.com>
Cc: gerald.schaefer@de.ibm.com, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Robert Jennings wrote:
>>> @@ -110,6 +125,9 @@ static long cmm_alloc_pages(long nr)
>>>  	cmm_dbg("Begin request for %ld pages\n", nr);
>>>
>>>  	while (nr) {
>>> +		if (atomic_read(&hotplug_active))
>>> +			break;
>>> +
>>>  		addr = __get_free_page(GFP_NOIO | __GFP_NOWARN |
>>>  				       __GFP_NORETRY | __GFP_NOMEMALLOC);
>>>  		if (!addr)
>>> @@ -119,8 +137,10 @@ static long cmm_alloc_pages(long nr)
>>>  		if (!pa || pa->index >= CMM_NR_PAGES) {
>>>  			/* Need a new page for the page list. */
>>>  			spin_unlock(&cmm_lock);
>>> -			npa = (struct cmm_page_array *)__get_free_page(GFP_NOIO | __GFP_NOWARN |
>>> -								       __GFP_NORETRY | __GFP_NOMEMALLOC);
>>> +			npa = (struct cmm_page_array *)__get_free_page(
>>> +					GFP_NOIO | __GFP_NOWARN |
>>> +					__GFP_NORETRY | __GFP_NOMEMALLOC |
>>> +					__GFP_MOVABLE);
>>>  			if (!npa) {
>>>  				pr_info("%s: Can not allocate new page list\n", __func__);
>>>  				free_page(addr);
>> Why is the __GFP_MOVABLE added here, for the page list alloc, and not
>> above for the balloon page alloc?
> 
> The pages allocated as __GFP_MOVABLE are used to store the list of pages
> allocated by the balloon.  They reference virtual addresses and it would
> be fine for the kernel to migrate the physical pages for those, the
> balloon would not notice this.

Does page migration really work for kernel pages that were allocated
with __get_free_page()? I was wondering if we can do this on s390, where
we have a 1:1 mapping of kernel virtual to physical addresses, but
looking at migrate_pages() and friends, it seems that kernel pages
w/o mapping and rmap should not be migrateable at all. Any thoughts from
the memory migration experts?

BTW, since we have real memory hotplug support on s390, allowing us
to add and remove memory chunks to/from ZONE_MOVABLE, this basically
makes cmm ballooning in ZONE_NORMAL obsolete, so we decided not to
support memory hotplug aware cmm on s390.

Regards,
Gerald

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
