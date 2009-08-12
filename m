Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5D46B0062
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 10:11:13 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7CE4s4b028773
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 10:04:54 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7CEBF9Z100488
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 10:11:15 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7CEB9eJ014877
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 10:11:14 -0400
Date: Wed, 12 Aug 2009 07:11:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv2 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090812141107.GD6833@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1249992497.git.mst@redhat.com> <20090811212802.GC26309@redhat.com> <4A82076A.1060805@gmail.com> <20090812090219.GB26847@redhat.com> <4A82BD2F.7080405@gmail.com> <20090812132539.GD29200@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090812132539.GD29200@redhat.com>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Gregory Haskins <gregory.haskins@gmail.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 12, 2009 at 04:25:40PM +0300, Michael S. Tsirkin wrote:
> On Wed, Aug 12, 2009 at 09:01:35AM -0400, Gregory Haskins wrote:
> > I think I understand what your comment above meant:  You don't need to
> > do synchronize_rcu() because you can flush the workqueue instead to
> > ensure that all readers have completed.
> 
> Yes.
> 
> >  But if thats true, to me, the
> > rcu_dereference itself is gratuitous,
> 
> Here's a thesis on what rcu_dereference does (besides documentation):
> 
> reader does this
> 
> 	A: sock = n->sock
> 	B: use *sock
> 
> Say writer does this:
> 
> 	C: newsock = allocate socket
> 	D: initialize(newsock)
> 	E: n->sock = newsock
> 	F: flush
> 
> 
> On Alpha, reads could be reordered.  So, on smp, command A could get
> data from point F, and command B - from point D (uninitialized, from
> cache).  IOW, you get fresh pointer but stale data.
> So we need to stick a barrier in there.
> 
> > and that pointer is *not* actually
> > RCU protected (nor does it need to be).
> 
> Heh, if readers are lockless and writer does init/update/sync,
> this to me spells rcu.

If you are using call_rcu(), synchronize_rcu(), or one of the
similar primitives, then you absolutely need rcu_read_lock() and
rcu_read_unlock(), or one of the similar pairs of primitives.

If you -don't- use rcu_read_lock(), then you are pretty much restricted
to adding data, but never removing it.

Make sense?  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
