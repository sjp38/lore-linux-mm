From: Dawson Engler <engler@csl.stanford.edu>
Message-Id: <200303221145.h2MBjAW09391@csl.stanford.edu>
Subject: [CHECKER] races in 2.5.65/mm/swapfile.c?
Date: Sat, 22 Mar 2003 03:45:10 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dawson Engler <engler@csl.stanford.edu>
List-ID: <linux-mm.kvack.org>

Hi All,

mm/swapfile.c seems to have three potential races.

The first two are in 
        linux-2.5.62/mm/swap_state.c:87:add_to_swap_cache

which seems reachable without a lock from the callchain:

        mm/swapfile.c:sys_swapoff:998->
              sys_swapoff:1026->
                try_to_unuse:591->
                        mm/swap_state.c:read_swap_cache_async:377->
                            add_to_swap_cache

add_to_swap_cache increments two global variables without a lock:
        INC_CACHE_INFO(add_total);
and
        INC_CACHE_INFO(exist_race);


The final one is in
        linux-2.5.62/mm/swapfile.c:213:swap_entry_free
which seems to increment
        nr_swap_pages++;
without a lock.

Are these real races?  Or are these just stats variables?  (Or is
there some implicit locking that protects these?)

Regards,
Dawson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
