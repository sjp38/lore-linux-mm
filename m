Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DFE7F6B13F0
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 20:33:28 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 9 Feb 2012 18:33:27 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A46A81FF0049
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 18:33:24 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1A1XO0j078630
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 18:33:24 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1A1XMA8032363
	for <linux-mm@kvack.org>; Thu, 9 Feb 2012 18:33:24 -0700
Date: Thu, 9 Feb 2012 15:41:45 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120209234144.GC2458@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20120202153437.GD2518@linux.vnet.ibm.com>
 <4F2AB66C.2030309@redhat.com>
 <20120202170134.GM2518@linux.vnet.ibm.com>
 <4F2AC69B.7000704@redhat.com>
 <20120202175155.GV2518@linux.vnet.ibm.com>
 <4F2E7311.8060808@redhat.com>
 <20120205165927.GH2467@linux.vnet.ibm.com>
 <20120209152155.GA22552@somewhere.redhat.com>
 <4F33EEB3.4080807@redhat.com>
 <20120209182216.GG22552@somewhere.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120209182216.GG22552@somewhere.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Avi Kivity <avi@redhat.com>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Feb 09, 2012 at 07:22:19PM +0100, Frederic Weisbecker wrote:
> On Thu, Feb 09, 2012 at 06:05:07PM +0200, Avi Kivity wrote:
> > On 02/09/2012 05:22 PM, Frederic Weisbecker wrote:
> > > > > 
> > > > > Looks like there are new rcu_user_enter() and rcu_user_exit() APIs which
> > > > > we can use.  Hopefully they subsume rcu_virt_note_context_switch() so we
> > > > > only need one set of APIs.
> > > > 
> > > > Now that you mention it, that is a good goal.  However, it requires
> > > > coordination with Frederic's code as well, so some investigation
> > > > is required.  Bad things happen if you tell RCU you are idle when you
> > > > really are not and vice versa!
> > > > 
> > > > 							Thanx, Paul
> > > > 
> > >
> > > Right. Avi I need to know more about what you need. rcu_virt_note_context_switch()
> > > notes a quiescent state while rcu_user_enter() shuts down RCU (it's in fact the same
> > > thing than rcu_idle_enter() minus the is_idle_cpu() checks).
> > 
> > I don't know enough about RCU to say if it's okay or not (I typically
> > peek at the quick quiz answers).  However, switching to guest mode is
> > very similar to exiting to user mode: we're guaranteed not to be in an
> > rcu critical section, and to remain so until the guest exits back to
> > us.
> 
> Awesome!
> 
> > What guarantees does rcu_user_enter() provide?  With luck guest
> > entry satisifies them all.
> 
> So rcu_user_enter() puts the CPU into RCU idle mode, which means the CPU
> won't need to be part of the global RCU grace period completion. This
> prevents it to depend on the timer tick (although for now you keep it)
> and to complete some RCU specific work during the tick.
> 
> Paul, do you think that would be a win?

As long as the code doesn't enter RCU read-side critical sections in
the time between rcu_idle_enter() and rcu_idle_exit(), this should
work fine.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
