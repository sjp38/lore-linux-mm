Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4067A6B78F5
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 09:24:07 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q130-v6so12607202oic.22
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 06:24:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c15-v6si3384527oig.152.2018.09.06.06.24.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 06:24:06 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w86DEgjb138933
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 09:24:05 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mb3vnbnu4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 09:24:05 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 6 Sep 2018 07:24:04 -0600
Subject: Re: [RFC PATCH V2 2/4] mm: Add get_user_pages_cma_migrate
References: <20180906054342.25094-1-aneesh.kumar@linux.ibm.com>
 <20180906054342.25094-2-aneesh.kumar@linux.ibm.com>
 <20180906124504.GW14951@dhcp22.suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 6 Sep 2018 18:53:55 +0530
MIME-Version: 1.0
In-Reply-To: <20180906124504.GW14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <cbcae00a-e42c-0279-1ccb-9192e486abf1@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 09/06/2018 06:15 PM, Michal Hocko wrote:
> On Thu 06-09-18 11:13:40, Aneesh Kumar K.V wrote:
>> This helper does a get_user_pages_fast and if it find pages in the CMA area
>> it will try to migrate them before taking page reference. This makes sure that
>> we don't keep non-movable pages (due to page reference count) in the CMA area.
>> Not able to move pages out of CMA area result in CMA allocation failures.
> 
> Again, there is no user so it is hard to guess the intention completely.
> There is no documentation to describe the expected context and
> assumptions about locking etc.
> 

patch 4 is the user for the new helper. I will add the documentation 
update.

> As noted in the previous email. You should better describe why you are
> bypassing hugetlb pools. I assume that the reason is to guarantee a
> forward progress because those might be sitting in the CMA pools
> already, right?
> 

The reason for that is explained in the code

+		struct hstate *h = page_hstate(page);
+		/*
+		 * We don't want to dequeue from the pool because pool pages will
+		 * mostly be from the CMA region.
+		 */
+		return alloc_migrate_huge_page(h, gfp_mask, nid, NULL);

-aneesh
