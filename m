Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A50C86B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 03:40:14 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 83so26724429pgb.14
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 00:40:14 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s61si510461plb.600.2017.08.08.00.40.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 00:40:13 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm: Clear to access sub-page last when clearing huge page
References: <20170807072131.8343-1-ying.huang@intel.com>
	<20170807101639.4fb4v42jynkscep6@node.shutemov.name>
	<87efsngff5.fsf@yhuang-mobile.sh.intel.com>
Date: Tue, 08 Aug 2017 15:40:04 +0800
In-Reply-To: <87efsngff5.fsf@yhuang-mobile.sh.intel.com> (Ying Huang's message
	of "Tue, 8 Aug 2017 06:51:26 +0800")
Message-ID: <877eye7bjf.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>

"Huang, Ying" <ying.huang@intel.com> writes:

> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
>
>> On Mon, Aug 07, 2017 at 03:21:31PM +0800, Huang, Ying wrote:
>>> From: Huang Ying <ying.huang@intel.com>
>>> 
>>> Huge page helps to reduce TLB miss rate, but it has higher cache
>>> footprint, sometimes this may cause some issue.  For example, when
>>> clearing huge page on x86_64 platform, the cache footprint is 2M.  But
>>> on a Xeon E5 v3 2699 CPU, there are 18 cores, 36 threads, and only 45M
>>> LLC (last level cache).  That is, in average, there are 2.5M LLC for
>>> each core and 1.25M LLC for each thread.  If the cache pressure is
>>> heavy when clearing the huge page, and we clear the huge page from the
>>> begin to the end, it is possible that the begin of huge page is
>>> evicted from the cache after we finishing clearing the end of the huge
>>> page.  And it is possible for the application to access the begin of
>>> the huge page after clearing the huge page.
>>> 
>>> To help the above situation, in this patch, when we clear a huge page,
>>> the order to clear sub-pages is changed.  In quite some situation, we
>>> can get the address that the application will access after we clear
>>> the huge page, for example, in a page fault handler.  Instead of
>>> clearing the huge page from begin to end, we will clear the sub-pages
>>> farthest from the the sub-page to access firstly, and clear the
>>> sub-page to access last.  This will make the sub-page to access most
>>> cache-hot and sub-pages around it more cache-hot too.  If we cannot
>>> know the address the application will access, the begin of the huge
>>> page is assumed to be the the address the application will access.
>>> 
>>> With this patch, the throughput increases ~28.3% in vm-scalability
>>> anon-w-seq test case with 72 processes on a 2 socket Xeon E5 v3 2699
>>> system (36 cores, 72 threads).  The test case creates 72 processes,
>>> each process mmap a big anonymous memory area and writes to it from
>>> the begin to the end.  For each process, other processes could be seen
>>> as other workload which generates heavy cache pressure.  At the same
>>> time, the cache miss rate reduced from ~33.4% to ~31.7%, the
>>> IPC (instruction per cycle) increased from 0.56 to 0.74, and the time
>>> spent in user space is reduced ~7.9%
>>
>> That's impressive.
>>
>> But what about the case when we are not bounded that much by the size of
>> LLC? What about running the same test on the same hardware, but with 4
>> processes instead of 72.
>>
>> I just want to make sure we don't regress on more realistic tast case.
>
> Sure.  I will test it.

Tested with 4 processes, there is no visible changes for benchmark result.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
