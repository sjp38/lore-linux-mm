Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3C2F6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 22:22:38 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id r7so33738422wrb.0
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 19:22:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h11si14405472wrb.480.2017.07.26.19.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 19:22:26 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6R2IvKW067689
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 22:22:25 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2by1jxnrxe-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 22:22:25 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 12:22:22 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6R2MIEk22544460
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:22:18 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6R2M9ir019025
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:22:09 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: gigantic hugepages vs. movable zones
In-Reply-To: <20170726105004.GI2981@dhcp22.suse.cz>
References: <20170726105004.GI2981@dhcp22.suse.cz>
Date: Thu, 27 Jul 2017 07:52:08 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87inie1uwf.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Michal Hocko <mhocko@kernel.org> writes:

> Hi,
> I've just noticed that alloc_gigantic_page ignores movability of the
> gigantic page and it uses any existing zone. Considering that
> hugepage_migration_supported only supports 2MB and pgd level hugepages
> then 1GB pages are not migratable and as such allocating them from a
> movable zone will break the basic expectation of this zone. Standard
> hugetlb allocations try to avoid that by using htlb_alloc_mask and I
> believe we should do the same for gigantic pages as well.
>
> I suspect this behavior is not intentional. What do you think about the
> following untested patch?


I also noticed an unrelated issue with the usage of
start_isolate_page_range. On error we set the migrate type to
MIGRATE_MOVABLE. That may conflict with CMA pages ? Wondering whether
we should check for page's pageblock migrate type in
pfn_range_valid_gigantic() ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
