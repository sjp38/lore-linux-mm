Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id AAC346B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 13:35:14 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 5 Jan 2012 13:35:13 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q05IZ9r4259832
	for <linux-mm@kvack.org>; Thu, 5 Jan 2012 13:35:09 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q05IZ6pm011280
	for <linux-mm@kvack.org>; Thu, 5 Jan 2012 11:35:08 -0700
Date: Thu, 5 Jan 2012 10:35:04 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120105183504.GF2393@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
 <4F033EC9.4050909@gmail.com>
 <20120105142017.GA27881@csn.ul.ie>
 <20120105144011.GU11810@n2100.arm.linux.org.uk>
 <20120105161739.GD27881@csn.ul.ie>
 <20120105163529.GA11810@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120105163529.GA11810@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Thu, Jan 05, 2012 at 04:35:29PM +0000, Russell King - ARM Linux wrote:
> On Thu, Jan 05, 2012 at 04:17:39PM +0000, Mel Gorman wrote:
> > Link please?
> 
> Forwarded, as its still in my mailbox.
> 
> > I'm including a patch below under development that is
> > intended to only cope with the page allocator case under heavy memory
> > pressure. Currently it does not pass testing because eventually RCU
> > gets stalled with the following trace
> > 
> > [ 1817.176001]  [<ffffffff810214d7>] arch_trigger_all_cpu_backtrace+0x87/0xa0
> > [ 1817.176001]  [<ffffffff810c4779>] __rcu_pending+0x149/0x260
> > [ 1817.176001]  [<ffffffff810c48ef>] rcu_check_callbacks+0x5f/0x110
> > [ 1817.176001]  [<ffffffff81068d7f>] update_process_times+0x3f/0x80
> > [ 1817.176001]  [<ffffffff8108c4eb>] tick_sched_timer+0x5b/0xc0
> > [ 1817.176001]  [<ffffffff8107f28e>] __run_hrtimer+0xbe/0x1a0
> > [ 1817.176001]  [<ffffffff8107f581>] hrtimer_interrupt+0xc1/0x1e0
> > [ 1817.176001]  [<ffffffff81020ef3>] smp_apic_timer_interrupt+0x63/0xa0
> > [ 1817.176001]  [<ffffffff81449073>] apic_timer_interrupt+0x13/0x20
> > [ 1817.176001]  [<ffffffff8116c135>] vfsmount_lock_local_lock+0x25/0x30
> > [ 1817.176001]  [<ffffffff8115c855>] path_init+0x2d5/0x370
> > [ 1817.176001]  [<ffffffff8115eecd>] path_lookupat+0x2d/0x620
> > [ 1817.176001]  [<ffffffff8115f4ef>] do_path_lookup+0x2f/0xd0
> > [ 1817.176001]  [<ffffffff811602af>] user_path_at_empty+0x9f/0xd0
> > [ 1817.176001]  [<ffffffff81154e7b>] vfs_fstatat+0x4b/0x90
> > [ 1817.176001]  [<ffffffff81154f4f>] sys_newlstat+0x1f/0x50
> > [ 1817.176001]  [<ffffffff81448692>] system_call_fastpath+0x16/0x1b
> > 
> > It might be a separate bug, don't know for sure.

Do you get multiple RCU CPU stall-warning messages?  If so, it can
be helpful to look at how the stack frame changes over time.  These
stalls are normally caused by a loop in the kernel with preemption
disabled, though other scenarios can also cause them.

I am assuming that the CPU is reporting a stall on itself in this case.
If not, then it is necessary to look at the stack of the CPU that the
stall is being reported for.

							Thanx, Paul

> I'm not going to even pretend to understand what the above backtrace
> means: it doesn't look like what I'd expect from the problem which
> PeterZ's patch is supposed to address.  It certainly doesn't do anything
> to address the cpu-going-offline problem you seem to have found.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
