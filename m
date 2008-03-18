Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2I1C0JR010427
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 06:42:00 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2I1C0Oh1040472
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 06:42:00 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2I1C4v6002113
	for <linux-mm@kvack.org>; Tue, 18 Mar 2008 01:12:06 GMT
Message-ID: <47DF167D.9040405@linux.vnet.ibm.com>
Date: Tue, 18 Mar 2008 06:40:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][2/3] Account and control virtual address space allocations
References: <20080316173005.8812.88290.sendpatchset@localhost.localdomain> <20080317233552.4A7E21E7CE6@siro.lan>
In-Reply-To: <20080317233552.4A7E21E7CE6@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-mm@kvack.org, hugh@veritas.com, skumar@linux.vnet.ibm.com, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, rientjes@google.com, xemul@openvz.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> diff -puN mm/swapfile.c~memory-controller-virtual-address-space-accounting-and-control mm/swapfile.c
>> diff -puN mm/memory.c~memory-controller-virtual-address-space-accounting-and-control mm/memory.c
>> --- linux-2.6.25-rc5/mm/memory.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-16 22:57:40.000000000 +0530
>> +++ linux-2.6.25-rc5-balbir/mm/memory.c	2008-03-16 22:57:40.000000000 +0530
>> @@ -838,6 +838,11 @@ unsigned long unmap_vmas(struct mmu_gath
>>  
>>  		if (vma->vm_flags & VM_ACCOUNT)
>>  			*nr_accounted += (end - start) >> PAGE_SHIFT;
>> +		/*
>> +		 * Unaccount used virtual memory for cgroups
>> +		 */
>> +		mem_cgroup_update_as(vma->vm_mm,
>> +					((long)(start - end)) >> PAGE_SHIFT);
>>  
>>  		while (start != end) {
>>  			if (!tlb_start_valid) {
> 
> i think you can sum and uncharge it with a single call.
> 

Like nr_accounted? I'll have to duplicate nr_accounted since that depends
conditionally on VM_ACCOUNT.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
