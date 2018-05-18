Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AAF76B0554
	for <linux-mm@kvack.org>; Thu, 17 May 2018 20:33:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r63-v6so3652818pfl.12
        for <linux-mm@kvack.org>; Thu, 17 May 2018 17:33:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b8-v6si6574942pls.261.2018.05.17.17.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 17:33:54 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V2 -mm] mm, hugetlbfs: Pass fault address to no page handler
References: <20180517083539.9242-1-ying.huang@intel.com>
	<2eba3615-5144-f08d-169a-6cfd417d00b9@oracle.com>
Date: Fri, 18 May 2018 08:33:50 +0800
In-Reply-To: <2eba3615-5144-f08d-169a-6cfd417d00b9@oracle.com> (Mike Kravetz's
	message of "Thu, 17 May 2018 10:56:45 -0700")
Message-ID: <87wow1x0nl.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>

Mike Kravetz <mike.kravetz@oracle.com> writes:

> On 05/17/2018 01:35 AM, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> This is to take better advantage of general huge page clearing
>> optimization (c79b57e462b5d, "mm: hugetlb: clear target sub-page last
>> when clearing huge page") for hugetlbfs.  In the general optimization
>> patch, the sub-page to access will be cleared last to avoid the cache
>> lines of to access sub-page to be evicted when clearing other
>> sub-pages.  This works better if we have the address of the sub-page
>> to access, that is, the fault address inside the huge page.  So the
>> hugetlbfs no page fault handler is changed to pass that information.
>> This will benefit workloads which don't access the begin of the
>> hugetlbfs huge page after the page fault under heavy cache contention
>> for shared last level cache.
>> 
>> The patch is a generic optimization which should benefit quite some
>> workloads, not for a specific use case.  To demonstrate the performance
>> benefit of the patch, we tested it with vm-scalability run on
>> hugetlbfs.
>> 
>> With this patch, the throughput increases ~28.1% in vm-scalability
>> anon-w-seq test case with 88 processes on a 2 socket Xeon E5 2699 v4
>> system (44 cores, 88 threads).  The test case creates 88 processes,
>> each process mmaps a big anonymous memory area with MAP_HUGETLB and
>> writes to it from the end to the begin.  For each process, other
>> processes could be seen as other workload which generates heavy cache
>> pressure.  At the same time, the cache miss rate reduced from ~36.3%
>> to ~25.6%, the IPC (instruction per cycle) increased from 0.3 to 0.37,
>> and the time spent in user space is reduced ~19.3%.
>> 
>
> Agree with Michal that commit message looks better.
>
> I went through updated patch with haddr naming so,
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
> still applies.

Thanks!

Best Regards,
Huang, Ying
