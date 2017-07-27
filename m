Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5826B04C3
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:20:45 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z48so33770442wrc.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:20:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 128si1968647wme.241.2017.07.27.09.20.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 09:20:44 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6RGJMY7153419
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:20:42 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2byj79vkqk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:20:42 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 10:20:41 -0600
Subject: Re: [PATCH v3 1/3] mm/hugetlb: Allow arch to override and call the
 weak function
References: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727130123.GE27766@dhcp22.suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 27 Jul 2017 21:50:35 +0530
MIME-Version: 1.0
In-Reply-To: <20170727130123.GE27766@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <e963e910-1999-ddff-87cf-9e8c356fea82@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org



On 07/27/2017 06:31 PM, Michal Hocko wrote:
> On Thu 27-07-17 11:48:26, Aneesh Kumar K.V wrote:
>> For ppc64, we want to call this function when we are not running as guest.
> 
> What does this mean?
> 

ppc64 guest (aka LPAR) support a different mechanism for hugetlb 
allocation/reservation. The LPAR management application called HMC can 
be used to reserve a set of hugepages and we pass the details of 
reserved pages via device tree to the guest. You can find the details in
htab_dt_scan_hugepage_blocks() . We do the memblock_reserve of the range 
and later in the boot sequence, we just add the reserved range to
huge_boot_pages.

For baremetal config (when we are not running as guest) we want to 
follow what other architecture does, that is look at the command line 
and do memblock allocation. Hence the need to call generic function 
__alloc_bootmem_huge_page() in that case.

I can add all these details in to the commit message if that makes it easy ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
