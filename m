Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2DB6B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 05:01:02 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id n0LA10cS026717
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 02:01:00 -0800
Received: from rv-out-0506.google.com (rvfb25.prod.google.com [10.140.179.25])
	by wpaz24.hot.corp.google.com with ESMTP id n0LA0uxt002411
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 02:00:57 -0800
Received: by rv-out-0506.google.com with SMTP id b25so3920290rvf.45
        for <linux-mm@kvack.org>; Wed, 21 Jan 2009 02:00:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090120194735.cc52c5e0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
	 <20090114120044.2ecf13db.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901131905ie10e4bl5168ab7f337b27e1@mail.gmail.com>
	 <20090114121205.1bb913aa.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090120194735.cc52c5e0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 21 Jan 2009 02:00:56 -0800
Message-ID: <6599ad830901210200q77b2553ag35f706c321a18d83@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir v2
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 20, 2009 at 2:47 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>        CGRP_NOTIFY_ON_RELEASE,
> +       /* Someone calls rmdir() and is wating for this cgroup is released */

/* A thread is in rmdir() waiting to destroy this cgroup */

Also document that it can only be set/cleared when you're holding the
inode_sem for the cgroup directory. And we should probably move this
enum inside cgroup.c, since nothing in the header file uses it.

> +       CGRP_WAIT_ON_RMDIR,
>  };

>
>  struct cgroup {
> @@ -350,7 +352,7 @@ int cgroup_is_descendant(const struct cg
>  struct cgroup_subsys {
>        struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
>                                                  struct cgroup *cgrp);
> -       void (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
> +       int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);

Can you update the documentation to indicate what an error result from
pre_destroy indicates? Can pre_destroy() be called multiple times for
the same subsystem/cgroup?

> +
> +       /* wake up rmdir() waiter....it should fail.*/

/* Wake up rmdir() waiter - the rmdir should fail since the cgroup is
no longer empty */

But is this safe? If we do a pre-destroy, is it OK to let new tasks
into the cgroup?

> @@ -2446,6 +2461,8 @@ static long cgroup_create(struct cgroup
>
>        mutex_unlock(&cgroup_mutex);
>        mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
> +       if (wakeup_on_rmdir(parent))
> +               cgroup_rmdir_wakeup_waiters();

I don't think that there can be a waiter, since rmdir() would hold the
parent's inode semaphore, which would block this thread before it gets
to cgroup_create()

> +DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
> +
> +static void cgroup_rmdir_wakeup_waiters(void)
> +{
> +       wake_up_all(&cgroup_rmdir_waitq);
> +}
> +

I think you can merge wakeup_on_rmdir() and
cgroup_rmdir_wakeup_waiters() into a single function,
cgroup_wakeup_rmdir(struct cgroup *)


>
> +       if (signal_pending(current))
> +               return -EINTR;

I think it would be better to move this check to after we've already
failed on cgroup_clear_css_refs(). That way we can't fail with an
EINTR just because we raced with a signal on the way into rmdir() - we
have to actually hit the EBUSY and try to sleep.
> +       ret = cgroup_call_pre_destroy(cgrp);
> +       if (ret == -EBUSY)
> +               return -EBUSY;

What about other potential error codes? If the subsystem's only
allowed to return 0 or EBUSY, then we should check for that.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
