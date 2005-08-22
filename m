Date: Mon, 22 Aug 2005 09:24:57 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] Use deltas to replace atomic inc
In-Reply-To: <20050822154300.GA29976@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0508220921460.6727@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
 <Pine.LNX.4.62.0508200033420.20471@schroedinger.engr.sgi.com>
 <20050820005843.21ba4d9b.akpm@osdl.org> <Pine.LNX.4.62.0508212030020.2093@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508212040380.3317@g5.osdl.org>
 <Pine.LNX.4.62.0508212102240.2290@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508212112260.3317@g5.osdl.org>
 <Pine.LNX.4.62.0508220617030.4675@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0508221508410.18930@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508220823150.6260@schroedinger.engr.sgi.com>
 <20050822154300.GA29976@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Aug 2005, Andi Kleen wrote:

> > The page_table_lock is taken using a spin_trylock. Its skipped if 
> > contended.
> Hmm - doesn't try lock cause a cache line bounce on the bus too? 
> I think it does. That would mean its latency is not much better 
> than a real spinlock (assuming it doesn't have to spin) 

Trylock does a cmpxchg on ia64 and thus acquires a exclusive cache line. 
So yes. But this is only done if there are updates pending. schedule() is 
not called that frequently. On bootup I see on average updates of 5-20 
pages per mm_counter_catchup. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
