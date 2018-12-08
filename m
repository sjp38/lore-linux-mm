Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 992078E0004
	for <linux-mm@kvack.org>; Sat,  8 Dec 2018 12:04:52 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s14so6106288pfk.16
        for <linux-mm@kvack.org>; Sat, 08 Dec 2018 09:04:52 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h5si5447629pgc.237.2018.12.08.09.04.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Dec 2018 09:04:51 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB8H3sav028988
	for <linux-mm@kvack.org>; Sat, 8 Dec 2018 12:04:51 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p8ax540ev-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 08 Dec 2018 12:04:50 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sat, 8 Dec 2018 17:04:50 -0000
Subject: Re: [PATCH V4 0/3] * mm/kvm/vfio/ppc64: Migrate compound pages out of
 CMA region
References: <20181121092259.16482-1-aneesh.kumar@linux.ibm.com>
 <20181207151226.cb00ace433738cf550e66885@linux-foundation.org>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Sat, 8 Dec 2018 22:34:39 +0530
MIME-Version: 1.0
In-Reply-To: <20181207151226.cb00ace433738cf550e66885@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <7a14631d-8077-e20f-d8a9-740710406168@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, paulus@samba.org, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On 12/8/18 4:42 AM, Andrew Morton wrote:
> On Wed, 21 Nov 2018 14:52:56 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
> 
>> Subject: [PATCH V4 0/3] * mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
> 
> Asterisk in title is strange?

My mistake while editing git-format-patch cover-letter.

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
>>   hugetlb migration we can end up allocating compound pages from CMA region. This
>> patch series add support for migrating compound pages. The first path adds the helper
>> get_user_pages_cma_migrate() which pin the page making sure we migrate them out of
>> CMA region before incrementing the reference count.
> 
> Very little review activity.  Perhaps Andrey and/or Michal can find the
> time..
> 
>> mm/migrate.c            | 108 ++++++++++++++++++++++++++++++++++++++++
> 
> can we make this code disappear when CONFIG_CMA=n?
> 


We can definitely do

static inline int get_user_pages_cma_migrate(unsigned long start, int 
nr_pages, int write,  struct page **pages)
{
	
	return get_user_pages_fast(start, nr_pages, write, pages);
}

with #ifdef CONFIG_CMA around but that is unnecessary #ifdef in the 
code. If CMA config is disabled, we will not be doing any migrate. Hence 
wondering whether we need an alternative definition for CONFIG_CMA=n

-aneesh
