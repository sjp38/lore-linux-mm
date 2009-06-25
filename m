Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 219786B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 17:49:22 -0400 (EDT)
Date: Thu, 25 Jun 2009 14:50:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] memcg: cgroup fix rmdir hang
Message-Id: <20090625145044.37d6c56c.akpm@linux-foundation.org>
In-Reply-To: <20090623160854.93abeecb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090623160720.36230fa2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090623160854.93abeecb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jun 2009 16:08:54 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, cgroup has a logic to wait until ready-to-rmdir for avoiding
> frequent -EBUSY at rmdir.
>  (See Commit ec64f51545fffbc4cb968f0cea56341a4b07e85a
>   cgroup: fix frequent -EBUSY at rmdir.
> 
> Nishimura-san reported bad case for waiting and This is a fix to
> make it reliable. A thread waiting for thread cannot be waken up
> when a refcnt gotten by css_tryget() isn't put immediately.
> (Original code assumed css_put() will be called soon.)
> 
> memcg has this case and this is a fix for the problem. This adds
> retry_rmdir() callback to subsys and check we can sleep or not.
> 
> Note: another solution will be adding "rmdir state" to subsys.
> But it will be much complicated than this do-enough-check solution.
> 

A few issues..

Firstly, this code (both before and after the patch) looks like a
rather horrid hack.  

<ooh look, a comment!>

	/*
	 * css_put/get is provided for subsys to grab refcnt to css. In typical
	 * case, subsystem has no reference after pre_destroy(). But, under
	 * hierarchy management, some *temporal* refcnt can be hold.
	 * To avoid returning -EBUSY to a user, waitqueue is used. If subsys
	 * is really busy, it should return -EBUSY at pre_destroy(). wake_up
	 * is called when css_put() is called and refcnt goes down to 0.
	 */

(The correct word here is "temporary").

Where and under what circumstances is this temporary reference taken? 
Is there any way in which we can fix all this properly, so that the
directory removal will happen deterministically, without needing the
in-kernel polling loop?

ie: refcounting?

(I have a vague feeling that I've asked all this before.  But that's OK
- the code's still horrid ;))


> Index: fix-rmdir-cgroup/include/linux/cgroup.h
> ===================================================================
> --- fix-rmdir-cgroup.orig/include/linux/cgroup.h
> +++ fix-rmdir-cgroup/include/linux/cgroup.h
> @@ -374,6 +374,7 @@ struct cgroup_subsys {
>  	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
>  						  struct cgroup *cgrp);
>  	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
> +	int (*retry_rmdir)(struct cgroup_subsys *ss, struct cgroup *cgrp);

This is poorly named.  The reader will expect that a function called
"retry_rmdir" will, umm, retry an rmdir.

But this function doesn't do that.  It's a predicate which the caller
will use to determine whether the caller should retry the rmdir.

A better name would be should_retry_rmdir(), for example.

But even that isn't very good, because "should_retry_rmdir()" implies
that the caller will only use this function for a single purpose.  The
callee shouldn't assume this!

So can we come up with a name which accurately reflects what the
function actually does?  Like "has_remaining_references()", or somesuch?

Also, making the return value `bool' would have come clarification
benefits.

>  	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	int (*can_attach)(struct cgroup_subsys *ss,
>  			  struct cgroup *cgrp, struct task_struct *tsk);
> Index: fix-rmdir-cgroup/kernel/cgroup.c
> ===================================================================
> --- fix-rmdir-cgroup.orig/kernel/cgroup.c
> +++ fix-rmdir-cgroup/kernel/cgroup.c
> @@ -636,6 +636,23 @@ static int cgroup_call_pre_destroy(struc
>  		}
>  	return ret;
>  }
> +/*
> + * Call subsys's retry_rmdir() handler. If this returns non-Zero, we retry
> + * rmdir immediately and call pre_destroy again.
> + */
> +static int cgroup_check_retry_rmdir(struct cgroup *cgrp)
> +{
> +	struct cgroup_subsys *ss;
> +	int ret = 0;
> +
> +	for_each_subsys(cgrp->root, ss)
> +		if (ss->pre_destroy) {
> +			ret = ss->retry_rmdir(ss, cgrp);
> +			if (ret)
> +				break;
> +		}
> +	return ret;
> +}

There's an important and subtle precondition for this function: it is
called in state TASK_INTERRUPTIBLE.  This means that the ->retry_rmdir
handler must be careful to not disturb that state.  For if that
function were to accidentally enter state TASK_RUNNING (say, it does a
mutex_lock/unlock) then the kernel could enter a busy loop and would use
lots of CPU time.  I guess that code comments are sufficient to cover
this.  It's a property of ->retry_rmdir, really.

Also, what sense does it make to call ->retry_rmdir() if ->pre_destroy
is non-NULL?  Was that actually intentional?  If so, it is strange to link
those two fields in this way.  The retry_rmdir() documentation didn't describe
this.

>  static void free_cgroup_rcu(struct rcu_head *obj)
>  {
> @@ -2722,7 +2739,8 @@ again:
>  
>  	if (!cgroup_clear_css_refs(cgrp)) {
>  		mutex_unlock(&cgroup_mutex);
> -		schedule();
> +		if (!cgroup_check_retry_rmdir(cgrp))
> +			schedule();
>  		finish_wait(&cgroup_rmdir_waitq, &wait);
>  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  		if (signal_pending(current))
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
