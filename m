Message-ID: <40C2799B.1010306@yahoo.com.au>
Date: Sun, 06 Jun 2004 11:55:39 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: mmap() > phys mem problem
References: <Pine.LNX.4.44.0405251523250.18898-100000@pygar.sc.orionmulti.com> <Pine.LNX.4.55L.0405282208210.32578@imladris.surriel.com> <Pine.LNX.4.60.0405292144350.1068@stimpy> <40B9A855.3030102@yahoo.com.au> <Pine.LNX.4.60.0406051219130.749@stimpy>
In-Reply-To: <Pine.LNX.4.60.0406051219130.749@stimpy>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ron Maeder <rlm@orionmulti.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

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
