Date: Thu, 11 Aug 2005 21:22:11 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH/RFT 5/5] CLOCK-Pro page replacement
In-Reply-To: <1123798095.4692.66.camel@moon.c3.lanl.gov>
Message-ID: <Pine.LNX.4.61.0508112117390.23457@chimarrao.boston.redhat.com>
References: <20050810200216.644997000@jumble.boston.redhat.com>
 <20050810200944.197606000@jumble.boston.redhat.com> <1123798095.4692.66.camel@moon.c3.lanl.gov>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Song Jiang <sjiang@lanl.gov>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Aug 2005, Song Jiang wrote:

> My machine has 2GB memory.
> The size of the file to be scanned is 2.5GB.

> Meanwhile, Clock-Pro is supposed to do a better job, because
> part of the file can be protected in the active list and get
> a decent number of hits.

> Active:          11356 kB
> Inactive:      1994400 kB

There is an error somewhere in my implementation of Clock-Pro.

I have made some tweaks but haven't found a proper fix yet.

The problem is that if I make things too well in favor of the
evicted pages, then pages on the active list may get replaced
by pages that have the _same_ inter-reference distance, which
would result in similarly bad behaviour.

Eyeballs on vmscan.c, nonresident.c and clockpro.c would be
very much appreciated ;)

> Here is from /proc/refaults:     
> 
>     Refault distance          Hits
>          0 -     32768           192
>     32768 -     65536           269
>     65536 -     98304           447
>     98304 -    131072           603
>    131072 -    163840          1087
>    163840 -    196608           909
>    196608 -    229376           558
>    229376 -    262144           404
>    262144 -    294912           287
>    294912 -    327680           191
>    327680 -    360448            79
>    360448 -    393216            68
>    393216 -    425984            41
>    425984 -    458752            45
>    458752 -    491520            31
> New/Beyond    491520          2443
> 
> In the statistic, we do see many hits at the distance of around 
> 150,000 pages. If we consider the inactive list size (1.9GB), 
> this position corresponds to the file size. However, if everything
> happens as expected, all the hits should happen at the
> distance. Unfortunately, there are also many hits listed as
> New/Beyond. Because "Beyond"s should not be there, are they all
> "New"s? Futhermore, I didn't see where the refault_histogram 
> statistics get reset, though they almost stop increasing after
> the first run. Can you show me that? 

Currently the statistics never get reset.

The number of "new/beyond" sounds about right for the
startup of a fully running Linux system.

-- 
All Rights Reversed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
