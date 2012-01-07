Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A520A6B005A
	for <linux-mm@kvack.org>; Sat,  7 Jan 2012 11:52:08 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 7 Jan 2012 09:52:07 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q07Gq4mH120060
	for <linux-mm@kvack.org>; Sat, 7 Jan 2012 09:52:04 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q07Gq31m019139
	for <linux-mm@kvack.org>; Sat, 7 Jan 2012 09:52:04 -0700
Date: Sat, 7 Jan 2012 08:52:01 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120107165201.GA23939@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
 <4F033EC9.4050909@gmail.com>
 <20120105142017.GA27881@csn.ul.ie>
 <20120105144011.GU11810@n2100.arm.linux.org.uk>
 <20120105161739.GD27881@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120105161739.GD27881@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Thu, Jan 05, 2012 at 04:17:39PM +0000, Mel Gorman wrote:
> On Thu, Jan 05, 2012 at 02:40:11PM +0000, Russell King - ARM Linux wrote:
> > On Thu, Jan 05, 2012 at 02:20:17PM +0000, Mel Gorman wrote:

[ . . . ]

> > I've been chasing that patch and getting no replies what so
> > ever from folk like Peter, Thomas and Ingo.
> > 
> > The problem affects all IPI-raising functions, which mask with
> > cpu_online_mask directly.
> 
> Actually, in one sense I'm glad to hear it because from my brief
> poking around, I was having trouble understanding why we were always
> safe from sending IPIs to CPUs in the process of being offlined.

The trick is to disable preemption (not interrupts!) across the IPI, which
prevents CPU-hotplug's stop_machine() from running.  You also have to
have checked that the CPU is online within this same preemption-disabled
section of code.  This means that the outgoing CPU has to accept IPIs
even after its CPU_DOWN_PREPARE notifier has been called -- right up
to the stop_machine() call to take_cpu_down().

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
