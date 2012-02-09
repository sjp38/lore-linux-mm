Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id EB4FF6B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 10:22:08 -0500 (EST)
Received: by qauh8 with SMTP id h8so1284636qau.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 07:22:08 -0800 (PST)
Date: Thu, 9 Feb 2012 16:22:01 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120209152155.GA22552@somewhere.redhat.com>
References: <alpine.DEB.2.00.1202011404500.2074@router.home>
 <20120201201336.GI2382@linux.vnet.ibm.com>
 <4F2A58A1.90800@redhat.com>
 <20120202153437.GD2518@linux.vnet.ibm.com>
 <4F2AB66C.2030309@redhat.com>
 <20120202170134.GM2518@linux.vnet.ibm.com>
 <4F2AC69B.7000704@redhat.com>
 <20120202175155.GV2518@linux.vnet.ibm.com>
 <4F2E7311.8060808@redhat.com>
 <20120205165927.GH2467@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120205165927.GH2467@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Avi Kivity <avi@redhat.com>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Sun, Feb 05, 2012 at 08:59:27AM -0800, Paul E. McKenney wrote:
> On Sun, Feb 05, 2012 at 02:16:17PM +0200, Avi Kivity wrote:
> > On 02/02/2012 07:51 PM, Paul E. McKenney wrote:
> > > On Thu, Feb 02, 2012 at 07:23:39PM +0200, Avi Kivity wrote:
> > > > On 02/02/2012 07:01 PM, Paul E. McKenney wrote:
> > > > > > 
> > > > > > It's not called (since the cpu is not idle).  Instead we call
> > > > > > rcu_virt_note_context_switch().
> > > > >
> > > > > Frederic's work checks to see if there is only one runnable user task
> > > > > on a given CPU.  If there is only one, then the scheduling-clock interrupt
> > > > > is turned off for that CPU, and RCU is told to ignore it while it is
> > > > > executing in user space.  Not sure whether this covers KVM guests.
> > > > 
> > > > Conceptually it's the same.  Maybe it needs adjustments, since kvm
> > > > enters a guest in a different way than the kernel exits to userspace.
> > > > 
> > > > > In any case, this is not yet in mainline.
> > > > 
> > > > Let me know when it's in, and I'll have a look.
> > >
> > > Could you please touch base with Frederic Weisbecker to make sure that
> > > what he is doing works for you?
> > 
> > Looks like there are new rcu_user_enter() and rcu_user_exit() APIs which
> > we can use.  Hopefully they subsume rcu_virt_note_context_switch() so we
> > only need one set of APIs.
> 
> Now that you mention it, that is a good goal.  However, it requires
> coordination with Frederic's code as well, so some investigation
> is required.  Bad things happen if you tell RCU you are idle when you
> really are not and vice versa!
> 
> 							Thanx, Paul
> 

Right. Avi I need to know more about what you need. rcu_virt_note_context_switch()
notes a quiescent state while rcu_user_enter() shuts down RCU (it's in fact the same
thing than rcu_idle_enter() minus the is_idle_cpu() checks).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
