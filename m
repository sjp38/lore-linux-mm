Date: Mon, 8 Jul 2002 23:30:28 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020709063028.GV25360@holomorphy.com>
References: <3D2A7466.AD867DA7@zip.com.au> <1221230287.1026170151@[10.10.2.3]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1221230287.1026170151@[10.10.2.3]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 08, 2002 at 11:15:52PM -0700, Martin J. Bligh wrote:
> wli might care to elaborate on 2 & 3, since I think he helped
> them identify / fix (helped maybe meaning did).
> 1. Irqbalance doesn't like clustered apic mode (have hack)
> 2. Using ioremap fairly early catches cpu_online_map set to 0
>    for some reason (have hack).
> 3. Something to do with BIO that I'll let Bill explain, but I
>    am given to believe it's well known (have hack).

(1) irqbalance is blatantly stuffing flat bitmasks into ICR2
	this breaks clustered hierarchical destination format
	everywhere all the time

(2) ioremap wants to flush_tlb_all() before cpu_online_map is
	initialized. This results in smp_call_function() spinning
	until an atomic_t goes to -1, which never happens since it
	doesn't kick any cpu's to decrement the counter.

(3) The bio thing is just the usual queue max_sectors where you've
	recommended decreasing the MPAGE max sectors so the bio 
	constraints are satisfied before they hit elevator.c where
	a BUG_ON() is triggered instead of a bio split.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
