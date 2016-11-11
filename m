Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69AB6280284
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 22:49:19 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so3976042pfy.2
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 19:49:19 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id vy10si6689671pac.129.2016.11.10.19.49.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Nov 2016 19:49:18 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAB3nGjQ012272
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 22:49:17 -0500
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com [125.16.236.2])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26mwc78ssy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 22:49:17 -0500
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 11 Nov 2016 09:18:53 +0530
Received: from d28relay09.in.ibm.com (d28relay09.in.ibm.com [9.184.220.160])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 7DFECE005E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 09:18:56 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay09.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAB3mnik16384100
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 09:18:49 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAB3mjXt019123
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 09:18:49 +0530
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5822FB60.5040905@linux.vnet.ibm.com>
 <20161109235223.GA31285@hori1.linux.bs1.fc.nec.co.jp>
 <D34FA575-7C5D-4E9D-B337-A925F1A89C66@cs.rutgers.edu>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2016 09:18:44 +0530
MIME-Version: 1.0
In-Reply-To: <D34FA575-7C5D-4E9D-B337-A925F1A89C66@cs.rutgers.edu>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <58253F9C.6040307@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 11/10/2016 07:31 PM, Zi Yan wrote:
> On 9 Nov 2016, at 18:52, Naoya Horiguchi wrote:
> 
>> Hi Anshuman,
>>
>> On Wed, Nov 09, 2016 at 04:03:04PM +0530, Anshuman Khandual wrote:
>>> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
>>>> Hi everyone,
>>>>
>>>> I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
>>>> with feedbacks for ver.1.
>>>>
>>>> General description (no change since ver.1)
>>>> ===========================================
>>>>
>>>> This patchset enhances page migration functionality to handle thp migration
>>>> for various page migration's callers:
>>>>  - mbind(2)
>>>>  - move_pages(2)
>>>>  - migrate_pages(2)
>>>>  - cgroup/cpuset migration
>>>>  - memory hotremove
>>>>  - soft offline
>>>>
>>>> The main benefit is that we can avoid unnecessary thp splits, which helps us
>>>> avoid performance decrease when your applications handles NUMA optimization on
>>>> their own.
>>>>
>>>> The implementation is similar to that of normal page migration, the key point
>>>> is that we modify a pmd to a pmd migration entry in swap-entry like format.
>>>
>>> Will it be better to have new THP_MIGRATE_SUCCESS and THP_MIGRATE_FAIL
>>> VM events to capture how many times the migration worked without first
>>> splitting the huge page and how many time it did not work ?
>>
>> Thank you for the suggestion.
>> I think that's helpful, so will try it in next version.
>>
>>> Also do you
>>> have a test case which demonstrates this THP migration and kind of shows
>>> its better than the present split and move method ?
>>
>> I don't have test cases which compare thp migration and split-then-migration
>> with some numbers. Maybe measuring/comparing the overhead of migration is
>> a good start point, although I think the real benefit of thp migration comes
>> from workload "after migration" by avoiding thp split.
> 
> Migrating 4KB pages has much lower (~1/3) throughput than 2MB pages.

I assume the 2MB throughput you mentioned is with this THP migration
feature enabled.

> 
> What I get is that on average it takes 1987.38 us to migrate 512 4KB pages and
>                                        658.54  us to migrate 1   2MB page.
> 
> I did the test in a two-socket Intel Xeon E5-2640v4 box. I used migrate_pages()
> system call to migrate pages. MADV_NOHUGEPAGE and MADV_HUGEPAGE are used to
> make 4KB and 2MB pages and each pagea??s flags are checked to make sure the page
> size is 4KB or 2MB THP.
> 
> There is no split page. But the page migration time already tells the story.

Right. Just wondering if we can add a test case which measures just
this migration time improvement by avoiding the split not the TLB
based improvement which the workload will receive as an addition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
