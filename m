Message-ID: <3D987CF7.6060203@colorfullife.com>
Date: Mon, 30 Sep 2002 18:33:59 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: 2.5.39 kmem_cache bug
References: <20020928201308.GA59189@compsoc.man.ac.uk> <200209292020.40824.tomlins@cam.org> <3D97E737.80405@colorfullife.com> <200209300718.57382.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

What's the optimal number of free objects in the partial/free lists of 
an active cache?

I'd say a few times the batchcount, otherwise a cpu won't be able to 
perform a complete refill. [during refill, at most one grow happens - 
I've assumed that swallowing 30 pages with GFP_ATOMIC in an interrupt 
handler is not nice from the system perspective]

What about this logic:
- if there were no recent allocations performed by a cpu, then return 
cc->limit/5 objects from the cpu array to the node lists.

- If a slab becomes a free slab, and there are more than 
3*cc->batchcount*NR_CPUS/NR_NODES objects in the partial or free lists, 
then return the slab immediately to the gfp.

- If noone accessed the free list recently, then a few slabs are 
returned to gfp. [<worst case number of free slabs that can exist>/5]

The constants could be updated by vm pressure callbacks.

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
