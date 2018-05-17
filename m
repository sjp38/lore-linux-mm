Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F2DA76B0381
	for <linux-mm@kvack.org>; Wed, 16 May 2018 21:45:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q15-v6so1732150pff.17
        for <linux-mm@kvack.org>; Wed, 16 May 2018 18:45:45 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b67-v6si4105923pfa.71.2018.05.16.18.45.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 18:45:44 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, hugetlb: Pass fault address to no page handler
References: <20180515005756.28942-1-ying.huang@intel.com>
	<20180516091226.GM12670@dhcp22.suse.cz>
	<c94f7180-d49b-3a9d-8d9e-002642ee9f3b@oracle.com>
Date: Thu, 17 May 2018 09:45:40 +0800
In-Reply-To: <c94f7180-d49b-3a9d-8d9e-002642ee9f3b@oracle.com> (Mike Kravetz's
	message of "Wed, 16 May 2018 13:04:31 -0700")
Message-ID: <878t8jxdff.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Punit Agrawal <punit.agrawal@arm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

Mike Kravetz <mike.kravetz@oracle.com> writes:

> On 05/16/2018 02:12 AM, Michal Hocko wrote:
>> On Tue 15-05-18 08:57:56, Huang, Ying wrote:
>>> From: Huang Ying <ying.huang@intel.com>
>>>
>>> This is to take better advantage of huge page clearing
>>> optimization (c79b57e462b5d, "mm: hugetlb: clear target sub-page last
>>> when clearing huge page").  Which will clear to access sub-page last
>>> to avoid the cache lines of to access sub-page to be evicted when
>>> clearing other sub-pages.  This needs to get the address of the
>>> sub-page to access, that is, the fault address inside of the huge
>>> page.  So the hugetlb no page fault handler is changed to pass that
>>> information.  This will benefit workloads which don't access the begin
>>> of the huge page after page fault.
>>>
>>> With this patch, the throughput increases ~28.1% in vm-scalability
>>> anon-w-seq test case with 88 processes on a 2 socket Xeon E5 2699 v4
>>> system (44 cores, 88 threads).  The test case creates 88 processes,
>>> each process mmap a big anonymous memory area and writes to it from
>>> the end to the begin.  For each process, other processes could be seen
>>> as other workload which generates heavy cache pressure.  At the same
>>> time, the cache miss rate reduced from ~36.3% to ~25.6%, the
>>> IPC (instruction per cycle) increased from 0.3 to 0.37, and the time
>>> spent in user space is reduced ~19.3%
>> 
>> This paragraph is confusing as Mike mentioned already. It would be
>> probably more helpful to see how was the test configured to use hugetlb
>> pages and what is the end benefit.
>> 
>> I do not have any real objection to the implementation so feel free to
>> add
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> I am just wondering what is the usecase driving this. Or is it just a
>> generic optimization that always makes sense to do? Indicating that in
>> the changelog would be helpful as well.
>
> I just noticed that the optimization was not added for 'gigantic' pages.
> Should we consider adding support for gigantic pages as well?  It may be
> that the cache miss cost is insignificant when added to the time required
> to clear a 1GB (for x86) gigantic page.

Yes.  I worry about that too.

> One more thing, I'm guessing the copy_huge/gigantic_page() routines would
> see a similar benefit.  Specifically, for copies as a result of a COW.
> Is that another area to consider?

Yes.  I have the patch already and will send it out soon.

> That gets back to Michal's question of a specific use case or generic
> optimization.  Unless code is simple (as in this patch), seems like we should
> hold off on considering additional optimizations unless there is a specific
> use case.
>
> I'm still OK with this change.

Thanks!

Best Regards,
Huang, Ying
