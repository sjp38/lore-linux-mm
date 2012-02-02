Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 94E696B002C
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 12:07:04 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 2 Feb 2012 12:07:01 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id ABDB66E8218
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 12:02:57 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q12H1erN033558
	for <linux-mm@kvack.org>; Thu, 2 Feb 2012 12:01:40 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q12H1au1015569
	for <linux-mm@kvack.org>; Thu, 2 Feb 2012 10:01:39 -0700
Date: Thu, 2 Feb 2012 09:01:34 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120202170134.GM2518@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
 <1327591185.2446.102.camel@twins>
 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
 <1328117722.2446.262.camel@twins>
 <20120201184045.GG2382@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1202011404500.2074@router.home>
 <20120201201336.GI2382@linux.vnet.ibm.com>
 <4F2A58A1.90800@redhat.com>
 <20120202153437.GD2518@linux.vnet.ibm.com>
 <4F2AB66C.2030309@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F2AB66C.2030309@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Feb 02, 2012 at 06:14:36PM +0200, Avi Kivity wrote:
> On 02/02/2012 05:34 PM, Paul E. McKenney wrote:
> > On Thu, Feb 02, 2012 at 11:34:25AM +0200, Avi Kivity wrote:
> > > On 02/01/2012 10:13 PM, Paul E. McKenney wrote:
> > > > > 
> > > > > Could we also apply the same approach to processors busy doing
> > > > > computational work? In that case the OS is also not needed. Interrupting
> > > > > these activities is impacting on performance and latency.
> > > >
> > > > Yep, that is in fact what Frederic's dyntick-idle userspace work does.
> > > 
> > > Running in a guest is a special case of running in userspace, so we'd
> > > need to extend this work to kvm as well.
> >
> > As long as rcu_idle_enter() is called at the appropriate time, RCU will
> > happily ignore the CPU.  ;-)
> >
> 
> It's not called (since the cpu is not idle).  Instead we call
> rcu_virt_note_context_switch().

Frederic's work checks to see if there is only one runnable user task
on a given CPU.  If there is only one, then the scheduling-clock interrupt
is turned off for that CPU, and RCU is told to ignore it while it is
executing in user space.  Not sure whether this covers KVM guests.

In any case, this is not yet in mainline.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
