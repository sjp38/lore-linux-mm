Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 076A46B00C2
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 04:59:39 -0500 (EST)
Message-ID: <4ECCC407.3040700@kernel.dk>
Date: Wed, 23 Nov 2011 10:59:35 +0100
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [patch v2 for-3.2] block: initialize request_queue's numa node
 during allocation
References: <4ECB5C80.8080609@redhat.com> <alpine.DEB.2.00.1111220140470.4306@chino.kir.corp.google.com> <20111122152739.GA5663@redhat.com> <20111122211954.GA17120@redhat.com> <alpine.DEB.2.00.1111221342320.2621@chino.kir.corp.google.com> <20111122220218.GA17543@redhat.com> <alpine.DEB.2.00.1111221703590.18644@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1111221703590.18644@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mike Snitzer <snitzer@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vivek Goyal <vgoyal@redhat.com>, Dave Young <dyoung@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org, stable@vger.kernel.org

On 2011-11-23 02:14, David Rientjes wrote:
> From: Mike Snitzer <snitzer@redhat.com>
> 
> struct request_queue is allocated with __GFP_ZERO so its "node" field is 
> zero before initialization.  This causes an oops if node 0 is offline in 
> the page allocator because its zonelists are not initialized.  From Dave 
> Young's dmesg:
> 
> 	SRAT: Node 1 PXM 2 0-d0000000
> 	SRAT: Node 1 PXM 2 100000000-330000000
> 	SRAT: Node 0 PXM 1 330000000-630000000
> 	Initmem setup node 1 0000000000000000-000000000affb000
> 	...
> 	Built 1 zonelists in Node order, mobility grouping on.
> 	...
> 	BUG: unable to handle kernel paging request at 0000000000001c08
> 	IP: [<ffffffff8111c355>] __alloc_pages_nodemask+0xb5/0x870
> 
> and __alloc_pages_nodemask+0xb5 translates to a NULL pointer on 
> zonelist->_zonerefs.
> 
> The fix is to initialize q->node at the time of allocation so the correct 
> node is passed to the slab allocator later.
> 
> Since blk_init_allocated_queue_node() is no longer needed, merge it with 
> blk_init_allocated_queue().

Thanks, queued for current release.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
