Message-ID: <419D47E6.8010409@yahoo.com.au>
Date: Fri, 19 Nov 2004 12:09:58 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: another approach to rss : sloppy rss
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain> <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@kernel.vger.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 6 Nov 2004, Hugh Dickins wrote:
> 
> 
>>But I don't know what the appropriate solution is.  My priorities
>>may be wrong, but I dislike the thought of a struct mm dominated
>>by a huge percpu array of rss longs (or cachelines?), even if the
>>machines on which it would be huge are ones which could well afford
>>the waste of memory.  It just offends my sense of proportion, when
>>the exact rss is of no importance.  I'm more attracted to just
>>leaving it unatomic, and living with the fact that it's racy
>>and approximate (but /proc report negatives as 0).
> 
> 
> Here is a patch that enables handling of rss outside of the page table
> lock by simply ignoring errors introduced by not locking. The loss
> of rss was always less than 1%.
> 
> The patch insures that negative rss values are not displayed and removes 3
> checks in mm/rmap.c that utilized rss (unecessarily AFAIK).
> 

I wonder if your lazy rss counting still has a place? You still have
a shared cacheline with sloppy rss. But is it significantly better
for you just by using unlocked instructions...

    4   3    4    0.180s     16.271s   5.010s 47801.151 154059.862

... can you tell me what these numbers mean?

And do you have results for tests with no rss counters at all?

Thanks,
Nick
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
