Date: Mon, 14 Jun 2004 15:04:56 -0700 (PDT)
From: Ron Maeder <rlm@orionmulti.com>
Subject: Re: mmap() > phys mem problem
Message-ID: <Pine.LNX.4.44.0406141501340.7351-100000@pygar.sc.orionmulti.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: riel@surriel.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I tried upping /proc/sys/vm/min_free_kbytes to 4096 as suggested below, 
with the same results (grinding to a halt, out of mem).

Any other suggestions?  Thanks for your help.

Ron

---------- Forwarded message ----------
Date: Sun, 06 Jun 2004 11:55:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
To: Ron Maeder <rlm@orionmulti.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org,
     Andrew Morton <akpm@osdl.org>
Subject: Re: mmap() > phys mem problem

Ron Maeder wrote:
> Thanks very much for your response.  I have had some help trying out the 
> patch and running recent versions of the kernel.  The problem is not 
> fixed in 2.6.6+patch or in 2.6.7-rc2.  Any other suggestions?
> 

OK, NFS is getting stuck in nfs_flush_one => mempool_alloc presumably
waiting for some network IO. Unfortunately at this point, the system
is so clogged up that order 0 GFP_ATOMIC allocations are failing in
this path: netedev_rx => refill_rx => alloc_skb. ie. deadlock.

Sadly this seems to happen pretty easily here. I don't know the
network layer, so I don't know what might be required to fix it or if
it is even possible.

This doesn't happen so easily with swap enabled (still theoretically
possible), because freeing block device backed memory should be
deadlock free, so you have another avenue to free memory. I assume
you want diskless clients, so this isn't an option.

You could try working around it by upping /proc/sys/vm/min_free_kbytes
maybe to 2048 or 4096.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
