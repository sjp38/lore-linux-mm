Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id C5EF16B004D
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 05:47:02 -0500 (EST)
Date: Fri, 6 Jan 2012 10:46:58 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH v5 7/8] mm: Only IPI CPUs to drain local pages if they
 exist
Message-ID: <20120106104658.GH27881@csn.ul.ie>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
 <1325499859-2262-8-git-send-email-gilad@benyossef.com>
 <4F033EC9.4050909@gmail.com>
 <20120105142017.GA27881@csn.ul.ie>
 <20120105144011.GU11810@n2100.arm.linux.org.uk>
 <20120105161739.GD27881@csn.ul.ie>
 <20120105163529.GA11810@n2100.arm.linux.org.uk>
 <20120105183504.GF2393@linux.vnet.ibm.com>
 <20120105222116.GF27881@csn.ul.ie>
 <4F068F53.50402@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F068F53.50402@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Greg KH <gregkh@suse.de>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Fri, Jan 06, 2012 at 11:36:11AM +0530, Srivatsa S. Bhat wrote:
> On 01/06/2012 03:51 AM, Mel Gorman wrote:
> 
> > (Adding Greg to cc to see if he recalls seeing issues with sysfs dentry
> > suffering from recursive locking recently)
> > 
> > On Thu, Jan 05, 2012 at 10:35:04AM -0800, Paul E. McKenney wrote:
> >> On Thu, Jan 05, 2012 at 04:35:29PM +0000, Russell King - ARM Linux wrote:
> >>> On Thu, Jan 05, 2012 at 04:17:39PM +0000, Mel Gorman wrote:
> >>>> Link please?
> >>>
> >>> Forwarded, as its still in my mailbox.
> >>>
> >>>> I'm including a patch below under development that is
> >>>> intended to only cope with the page allocator case under heavy memory
> >>>> pressure. Currently it does not pass testing because eventually RCU
> >>>> gets stalled with the following trace
> >>>>
> >>>> [ 1817.176001]  [<ffffffff810214d7>] arch_trigger_all_cpu_backtrace+0x87/0xa0
> >>>> [ 1817.176001]  [<ffffffff810c4779>] __rcu_pending+0x149/0x260
> >>>> [ 1817.176001]  [<ffffffff810c48ef>] rcu_check_callbacks+0x5f/0x110
> >>>> [ 1817.176001]  [<ffffffff81068d7f>] update_process_times+0x3f/0x80
> >>>> [ 1817.176001]  [<ffffffff8108c4eb>] tick_sched_timer+0x5b/0xc0
> >>>> [ 1817.176001]  [<ffffffff8107f28e>] __run_hrtimer+0xbe/0x1a0
> >>>> [ 1817.176001]  [<ffffffff8107f581>] hrtimer_interrupt+0xc1/0x1e0
> >>>> [ 1817.176001]  [<ffffffff81020ef3>] smp_apic_timer_interrupt+0x63/0xa0
> >>>> [ 1817.176001]  [<ffffffff81449073>] apic_timer_interrupt+0x13/0x20
> >>>> [ 1817.176001]  [<ffffffff8116c135>] vfsmount_lock_local_lock+0x25/0x30
> >>>> [ 1817.176001]  [<ffffffff8115c855>] path_init+0x2d5/0x370
> >>>> [ 1817.176001]  [<ffffffff8115eecd>] path_lookupat+0x2d/0x620
> >>>> [ 1817.176001]  [<ffffffff8115f4ef>] do_path_lookup+0x2f/0xd0
> >>>> [ 1817.176001]  [<ffffffff811602af>] user_path_at_empty+0x9f/0xd0
> >>>> [ 1817.176001]  [<ffffffff81154e7b>] vfs_fstatat+0x4b/0x90
> >>>> [ 1817.176001]  [<ffffffff81154f4f>] sys_newlstat+0x1f/0x50
> >>>> [ 1817.176001]  [<ffffffff81448692>] system_call_fastpath+0x16/0x1b
> >>>>
> >>>> It might be a separate bug, don't know for sure.
> >>
> > 
> > I rebased the patch on top of 3.2 and tested again with a bunch of
> > debugging options set (PROVE_RCU, PROVE_LOCKING etc). Same results. CPU
> > hotplug is a lot more reliable and less likely to hang but eventually
> > gets into trouble.
> > 
> 
> I was running some CPU hotplug stress tests recently and found it to be
> problematic too. Mel, I have some logs from those tests which appear very
> relevant to the "IPI to offline CPU" issue that has been discussed in this
> thread.
> 
> Kernel: 3.2-rc7
> Here is the log: 
> (Unfortunately I couldn't capture the log intact, due to some annoying
> serial console issues, but I hope this log is good enough to analyze.)
>   

Ok, it looks vaguely similar to what I'm seeing. I think I spotted
the sysfs problem as well and am testing a series. I'll add you to
the cc if it passes tests locally.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
