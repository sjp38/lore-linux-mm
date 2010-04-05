Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5B6B16B0224
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 06:49:47 -0400 (EDT)
Received: by pwi2 with SMTP id 2so2653795pwi.14
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 03:49:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100405101424.GA21207@csn.ul.ie>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
	 <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
	 <20100402135955.645F.A69D9226@jp.fujitsu.com>
	 <20100402094805.GA12886@csn.ul.ie>
	 <h2rd6200be21004021759x4ae83403i4daa206d47b7d523@mail.gmail.com>
	 <20100405101424.GA21207@csn.ul.ie>
Date: Mon, 5 Apr 2010 19:49:44 +0900
Message-ID: <n2n28c262361004050349t943cdc03t7079f3066660e3d3@mail.gmail.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding page->lru?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Arve Hj?nnev?g <arve@android.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, TAO HU <tghk48@motorola.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hi, Mel and Arve.

On Mon, Apr 5, 2010 at 7:14 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Fri, Apr 02, 2010 at 05:59:00PM -0700, Arve Hj?nnev?g wrote:
>> On Fri, Apr 2, 2010 at 2:48 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > On Fri, Apr 02, 2010 at 02:03:23PM +0900, KOSAKI Motohiro wrote:
>> >> Cc to Mel,
>> >>
>> >> > 2 patches related to page_alloc.c were applied.
>> >> > Does anyone see a connection between the 2 patches and the panic?
>> >> > NOTE: the full patches are attached.
>> >>
>> >> I think your attached two patches are perfectly unrelated your problem.
>> >>
>> >
>> > Agreed. It's unlikely that there is a race as such in the page
>> > allocator. In buffered_rmqueue that you initially talk about, the lists
>> > being manipulated are per-cpu lists. About the only way to corrupt them
>> > is if you had a NMI hander that called the page allocator. I really hope
>> > your platform is not doing anything like that.
>> >
>> > A double free of page->lru is a possibility. You could try reproducing
>> > the problem with CONFIG_DEBUG_LIST enabled to see if anything falls out.
>> >
>> >> "mm: Add min_free_order_shift tunable." seems makes zero sense. I don't think this patch
>> >> need to be merge.
>> >>
>> >
>> > It makes a marginal amount of sense. Basically what it does is allowing
>> > high-order allocations to go much further below their watermarks than is
>> > currently allowed. If the platform in question is doing a lot of high-order
>> > allocations, this patch could be seen to "fix" the problem but you wouldn't
>> > touch mainline with it with a barge pole. It would be more stable to fix
>> > the drivers to not use high order allocations or use a mempool.
>> >
>>
>> The high order allocation that caused problems was the first level
>> page table for each process.
>
> Out of curiousity, how big is that allocation? Is it specific to
> android? If it is, I guess it can be let slide but if it's common, it

It is the specific on ARM. You can refer get_pgd_slow in arch/arm/mm/pgd.c.
It allocates order 2 page for pgd.

> would be worth thinking of an arch-hook that tells the VM that a
> particular high-order is very common. For example, one possibility would
> be to ask kswapd to always reclaim at a given order even if the
> watermarks required are for a lower order.

Just out of curiosity, too.

Normally, embedded system don't have fork-bomb workload.
But I think android's case is some different.
That's because Dalvik(JVM) keeps many memory which are anon pages for byte codes
by itself as possible as.
So system always doesn't have enough memory.
In addition, most of embedded system don't have swap. It makes system
worse, too.
So current reclaimer can't be work well.

I am not sure my assumption.
Arve, my guessing is right?
If it is so, Dalvik have to solve this problem?
For example, AFAIK, android kernel has low memory killer.
If kernel signals memory pressure, Dalvik have to discard some
anon pages which has byte codes for executable.

It is just my guessing about android. If I misunderstood about android,
please, correct me. :)

>
>> Each time a new process started the
>> kernel would empty the entire page cache to create contiguous free
>> memory.
>
> I ask because I'm surprised the entire page cache got chucked out

Maybe it was because system has lots of anon pages but no swap.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
