Message-ID: <461ED00E.1090808@yahoo.com.au>
Date: Fri, 13 Apr 2007 10:34:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] make MADV_FREE lazily free memory
References: <461C6452.1000706@redhat.com> <461D6413.6050605@cosmosbay.com> <461D67A9.5020509@redhat.com> <461DC75B.8040200@cosmosbay.com> <461DCCEB.70004@yahoo.com.au> <461DCDDA.2030502@yahoo.com.au> <461DDE44.2040409@redhat.com> <461E30A6.5030203@yahoo.com.au> <461E9D77.4080308@redhat.com>
In-Reply-To: <461E9D77.4080308@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ulrich Drepper <drepper@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Nick Piggin wrote:
> 
>>> The lazy freeing is aimed at avoiding page faults on memory
>>> that is freed and later realloced, which is quite a common
>>> thing in many workloads.
>>
>>
>> I would be interested to see how it performs and what these
>> workloads look like, although we do need to fix the basic glibc and
>> madvise locking problems first.
> 
> 
> The attached graph are results of running the MySQL sysbench
> workload on my quad core system.  As you can see, performance
> with #threads == #cpus (4) almost doubles from 1070 transactions
> per second to 2014 transactions/second.
> 
> On the high end (16 threads on 4 cpus), performance increases
> from 778 transactions/second on vanilla to 1310 transactions/second.
> 
> I have also benchmarked running Ulrich's changed glibc on a vanilla
> kernel, which gives results somewhere in-between, but much closer to
> just the vanilla kernel.

Looks like the idle time issue is still biting for those guys.

Hmm, maybe MySQL is actually _touching_ the memory inside a more
critical lock, so the faults get tangled up on mmap_sem there. I
wonder if making malloc call memset right afterwards would hide
that ;) Or the madvise exclusive mmap_sem avoidance.

Seems like with perfect scaling we should get to the 2400 mark.
It would be nice to be able to not degrade under load. Of course
some of that will be MySQL scaling issues.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
