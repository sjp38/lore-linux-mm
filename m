Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD0B46B03A9
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 02:43:15 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 34so8817252pgx.6
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 23:43:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x8si1468775pff.140.2017.04.18.23.43.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 23:43:14 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3J6d2Y3046577
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 02:43:14 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29wqpuy958-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 02:43:13 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 19 Apr 2017 16:43:11 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3J6h0j649217714
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 16:43:08 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3J6gVjN002090
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 16:42:31 +1000
Subject: Re: [RFC] mm/madvise: Enable (soft|hard) offline of HugeTLB pages at
 PGD level
References: <20170419032759.29700-1-khandual@linux.vnet.ibm.com>
 <877f2ghqaf.fsf@skywalker.in.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 19 Apr 2017 12:12:17 +0530
MIME-Version: 1.0
In-Reply-To: <877f2ghqaf.fsf@skywalker.in.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d3189584-4ddd-53b8-f412-57e378dbf7ca@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org

On 04/19/2017 11:50 AM, Aneesh Kumar K.V wrote:
> Anshuman Khandual <khandual@linux.vnet.ibm.com> writes:
> 
>> Though migrating gigantic HugeTLB pages does not sound much like real
>> world use case, they can be affected by memory errors. Hence migration
>> at the PGD level HugeTLB pages should be supported just to enable soft
>> and hard offline use cases.
> 
> In that case do we want to isolated the entire 16GB range ? Should we
> just dequeue the page from hugepage pool convert them to regular 64K
> pages and then isolate the 64K that had memory error ?

Though its a better thing to do, assuming that we can actually dequeue
the huge page and push it to the buddy allocator as normal 64K pages
(need to check on this as the original allocation happened from the
memblock instead of the buddy allocator, guess it should be possible
given that we do similar stuff during memory hot plug). In that case
we will also have to consider the same for the PMD based HugeTLB pages
as well or it should be only for these gigantic huge pages ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
