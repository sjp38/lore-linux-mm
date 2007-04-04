Subject: Re: A question about page aging in page frame reclaimation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <ac8af0be0704040333k25459a8cwec6729e8ad6a4db4@mail.gmail.com>
References: <ac8af0be0704040333k25459a8cwec6729e8ad6a4db4@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 04 Apr 2007 12:50:29 +0200
Message-Id: <1175683829.6483.57.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 18:33 +0800, Zhao Forrest wrote:
> Hi Riel,
> 
> I'm studying the code of page frame reclaimation in 2.6 kernel. From
> my understanding, there should be kernel thread periodically scanning
> the active and inactive list and move the page frames between active
> and inactive list according to LRU rule.
> 
> But I can't find the related code.....would you please point me to the
> code piece that implement this "page aging" functionality?
> Sorry for the stupid question, but I think I don't have a very strong
> code-reading ability.

There is no time related scanning; we only scan when we wake up kswapd
or in direct reclaim. 

We wake kswapd when the free page count drops below the high watermark.
(look for callers of wakeup_kswapd()).

Direct reclaim is a per task reclaim, entered when the free page count
drops below the low watermark, this provides per task feedback when
under heavy pressure.

So reclaim is driven purely by page allocation.

The active -> inactive shuffling is a tad involved. But basically: we
scan the active list proportionally to its size to move active pages to
the inactive list, then scan the inactive list (proportional to its size
before the active->inactive move).

Pages on the inactive list that are referenced are moved to the active
list. Unreferenced pages in the active list are moved to the inactive
list. (Checking the reference bit also clears it).

And a gazillion exceptions and details...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
