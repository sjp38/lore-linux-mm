Message-ID: <413AB179.5030706@yahoo.com.au>
Date: Sun, 05 Sep 2004 16:26:01 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/3] beat kswapd with the proverbial clue-bat
References: <413AA7B2.4000907@yahoo.com.au> <20040904230939.03da8d2d.akpm@osdl.org>
In-Reply-To: <20040904230939.03da8d2d.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 

>>Apparently these (higher-order && !wait) come up mainly in networking
>>which is the thing I had in mind. *However* as I only have half of a
>>gigabit network (ie. 1 card), I haven't done any testing where it
>>really counts. I'm also seeing surprisingly few reports on lkml, so
>>perhaps it is me that needs the beating?
> 
> 
> There have been few reports, and I believe that networking is getting
> changed to reduce the amount of GFP_ATOMIC higher-order allocation
> attempts.
> 

That is the ideal goal, I think. But while our allocator offers higher
order allocations, we *should* be a bit smarter about them.

> There have been multiple instances in the past year or so where we've made
> changes in there, the changes were not adequately tested and stuff broke in
> subtle ways.  We need to raise the bar a bit - clearly demonstrate that we
> have a problem, and then demonstrate that the fix fixes it, then worry
> about side-effects.
> 

Yep. As you see I've already corrected myself a couple of times :\
RFC only at this stage.

> 
> I don't see anything in your code which directly prevents the following
> serious scenario:
> 
> a) Some random 0-order allocation causes a 4-order page to be split up,
>    taking the 4-order pool below threshold.
> 
> b) kswapd goes berzerk reclaiming 9000 pages to replenish the 4-order
>    pool even though we don't need it.  
> 
> You have arith in there which kinda-sorta prevents it, but I don't see any
> hard-and-fast protection.  Or did I miss it?  
> 

Yep. Kswapd will not care about 4-order allocations unless someone does
a wake_kswapd(order 4);

We could get into a situation where kswapd free smore than required, but
if you've got someone regularly allocating 4-order pages, it probably
isn't *that* dumb to free one or two more.

If we complete an entire balance_pgdat round without freeing the required
pages, that kswapd_max_order gets reset to zero anyway...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
