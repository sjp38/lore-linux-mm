Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B088E6B0188
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 19:03:48 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p9DN3kS2003538
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:03:46 -0700
Received: from pzd13 (pzd13.prod.google.com [10.243.17.205])
	by wpaz1.hot.corp.google.com with ESMTP id p9DMmqWb020784
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:03:45 -0700
Received: by pzd13 with SMTP id 13so5550140pzd.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:03:43 -0700 (PDT)
Date: Thu, 13 Oct 2011 16:03:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: possible slab deadlock while doing ifenslave
In-Reply-To: <201110131019.58397.hans@schillstrom.com>
Message-ID: <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>
References: <201110121019.53100.hans@schillstrom.com> <alpine.DEB.2.00.1110121333560.7646@chino.kir.corp.google.com> <201110131019.58397.hans@schillstrom.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Schillstrom <hans@schillstrom.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@gentwo.org>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org

On Thu, 13 Oct 2011, Hans Schillstrom wrote:

> > > Hello,
> > > I got this when I was testing a VLAN patch i.e. using Dave Millers net-next from today.
> > > When doing this on a single core i686 I got the warning every time,
> > > however ifenslave is not hanging it's just a warning
> > > Have not been testing this on a multicore jet.
> > > 
> > > There is no warnings with a 3.0.4 kernel.
> > > 
> > > Is this a known warning ?
> > > 
> > > ~ # ifenslave bond0 eth1 eth2
> > > 
> > > =============================================
> > > [ INFO: possible recursive locking detected ]
> > > 3.1.0-rc9+ #3
> > > ---------------------------------------------
> > > ifenslave/749 is trying to acquire lock:
> > >  (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb
> > > 
> > > but task is already holding lock:
> > >  (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb
> > > 
> > 
> > Hmm, the only candidate that I can see that may have caused this is 
> > 83835b3d9aec ("slab, lockdep: Annotate slab -> rcu -> debug_object -> 
> > slab").  Could you try reverting that patch in your local tree and seeing 
> > if it helps?
> > 
> 
> That was not our candidate ...
> i.e. same results
> 

Ok, I think this may be related to what Sitsofe reported in the "lockdep 
recursive locking detected" thread on LKML (see 
http://marc.info/?l=linux-kernel&m=131805699106560).

Peter and Christoph hypothesized that 056c62418cc6 ("slab: fix lockdep 
warnings") may not have had full coverage when setting lockdep classes for 
kmem_list3 locks that may be called inside of each other because of 
off-slab metadata.

I think it's safe to say there is no deadlock possibility here or we would 
have seen it since 2006 and this is just a matter of lockdep annotation 
that needs to be done.  So don't worry too much about the warning even 
though I know it's annoying and it suppresses future lockdep output (even 
more annoying!).

I'm not sure if there's a patch to address that yet, I think one was in 
the works.  If not, I'll take a look at rewriting that lockdep annotation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
