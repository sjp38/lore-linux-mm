Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 544176B009B
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 00:19:02 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBH5Kh0p004379
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Dec 2008 14:20:43 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 98FA145DE59
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:20:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 53F8845DD72
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:20:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 25F7F1DB803E
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:20:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B7F8D1DB8040
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 14:20:41 +0900 (JST)
Date: Wed, 17 Dec 2008 14:19:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] CGroups: Add css_tryget()
Message-Id: <20081217141946.2e969fa7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081216113653.252690000@menage.corp.google.com>
References: <20081216113055.713856000@menage.corp.google.com>
	<20081216113653.252690000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: menage@google.com
Cc: akpm@linux-foundation.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
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
> Signed-off-by: Paul Menage <menage@google.com>
> 
mkdir/rmdir works well. I'll write the user of this patch "css_tryget()" 
in memcg.

Tested-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  include/linux/cgroup.h |   38 +++++++++++++++++++++++++-----
>  kernel/cgroup.c        |   61 ++++++++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 88 insertions(+), 11 deletions(-)
> 
> Index: hierarchy_lock-mmotm-2008-12-09/include/linux/cgroup.h
> ===================================================================
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
>  
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
> +
>  /*
>   * css_put() should be called to release a reference taken by
> - * css_get()
> + * css_get() or css_tryget()
>   */
>  
>  extern void __css_put(struct cgroup_subsys_state *css);
> Index: hierarchy_lock-mmotm-2008-12-09/kernel/cgroup.c
> ===================================================================
> --- hierarchy_lock-mmotm-2008-12-09.orig/kernel/cgroup.c
> +++ hierarchy_lock-mmotm-2008-12-09/kernel/cgroup.c
> @@ -2321,7 +2321,7 @@ static void init_cgroup_css(struct cgrou
>  			       struct cgroup *cgrp)
>  {
>  	css->cgroup = cgrp;
> -	atomic_set(&css->refcnt, 0);
> +	atomic_set(&css->refcnt, 1);
>  	css->flags = 0;
>  	if (cgrp == dummytop)
>  		set_bit(CSS_ROOT, &css->flags);
> @@ -2453,7 +2453,7 @@ static int cgroup_has_css_refs(struct cg
>  {
>  	/* Check the reference count on each subsystem. Since we
>  	 * already established that there are no tasks in the
> -	 * cgroup, if the css refcount is also 0, then there should
> +	 * cgroup, if the css refcount is also 1, then there should
>  	 * be no outstanding references, so the subsystem is safe to
>  	 * destroy. We scan across all subsystems rather than using
>  	 * the per-hierarchy linked list of mounted subsystems since
> @@ -2474,12 +2474,62 @@ static int cgroup_has_css_refs(struct cg
>  		 * matter, since it can only happen if the cgroup
>  		 * has been deleted and hence no longer needs the
>  		 * release agent to be called anyway. */
> -		if (css && atomic_read(&css->refcnt))
> +		if (css && (atomic_read(&css->refcnt) > 1))
>  			return 1;
>  	}
>  	return 0;
>  }
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
> +
>  static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
>  {
>  	struct cgroup *cgrp = dentry->d_fsdata;
> @@ -2510,7 +2560,7 @@ static int cgroup_rmdir(struct inode *un
>  
>  	if (atomic_read(&cgrp->count)
>  	    || !list_empty(&cgrp->children)
> -	    || cgroup_has_css_refs(cgrp)) {
> +	    || !cgroup_clear_css_refs(cgrp)) {
>  		mutex_unlock(&cgroup_mutex);
>  		return -EBUSY;
>  	}
> @@ -3065,7 +3115,8 @@ void __css_put(struct cgroup_subsys_stat
>  {
>  	struct cgroup *cgrp = css->cgroup;
>  	rcu_read_lock();
> -	if (atomic_dec_and_test(&css->refcnt) && notify_on_release(cgrp)) {
> +	if ((atomic_dec_return(&css->refcnt) == 1) &&
> +	    notify_on_release(cgrp)) {
>  		set_bit(CGRP_RELEASABLE, &cgrp->flags);
>  		check_for_release(cgrp);
>  	}
> 
> --
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
