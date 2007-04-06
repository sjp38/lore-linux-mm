Message-ID: <4615A22A.7040909@yahoo.com.au>
Date: Fri, 06 Apr 2007 11:28:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <461357C4.4010403@yahoo.com.au> <46154226.6080300@redhat.com>
In-Reply-To: <46154226.6080300@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Nick Piggin wrote:
> 
>> Oh, also: something like this patch would help out MADV_DONTNEED, as it
>> means it can run concurrently with page faults. I think the locking will
>> work (but needs forward porting).
> 
> 
> Ironically, your patch decreases throughput on my quad core
> test system, with Jakub's test case.
> 
> MADV_DONTNEED, my patch, 10000 loops  (14k context switches/second)
> 
> real    0m34.890s
> user    0m17.256s
> sys     0m29.797s
> 
> 
> MADV_DONTNEED, my patch & your patch, 10000 loops  (50 context 
> switches/second)
> 
> real    1m8.321s
> user    0m20.840s
> sys     1m55.677s
> 
> I suspect it's moving the contention onto the page table lock,
> in zap_pte_range().  I guess that the thread private memory
> areas must be living right next to each other, in the same
> page table lock regions :)
> 
> For more real world workloads, like the MySQL sysbench one,
> I still suspect that your patch would improve things.

I think it definitely would, because the app will be wanting to
do other things with mmap_sem as well (like futexes *grumble*).

Also, the test case is allocating and freeing 512K chunks, which
I think would be on the high side of typical.

You have 32 threads for 4 CPUs, so then it would actually make
sense to context switch on mmap_sem write lock rather than spin
on ptl. But the kernel doesn't know that.

Testing with a small chunk size or thread == CPUs I think would
show a swing toward my patch.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
