Message-ID: <46385699.4090201@yahoo.com.au>
Date: Wed, 02 May 2007 19:15:05 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com> <4638009E.3070408@yahoo.com.au>
In-Reply-To: <4638009E.3070408@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hugh Dickins wrote:
> 
>> On Tue, 1 May 2007, Nick Piggin wrote:
> 
> 
>>> There were concerns that we could do this more cheaply, but I think it
>>> is important to start with a base that is simple and more likely to
>>> be correct and build on that. My testing didn't show any obvious
>>> problems with performance.
>>
>>
>>
>> I don't see _problems_ with performance, but I do consistently see the
>> same kind of ~5% degradation in lmbench fork, exec, sh, mmap latency
>> and page fault tests on SMP, several machines, just as I did last year.
> 
> 
> OK. I did run some tests at one stage which didn't show a regression
> on my P4, however I don't know that they were statistically significant.
> I'll try a couple more runs and post numbers.

I didn't have enough time tonight to get means/stddev, etc, but the runs
are pretty stable.

Patch tested was just the lock page one.

SMP kernel, tasks bound to 1 CPU:

P4 Xeon
          pagefault   fork          exec
2.6.21   1.67-1.69   140.7-142.0   449.5-460.8
+patch   1.75-1.77   144.0-145.5   456.2-463.0

So it's taken on nearly 5% on pagefault, but looks like less than 2% on
fork, so not as bad as your numbers (phew).

G5
          pagefault   fork          exec
2.6.21   1.49-1.51   164.6-170.8   741.8-760.3
+patch   1.71-1.73   175.2-180.8   780.5-794.2

Bigger hit there.

Page faults can be improved a tiny bit by not using a test and clear op
in unlock_page (less barriers for the G5).

I don't think that's really a blocker problem for a merge, but I wonder
what we can do to improve it. Lockless pagecache shaves quite a bit of
straight line find_get_page performance there.

Going to a non-sleeping lock might be one way to go in the long term, but
it would require quite a lot of restructuring.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
