Message-ID: <47287220.8050804@garzik.org>
Date: Wed, 31 Oct 2007 08:16:32 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/33] Swap over NFS -v14
References: <20071030160401.296770000@chello.nl>	 <200710311426.33223.nickpiggin@yahoo.com.au> <1193830033.27652.159.camel@twins>
In-Reply-To: <1193830033.27652.159.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

1) I absolutely agree that NFS is far more prominent and useful than any 
network block device, at the present time.


2) Nonetheless, swap over NFS is a pretty rare case.  I view this work 
as interesting, but I really don't see a huge need, for swapping over 
NBD or swapping over NFS.  I tend to think swapping to a remote resource 
starts to approach "migration" rather than merely swapping.  Yes, we can 
do it...  but given the lack of burning need one must examine the price.


3) You note
> Swap over network has the problem that the network subsystem does not use fixed
> sized allocations, but heavily relies on kmalloc(). This makes mempools
> unusable.

True, but IMO there are mitigating factors that should be researched and 
taken into account:

a) To give you some net driver background/history, most mainstream net 
drivers were coded to allocate RX skbs of size 1538, under the theory 
that they would all be allocating out of the same underlying slab cache. 
  It would not be difficult to update a great many of the [non-jumbo] 
cases to create a fixed size allocation pattern.

b) Spare-time experiments and anecdotal evidence points to RX and TX skb 
recycling as a potentially valuable area of research.  If you are able 
to do something like that, then memory suddenly becomes a lot more 
bounded and predictable.


So my gut feeling is that taking a hard look at how net drivers function 
in the field should give you a lot of good ideas that approach the 
shared goal of making network memory allocations more predictable and 
bounded.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
