Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9125E6B01EE
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 17:04:05 -0400 (EDT)
Date: Mon, 5 Apr 2010 13:58:57 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
In-Reply-To: <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
Message-ID: <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
References: <patchbomb.1270168887@v2.random>  <20100405120906.0abe8e58.akpm@linux-foundation.org>  <20100405193616.GA5125@elte.hu>  <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com>  <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>



On Mon, 5 Apr 2010, Pekka Enberg wrote:
> 
> Unfortunately I wasn't able to find a pony on Google but here are some
> huge page numbers if you're interested:

You missed the point.

Those numbers weren't done with the patches in question. They weren't done 
with the magic new code that can handle fragmentation and swapping. They 
are simply not relevant to any of the complex code under discussion.

The thing you posted is already doable (and done) using the existing hacky 
(but at least unsurprising) preallocation crud. We know that works. That's 
never been the issue.

What I'm asking for is this thing called "Does it actually work in 
REALITY". That's my point about "not just after a clean boot".

Just to really hit the issue home, here's my current machine:

	[root@i5 ~]# free
	             total       used       free     shared    buffers     cached
	Mem:       8073864    1808488    6265376          0      75480    1018412
	-/+ buffers/cache:     714596    7359268
	Swap:     10207228      12848   10194380

Look, I have absolutely _sh*tloads_ of memory, and I'm not using it. 
Really. I've got 8GB in that machine, it's just not been doing much more 
than a few "git pull"s and "make allyesconfig" runs to check the current 
kernel and so it's got over 6GB free. 

So I'm bound to have _tons_ of 2M pages, no?

No. Lookie here:

	[344492.280001] DMA: 1*4kB 1*8kB 1*16kB 2*32kB 2*64kB 0*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15836kB
	[344492.280020] DMA32: 17516*4kB 19497*8kB 18318*16kB 15195*32kB 10332*64kB 5163*128kB 1371*256kB 123*512kB 2*1024kB 1*2048kB 0*4096kB = 2745528kB
	[344492.280027] Normal: 57295*4kB 66959*8kB 39639*16kB 29486*32kB 10483*64kB 2366*128kB 398*256kB 100*512kB 27*1024kB 3*2048kB 0*4096kB = 3503268kB

just to help you parse that: this is a _lightly_ loaded machine. It's been 
up for about four days. And look at it.

In case you can't read it, the relevant part is this part:

	DMA: .. 1*2048kB 3*4096kB
	DMA32: .. 1*2048kB 0*4096kB
	Normal: .. 3*2048kB 0*4096kB

there is just a _small handful_ of 2MB pages. Seriously. On a machine with 
8 GB of RAM, and three quarters of it free, and there is just a couple of 
contiguous 2MB regions. Note, that's _MB_, not GB.

And don't tell me that these things are easy to fix. Don't tell me that 
the current VM is quite clean and can be harmlessly extended to deal with 
this all. Just don't. Not when we currently have a totally unexplained 
regression in the VM from the last scalability thing we did.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
