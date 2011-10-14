Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id AFF3B6B019A
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 02:31:33 -0400 (EDT)
From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: possible slab deadlock while doing ifenslave
Date: Fri, 14 Oct 2011 08:30:47 +0200
References: <201110121019.53100.hans@schillstrom.com> <201110131019.58397.hans@schillstrom.com> <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110131557090.10968@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201110140830.48368.hans@schillstrom.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@gentwo.org>, Ingo Molnar <mingo@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org


On Friday, October 14, 2011 01:03:40 David Rientjes wrote:
> On Thu, 13 Oct 2011, Hans Schillstrom wrote:
> 
> > > > Hello,
> > > > I got this when I was testing a VLAN patch i.e. using Dave Millers net-next from today.
> > > > When doing this on a single core i686 I got the warning every time,
> > > > however ifenslave is not hanging it's just a warning
> > > > Have not been testing this on a multicore jet.
> > > > 
> > > > There is no warnings with a 3.0.4 kernel.
> > > > 
> > > > Is this a known warning ?
> > > > 
> > > > ~ # ifenslave bond0 eth1 eth2
> > > > 
> > > > =============================================
> > > > [ INFO: possible recursive locking detected ]
> > > > 3.1.0-rc9+ #3
> > > > ---------------------------------------------
> > > > ifenslave/749 is trying to acquire lock:
> > > >  (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb
> > > > 
> > > > but task is already holding lock:
> > > >  (&(&parent->list_lock)->rlock){-.-...}, at: [<c14234a0>] cache_flusharray+0x41/0xdb
> > > > 
> > > 
> > > Hmm, the only candidate that I can see that may have caused this is 
> > > 83835b3d9aec ("slab, lockdep: Annotate slab -> rcu -> debug_object -> 
> > > slab").  Could you try reverting that patch in your local tree and seeing 
> > > if it helps?
> > > 
> > 
> > That was not our candidate ...
> > i.e. same results
> > 
> 
> Ok, I think this may be related to what Sitsofe reported in the "lockdep 
> recursive locking detected" thread on LKML (see 
> http://marc.info/?l=linux-kernel&m=131805699106560).
> 
> Peter and Christoph hypothesized that 056c62418cc6 ("slab: fix lockdep 
> warnings") may not have had full coverage when setting lockdep classes for 
> kmem_list3 locks that may be called inside of each other because of 
> off-slab metadata.
> 
> I think it's safe to say there is no deadlock possibility here or we would 
> have seen it since 2006 and this is just a matter of lockdep annotation 
> that needs to be done.  So don't worry too much about the warning even 
> though I know it's annoying and it suppresses future lockdep output (even 
> more annoying!).

I have not seen any deadlock, and so far I've got hundreds of this warnings.

> 
> I'm not sure if there's a patch to address that yet, I think one was in 
> the works.  If not, I'll take a look at rewriting that lockdep annotation.
> 

If you want me to do some more testing, I keep the setup for a couple of month.

Thanks
Hans

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
