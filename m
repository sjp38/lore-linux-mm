Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 04C4F6B0036
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 16:53:46 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id dc16so2483835qab.1
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 13:53:46 -0700 (PDT)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id h50si7955895qgf.62.2014.06.19.13.53.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 13:53:46 -0700 (PDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 19 Jun 2014 14:53:44 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 693913E40062
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:53:39 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5JKqZAW51380350
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 22:52:35 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s5JKvXYo006543
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 14:57:34 -0600
Date: Thu, 19 Jun 2014 13:53:36 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: slub/debugobjects: lockup when freeing memory
Message-ID: <20140619205336.GM4904@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <53A2F406.4010109@oracle.com>
 <alpine.DEB.2.11.1406191001090.2785@gentwo.org>
 <20140619165247.GA4904@linux.vnet.ibm.com>
 <alpine.DEB.2.10.1406192127100.5170@nanos>
 <20140619202928.GG4904@linux.vnet.ibm.com>
 <53A34B23.1000401@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A34B23.1000401@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 19, 2014 at 04:42:11PM -0400, Sasha Levin wrote:
> On 06/19/2014 04:29 PM, Paul E. McKenney wrote:
> > rcu: Provide call_rcu_alloc() and call_rcu_sched_alloc() to avoid recursion
> > 
> > The sl*b allocators use call_rcu() to manage object lifetimes, but
> > call_rcu() can use debug-objects, which in turn invokes the sl*b
> > allocators.  These allocators are not prepared for this sort of
> > recursion, which can result in failures.
> > 
> > This commit therefore creates call_rcu_alloc() and call_rcu_sched_alloc(),
> > which act as their call_rcu() and call_rcu_sched() counterparts, but
> > which avoid invoking debug-objects.  These new API members are intended
> > only for use by the sl*b allocators, and this commit makes the sl*b
> > allocators use call_rcu_alloc().  Why call_rcu_sched_alloc()?  Because
> > in CONFIG_PREEMPT=n kernels, call_rcu() maps to call_rcu_sched(), so
> > therefore call_rcu_alloc() must map to call_rcu_sched_alloc().
> > 
> > Reported-by: Sasha Levin <sasha.levin@oracle.com>
> > Set-straight-by: Thomas Gleixner <tglx@linutronix.de>
> > Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> Paul, what is this patch based on? It won't apply cleanly on -next
> or Linus's tree.

On my -rcu tree, but I think that Thomas's approach is better.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
