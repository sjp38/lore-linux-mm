Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B87136B0038
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 14:13:20 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so8708192pad.24
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 11:13:20 -0800 (PST)
Received: from psmtp.com ([74.125.245.183])
        by mx.google.com with SMTP id cl4si8673819pad.24.2013.11.19.11.13.18
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 11:13:19 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Nov 2013 12:13:17 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 5AA2E3E40055
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:13:15 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAJHBGrs60751992
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 18:11:16 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rAJJG5fO008925
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:16:08 -0700
Date: Tue, 19 Nov 2013 11:13:10 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 2/4] MCS Lock: optimizations and extra comments
Message-ID: <20131119191310.GO4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1383935697.git.tim.c.chen@linux.intel.com>
 <1383940325.11046.415.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383940325.11046.415.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Nov 08, 2013 at 11:52:05AM -0800, Tim Chen wrote:
> From: Jason Low <jason.low2@hp.com>
> 
> Remove unnecessary operation and make the cmpxchg(lock, node, NULL) == node
> check in mcs_spin_unlock() likely() as it is likely that a race did not occur
> most of the time.
> 
> Also add in more comments describing how the local node is used in MCS locks.
> 
> Reviewed-by: Tim Chen <tim.c.chen@linux.intel.com>
> Signed-off-by: Jason Low <jason.low2@hp.com>
> ---
>  include/linux/mcs_spinlock.h |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> index b5de3b0..96f14299 100644
> --- a/include/linux/mcs_spinlock.h
> +++ b/include/linux/mcs_spinlock.h
> @@ -18,6 +18,12 @@ struct mcs_spinlock {
>  };
> 
>  /*
> + * In order to acquire the lock, the caller should declare a local node and
> + * pass a reference of the node to this function in addition to the lock.
> + * If the lock has already been acquired, then this will proceed to spin
> + * on this node->locked until the previous lock holder sets the node->locked
> + * in mcs_spin_unlock().
> + *
>   * We don't inline mcs_spin_lock() so that perf can correctly account for the
>   * time spent in this lock function.
>   */
> @@ -33,7 +39,6 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  	prev = xchg(lock, node);
>  	if (likely(prev == NULL)) {
>  		/* Lock acquired */
> -		node->locked = 1;

Agreed, no one looks at this field in this case, so no need to initialize
it, unless for debug purposes.

>  		return;
>  	}
>  	ACCESS_ONCE(prev->next) = node;
> @@ -43,6 +48,10 @@ void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  		arch_mutex_cpu_relax();
>  }
> 
> +/*
> + * Releases the lock. The caller should pass in the corresponding node that
> + * was used to acquire the lock.
> + */
>  static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  {
>  	struct mcs_spinlock *next = ACCESS_ONCE(node->next);
> @@ -51,7 +60,7 @@ static void mcs_spin_unlock(struct mcs_spinlock **lock, struct mcs_spinlock *nod
>  		/*
>  		 * Release the lock by setting it to NULL
>  		 */
> -		if (cmpxchg(lock, node, NULL) == node)
> +		if (likely(cmpxchg(lock, node, NULL) == node))

Agreed here as well.  Takes a narrow race to hit this.

So, did your testing exercise this path?  If the answer is "yes", and
if the issues that I called out in patch #1 are resolved:

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

>  			return;
>  		/* Wait until the next pointer is set */
>  		while (!(next = ACCESS_ONCE(node->next)))
> -- 
> 1.7.4.4
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
