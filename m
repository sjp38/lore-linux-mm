Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53B2B8E009D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 03:41:37 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id p79so5620487qki.15
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 00:41:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p58si244054qtb.253.2019.01.09.00.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 00:41:36 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x098d7N2140091
	for <linux-mm@kvack.org>; Wed, 9 Jan 2019 03:41:36 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pwcbru7kb-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:41:35 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 9 Jan 2019 08:41:34 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V6 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
In-Reply-To: <20190108115620.6ec22e7d60b86d5f609d5a87@linux-foundation.org>
References: <20190108045110.28597-1-aneesh.kumar@linux.ibm.com> <20190108115620.6ec22e7d60b86d5f609d5a87@linux-foundation.org>
Date: Wed, 09 Jan 2019 14:11:25 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <875zuyjk96.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue,  8 Jan 2019 10:21:06 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
>
>> ppc64 use CMA area for the allocation of guest page table (hash page table). We won't
>> be able to start guest if we fail to allocate hash page table. We have observed
>> hash table allocation failure because we failed to migrate pages out of CMA region
>> because they were pinned. This happen when we are using VFIO. VFIO on ppc64 pins
>> the entire guest RAM. If the guest RAM pages get allocated out of CMA region, we
>> won't be able to migrate those pages. The pages are also pinned for the lifetime of the
>> guest.
>> 
>> Currently we support migration of non-compound pages. With THP and with the addition of
>>  hugetlb migration we can end up allocating compound pages from CMA region. This
>> patch series add support for migrating compound pages. The first path adds the helper
>> get_user_pages_cma_migrate() which pin the page making sure we migrate them out of
>> CMA region before incrementing the reference count. 
>
> Does this code do anything for architectures other than powerpc?  If
> not, should we be adding the ifdefs to avoid burdening other
> architectures with unused code?

Any architecture enabling CMA may need this. I will move most of this below
CONFIG_CMA.

-aneesh
