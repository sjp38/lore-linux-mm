Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C74E56B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 08:56:36 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so25721683wjy.6
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 05:56:36 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e2si5124440wra.193.2017.02.07.05.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 05:56:35 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v17Ds5rU019373
	for <linux-mm@kvack.org>; Tue, 7 Feb 2017 08:56:34 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28fesx2c8e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Feb 2017 08:56:33 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 7 Feb 2017 23:56:31 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 03F722CE8057
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 00:56:28 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v17DuJZJ6094876
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 00:56:27 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v17Dttn1011354
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 00:55:55 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in zap_pmd_range()
In-Reply-To: <20170206160751.GA29962@node.shutemov.name>
References: <20170205161252.85004-1-zi.yan@sent.com> <20170205161252.85004-4-zi.yan@sent.com> <20170206160751.GA29962@node.shutemov.name>
Date: Tue, 07 Feb 2017 19:25:30 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87bmueqf59.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@sent.com>, mgorman@techsingularity.net, riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, Zi Yan <ziy@nvidia.com>

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Sun, Feb 05, 2017 at 11:12:41AM -0500, Zi Yan wrote:
>> From: Zi Yan <ziy@nvidia.com>
>> 
>> Originally, zap_pmd_range() checks pmd value without taking pmd lock.
>> This can cause pmd_protnone entry not being freed.
>> 
>> Because there are two steps in changing a pmd entry to a pmd_protnone
>> entry. First, the pmd entry is cleared to a pmd_none entry, then,
>> the pmd_none entry is changed into a pmd_protnone entry.
>> The racy check, even with barrier, might only see the pmd_none entry
>> in zap_pmd_range(), thus, the mapping is neither split nor zapped.
>
> That's definately a good catch.
>
> But I don't agree with the solution. Taking pmd lock on each
> zap_pmd_range() is a significant hit by scalability of the code path.
> Yes, split ptl lock helps, but it would be nice to avoid the lock in first
> place.
>
> Can we fix change_huge_pmd() instead? Is there a reason why we cannot
> setup the pmd_protnone() atomically?
>
> Mel? Rik?
>

I am also trying to fixup the usage of set_pte_at on ptes that are
valid/present (that this autonuma ptes). I guess what we are missing is a
variant of pte update routines that can atomically update a pte without
clearing it and that also doesn't do a tlb flush ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
