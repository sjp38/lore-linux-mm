Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA27518
	for <linux-mm@kvack.org>; Mon, 17 Aug 1998 14:43:45 -0400
Date: Mon, 17 Aug 1998 20:41:03 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] OOM killer
In-Reply-To: <199808171650.JAA13881@tcadnt01.sc.intel.com>
Message-ID: <Pine.LNX.3.96.980817203457.5034D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Claus Fischer <cfischer@td2cad.intel.com>
Cc: H.H.vanRiel@phys.uu.nl, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 17 Aug 1998, Claus Fischer wrote:

> Comments (disordered):
> 	unsigned int ram;         /* in percent */
> 	unsigned int total;       /* in percent */
>     The comments would help just a bit :-)

I promise a code cleanup before submission. Note the
"this should be in a .h file" statements...

> 	points /= int_sqrt(int_sqrt((jiffies - p->start_time) >> (SHIFT_HZ + 10)));
> 
>     If jiffies have wrapped around, the process does not get more points.
>     I don't know of a good solution to that.

Anybody?

> 		int tries, tried, succes;
> 
>      Should it read success, or is this deliberate?

Oops, a speling erorr :)

>      Here's the most important comment:
> 
> 	free_vm = ((val.freeram + val.bufferram + val.freeswap) >>
> 		PAGE_SHIFT) + page_cache_size - (page_cache.min_percent +
> 		buffer_mem.min_percent) * num_physpages;
>        
>      I somehow have a feeling that the page cache, min_percent etc. things
>      should be subtracted from the kill_limit instead of added to the
>      free_vm. Also, they should perhaps be individually limited?
> 
>      Rationale:
>           Just imagine 2 % free memory, buffer_mem.min_percent is 5?
>           In this case free_vm would result as a negative value, and
>           it would kill though it should't.

Even with 2% of free memory, if you have buffer_mem.min_percent at
5, at least 5% of memory will be used by the buffer cache. This
makes sure that free_vm can't be negative. This also means the
code _is_ correct after all...

>           int page_cache_min = page_cache.min_percent * num_physpages;
>           int buffer_min = /* something similar? */
>           int blocked_ram = page_cache_min +
>                             (buffer_mem.min_percent * num_physpages;
>           int page_cache_exceeding = max(page_cache_size - page_cache_min,0);
>           int buffer_exceeding = max(buffer_size - buffer_min,0);

This doesn't add much to the readability of the code. Nice comments
and pointers to other places in the code will teach new folks much
more.

> Generally, I think this is an excellent object for 'theoretical programming';
> since this code will not be used much in everyday practice (hopefully),
> you can only look at it and try very hard to make sure it will work :-)

See the comment at the top of the file. I intend it to be a nice and
readable starting point for newbie kernel hackers. This is _the_
place in the kernel where we don't need performance and where we
_do_ need to be absolutely correct.

Besides, having a nice signpost in the kernel source might not be
bad after all. What's 5 or even 10 kB of signposting in this file
if it can teach a lot about memory management and scheduling to new
potential kernel hackers?

> Thanks for doing all that. You probably have a small circle of dedicated
> customers for that but this circle will appreciate it very much.

Thanks.

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
