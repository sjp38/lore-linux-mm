Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AC0CE6B0044
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 05:33:57 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0LAXtLI004909
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 21 Jan 2009 19:33:55 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D7DEF45DE5A
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:33:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 62C7045DE51
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:33:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 438841DB8040
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:33:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D8F101DB8060
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 19:33:52 +0900 (JST)
Date: Wed, 21 Jan 2009 19:32:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir v2
Message-Id: <20090121193248.94aecb10.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830901210200q77b2553ag35f706c321a18d83@mail.gmail.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
	<20090114120044.2ecf13db.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901131905ie10e4bl5168ab7f337b27e1@mail.gmail.com>
	<20090114121205.1bb913aa.kamezawa.hiroyu@jp.fujitsu.com>
	<20090120194735.cc52c5e0.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830901210200q77b2553ag35f706c321a18d83@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jan 2009 02:00:56 -0800
Paul Menage <menage@google.com> wrote:

> On Tue, Jan 20, 2009 at 2:47 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >        CGRP_NOTIFY_ON_RELEASE,
> > +       /* Someone calls rmdir() and is wating for this cgroup is released */
> 
> /* A thread is in rmdir() waiting to destroy this cgroup */
> 
> Also document that it can only be set/cleared when you're holding the
> inode_sem for the cgroup directory. And we should probably move this
> enum inside cgroup.c, since nothing in the header file uses it.
> 
> > +       CGRP_WAIT_ON_RMDIR,
> >  };

Hmm, ok. move this all enum to cgroup.c ?


> 
> >
> >  struct cgroup {
> > @@ -350,7 +352,7 @@ int cgroup_is_descendant(const struct cg
> >  struct cgroup_subsys {
> >        struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
> >                                                  struct cgroup *cgrp);
> > -       void (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
> > +       int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
> 
> Can you update the documentation to indicate what an error result from
> pre_destroy indicates? Can pre_destroy() be called multiple times for
> the same subsystem/cgroup?
> 

yes, after this, memcg will return -EBUSY in some special cases.
(patches are on my stack.)
We'll have -EBUSY situation especially on swap-less system.



> > +
> > +       /* wake up rmdir() waiter....it should fail.*/
> 
> /* Wake up rmdir() waiter - the rmdir should fail since the cgroup is
> no longer empty */
> 
> But is this safe? If we do a pre-destroy, is it OK to let new tasks
> into the cgroup?
> 
Current memcg allows it. (so, I removed "obsolete" flag in memcg and asked
you to add css_tryget().)



> > @@ -2446,6 +2461,8 @@ static long cgroup_create(struct cgroup
> >
> >        mutex_unlock(&cgroup_mutex);
> >        mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
> > +       if (wakeup_on_rmdir(parent))
> > +               cgroup_rmdir_wakeup_waiters();
> 
> I don't think that there can be a waiter, since rmdir() would hold the
> parent's inode semaphore, which would block this thread before it gets
> to cgroup_create()
> 
Oh, I see. I missed that. I'll remove this.


> > +DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
> > +
> > +static void cgroup_rmdir_wakeup_waiters(void)
> > +{
> > +       wake_up_all(&cgroup_rmdir_waitq);
> > +}
> > +
> 
> I think you can merge wakeup_on_rmdir() and
> cgroup_rmdir_wakeup_waiters() into a single function,
> cgroup_wakeup_rmdir(struct cgroup *)
> 
will try.


> 
> >
> > +       if (signal_pending(current))
> > +               return -EINTR;
> 
> I think it would be better to move this check to after we've already
> failed on cgroup_clear_css_refs(). That way we can't fail with an
> EINTR just because we raced with a signal on the way into rmdir() - we
> have to actually hit the EBUSY and try to sleep.

Ok, will move.


> > +       ret = cgroup_call_pre_destroy(cgrp);
> > +       if (ret == -EBUSY)
> > +               return -EBUSY;
> 
> What about other potential error codes? If the subsystem's only
> allowed to return 0 or EBUSY, then we should check for that.
> 

Hmm, subsystem may return -EPERM or some..
I'll change this to

 if (!ret)
    return ret;

Thank you for review. very helpful.
I'll consider more.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
