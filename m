Received: from Galois.suse.de (Zuse.suse.de [195.125.217.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA01798
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 08:02:18 -0500
Date: Thu, 26 Mar 1998 14:00:53 +0100
Message-Id: <199803261300.OAA25495@boole.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <19980326034544.27868@jackalz> (message from Myrdraal on Thu, 26
	Mar 1998 03:45:44 -0500)
Subject: Re: 2.1.91pre2 death by swapping.
Sender: owner-linux-mm@kvack.org
To: myrdraal@jackalz.dyn.ml.org
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> 
> Hi,
>  Well, shortly after I wrote my previous message, 2.1.91pre2 died a nasty
>  death. This system has 64mb RAM and was lightly loaded, the main thing
>  it was doing was playing a MOD. It started to swap out of the blue, the
>  mod started skipping more and more, and eventually stopped playing
>  entiredly while the machine thrashed. It continued thrashing for 10-15
>  minutes, every program totally stopped while this was happening. Using
>  the magic sysrq show memory option, I could see that the free pages
>  number was fluctuating between 10200 and 10250 or so. Eventually I rebooted
>  back to 2.1.90 with the magic sysrq.
> -Myrdraal


I've found the following piece of code in the 2.1.91pre2:

--------------------------------------------------------------------------
--- v2.1.90/linux/mm/filemap.c	Tue Mar 10 10:03:36 1998
+++ linux/mm/filemap.c	Wed Mar 25 13:13:36 1998
@@ -150,6 +150,10 @@
 				}
 				tmp = tmp->b_this_page;
 			} while (tmp != bh);
+
+			/* Refuse to swap out all buffer pages */
+			if ((buffermem >> PAGE_SHIFT) * 100 > (buffer_mem.min_percent * num_physpages))
+				goto next;
 		}
 
 		/* We can't throw away shared pages, but we do mark
--------------------------------------------------------------------------

IMHO the `>' should be a `<', shouldn't it?

... and the better place fur such a statement is IMHO
linux/mm/vmscan.c:do_try_to_free_page() which would avoid the shrink_mmap()
and its do-while-loop.


          Werner
