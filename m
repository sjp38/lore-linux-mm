Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 227A86B00EE
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 14:07:47 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p5TI7fXR025029
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 23:37:41 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5TI7eV73059754
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 23:37:40 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5TI7daU021828
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 04:07:39 +1000
Date: Wed, 29 Jun 2011 23:37:33 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110629180733.GF3646@dirshya.in.ibm.com>
Reply-To: svaidy@linux.vnet.ibm.com
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110629130038.GA7909@in.ibm.com>
 <1309367184.11430.594.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1309367184.11430.594.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, thomas.abraham@linaro.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>

* Dave Hansen <dave@linux.vnet.ibm.com> [2011-06-29 10:06:24]:

> I was kinda hoping for something a bit simpler than that.  I'd boil down
> what you were saying to this:
> 
>      1. The kernel must be aware of how the pieces of hardware are
>         mapped in to the system's physical address space
>      2. The kernel must have a mechanism in place to minimize access to
>         specific pieces of hardware 
          (mainly by controlling allocations and reclaim)
                

>      3. For destructive power-down operations, the kernel should have a
>         mechanism in place to ensure that no valuable data is contained
>         in the memory to be powered down.
> 
> Is that complete?

At a high level these are the main requirements, except that different
operations/features can happen at different/higher granularity.  The
infrastructure should be able to related groups of regions and act
upon for a specific optimization.  Like granularity for (2) may be
512MB, while (3) could be a pair of 512MB blocks. This is relatively
a minor issue to solve.

> On Wed, 2011-06-29 at 18:30 +0530, Ankita Garg wrote:
> > 1) Dynamic Power Transition: The memory controller can have the ability
> > to automatically transition regions of memory into lower power states
> > when they are devoid of references for a pre-defined threshold amount of
> > time. Memory contents are preserved in the low power states and accessing
> > memory that is at a low power state takes a latency hit.
> > 
> > 2) Dynamic Power Off: If a region is free/unallocated, the software can
> > indicate to the controller to completely turn off power to a certain
> > region. Memory contents are lost and hence the software has to be
> > absolutely sure about the usage statistics of the particular region. This
> > is a runtime capability, where the required amount of memory can be
> > powered 'ON' to match the workload demands.
> > 
> > 3) Partial Array Self-Refresh (PASR): If a certain regions of memory is
> > free/unallocated, the software can indicate to the controller to not
> > refresh that region when the system goes to suspend-to-ram state and
> > thereby save standby power consumption.
> 
> (3) is simply a subset of (2), but with the additional restriction that
> the power off can only occur during a suspend operation.  
> 
> Let's say we fully implemented support for (2).  What would be missing
> to support PASR?

The similarity between (2) and (3) here is the need for accurate
statistics to know allocation status. The difference is the
actuation/trigger part... in case of (2) the trigger would happen
during allocation/free while in case of (3) it happens only at suspend
time.  Also the granularity could be different, generally PASR is very
fine grain as compared for power-off at controller level.

We can combine them and look at just how to track allocations at
different (or multiple) physical boundaries.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
