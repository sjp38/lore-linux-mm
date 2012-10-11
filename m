Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 059A46B005D
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 09:46:47 -0400 (EDT)
Date: Thu, 11 Oct 2012 14:46:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/33] autonuma: define the autonuma flags
Message-ID: <20121011134643.GU3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-9-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1349308275-2174-9-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Oct 04, 2012 at 01:50:50AM +0200, Andrea Arcangeli wrote:
> These flags are the ones tweaked through sysfs, they control the
> behavior of autonuma, from enabling disabling it, to selecting various
> runtime options.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/autonuma_flags.h |  120 ++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 120 insertions(+), 0 deletions(-)
>  create mode 100644 include/linux/autonuma_flags.h
> 
> diff --git a/include/linux/autonuma_flags.h b/include/linux/autonuma_flags.h
> new file mode 100644
> index 0000000..630ecc5
> --- /dev/null
> +++ b/include/linux/autonuma_flags.h
> @@ -0,0 +1,120 @@
> +#ifndef _LINUX_AUTONUMA_FLAGS_H
> +#define _LINUX_AUTONUMA_FLAGS_H
> +
> +/*
> + * If CONFIG_AUTONUMA=n only autonuma_possible() is defined (as false)
> + * to allow optimizing away at compile time blocks of common code
> + * without using #ifdefs.
> + */
> +
> +#ifdef CONFIG_AUTONUMA
> +
> +enum autonuma_flag {
> +	/*
> +	 * Set if the kernel wasn't passed the "noautonuma" boot
> +	 * parameter and the hardware is NUMA. If AutoNUMA is not
> +	 * possible the value of all other flags becomes irrelevant
> +	 * (they will never be checked) and AutoNUMA can't be enabled.
> +	 *
> +	 * No defaults: depends on hardware discovery and "noautonuma"
> +	 * early param.
> +	 */
> +	AUTONUMA_POSSIBLE_FLAG,
> +	/*
> +	 * If AutoNUMA is possible, this defines if AutoNUMA is
> +	 * currently enabled or disabled. It can be toggled at runtime
> +	 * through sysfs.
> +	 *
> +	 * The default depends on CONFIG_AUTONUMA_DEFAULT_ENABLED.
> +	 */
> +	AUTONUMA_ENABLED_FLAG,
> +	/*
> +	 * If set through sysfs this will print lots of debug info
> +	 * about the AutoNUMA activities in the kernel logs.
> +	 *
> +	 * Default not set.
> +	 */
> +	AUTONUMA_DEBUG_FLAG,
> +	/*
> +	 * This defines if CFS should prioritize between load
> +	 * balancing fairness or NUMA affinity, if there are no idle
> +	 * CPUs available. If this flag is set AutoNUMA will
> +	 * prioritize on NUMA affinity and it will disregard
> +	 * inter-node fairness.
> +	 *
> +	 * Default not set.
> +	 */
> +	AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG,

Should this be a SCHED_FEATURE flag?

> +	/*
> +	 * This flag defines if the task/mm_autonuma statistics should
> +	 * be inherited from the parent task/process or instead if
> +	 * they should be cleared at every fork/clone. The
> +	 * task/mm_autonuma statistics are always cleared across
> +	 * execve and there's no way to disable that.
> +	 *
> +	 * Default not set.
> +	 */
> +	AUTONUMA_CHILD_INHERITANCE_FLAG,

Have you ever identified a case where it's a good idea to set that flag?
A child that closely shared data with its parent is not likely to also
want to migrate to separate nodes. It just seems unnecessary to have and
impossible to suggest to an administrator how the flag might be used.

> +	/*
> +	 * If set, this tells knuma_scand to trigger NUMA hinting page
> +	 * faults at the pmd level instead of the pte level. This
> +	 * reduces the number of NUMA hinting faults potentially
> +	 * saving CPU time. It reduces the accuracy of the
> +	 * task_autonuma statistics (but does not change the accuracy
> +	 * of the mm_autonuma statistics). This flag can be toggled
> +	 * through sysfs as runtime.
> +	 *
> +	 * This flag does not affect AutoNUMA with transparent
> +	 * hugepages (THP). With THP the NUMA hinting page faults
> +	 * always happen at the pmd level, regardless of the setting
> +	 * of this flag. Note: there is no reduction in accuracy of
> +	 * task_autonuma statistics with THP.
> +	 *
> +	 * Default set.
> +	 */
> +	AUTONUMA_SCAN_PMD_FLAG,

This flag and the other flags make sense. Early on we just are not going
to know what the correct choice is. My gut says that ultimately we'll
default to PMD level *but* fall back to PTE level on a per-task basis if
ping-pong migrations are detected. This will catch ping-pongs on data
that is not PMD aligned although obviously data that is not page aligned
will also suffer. Eventually I think this flag will go away but the
behaviour will be;

default, AUTONUMA_SCAN_PMD
if ping-pong, fallback to AUTONUMA_SCAN_PTE
if ping-ping, AUTONUMA_SCAN_NONE

so there is a graceful degradation if autonuma is doing the wrong thing.

> +};
> +
> +extern unsigned long autonuma_flags;
> +
> +static inline bool autonuma_possible(void)
> +{
> +	return test_bit(AUTONUMA_POSSIBLE_FLAG, &autonuma_flags);
> +}
> +
> +static inline bool autonuma_enabled(void)
> +{
> +	return test_bit(AUTONUMA_ENABLED_FLAG, &autonuma_flags);
> +}
> +
> +static inline bool autonuma_debug(void)
> +{
> +	return test_bit(AUTONUMA_DEBUG_FLAG, &autonuma_flags);
> +}
> +
> +static inline bool autonuma_sched_load_balance_strict(void)
> +{
> +	return test_bit(AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG,
> +			&autonuma_flags);
> +}
> +
> +static inline bool autonuma_child_inheritance(void)
> +{
> +	return test_bit(AUTONUMA_CHILD_INHERITANCE_FLAG, &autonuma_flags);
> +}
> +
> +static inline bool autonuma_scan_pmd(void)
> +{
> +	return test_bit(AUTONUMA_SCAN_PMD_FLAG, &autonuma_flags);
> +}
> +
> +#else /* CONFIG_AUTONUMA */
> +
> +static inline bool autonuma_possible(void)
> +{
> +	return false;
> +}
> +
> +#endif /* CONFIG_AUTONUMA */
> +
> +#endif /* _LINUX_AUTONUMA_FLAGS_H */
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
