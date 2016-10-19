Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id ABA826B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:11:30 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id kc8so7506278pab.2
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 22:11:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s10si1279817pav.187.2016.10.18.22.11.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 22:11:29 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9J541LS091936
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:11:29 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2660nkkxgb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:11:28 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Oct 2016 23:11:28 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hugetlb: Use the right pte val for compare in hugetlb_cow
In-Reply-To: <20161018113341.e032f26c052dd63a8dca1f09@linux-foundation.org>
References: <20161018154245.18023-1-aneesh.kumar@linux.vnet.ibm.com> <20161018113341.e032f26c052dd63a8dca1f09@linux-foundation.org>
Date: Wed, 19 Oct 2016 10:41:19 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <871szcsz2g.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Stancek <jstancek@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue, 18 Oct 2016 21:12:45 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:
>
>> We cannot use the pte value used in set_pte_at for pte_same comparison,
>> because archs like ppc64, filter/add new pte flag in set_pte_at. Instead
>> fetch the pte value inside hugetlb_cow. We are comparing pte value to
>> make sure the pte didn't change since we dropped the page table lock.
>> hugetlb_cow get called with page table lock held, and we can take a copy
>> of the pte value before we drop the page table lock.
>> 
>> With hugetlbfs, we optimize the MAP_PRIVATE write fault path with no
>> previous mapping (huge_pte_none entries), by forcing a cow in the fault
>> path. This avoid take an addition fault to covert a read-only mapping
>> to read/write. Here we were comparing a recently instantiated pte (via
>> set_pte_at) to the pte values from linux page table. As explained above
>> on ppc64 such pte_same check returned wrong result, resulting in us
>> taking an additional fault on ppc64.
>
> From my reading this is a minor performance improvement and a -stable
> backport isn't needed.  But it is unclear whether the impact warrants a
> 4.9 merge.

This patch workaround the issue reported at https://lkml.kernel.org/r/57FF7BB4.1070202@redhat.com
The reason for that OOM was a reserve count accounting issue which
happens in the error path of hugetlb_cow. Not this patch avoid us taking
the error path and hence we don't have the reported OOM.

An actual fix for that issue is being worked on by Mike Kravetz.

>
> Please be careful about describing end-user visible impacts when fixing
> bugs, thanks.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
