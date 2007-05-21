Date: Mon, 21 May 2007 04:26:03 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070521112603.GJ19966@holomorphy.com>
References: <20070518040854.GA15654@wotan.suse.de> <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com> <20070519012530.GB15569@wotan.suse.de> <20070519181501.GC19966@holomorphy.com> <20070520052229.GA9372@wotan.suse.de> <20070520084647.GF19966@holomorphy.com> <20070520092552.GA7318@wotan.suse.de> <20070521080813.GQ31925@holomorphy.com> <20070521092742.GA19642@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070521092742.GA19642@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, May 21, 2007 at 01:08:13AM -0700, William Lee Irwin III wrote:
>> Choosing k distinct integers (mem_map array indices) from the interval
>> [0,n-1] results in k(n-k+1)/n non-adjacent intervals of contiguous
>> array indices on average. The average interval length is
>> (n+1)/(n-k+1) - 1/C(n,k). Alignment considerations make going much
>> further somewhat hairy, but it should be clear that contiguity arising
>> from random choice is non-negligible.

On Mon, May 21, 2007 at 11:27:42AM +0200, Nick Piggin wrote:
> That doesn't say anything about temporal locality, though.

It doesn't need to. If what's in the cache is uniformly distributed,
you get that result for spatial locality. From there, it's counting
cachelines.


On Mon, May 21, 2007 at 01:08:13AM -0700, William Lee Irwin III wrote:
>> In any event, I don't have all that much of an objection to what's
>> actually proposed, just this particular cache footprint argument.
>> One can motivate increases in sizeof(struct page), but not this way.

On Mon, May 21, 2007 at 01:08:13AM -0700, William Lee Irwin III wrote:
> Realise that you have to have a run of I think at least 7 or 8 contiguous
> pages and temporally close references in order to save a single cacheline.
> Then also that if the page being touched is not partially in cache from
> an earlier access, then it is statistically going to cost more lines to
> touch it (up to 75% if you touch the first and the last field, obviously 0%
> if you only touch a single field, but that's unlikely given that you
> usually take a reference then do at least something else like check flags).
> I think the problem with the cache footprint argument is just whether
> it makes any significant difference to performance. But..

The average interval ("run") length is (n+1)/(n-k+1) - 1/C(n,k), so for
that to be >= 8 you need (n+1)/(n-k+1) - 1/C(n,k) >= 8 which also happens
when (n+1)/(n-k+1) >= 9 or when n >= (9/8)*k - 1 or k <= (8/9)*(n+1).
Clearly a lower bound on k is required, but not obviously derivable.
k >= 8 is obvious, but the least k where (n+1)/(n-k+1) - 1/C(n,k) >= 8
is not entirely obvious. Numerically solving for the least such k finds
that k actually needs to be relatively close to (8/9)*n. A lower bound
of something like 0.87*n + O(1) probably holds.


On Mon, May 21, 2007 at 01:08:13AM -0700, William Lee Irwin III wrote:
>> Now that I've been informed of the ->_count and ->_mapcount issues,
>> I'd say that they're grave and should be corrected even at the cost
>> of sizeof(struct page).

On Mon, May 21, 2007 at 11:27:42AM +0200, Nick Piggin wrote:
> ... yeah, something like that would bypass 

Did you get cut off here?


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
