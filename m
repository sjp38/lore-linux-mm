Subject: Re: [PATCH 23/33] netvm: skb processing
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20071030142634.0f00b492@freepuppy.rosehill>
References: <20071030160401.296770000@chello.nl>
	 <20071030160914.749995000@chello.nl>
	 <20071030142634.0f00b492@freepuppy.rosehill>
Content-Type: text/plain
Date: Tue, 30 Oct 2007 22:44:34 +0100
Message-Id: <1193780674.27652.103.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-30 at 14:26 -0700, Stephen Hemminger wrote:
> On Tue, 30 Oct 2007 17:04:24 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > In order to make sure emergency packets receive all memory needed to proceed
> > ensure processing of emergency SKBs happens under PF_MEMALLOC.
> > 
> > Use the (new) sk_backlog_rcv() wrapper to ensure this for backlog processing.
> > 
> > Skip taps, since those are user-space again.
> > 
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> >  include/net/sock.h |    5 +++++
> >  net/core/dev.c     |   44 ++++++++++++++++++++++++++++++++++++++------
> >  net/core/sock.c    |   18 ++++++++++++++++++
> >  3 files changed, 61 insertions(+), 6 deletions(-)
> > 
> > Index: linux-2.6/net/core/dev.c
> > ===================================================================
> > --- linux-2.6.orig/net/core/dev.c
> > +++ linux-2.6/net/core/dev.c
> > @@ -1976,10 +1976,23 @@ int netif_receive_skb(struct sk_buff *sk
> >  	struct net_device *orig_dev;
> >  	int ret = NET_RX_DROP;
> >  	__be16 type;
> > +	unsigned long pflags = current->flags;
> > +
> > +	/* Emergency skb are special, they should
> > +	 *  - be delivered to SOCK_MEMALLOC sockets only
> > +	 *  - stay away from userspace
> > +	 *  - have bounded memory usage
> > +	 *
> > +	 * Use PF_MEMALLOC as a poor mans memory pool - the grouping kind.
> > +	 * This saves us from propagating the allocation context down to all
> > +	 * allocation sites.
> > +	 */
> > +	if (skb_emergency(skb))
> > +		current->flags |= PF_MEMALLOC;
> >  
> >  	/* if we've gotten here through NAPI, check netpoll */
> >  	if (netpoll_receive_skb(skb))
> > -		return NET_RX_DROP;
> > +		goto out;
> 
> Why the change? doesn't gcc optimize the common exit case anyway?

It needs to unset PF_MEMALLOC at the exit.

> > @@ -2029,19 +2046,31 @@ int netif_receive_skb(struct sk_buff *sk
> >  
> >  	if (ret == TC_ACT_SHOT || (ret == TC_ACT_STOLEN)) {
> >  		kfree_skb(skb);
> > -		goto out;
> > +		goto unlock;
> >  	}
> >  
> >  	skb->tc_verd = 0;
> >  ncls:
> >  #endif
> >  
> > +	if (skb_emergency(skb))
> > +		switch(skb->protocol) {
> > +			case __constant_htons(ETH_P_ARP):
> > +			case __constant_htons(ETH_P_IP):
> > +			case __constant_htons(ETH_P_IPV6):
> > +			case __constant_htons(ETH_P_8021Q):
> > +				break;
> 
> Indentation is wrong, and hard coding protocol values as spcial case
> seems bad here. What about vlan's, etc?

The other protocols needs analysis on what memory allocations occur
during packet processing, if anything is done that is not yet accounted
for (skb, route cache) then that needs to be added to a reserve, if
there are any paths that could touch user-space, those need to be
handled.

I've started looking at a few others, but its hard and difficult work if
one is not familiar with the protocols.


> > @@ -2063,8 +2093,10 @@ ncls:
> >  		ret = NET_RX_DROP;
> >  	}
> >  
> > -out:
> > +unlock:
> >  	rcu_read_unlock();
> > +out:
> > +	tsk_restore_flags(current, pflags, PF_MEMALLOC);
> >  	return ret;
> >  }

Its that tsk_restore_flags() there what requires the s/return/goto/
stuff you noted earlier.

> I am still not convinced that this solves the problem well enough
> to be useful.  Can you really survive a heavy memory overcommit?

On a machine with mem=128M, I've ran 4 processes of 64M, 2 file backed
with the files on NFS, 2 anonymous. The processes just cycle through the
memory using writes. This is a 100% overcommit.

During these tests I've ran various network loads.

I've shut down the NFS server, waited for say 15 minutes, and restarted
the NFS server, and the machine came back up and continued.

> In other words, can you prove that the added complexity causes the system
> to survive a real test where otherwise it would not?

I've put some statistics in the skb reserve allocations, those are most
definately used. I'm quite certain the machine would lock up solid
without it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
