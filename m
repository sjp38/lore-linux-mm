Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E72782970
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:22:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so71479609pfg.2
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:22:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id pj6si47664228pac.250.2016.08.10.02.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 02:22:08 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7A9JLSs112848
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:22:07 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24qm9t4gqj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 05:22:06 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 10 Aug 2016 19:21:52 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 947EB357805D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 19:21:49 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7A9Ln8J13172828
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 19:21:49 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7A9Lm6U020073
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 19:21:49 +1000
Date: Wed, 10 Aug 2016 14:51:45 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH] fadump: Register the memory reserved by fadump
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com>
 <87mvkritii.fsf@concordia.ellerman.id.au>
 <20160805072838.GF11268@linux.vnet.ibm.com>
 <87h9azin4g.fsf@concordia.ellerman.id.au>
 <20160805100609.GP2799@techsingularity.net>
 <87d1lhtb3s.fsf@concordia.ellerman.id.au>
 <20160810064056.GB24800@linux.vnet.ibm.com>
 <877fbpt8ju.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <877fbpt8ju.fsf@concordia.ellerman.id.au>
Message-Id: <20160810092145.GA20502@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

* Michael Ellerman <mpe@ellerman.id.au> [2016-08-10 16:57:57]:

> Srikar Dronamraju <srikar@linux.vnet.ibm.com> writes:
> 
> >> 
> >> > Conceptually it would be cleaner, if expensive, to calculate the real
> >> > memblock reserves if HASH_EARLY and ditch the dma_reserve, memory_reserve
> >> > and nr_kernel_pages entirely.
> >> 
> >> Why is it expensive? memblock tracks the totals for all memory and
> >> reserved memory AFAIK, so it should just be a case of subtracting one
> >> from the other?
> >
> > Are you suggesting that we use something like
> > memblock_phys_mem_size() but one which returns
> > memblock.reserved.total_size ? Maybe a new function like
> > memblock_reserved_mem_size()?
> 
> Yeah, something like that. I'm not sure if it actually needs a function,
> AFAIK you can just look at the structure directly.

For now memblock structure is only available in mm/memblock.c
Every other access to memblock from outside mm/memblock is through an
api.

> >
> > Yes, this is a possibility, for example lets say we want fadump to
> > continue to run instead of rebooting to a new kernel as it does today.
> 
> But that's a bad idea and no one should ever do it.
> 
> For starters all your caches will be undersized, and anything that is
> allocated per-node early in boot will not be allocated on the nodes
> which were reserved, so the system's performance will potentially differ
> from a normal boot in weird and unpredictable ways.
> 

Okay

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
