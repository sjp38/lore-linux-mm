Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 7907D6B0070
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 19:49:50 -0400 (EDT)
Date: Thu, 5 Jul 2012 01:45:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 11/40] autonuma: define the autonuma flags
Message-ID: <20120704234557.GR25743@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-12-git-send-email-aarcange@redhat.com>
 <20120630050143.GD3975@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120630050143.GD3975@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Sat, Jun 30, 2012 at 01:01:44AM -0400, Konrad Rzeszutek Wilk wrote:
> On Thu, Jun 28, 2012 at 02:55:51PM +0200, Andrea Arcangeli wrote:
> > +extern unsigned long autonuma_flags;
> 
> I could not find the this variable in the preceding patches?
>
> Which patch actually uses it?

Well the below code also uses the above variable, but the variable is
defined in mm/autonuma.c in a later patch.

The aa.git/autonuma branch is constantly tracked by Wu C=1 checker
with the allconfig tester, every commit is built independently, so if
I add a minuscule error that breaks inter-bisectability or if I adds a
C=1 warning for the headers inclusion order I get an automated
email. Any patch reordering needs to take those things into account,
while trying to keep the size of the patches small too (I can't put
all new files in a single patch).

> Also, is there a way to force the AutoNUMA framework
> from not initializing at all? Hold that thought, it probably
> is in some of the other patches.

That is what the AUTONUMA_IMPOSSIBLE_FLAG is about, that flag is set
if you boot with "noautonuma" as parameter to the kernel. (soon that
flag will be renamed to AUTONUMA_POSSIBLE_FLAG and it'll work in the
same but opposite way)

The 12 byte per page overhead goes away, the
knuma_scand/knuma_migratedN kernel daemons are not started, the
task_autonuma/mm_autonuma are not allocated and the kernel boots as if
the hardware is not NUMA (the only loss is a pointer in the mm
struct... the pointer in the task struct is zero cost, stack overflow
permitting :).

> 
> > +
> > +static inline bool autonuma_enabled(void)
> > +{
> > +	return !!test_bit(AUTONUMA_FLAG, &autonuma_flags);
> > +}
> > +
> > +static inline bool autonuma_debug(void)
> > +{
> > +	return !!test_bit(AUTONUMA_DEBUG_FLAG, &autonuma_flags);
> > +}
> > +
> > +static inline bool autonuma_sched_load_balance_strict(void)
> > +{
> > +	return !!test_bit(AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG,
> > +			  &autonuma_flags);
> > +}
> > +
> > +static inline bool autonuma_sched_clone_reset(void)
> > +{
> > +	return !!test_bit(AUTONUMA_SCHED_CLONE_RESET_FLAG,
> > +			  &autonuma_flags);
> > +}
> > +
> > +static inline bool autonuma_sched_fork_reset(void)
> > +{
> > +	return !!test_bit(AUTONUMA_SCHED_FORK_RESET_FLAG,
> > +			  &autonuma_flags);
> > +}
> > +
> > +static inline bool autonuma_scan_pmd(void)
> > +{
> > +	return !!test_bit(AUTONUMA_SCAN_PMD_FLAG, &autonuma_flags);
> > +}
> > +
> > +static inline bool autonuma_scan_use_working_set(void)
> > +{
> > +	return !!test_bit(AUTONUMA_SCAN_USE_WORKING_SET_FLAG,
> > +			  &autonuma_flags);
> > +}
> > +
> > +static inline bool autonuma_migrate_defer(void)
> > +{
> > +	return !!test_bit(AUTONUMA_MIGRATE_DEFER_FLAG, &autonuma_flags);
> > +}
> > +
> > +#endif /* _LINUX_AUTONUMA_FLAGS_H */
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
