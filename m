Received: from crotus.sc.intel.com (root@crotus.sc.intel.com [143.183.152.26])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA26905
	for <linux-mm@kvack.org>; Mon, 17 Aug 1998 12:48:04 -0400
Date: Mon, 17 Aug 1998 09:50:05 -0700
Message-Id: <199808171650.JAA13881@tcadnt01.sc.intel.com>
From: Claus Fischer <cfischer@td2cad.intel.com>
In-reply-to: <Pine.LNX.3.96.980816182759.697A-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Sun, 16 Aug 1998 18:34:32 +0200 (CEST))
Subject: Re: [PATCH] OOM killer
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@phys.uu.nl
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>



Rik,

thanks for doing it so nicely. I just came back from a Yellowstone vacation.

Comments (disordered):

	unsigned int ram;         /* in percent */
	unsigned int total;       /* in percent */

    The comments would help just a bit :-)


	points /= int_sqrt(int_sqrt((jiffies - p->start_time) >> (SHIFT_HZ + 10)));

    If jiffies have wrapped around, the process does not get more points.
    It's no big problem in this case, it just means that jobs like are not 
    init etc. all too well weighted after the wrap-around.

    I don't know of a good solution to that.


                unsigned int points;
                unsigned int b;

		if (p->pid && (b = badness(p)) > points)
			chosen = p, points = b;

    
\ No newline at end of file

     Not easy to apply for a patch; Wine recently had the same thing in one of
     its patches :-)

		int tries, tried, succes;

     Should it read success, or is this deliberate?
     Otherwise I can't comment on the last patch part.

     Here's the most important comment:

	free_vm = ((val.freeram + val.bufferram + val.freeswap) >>
		PAGE_SHIFT) + page_cache_size - (page_cache.min_percent +
		buffer_mem.min_percent) * num_physpages;
       
     I somehow have a feeling that the page cache, min_percent etc. things
     should be subtracted from the kill_limit instead of added to the
     free_vm. Also, they should perhaps be individually limited?
     

     Rationale:
          Just imagine 2 % free memory, buffer_mem.min_percent is 5?
          In this case free_vm would result as a negative value, and
          it would kill though it should't.

     Perhaps so:

          int page_cache_min = page_cache.min_percent * num_physpages;
          int buffer_min = /* something similar? */
          int blocked_ram = page_cache_min +
                            (buffer_mem.min_percent * num_physpages;
          int page_cache_exceeding = max(page_cache_size - page_cache_min,0);
          int buffer_exceeding = max(buffer_size - buffer_min,0);

          kill_limit = min(vm_kill.ram * (val.totalram >> PAGE_SHIFT -
                                          blocked_ram),
                           ...);
          free_vm = ( ... )
                    + page_cache_exceeding + buffer_exceeding;


Generally, I think this is an excellent object for 'theoretical programming';
since this code will not be used much in everyday practice (hopefully),
you can only look at it and try very hard to make sure it will work :-)

Right now I have some friends to visit, so I can't spend too much time,
but I promise to take a closer look before end of August.

Thanks for doing all that. You probably have a small circle of dedicated
customers for that but this circle will appreciate it very much.

Claus
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
