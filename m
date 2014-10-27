Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4852D900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 19:48:17 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id s7so4594871qap.19
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:48:17 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id o1si23178936qat.26.2014.10.27.16.48.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 16:48:16 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 27 Oct 2014 17:48:15 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 682BAC9003C
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 19:36:55 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9RNiQZ652887728
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 00:44:26 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s9RNnB5S016124
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 17:49:11 -0600
Date: Mon, 27 Oct 2014 16:44:25 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: rcu_preempt detected stalls.
Message-ID: <20141027234425.GA19438@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20141013173504.GA27955@redhat.com>
 <543DDD5E.9080602@oracle.com>
 <20141023183917.GX4977@linux.vnet.ibm.com>
 <54494F2F.6020005@oracle.com>
 <20141023195808.GB4977@linux.vnet.ibm.com>
 <544A45F8.2030207@oracle.com>
 <20141024161337.GQ4977@linux.vnet.ibm.com>
 <544A80B3.9070800@oracle.com>
 <20141027211329.GJ5718@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141027211329.GJ5718@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, htejun@gmail.com, linux-mm@kvack.org

On Mon, Oct 27, 2014 at 02:13:29PM -0700, Paul E. McKenney wrote:
> On Fri, Oct 24, 2014 at 12:39:15PM -0400, Sasha Levin wrote:
> > On 10/24/2014 12:13 PM, Paul E. McKenney wrote:
> > > On Fri, Oct 24, 2014 at 08:28:40AM -0400, Sasha Levin wrote:
> > >> > On 10/23/2014 03:58 PM, Paul E. McKenney wrote:
> > >>> > > On Thu, Oct 23, 2014 at 02:55:43PM -0400, Sasha Levin wrote:
> > >>>>> > >> > On 10/23/2014 02:39 PM, Paul E. McKenney wrote:
> > >>>>>>> > >>> > > On Tue, Oct 14, 2014 at 10:35:10PM -0400, Sasha Levin wrote:
> > >>>>>>>>> > >>>> > >> On 10/13/2014 01:35 PM, Dave Jones wrote:
> > >>>>>>>>>>> > >>>>> > >>> oday in "rcu stall while fuzzing" news:
> > >>>>>>>>>>> > >>>>> > >>>
> > >>>>>>>>>>> > >>>>> > >>> INFO: rcu_preempt detected stalls on CPUs/tasks:
> > >>>>>>>>>>> > >>>>> > >>> 	Tasks blocked on level-0 rcu_node (CPUs 0-3): P766 P646
> > >>>>>>>>>>> > >>>>> > >>> 	Tasks blocked on level-0 rcu_node (CPUs 0-3): P766 P646
> > >>>>>>>>>>> > >>>>> > >>> 	(detected by 0, t=6502 jiffies, g=75434, c=75433, q=0)
> > >>>>>>>>> > >>>> > >>
> > >>>>>>>>> > >>>> > >> I've complained about RCU stalls couple days ago (in a different context)
> > >>>>>>>>> > >>>> > >> on -next. I guess whatever causing them made it into Linus's tree?
> > >>>>>>>>> > >>>> > >>
> > >>>>>>>>> > >>>> > >> https://lkml.org/lkml/2014/10/11/64
> > >>>>>>> > >>> > > 
> > >>>>>>> > >>> > > And on that one, I must confess that I don't see where the RCU read-side
> > >>>>>>> > >>> > > critical section might be.
> > >>>>>>> > >>> > > 
> > >>>>>>> > >>> > > Hmmm...  Maybe someone forgot to put an rcu_read_unlock() somewhere.
> > >>>>>>> > >>> > > Can you reproduce this with CONFIG_PROVE_RCU=y?
> > >>>>> > >> > 
> > >>>>> > >> > Paul, if that was directed to me - Yes, I see stalls with CONFIG_PROVE_RCU
> > >>>>> > >> > set and nothing else is showing up before/after that.
> > >>> > > Indeed it was directed to you.  ;-)
> > >>> > > 
> > >>> > > Does the following crude diagnostic patch turn up anything?
> > >> > 
> > >> > Nope, seeing stalls but not seeing that pr_err() you added.
> > > OK, color me confused.  Could you please send me the full dmesg or a
> > > pointer to it?
> > 
> > Attached.
> 
> Thank you!  I would complain about the FAULT_INJECTION messages, but
> they don't appear to be happening all that frequently.
> 
> The stack dumps do look different here.  I suspect that this is a real
> issue in the VM code.

And to that end...  The filemap_map_pages() function does have loop over
a list of pages.  I wonder if the rcu_read_lock() should be moved into
the radix_tree_for_each_slot() loop.  CCing linux-mm for their thoughts,
though it looks to me like the current radix_tree_for_each_slot() wants
to be under RCU protection.  But I am not seeing anything that requires
all iterations of the loop to be under the same RCU read-side critical
section.  Maybe something like the following patch?

							Thanx, Paul

------------------------------------------------------------------------

mm: Attempted fix for RCU CPU stall warning

It appears that filemap_map_pages() can stay in a single RCU read-side
critical section for a very long time if given a large area to map.
This could result in RCU CPU stall warnings.  This commit therefore breaks
the read-side critical section into per-iteration critical sections, taking
care to make sure that the radix_tree_for_each_slot() call itself remains
in an RCU read-side critical section, as required.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/mm/filemap.c b/mm/filemap.c
index 14b4642279f1..f78f144fb41f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2055,6 +2055,8 @@ skip:
 next:
 		if (iter.index == vmf->max_pgoff)
 			break;
+		rcu_read_unlock();
+		rcu_read_lock();
 	}
 	rcu_read_unlock();
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
