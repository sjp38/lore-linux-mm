Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F02BB6B00AC
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 17:06:32 -0500 (EST)
Date: Wed, 17 Dec 2008 14:07:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] CGroups: Add css_tryget()
Message-Id: <20081217140741.0085e6a0.akpm@linux-foundation.org>
In-Reply-To: <20081216113653.252690000@menage.corp.google.com>
References: <20081216113055.713856000@menage.corp.google.com>
	<20081216113653.252690000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: menage@google.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Dec 2008 03:30:58 -0800
menage@google.com wrote:

> This patch adds css_tryget(), that obtains a counted reference on a
> CSS.  It is used in situations where the caller has a "weak" reference
> to the CSS, i.e. one that does not protect the cgroup from removal via
> a reference count, but would instead be cleaned up by a destroy()
> callback.
> 
> css_tryget() will return true on success, or false if the cgroup is
> being removed.
> 
> This is similar to Kamezawa Hiroyuki's patch from a week or two ago,
> but with the difference that in the event of css_tryget() racing with
> a cgroup_rmdir(), css_tryget() will only return false if the cgroup
> really does get removed.
> 
> This implementation is done by biasing css->refcnt, so that a refcnt
> of 1 means "releasable" and 0 means "released or releasing". In the
> event of a race, css_tryget() distinguishes between "released" and
> "releasing" by checking for the CSS_REMOVED flag in css->flags.
> 
> ...
>
> --- hierarchy_lock-mmotm-2008-12-09.orig/include/linux/cgroup.h
> +++ hierarchy_lock-mmotm-2008-12-09/include/linux/cgroup.h
> @@ -52,9 +52,9 @@ struct cgroup_subsys_state {
>  	 * hierarchy structure */
>  	struct cgroup *cgroup;
>  
> -	/* State maintained by the cgroup system to allow
> -	 * subsystems to be "busy". Should be accessed via css_get()
> -	 * and css_put() */
> +	/* State maintained by the cgroup system to allow subsystems
> +	 * to be "busy". Should be accessed via css_get(),
> +	 * css_tryget() and and css_put(). */

nanonit.  This layout:

	/*
	 * State maintained by the cgroup system to allow subsystems
	 * to be "busy". Should be accessed via css_get(),
	 * css_tryget() and and css_put().
	 */

is conventional/preferred.

>  	atomic_t refcnt;
>  
> @@ -64,11 +64,14 @@ struct cgroup_subsys_state {
>  /* bits in struct cgroup_subsys_state flags field */
>  enum {
>  	CSS_ROOT, /* This CSS is the root of the subsystem */
> +	CSS_REMOVED, /* This CSS is dead */
>  };
>  
>  /*
> - * Call css_get() to hold a reference on the cgroup;
> - *
> + * Call css_get() to hold a reference on the css; it can be used
> + * for a reference obtained via:
> + * - an existing ref-counted reference to the css
> + * - task->cgroups for a locked task
>   */
>  
>  static inline void css_get(struct cgroup_subsys_state *css)
> @@ -77,9 +80,32 @@ static inline void css_get(struct cgroup
>  	if (!test_bit(CSS_ROOT, &css->flags))
>  		atomic_inc(&css->refcnt);
>  }
> +
> +static inline bool css_is_removed(struct cgroup_subsys_state *css)
> +{
> +	return test_bit(CSS_REMOVED, &css->flags);
> +}
> +
> +/*
> + * Call css_tryget() to take a reference on a css if your existing
> + * (known-valid) reference isn't already ref-counted. Returns false if
> + * the css has been destroyed.
> + */
> +
> +static inline bool css_tryget(struct cgroup_subsys_state *css)
> +{
> +	if (test_bit(CSS_ROOT, &css->flags))
> +		return true;
> +	while (!atomic_inc_not_zero(&css->refcnt)) {
> +		if (test_bit(CSS_REMOVED, &css->flags))
> +			return false;
> +	}
> +	return true;
> +}

This looks too large to inline.

We should have a cpu_relax() in the loop?

And possibly a cond_resched().

It would be better if these polling loops didn't exist at all, of
course.  But I guess if you could work out a way of doing that, this
patch wouldn't exist.

>
>  ...
>
> +/*
> + * Atomically mark all (or else none) of the cgroup's CSS objects as
> + * CSS_REMOVED. Return true on success, or false if the cgroup has
> + * busy subsystems. Call with cgroup_mutex held
> + */
> +
> +static int cgroup_clear_css_refs(struct cgroup *cgrp)
> +{
> +	struct cgroup_subsys *ss;
> +	unsigned long flags;
> +	bool failed = false;
> +	local_irq_save(flags);

please put a blank line between end-of-locals and start-of-code.

> +	for_each_subsys(cgrp->root, ss) {
> +		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
> +		int refcnt;
> +		do {
> +			/* We can only remove a CSS with a refcnt==1 */
> +			refcnt = atomic_read(&css->refcnt);
> +			if (refcnt > 1) {
> +				failed = true;
> +				goto done;
> +			}
> +			BUG_ON(!refcnt);
> +			/*
> +			 * Drop the refcnt to 0 while we check other
> +			 * subsystems. This will cause any racing
> +			 * css_tryget() to spin until we set the
> +			 * CSS_REMOVED bits or abort
> +			 */
> +		} while (atomic_cmpxchg(&css->refcnt, refcnt, 0) != refcnt);

This loop also should have a cpu_relax(), I think?

> +	}
> + done:
> +	for_each_subsys(cgrp->root, ss) {
> +		struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
> +		if (failed) {
> +			/*
> +			 * Restore old refcnt if we previously managed
> +			 * to clear it from 1 to 0
> +			 */
> +			if (!atomic_read(&css->refcnt))
> +				atomic_set(&css->refcnt, 1);
> +		} else {
> +			/* Commit the fact that the CSS is removed */
> +			set_bit(CSS_REMOVED, &css->flags);
> +		}
> +	}
> +	local_irq_restore(flags);
> +	return !failed;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
