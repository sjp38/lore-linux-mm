Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B588A8D0040
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 15:30:38 -0400 (EDT)
Date: Sat, 26 Mar 2011 14:30:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Disable the lockless allocator
In-Reply-To: <alpine.DEB.2.00.1103261406420.24195@router.home>
Message-ID: <alpine.DEB.2.00.1103261428200.25375@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>  <20110324142146.GA11682@elte.hu>  <alpine.DEB.2.00.1103240940570.32226@router.home>  <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>  <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
  <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>  <20110324192247.GA5477@elte.hu>  <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>  <20110326112725.GA28612@elte.hu>  <20110326114736.GA8251@elte.hu> <1301161507.2979.105.camel@edumazet-laptop>
 <alpine.DEB.2.00.1103261406420.24195@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Indeed I can reproduce it easily.
With a few printk's this shows that alloc_percpu() returns a wrong
address which is the cause of all of this:

logs:

Memory: 1011444k/1048564k available (11622k kernel code, 452k absent,
36668k reserved, 6270k data, 1028k init)
alloc_kmem_cache_cpus kmem_cache_node = ffff88003ffcf000
alloc_kmem_cache_cpus kmem_cache = ffff88003ffcf020

This means that the cpu_slab is not a percpu pointer.

Now the first allocation attempt:

Slab kmem_cache cpu_slab=ffff88003ffcf020 freelist=ffff88003f8020c0
BUG: unable to handle kernel paging request at ffff87ffc1fdc020
IP: [<ffffffff812c3852>] this_cpu_cmpxchg16b_emu+0x2/0x1c

Tejun: Whats going on there? I should be getting offsets into the per cpu
area and not kernel addresses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
