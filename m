Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BAB16B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 04:00:39 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u7so196696399pgo.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 01:00:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 189si10598331pfe.678.2017.07.27.01.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 01:00:38 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6R7wvpC030032
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 04:00:37 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2byc080sxb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 04:00:37 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 04:00:36 -0400
Subject: Re: gigantic hugepages vs. movable zones
References: <20170726105004.GI2981@dhcp22.suse.cz>
 <87inie1uwf.fsf@linux.vnet.ibm.com> <20170727072857.GI20970@dhcp22.suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 27 Jul 2017 13:30:31 +0530
MIME-Version: 1.0
In-Reply-To: <20170727072857.GI20970@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <1529e986-5f28-35dd-c82e-a4b5801b4afd@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>



On 07/27/2017 12:58 PM, Michal Hocko wrote:
> On Thu 27-07-17 07:52:08, Aneesh Kumar K.V wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>>
>>> Hi,
>>> I've just noticed that alloc_gigantic_page ignores movability of the
>>> gigantic page and it uses any existing zone. Considering that
>>> hugepage_migration_supported only supports 2MB and pgd level hugepages
>>> then 1GB pages are not migratable and as such allocating them from a
>>> movable zone will break the basic expectation of this zone. Standard
>>> hugetlb allocations try to avoid that by using htlb_alloc_mask and I
>>> believe we should do the same for gigantic pages as well.
>>>
>>> I suspect this behavior is not intentional. What do you think about the
>>> following untested patch?
>>
>>
>> I also noticed an unrelated issue with the usage of
>> start_isolate_page_range. On error we set the migrate type to
>> MIGRATE_MOVABLE.
> 
> Why that should be a problem? I think it is perfectly OK to have
> MIGRATE_MOVABLE pageblocks inside kernel zones.
> 

we can pick pages with migrate type movable and if we fail to isolate 
won't we set the migrate type of that pages to MOVABLE ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
