Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3DFE86B0038
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 02:16:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g7so9067822wrd.16
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 23:16:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c41si6182416wrc.176.2017.04.06.23.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 23:16:02 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3769kd8027681
	for <linux-mm@kvack.org>; Fri, 7 Apr 2017 02:16:01 -0400
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29p3dc5m2v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 07 Apr 2017 02:16:00 -0400
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 7 Apr 2017 11:45:27 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v376FPUp17891534
	for <linux-mm@kvack.org>; Fri, 7 Apr 2017 11:45:25 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v376FOeF011910
	for <linux-mm@kvack.org>; Fri, 7 Apr 2017 11:45:25 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [v2 5/5] mm: teach platforms not to zero struct pages memory
In-Reply-To: <20170327060032.GB5092@osiris>
References: <1490383192-981017-1-git-send-email-pasha.tatashin@oracle.com> <1490383192-981017-6-git-send-email-pasha.tatashin@oracle.com> <20170327060032.GB5092@osiris>
Date: Fri, 07 Apr 2017 11:45:23 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87bms8rbes.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, davem@davemloft.net, willy@infradead.org

Heiko Carstens <heiko.carstens@de.ibm.com> writes:

> On Fri, Mar 24, 2017 at 03:19:52PM -0400, Pavel Tatashin wrote:
>> If we are using deferred struct page initialization feature, most of
>> "struct page"es are getting initialized after other CPUs are started, and
>> hence we are benefiting from doing this job in parallel. However, we are
>> still zeroing all the memory that is allocated for "struct pages" using the
>> boot CPU.  This patch solves this problem, by deferring zeroing "struct
>> pages" to only when they are initialized.
>> 
>> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
>> Reviewed-by: Shannon Nelson <shannon.nelson@oracle.com>
>> ---
>>  arch/powerpc/mm/init_64.c |    2 +-
>>  arch/s390/mm/vmem.c       |    2 +-
>>  arch/sparc/mm/init_64.c   |    2 +-
>>  arch/x86/mm/init_64.c     |    2 +-
>>  4 files changed, 4 insertions(+), 4 deletions(-)
>> 
>> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
>> index eb4c270..24faf2d 100644
>> --- a/arch/powerpc/mm/init_64.c
>> +++ b/arch/powerpc/mm/init_64.c
>> @@ -181,7 +181,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
>>  		if (vmemmap_populated(start, page_size))
>>  			continue;
>> 
>> -		p = vmemmap_alloc_block(page_size, node, true);
>> +		p = vmemmap_alloc_block(page_size, node, VMEMMAP_ZERO);
>>  		if (!p)
>>  			return -ENOMEM;
>> 
>> diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
>> index 9c75214..ffe9ba1 100644
>> --- a/arch/s390/mm/vmem.c
>> +++ b/arch/s390/mm/vmem.c
>> @@ -252,7 +252,7 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node)
>>  				void *new_page;
>> 
>>  				new_page = vmemmap_alloc_block(PMD_SIZE, node,
>> -							       true);
>> +							       VMEMMAP_ZERO);
>>  				if (!new_page)
>>  					goto out;
>>  				pmd_val(*pm_dir) = __pa(new_page) | sgt_prot;
>
> s390 has two call sites that need to be converted, like you did in one of
> your previous patches. The same seems to be true for powerpc, unless there
> is a reason to not convert them?
>

vmemmap_list_alloc is not really struct page allocation right ? We are
just allocating memory to be used as vmemmmap_backing. But considering
we are updating all the three elements of the sturct, we can avoid that
memset . But instead of VMEMMAP_ZERO we can just pass false in that case
?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
