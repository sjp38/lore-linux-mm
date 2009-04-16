Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3C3305F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 13:12:27 -0400 (EDT)
Message-ID: <49E766F3.60800@vlnb.net>
Date: Thu, 16 Apr 2009 21:12:19 +0400
From: Vladislav Bolkhovitin <vst@vlnb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] readahead: introduce context readahead algorithm
References: <20090412071950.166891982@intel.com> <20090412072052.686760755@intel.com> <20090412084819.GA25314@elte.hu> <20090412123518.GA5599@localhost>
In-Reply-To: <20090412123518.GA5599@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Jeff Moyer <jmoyer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Chenfeng Xu <xcf@ustc.edu.cn>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wu Fengguang, on 04/12/2009 04:35 PM wrote:
> On Sun, Apr 12, 2009 at 04:48:19PM +0800, Ingo Molnar wrote:
>> * Wu Fengguang <fengguang.wu@intel.com> wrote:
>>
>>> Introduce page cache context based readahead algorithm.
>>> This is to better support concurrent read streams in general.
>>>  /*
>>> + * Count contiguously cached pages from @offset-1 to @offset-@max,
>>> + * this count is a conservative estimation of
>>> + * 	- length of the sequential read sequence, or
>>> + * 	- thrashing threshold in memory tight systems
>>> + */
>>> +static pgoff_t count_history_pages(struct address_space *mapping,
>>> +				   struct file_ra_state *ra,
>>> +				   pgoff_t offset, unsigned long max)
>>> +{
>>> +	pgoff_t head;
>>> +
>>> +	rcu_read_lock();
>>> +	head = radix_tree_prev_hole(&mapping->page_tree, offset - 1, max);
>>> +	rcu_read_unlock();
>>> +
>>> +	return offset - 1 - head;
>>> +}
>> Very elegant method! I suspect this will work far better 
>> than adding various increasingly more complex heuristics.
>>
>> Emphatically-Acked-by: Ingo Molnar <mingo@elte.hu>
> 
> Thank you Ingo!
> 
> The only pity is that this heuristic can be defeated by some user
> space program that tries to do aggressive drop-behind via
> fadvise(DONTNEED) calls. But as long as the drop-behind algorithm
> be a bit lazy and does not try to squeeze the last page at @offset-1,
> this patch will work just OK.
> 
> The context readahead idea is so fundamental, that a slightly modified
> algorithm can be used for all kinds of sequential patterns, and it can
> automatically adapt to the thrashing threshold.
> 
>         1 if (probe_page(index - 1)) {
>         2          begin = next_hole(index, max);
>         3          H     = index - prev_hole(index, 2*max);
>         4          end   = index + H;
>         5          update_window(begin, end);
>         6          submit_io();
>         7 }
> 
>             [=] history [#] current [_] readahead [.] new readahead
>             ==========================#____________..............
>         1                            ^index-1
>         2                             |----------->[begin
>         3  |<----------- H -----------|
>         4                             |----------- H ----------->]end
>         5                                          [ new window ]
> 
> 
> We didn't do that because we want to
> - avoid unnecessary page cache lookups for normal cases
> - be more aggressive when thrashings are not a concern
> 
> However, readahead thrashings are far more prevalent than one would
> expect in a FTP/HTTP file streaming server. It can happen in a modern
> server with 16GB memory, 1Gbps outbound bandwidth and 1MB readahead
> size, due to the existences of slow streams.
> 
> Let's do a coarse calculation. The 8GB inactive_list pages will be
> cycled in 64Gb/1Gbps=64 seconds. This means an async readahead window
> must be consumed in 64s, or it will be thrashed.  That's a speed of
> 2048KB/64s=32KB/s. Any client below this speed will create thrashings
> in the server. In practice, those poor slow clients could amount to
> half of the total connections(partly because it will take them more
> time to download anything). The frequent thrashings will in return
> speedup the LRU cycling/aging speed...
> 
> We need a thrashing safe mode which do
> - the above modified context readahead algorithm
> - conservative ramp up of readahead size
> - conservative async readahead size
> 
> The main problem is: when shall we switch into the mode?

More I think about an ideal readahead, more it looks like page cache 
should also keep fairness between its users, similarly as it's done for 
CPU (CFS) and disk (CFQ). A slow user should have a chance to use its 
chunk the cache in face of too fast thrasher.

The main problems with it are to define what "user" is and how to 
implement the fairness in an acceptably simple way.

Maybe something like that: "user" is IO context (or IO stream?) and, if 
there would be a need to get some pages for "user" A, pages belonging to 
other "users" would be evicted with additional wight W, so A's pages 
would be preferred during eviction.

Just my 0.05c.

> We can start with aggressive readahead and try to detect readahead
> thrashings and switch into thrashing safe mode automatically. This
> will work for non-interleaved reads.  However the big file streamer -
> lighttpd - does interleaved reads.  The current data structure is not
> able to detect most readahead thrashings for lighttpd.
> 
> Luckily, the non-resident page tracking facility could help this case.
> There the thrashed pages with their timing info can be found, based on
> which we can have some extended context readahead algorithm that could
> even overcome the drop-behind problem :)
> 
> Thanks,
> Fengguang
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
