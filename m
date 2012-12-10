Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 6C3436B006C
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 13:29:06 -0500 (EST)
Date: Mon, 10 Dec 2012 19:29:00 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <20121201004520.GK2301@cmpxchg.org> <50BC6314.7060106@leemhuis.info> <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org> <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to> <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com> <50C32D32.6040800@iskon.hr> <50C3AF80.8040700@iskon.hr> <alpine.LFD.2.02.1212081651270.4593@air.linux-foundation.org> <20121210110337.GH1009@suse.de>
In-Reply-To: <20121210110337.GH1009@suse.de>
Message-ID: <50C629EC.6080800@iskon.hr>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: kswapd craziness in 3.7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 10.12.2012 12:03, Mel Gorman wrote:
> There is a big difference between a direct reclaim/compaction for THP
> and kswapd doing the same work. Direct reclaim/compaction will try once,
> give up quickly and defer requests in the near future to avoid impacting
> the system heavily for THP. The same applies for khugepaged.
>
> kswapd is different. It can keep going until it meets its watermarks for
> a THP allocation are met. Two reasons why it might keep going for a long
> time are that compaction is being inefficient which we know it may be due
> to crap like this
>
> end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
>
> and the second reason is if the highest zone is relatively because
> compaction_suitable will keep saying that allocations are failing due to
> insufficient amounts of memory in the highest zone. It'll reclaim a little
> from this highest zone and then shrink_slab() potentially dumping a large
> amount of memory. This may be the case for Zlatko as with a 4G machine
> his ZONE_NORMAL could be small depending on how the 32-bit address space
> is used by his hardware.
>

The kernel is 64-bit, if it makes any difference (userspace, though is 
still 32-bit). There's no swap (swap support not even compiled in). The 
zones are as follows:

On node 0 totalpages: 1048019
   DMA zone: 64 pages used for memmap
   DMA zone: 6 pages reserved
   DMA zone: 3913 pages, LIFO batch:0
   DMA32 zone: 16320 pages used for memmap
   DMA32 zone: 831109 pages, LIFO batch:31
   Normal zone: 3072 pages used for memmap
   Normal zone: 193535 pages, LIFO batch:31

If I understand correctly, you think that because 193535 pages in 
ZONE_NORMAL is relatively small compared to 831109 pages of ZONE_DMA32 
the system has hard time balancing itself?

Is there any way I could force and test different memory layout? I'm 
slightly lost at all the memory models (if I have a choice at all), so 
if you have any suggestions, I'm all ears.

Maybe I could limit available memory and thus have only DMA32 zone, just 
to prove your theory? I remember doing tuning like that many years ago 
when I had more time to play with Linux MM, unfortunately didn't have 
much time lately, so I'm a bit rusty, but I'm willing to help testing 
and resolving this issue.

-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
