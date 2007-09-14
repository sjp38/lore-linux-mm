Date: Thu, 13 Sep 2007 19:31:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 04 of 24] serialize oom killer
In-Reply-To: <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
References: <871b7a4fd566de081120.1187786931@v2.random>
 <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Paul Jackson <pj@sgi.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Sep 2007, David Rientjes wrote:

> serialize oom killer
> 
> Serializes the OOM killer both globally and per-cpuset, depending on the
> system configuration.
> 
> A new spinlock, oom_lock, is introduced for the global case.  It
> serializes the OOM killer for systems that are not using cpusets.  Only
> one system task may enter the OOM killer at a time to prevent
> unnecessarily killing others.

That oom_lock seems to be handled strangely. There is already a global 
cpuset with the per cpuset locks. If those locks would be available in a 
static structure in the !CPUSET case then I think that we could avoid the
oom_lock weirdness.

> > A per-cpuset flag, CS_OOM, is introduced in the flags field of struct
> cpuset.  It serializes the OOM killer for only for hardwall allocations
> targeted for that cpuset.  Only one task for each cpuset may enter the
> OOM killer at a time to prevent unnecessarily killing others.  When a
> per-cpuset OOM killing is taking place, the global spinlock is also
> locked since we'll be alleviating that condition at the same time.

Hummm... If the global lock is taken then we can only run one OOM killer 
at the time right?

> Also converts the CONSTAINT_{NONE,CPUSET,MEMORY_POLICY} defines to an
> enum and moves them to include/linux/swap.h.  We're going to need an
> include/linux/oom_kill.h soon, probably.

Sounds good.

> +/*
> + * If using cpusets, try to lock task's per-cpuset OOM lock; otherwise, try to
> + * lock the global OOM spinlock.  Returns non-zero if the lock is contended or
> + * zero if acquired.
> + */
> +int oom_test_and_set_lock(struct zonelist *zonelist, gfp_t gfp_mask,
> +			  enum oom_constraint *constraint)
> +{
> +	int ret;
> +
> +	*constraint = constrained_alloc(zonelist, gfp_mask);
> +	switch (*constraint) {
> +	case CONSTRAINT_CPUSET:
> +		ret = cpuset_oom_test_and_set_lock();
> +		if (!ret)
> +			spin_trylock(&oom_lock);

Ummm... If we cannot take the cpuset lock then we just casually try the 
oom_lock and do not care about the result?

> +		break;
> +	default:
> +		ret = spin_trylock(&oom_lock);
> +		break;
> +	}

So we take the global lock if we run out of memory in an allocation 
restriction using MPOL_BIND?

> +	return ret;
> +}
> +
> +/*
> + * If using cpusets, unlock task's per-cpuset OOM lock; otherwise, unlock the
> + * global OOM spinlock.
> + */
> +void oom_unlock(enum oom_constraint constraint)
> +{
> +	switch (constraint) {
> +	case CONSTRAINT_CPUSET:
> +		if (likely(spin_is_locked(&oom_lock)))
> +			spin_unlock(&oom_lock);

That looks a bit strange too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
