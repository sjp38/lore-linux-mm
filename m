Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 252726B76A9
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 23:54:28 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w194-v6so11424416oiw.5
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 20:54:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a84-v6si2524561oif.101.2018.09.05.20.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 20:54:26 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w863sQqM002868
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 23:54:26 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2masq2wqna-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 23:54:25 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Sep 2018 21:54:25 -0600
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
 <20180905130440.GA3729@bombadil.infradead.org>
 <d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
 <20180905134848.GB3729@bombadil.infradead.org>
 <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 6 Sep 2018 09:24:17 +0530
MIME-Version: 1.0
In-Reply-To: <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <19bb32a4-7acc-29ea-c00c-65cd2ebf9878@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/06/2018 01:28 AM, Andrew Morton wrote:
> On Wed, 5 Sep 2018 06:48:48 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> 
>>> I didn't. The reason I looked at current patch is to enable the usage of
>>> put_page() from irq context. We do allow that for non hugetlb pages. So was
>>> not sure adding that additional restriction for hugetlb
>>> is really needed. Further the conversion to irqsave/irqrestore was
>>> straightforward.
>>
>> straightforward, sure.  but is it the right thing to do?  do we want to
>> be able to put_page() a hugetlb page from hardirq context?
> 
> Calling put_page() against a huge page from hardirq seems like the
> right thing to do - even if it's rare now, it will presumably become
> more common as the hugepage virus spreads further across the kernel.
> And the present asymmetry is quite a wart.
> 
> That being said, arch/powerpc/mm/mmu_context_iommu.c:mm_iommu_free() is
> the only known site which does this (yes?) so perhaps we could put some
> stopgap workaround into that site and add a runtime warning into the
> put_page() code somewhere to detect puttage of huge pages from hardirq
> and softirq contexts.
> 
> And attention will need to be paid to -stable backporting.  How long
> has mm_iommu_free() existed, and been doing this?
> 

That is old code that goes back to v4.2 ( 
15b244a88e1b2895605be4300b40b575345bcf50)



-aneesh
