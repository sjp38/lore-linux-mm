Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 9422B6B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 11:20:03 -0400 (EDT)
Date: Wed, 26 Jun 2013 14:53:38 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 5/5] rwsem: do optimistic spinning for writer lock
 acquisition
Message-ID: <20130626125338.GK28407@twins.programming.kicks-ass.net>
References: <cover.1372112541.git.tim.c.chen@linux.intel.com>
 <1372116051.22432.95.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1372116051.22432.95.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Mon, Jun 24, 2013 at 04:20:51PM -0700, Tim Chen wrote:
> +#ifdef CONFIG_RWSEM_SPIN_ON_WRITE_OWNER
> +static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
> +{
> +	int retval;
> +	task_struct *owner;
> +
> +	rcu_read_lock();
> +	owner = sem->owner;

That wants to be: owner = ACCESS_ONCE(sem->owner);

> +
> +	/* Spin only if active writer running */
> +	if (owner)
> +		retval = owner->on_cpu;
> +	else
> +		retval = false;
> +
> +	rcu_read_unlock();
> +	/*
> +	 * if lock->owner is not set, the sem owner may have just acquired
> +	 * it and not set the owner yet, or the sem has been released, or
> +	 * reader active.
> +	 */
> +	return retval;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
