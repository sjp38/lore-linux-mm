Received: from venus.star.net (root@venus.star.net [199.232.114.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA05698
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 12:03:22 -0400
Message-ID: <35B75FE8.63173E88@star.net>
Date: Thu, 23 Jul 1998 12:08:08 -0400
From: Bill Hawes <whawes@star.net>
MIME-Version: 1.0
Subject: Re: Good and bad news on 2.1.110, and a fix
References: <199807231248.NAA04764@dax.dcs.ed.ac.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <number6@the-village.bc.nu>, "David S. Miller" <davem@dm.cobaltmicro.com>, Ingo Molnar <mingo@valerie.inf.elte.hu>, Mark Hemment <markhe@nextd.demon.co.uk>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
 
> The patch to page_alloc.c is a minimal fix for the fragmentation
> problem.  It simply records allocation failures for high-order pages,
> and forces free_memory_available to return false until a page of at
> least that order becomes available.  The impact should be low, since
> with the SLAB_BREAK_GFP_ORDER patch 2.1.111-pre1 seems to survive pretty
> well anyway (and hence won't invoke the new mechanism), but in cases of
> major atomic allocation load, the patch allows even low memory machines
> to survive the ping attack handsomely (even with 8k NFS on a 6.5MB
> configuration).  I get tons of "IP: queue_glue: no memory for gluing
> queue" failures, but enough NFS retries get through even during the ping
> flood to prevent any NFS server unreachables happening.

Hi Stephen,

Your change to track the maximum failed allocation looks helpful, as
this will focus extra swap attention when a problem actually occurs. So
assuming that the client has a retry capability (as with NFS), it should
improve recoverability.

One possible downside is that kswapd infinite looping may become more
likely, as we still have no way to determine when the memory
configuration makes it impossible to achieve the memory goal. I still
see this "swap deadlock" in 110 (and all recent kernels) under low
memory or by doing a swapoff. Any ideas on how to best determine an
infeasible memory configuration?

Under some conditions the most helpful action may be to let some
allocations fail, to shed load or kill processes. (But selecting the
right process to kill may not be easy ...)

Regards,
Bill
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
