Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 307E76B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:41:09 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so47945214wmz.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:41:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u1si38375463wjx.280.2016.08.09.23.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 23:41:08 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7A6d1cM093383
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:41:06 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24qm9qpu9b-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:41:06 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 10 Aug 2016 16:41:03 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 8F3383578053
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 16:41:00 +1000 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7A6f02K20709486
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 16:41:00 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7A6excG011898
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 16:41:00 +1000
Date: Wed, 10 Aug 2016 12:10:56 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH] fadump: Register the memory reserved by fadump
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com>
 <87mvkritii.fsf@concordia.ellerman.id.au>
 <20160805072838.GF11268@linux.vnet.ibm.com>
 <87h9azin4g.fsf@concordia.ellerman.id.au>
 <20160805100609.GP2799@techsingularity.net>
 <87d1lhtb3s.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <87d1lhtb3s.fsf@concordia.ellerman.id.au>
Message-Id: <20160810064056.GB24800@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

> 
> > Conceptually it would be cleaner, if expensive, to calculate the real
> > memblock reserves if HASH_EARLY and ditch the dma_reserve, memory_reserve
> > and nr_kernel_pages entirely.
> 
> Why is it expensive? memblock tracks the totals for all memory and
> reserved memory AFAIK, so it should just be a case of subtracting one
> from the other?

Are you suggesting that we use something like
memblock_phys_mem_size() but one which returns
memblock.reserved.total_size ? Maybe a new function like
memblock_reserved_mem_size()?

> 
> > Unfortuantely, aside from the calculation,
> > there is a potential cost due to a smaller hash table that affects everyone,
> > not just ppc64.
> 
> Yeah OK. We could make it an arch hook, or controlled by a CONFIG.

If its based on memblock.reserved.total_size, then should it be arch
specific?

> 
> > However, if the hash table is meant to be sized on the
> > number of available pages then it really should be based on that and not
> > just a made-up number.
> 
> Yeah that seems to make sense.
> 
> The one complication I think is that we may have memory that's marked
> reserved in memblock, but is later freed to the page allocator (eg.
> initrd).

Yes, this is a possibility, for example lets say we want fadump to
continue to run instead of rebooting to a new kernel as it does today.

> 
> I'm not sure if that's actually a concern in practice given the relative
> size of the initrd and memory on most systems. But possibly there are
> other things that get reserved and then freed which could skew the hash
> table size calculation.
> 

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
