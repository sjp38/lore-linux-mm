Date: Mon, 14 Jun 2004 16:06:42 +0200
From: Miquel van Smoorenburg <miquels@cistron.nl>
Subject: Re: Keeping mmap'ed files in core regression in 2.6.7-rc
Message-ID: <20040614140642.GE13422@traveler.cistron.net>
References: <20040608142918.GA7311@traveler.cistron.net> <40CAA904.8080305@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Miquel van Smoorenburg <miquels@cistron.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2004.06.12 08:56, Nick Piggin wrote:
> Miquel van Smoorenburg wrote:
> 
> > Now I tried 2.6.7-rc2 and -rc3 (well rc2-bk-latest-before-rc3) and
> > with those kernels, performance goes to hell because no matter
> > how much I tune, the kernel will throw out the mmap'ed pages first.
> > RSS of the innd process hovers around 200-250 MB instead of 600.
> > 
> > Ideas ?
> > 
> 
> Can you try the following patch please?

The patch below indeed fixes this problem. Now most of the mmap'ed files
are actually kept in memory and RSS is around 600 MB again:

$ uname -a
Linux quantum 2.6.7-rc3 #1 SMP Mon Jun 14 12:48:34 CEST 2004 i686 GNU/Linux
$ free
             total       used       free     shared    buffers     cached
Mem:       1037240     897668     139572          0     159320     501688
-/+ buffers/cache:     236660     800580
Swap:       996020      16160     979860
$ ps u -C innd
USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND
news       277 31.8 56.2 857124 583896 ?     D    13:02  57:01 /usr/local/news/b

Hmm, weird that 'free' says that 139 MB is unused.. the box is doing
lots of I/O. 'free' hovers between 30 - 250 MB over time.

Look, 1 minute later:

$ free
             total       used       free     shared    buffers     cached
Mem:       1037240     788368     248872          0      29260     497600
-/+ buffers/cache:     261508     775732
Swap:       996020      16260     979760

Ah wait, that appears to be an outgoing feed process that keeps on allocating
and freeing memory at a fast rate, so that makes sense I guess. At least
the RSS of the main innd process remains steady at around ~600 MB and that
is what is important for this application.

Thanks,

Mike.



>  linux-2.6-npiggin/mm/vmscan.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff -puN mm/vmscan.c~vm-revert-fix mm/vmscan.c
> --- linux-2.6/mm/vmscan.c~vm-revert-fix	2004-06-12 16:53:02.000000000 +1000
> +++ linux-2.6-npiggin/mm/vmscan.c	2004-06-12 16:54:26.000000000 +1000
> @@ -813,9 +813,8 @@ shrink_caches(struct zone **zones, int p
>  		struct zone *zone = zones[i];
>  		int max_scan;
>  
> -		zone->temp_priority = priority;
> -		if (zone->prev_priority > priority)
> -			zone->prev_priority = priority;
> +		if (zone->free_pages < zone->pages_high)
> +			zone->temp_priority = priority;
>  
>  		if (zone->all_unreclaimable && priority != DEF_PRIORITY)
>  			continue;	/* Let kswapd poll it */
> @@ -996,8 +995,6 @@ scan:
>  					all_zones_ok = 0;
>  			}
>  			zone->temp_priority = priority;
> -			if (zone->prev_priority > priority)
> -				zone->prev_priority = priority;
>  			max_scan = (zone->nr_active + zone->nr_inactive)
>  								>> priority;
>  			reclaimed = shrink_zone(zone, max_scan, GFP_KERNEL,
> 
> _
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
