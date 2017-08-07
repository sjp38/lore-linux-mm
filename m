Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16CD86B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 06:00:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r13so89388116pfd.14
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 03:00:20 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q1si4366260pga.917.2017.08.07.03.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 03:00:18 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm: Clear to access sub-page last when clearing huge page
References: <20170807072131.8343-1-ying.huang@intel.com>
	<20170807095515.GA6470@quack2.suse.cz>
Date: Mon, 07 Aug 2017 18:00:12 +0800
In-Reply-To: <20170807095515.GA6470@quack2.suse.cz> (Jan Kara's message of
	"Mon, 7 Aug 2017 11:55:15 +0200")
Message-ID: <8760dzlmtv.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>

Jan Kara <jack@suse.cz> writes:

> On Mon 07-08-17 15:21:31, Huang, Ying wrote:
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
> Hum, the improvement looks impressive enough that it is probably worth the
> bother. But please add at least a brief explanation why you do stuff in
> this more complicated way to a comment in clear_huge_page() so that people
> don't have to look it up in the changelog.

Good suggestion!  I will do that in the next version.

> Otherwise the patch looks good
> to me so feel free to add:
>
> Acked-by: Jan Kara <jack@suse.cz>

Thanks!

Best Regards,
Huang, Ying

> 								Honza
>
>> @@ -4374,9 +4374,31 @@ void clear_huge_page(struct page *page,
>>  	}
>>  
>>  	might_sleep();
>> -	for (i = 0; i < pages_per_huge_page; i++) {
>> +	VM_BUG_ON(clamp(addr_hint, addr, addr +
>> +			(pages_per_huge_page << PAGE_SHIFT)) != addr_hint);
>> +	n = (addr_hint - addr) / PAGE_SIZE;
>> +	if (2 * n <= pages_per_huge_page) {
>> +		base = 0;
>> +		l = n;
>> +		for (i = pages_per_huge_page - 1; i >= 2 * n; i--) {
>> +			cond_resched();
>> +			clear_user_highpage(page + i, addr + i * PAGE_SIZE);
>> +		}
>> +	} else {
>> +		base = 2 * n - pages_per_huge_page;
>> +		l = pages_per_huge_page - n;
>> +		for (i = 0; i < base; i++) {
>> +			cond_resched();
>> +			clear_user_highpage(page + i, addr + i * PAGE_SIZE);
>> +		}
>> +	}
>> +	for (i = 0; i < l; i++) {
>> +		cond_resched();
>> +		clear_user_highpage(page + base + i,
>> +				    addr + (base + i) * PAGE_SIZE);
>>  		cond_resched();
>> -		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
>> +		clear_user_highpage(page + base + 2 * l - 1 - i,
>> +				    addr + (base + 2 * l - 1 - i) * PAGE_SIZE);
>>  	}
>>  }
>>  
>> -- 
>> 2.11.0
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
