Message-ID: <4639DBEC.2020401@yahoo.com.au>
Date: Thu, 03 May 2007 22:56:12 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com> <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com> <46393BA7.6030106@yahoo.com.au> <20070503103756.GA19958@infradead.org>
In-Reply-To: <20070503103756.GA19958@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> On Thu, May 03, 2007 at 11:32:23AM +1000, Nick Piggin wrote:
> 
>>The attached patch gets performance up a bit by avoiding some
>>barriers and some cachelines:
>>
>>G5
>>         pagefault   fork          exec
>>2.6.21   1.49-1.51   164.6-170.8   741.8-760.3
>>+patch   1.71-1.73   175.2-180.8   780.5-794.2
>>+patch2  1.61-1.63   169.8-175.0   748.6-757.0
>>
>>So that brings the fork/exec hits down to much less than 5%, and
>>would likely speed up other things that lock the page, like write
>>or page reclaim.
> 
> 
> Is that every fork/exec or just under certain cicumstances?
> A 5% regression on every fork/exec is not acceptable.

Well after patch2, G5 fork is 3% and exec is 1%, I'd say the P4
numbers will be improved as well with that patch. Then if we have
specific lock/unlock bitops, I hope it should reduce that further.

The overhead that is there should just be coming from the extra
overhead in the file backed fault handler. For noop fork/execs,
I think that tends to be more pronounced, it is hard to see any
difference on any non-micro benchmark.

The other thing is that I think there could be some cache effects
happening -- for example the exec numbers on the 2nd line are
disproportionately large.

It definitely isn't a good thing to drop performance anywhere
though, so I'll keep looking for improvements.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
