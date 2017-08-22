Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7C00C2803DB
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 20:54:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t193so82324672pgc.0
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 17:54:20 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id z23si9129419pll.112.2017.08.21.17.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 17:54:19 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v2] mm: Clear to access sub-page last when clearing huge page
References: <20170815014618.15842-1-ying.huang@intel.com>
	<20170821115235.GD25956@dhcp22.suse.cz>
Date: Tue, 22 Aug 2017 08:54:15 +0800
In-Reply-To: <20170821115235.GD25956@dhcp22.suse.cz> (Michal Hocko's message
	of "Mon, 21 Aug 2017 13:52:35 +0200")
Message-ID: <87h8x0whfs.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Matthew Wilcox <mawilcox@microsoft.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>

Michal Hocko <mhocko@kernel.org> writes:

> On Tue 15-08-17 09:46:18, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> Huge page helps to reduce TLB miss rate, but it has higher cache
>> footprint, sometimes this may cause some issue.  For example, when
>> clearing huge page on x86_64 platform, the cache footprint is 2M.  But
>> on a Xeon E5 v3 2699 CPU, there are 18 cores, 36 threads, and only 45M
>> LLC (last level cache).  That is, in average, there are 2.5M LLC for
>> each core and 1.25M LLC for each thread.  If the cache pressure is
>> heavy when clearing the huge page, and we clear the huge page from the
>> begin to the end, it is possible that the begin of huge page is
>> evicted from the cache after we finishing clearing the end of the huge
>> page.  And it is possible for the application to access the begin of
>> the huge page after clearing the huge page.
>> 
>> To help the above situation, in this patch, when we clear a huge page,
>> the order to clear sub-pages is changed.  In quite some situation, we
>> can get the address that the application will access after we clear
>> the huge page, for example, in a page fault handler.  Instead of
>> clearing the huge page from begin to end, we will clear the sub-pages
>> farthest from the the sub-page to access firstly, and clear the
>> sub-page to access last.  This will make the sub-page to access most
>> cache-hot and sub-pages around it more cache-hot too.  If we cannot
>> know the address the application will access, the begin of the huge
>> page is assumed to be the the address the application will access.
>> 
>> With this patch, the throughput increases ~28.3% in vm-scalability
>> anon-w-seq test case with 72 processes on a 2 socket Xeon E5 v3 2699
>> system (36 cores, 72 threads).  The test case creates 72 processes,
>> each process mmap a big anonymous memory area and writes to it from
>> the begin to the end.  For each process, other processes could be seen
>> as other workload which generates heavy cache pressure.  At the same
>> time, the cache miss rate reduced from ~33.4% to ~31.7%, the
>> IPC (instruction per cycle) increased from 0.56 to 0.74, and the time
>> spent in user space is reduced ~7.9%
>
> The patch looks good to me alebit little bit tricky to read.
>
> But I am still wondering. Have you considered non-temporal stores for
> clearing?

Yes, the non-temporal stores will have no cache pressure to other
processes.  But the cache will be cold for current process too.  That
is, accessing memory after non-temporal stores need synchronous RAM
loading.  And if cache overhead on other cores isn't heavy, we can take
better advantage of the shared last level cache if we use normal memory
clearing.

>> Christopher Lameter suggests to clear bytes inside a sub-page from end
>> to begin too.  But tests show no visible performance difference in the
>> tests.  May because the size of page is small compared with the cache
>> size.
>> 
>> Thanks Andi Kleen to propose to use address to access to determine the
>> order of sub-pages to clear.
>> 
>> The hugetlbfs access address could be improved, will do that in
>> another patch.
>> 
>> [Use address to access information]
>> Suggested-by: Andi Kleen <andi.kleen@intel.com>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Acked-by: Jan Kara <jack@suse.cz>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Matthew Wilcox <mawilcox@microsoft.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Shaohua Li <shli@fb.com>
>> Cc: Christopher Lameter <cl@linux.com>
>> Cc: Mike Kravetz <mike.kravetz@oracle.com>
>
> Reviewed-by: Michal Hocko <mhocko@suse.com>

Thanks!

>> +	for (i = 0; i < l; i++) {
>
> I would find it a bit easier to read if this was
> 		int left_idx = base + i;
> 		int right_idx = base + 2*l - 1 - i
>
>> +		cond_resched();
>> +		clear_user_highpage(page + base + i,
>> +				    addr + (base + i) * PAGE_SIZE);
> 		clear_user_highpage(page + left_idx, addr + left_idx * PAGE_SIZE);
>
>>  		cond_resched();
>> -		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
>> +		clear_user_highpage(page + base + 2 * l - 1 - i,
>> +				    addr + (base + 2 * l - 1 - i) * PAGE_SIZE);
> 		clear_user_highpage(page + right_idx, addr + right_idx * PAGE_SIZE);
>>  	}
>>  }

Yes.  This looks better.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
