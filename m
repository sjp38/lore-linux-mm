Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6326B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 01:58:36 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5U5tA4Y025216
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 01:55:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5U60M35218940
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 02:00:24 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5U60M4R021790
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 02:00:22 -0400
Date: Mon, 29 Jun 2009 23:00:31 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem
	in sl[aou]b
Message-ID: <20090630060031.GL7070@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20090625193137.GA16861@linux.vnet.ibm.com> <alpine.DEB.1.10.0906291827050.21956@gentwo.org> <1246315553.21295.100.camel@calx> <alpine.DEB.1.10.0906291910130.32637@gentwo.org> <1246320394.21295.105.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1246320394.21295.105.camel@calx>
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

On Mon, Jun 29, 2009 at 07:06:34PM -0500, Matt Mackall wrote:
> On Mon, 2009-06-29 at 19:19 -0400, Christoph Lameter wrote:
> > On Mon, 29 Jun 2009, Matt Mackall wrote:
> > 
> > > This is a reasonable point, and in keeping with the design principle
> > > 'callers should handle their own special cases'. However, I think it
> > > would be more than a little surprising for kmem_cache_free() to do the
> > > right thing, but not kmem_cache_destroy().
> > 
> > kmem_cache_free() must be used carefully when using SLAB_DESTROY_BY_RCU.
> > The freed object can be accessed after free until the rcu interval
> > expires (well sortof, it may even be reallocated within the interval).
> > 
> > There are special RCU considerations coming already with the use of
> > kmem_cache_free().
> > 
> > Adding RCU operations to the kmem_cache_destroy() logic may result in
> > unnecessary RCU actions for slabs where the coder is ensuring that the
> > RCU interval has passed by other means.
> 
> Do we care? Cache destruction shouldn't be in anyone's fast path.
> Correctness is more important and users are more liable to be correct
> with this patch.

I am with Matt on this one -- if we are going to hand the users of
SLAB_DESTROY_BY_RCU a hand grenade, let's at least leave the pin in.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
