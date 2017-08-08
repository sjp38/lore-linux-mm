Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6771F6B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 00:07:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id h126so2991358wmf.10
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 21:07:44 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h9si660227edl.218.2017.08.07.21.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 21:07:43 -0700 (PDT)
Subject: Re: [PATCH -mm] mm: Clear to access sub-page last when clearing huge
 page
References: <20170807072131.8343-1-ying.huang@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <d1466e25-5345-e780-c578-4346313e3419@oracle.com>
Date: Mon, 7 Aug 2017 21:07:27 -0700
MIME-Version: 1.0
In-Reply-To: <20170807072131.8343-1-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>

On 08/07/2017 12:21 AM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Huge page helps to reduce TLB miss rate, but it has higher cache
> footprint, sometimes this may cause some issue.  For example, when
> clearing huge page on x86_64 platform, the cache footprint is 2M.  But
> on a Xeon E5 v3 2699 CPU, there are 18 cores, 36 threads, and only 45M
> LLC (last level cache).  That is, in average, there are 2.5M LLC for
> each core and 1.25M LLC for each thread.  If the cache pressure is
> heavy when clearing the huge page, and we clear the huge page from the
> begin to the end, it is possible that the begin of huge page is
> evicted from the cache after we finishing clearing the end of the huge
> page.  And it is possible for the application to access the begin of
> the huge page after clearing the huge page.
> 
> To help the above situation, in this patch, when we clear a huge page,
> the order to clear sub-pages is changed.  In quite some situation, we
> can get the address that the application will access after we clear
> the huge page, for example, in a page fault handler.  Instead of
> clearing the huge page from begin to end, we will clear the sub-pages
> farthest from the the sub-page to access firstly, and clear the
> sub-page to access last.  This will make the sub-page to access most
> cache-hot and sub-pages around it more cache-hot too.  If we cannot
> know the address the application will access, the begin of the huge
> page is assumed to be the the address the application will access.
> 
> With this patch, the throughput increases ~28.3% in vm-scalability
> anon-w-seq test case with 72 processes on a 2 socket Xeon E5 v3 2699
> system (36 cores, 72 threads).  The test case creates 72 processes,
> each process mmap a big anonymous memory area and writes to it from
> the begin to the end.  For each process, other processes could be seen
> as other workload which generates heavy cache pressure.  At the same
> time, the cache miss rate reduced from ~33.4% to ~31.7%, the
> IPC (instruction per cycle) increased from 0.56 to 0.74, and the time
> spent in user space is reduced ~7.9%
> 
> Thanks Andi Kleen to propose to use address to access to determine the
> order of sub-pages to clear.
> 
> The hugetlbfs access address could be improved, will do that in
> another patch.

hugetlb_fault masks off the actual faulting address with,
        address &= huge_page_mask(h);
before calling hugetlb_no_page.

But, we could pass down the actual (unmasked) address to take advantage
of this optimization for hugetlb faults as well.  hugetlb_fault is the
only caller of hugetlb_no_page, so this should be pretty straight forward.

Were you thinking of additional improvements?
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
