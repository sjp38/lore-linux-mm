Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA3F6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 06:21:40 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 184so30835096pff.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 03:21:40 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [125.16.236.7])
        by mx.google.com with ESMTPS id q82si3707381pfi.220.2016.04.06.03.21.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 06 Apr 2016 03:21:39 -0700 (PDT)
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 6 Apr 2016 15:51:37 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u36ALXfP4063704
	for <linux-mm@kvack.org>; Wed, 6 Apr 2016 15:51:33 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u36FkphC001581
	for <linux-mm@kvack.org>; Wed, 6 Apr 2016 21:19:53 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] powerpc/mm: Add memory barrier in __hugepte_alloc()
In-Reply-To: <20160406095623.GA24283@dhcp22.suse.cz>
References: <20160405190547.GA12673@us.ibm.com> <20160406095623.GA24283@dhcp22.suse.cz>
Date: Wed, 06 Apr 2016 15:39:17 +0530
Message-ID: <8737qzxd4i.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, James Dykman <jdykman@us.ibm.com>

Michal Hocko <mhocko@kernel.org> writes:

> [ text/plain ]
> On Tue 05-04-16 12:05:47, Sukadev Bhattiprolu wrote:
> [...]
>> diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
>> index d991b9e..081f679 100644
>> --- a/arch/powerpc/mm/hugetlbpage.c
>> +++ b/arch/powerpc/mm/hugetlbpage.c
>> @@ -81,6 +81,13 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
>>  	if (! new)
>>  		return -ENOMEM;
>>  
>> +	/*
>> +	 * Make sure other cpus find the hugepd set only after a
>> +	 * properly initialized page table is visible to them.
>> +	 * For more details look for comment in __pte_alloc().
>> +	 */
>> +	smp_wmb();
>> +
>
> what is the pairing memory barrier?
>
>>  	spin_lock(&mm->page_table_lock);
>>  #ifdef CONFIG_PPC_FSL_BOOK3E
>>  	/*

This is documented in __pte_alloc(). I didn't want to repeat the same
here.

	/*
	 * Ensure all pte setup (eg. pte page lock and page clearing) are
	 * visible before the pte is made visible to other CPUs by being
	 * put into page tables.
	 *
	 * The other side of the story is the pointer chasing in the page
	 * table walking code (when walking the page table without locking;
	 * ie. most of the time). Fortunately, these data accesses consist
	 * of a chain of data-dependent loads, meaning most CPUs (alpha
	 * being the notable exception) will already guarantee loads are
	 * seen in-order. See the alpha page table accessors for the
	 * smp_read_barrier_depends() barriers in page table walking code.
	 */
	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
