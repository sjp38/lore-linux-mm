Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id BE18A6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 16:17:40 -0400 (EDT)
Date: Thu, 11 Oct 2012 21:17:36 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/33] autonuma: define the autonuma flags
Message-ID: <20121011201736.GP3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-9-git-send-email-aarcange@redhat.com>
 <20121011134643.GU3317@csn.ul.ie>
 <20121011173442.GS1818@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121011173442.GS1818@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Oct 11, 2012 at 07:34:42PM +0200, Andrea Arcangeli wrote:
> On Thu, Oct 11, 2012 at 02:46:43PM +0100, Mel Gorman wrote:
> > Should this be a SCHED_FEATURE flag?
> 
> I guess it could. It is only used by kernel/sched/numa.c which isn't
> even built unless CONFIG_AUTONUMA is set. So it would require a
> CONFIG_AUTONUMA in the sched feature flags unless we want to expose
> no-operational bits. I'm not sure what the preferred way is.
> 

It's fine this way for now. It just felt that it was bolted onto the
side a bit and didn't quite belong there but it could be argued either
way so just leave it alone.

> > Have you ever identified a case where it's a good idea to set that flag?
> 
> It's currently set by default but no, I didn't do enough experiments
> if it's worth copying or resetting the data.
> 

Ok, if it was something that was going to be regularly used there would
be more justification for SCHED_FEATURE.

> > A child that closely shared data with its parent is not likely to also
> > want to migrate to separate nodes. It just seems unnecessary to have and
> 
> Agreed, this is why the task_selected_nid is always inherited by
> default (that is the CFS autopilot driver).
> 
> The question is if the full statistics also should be inherited across
> fork/clone or not. I don't know the answer yet and that's why that
> knob exists.
> 

I very strongly suspect the answer is "no".

> If we retain them, the autonuma_balance may decide to move the
> task before a full statistics buildup executed the child.
> 
> The current way is to reset the data, and wait the data to buildup in
> the child, while we keep CFS on autopilot with task_selected_nid
> (which is always inherited). I thought the current one to be a good
> tradeoff, but copying all data isn't an horrible idea either.
> 
> > impossible to suggest to an administrator how the flag might be used.
> 
> Agreed. this in fact is a debug flag only, it won't ever showup to the admin.
> 
> #ifdef CONFIG_DEBUG_VM
> SYSFS_ENTRY(sched_load_balance_strict, AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG);
> SYSFS_ENTRY(child_inheritance, AUTONUMA_CHILD_INHERITANCE_FLAG);
> SYSFS_ENTRY(migrate_allow_first_fault,
> 	    AUTONUMA_MIGRATE_ALLOW_FIRST_FAULT_FLAG);
> #endif /* CONFIG_DEBUG_VM */
> 

Good. Nice to have just in case even if I think it'll never be used :)

> > 
> > > +	/*
> > > +	 * If set, this tells knuma_scand to trigger NUMA hinting page
> > > +	 * faults at the pmd level instead of the pte level. This
> > > +	 * reduces the number of NUMA hinting faults potentially
> > > +	 * saving CPU time. It reduces the accuracy of the
> > > +	 * task_autonuma statistics (but does not change the accuracy
> > > +	 * of the mm_autonuma statistics). This flag can be toggled
> > > +	 * through sysfs as runtime.
> > > +	 *
> > > +	 * This flag does not affect AutoNUMA with transparent
> > > +	 * hugepages (THP). With THP the NUMA hinting page faults
> > > +	 * always happen at the pmd level, regardless of the setting
> > > +	 * of this flag. Note: there is no reduction in accuracy of
> > > +	 * task_autonuma statistics with THP.
> > > +	 *
> > > +	 * Default set.
> > > +	 */
> > > +	AUTONUMA_SCAN_PMD_FLAG,
> > 
> > This flag and the other flags make sense. Early on we just are not going
> > to know what the correct choice is. My gut says that ultimately we'll
> 
> Agreed. This is why I left these knobs in, even if I've been asked to
> drop them a few times (they were perceived as adding complexity). But
> for things we're not sure about, these really helps to benchmark quick
> one way or another.
> 

I don't mind them being left in for now. They at least forced me to
consider the cases where they might be required and consider if that is
realistic or not. From that perspective alone it was worth it :)

> scan_pmd is actually not under DEBUG_VM as it looked a more fundamental thing.
> 
> > default to PMD level *but* fall back to PTE level on a per-task basis if
> > ping-pong migrations are detected. This will catch ping-pongs on data
> > that is not PMD aligned although obviously data that is not page aligned
> > will also suffer. Eventually I think this flag will go away but the
> > behaviour will be;
> > 
> > default, AUTONUMA_SCAN_PMD
> > if ping-pong, fallback to AUTONUMA_SCAN_PTE
> > if ping-ping, AUTONUMA_SCAN_NONE
> 
> That would be ideal, good idea indeed.
> 
> > so there is a graceful degradation if autonuma is doing the wrong thing.
> 
> Makes perfect sense to me if we figure out how to reliably detect when
> to make the switch.
> 

The "reliable" part is the mess. I think it potentially would be possible
to detect it based on the number of times numa_hinting_fault() migrated
pages and decay that at each knuma_scan but that could take too long
to detect with the 10 second delays so there is no obvious good answer.
WIth some experience on a few different workloads, it might be a bit
more obvious. Right now what you have is good enough and we can just
keep the potential problem in mind so we'll recognise it when we see it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
