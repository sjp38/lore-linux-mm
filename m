Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 98FCC6B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 02:39:06 -0400 (EDT)
Date: Tue, 16 Jun 2009 15:38:10 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-Id: <20090616153810.fd710c5b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090616140050.4172f988.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
	<20090612151924.2d305ce8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090615115021.c79444cb.nishimura@mxp.nes.nec.co.jp>
	<20090615120213.e9a3bd1d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090615171715.53743dce.kamezawa.hiroyu@jp.fujitsu.com>
	<20090616114735.c7a91b8b.nishimura@mxp.nes.nec.co.jp>
	<20090616140050.4172f988.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jun 2009 14:00:50 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 16 Jun 2009 11:47:35 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Mon, 15 Jun 2009 17:17:15 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Mon, 15 Jun 2009 12:02:13 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > I don't like implict resource move. I'll try some today. plz see it.
> > > > _But_ this case just happens when swap is shared between cgroups and _very_ heavy
> > > > swap-in continues very long. I don't think this is a fatal and BUG.
> > > > 
> > > > But ok, maybe wake-up path is not enough.
> > > > 
> > > Here.
> > > Anyway, there is an unfortunate complexity in cgroup's rmdir() path.
> > > I think this will remove all concern in
> > > 	pre_destroy -> check -> start rmdir path
> > > if subsys is aware of what they does.
> > > Usual subsys just consider "tasks" and no extra references I hope.
> > > If your test result is good, I'll post again (after merge window ?).
> > > 
> > Thank you for your patch.
> > 
> > At first, I thought this problem can be solved by this direction, but
> > there is a race window yet.
> > 
> > The root cause of this problem is that mem.usage can be incremented
> > by swap-in behavior of memcg even after it has become 0 once.
> > So, mem.usage can also be incremented between cgroup_need_restart_rmdir()
> > and schedule().
> > I can see rmdir being locked up actually in my test.
> > 
> > hmm, sleeping until being waken up might not be good if we don't change
> > swap-in behavior of memcg in some way.
> > 
> Or, invalidate all refs from swap_cgroup in force_empty().
> Fixed one is attached.
> 
> Why I don't like "charge to current process" at swap-in is that a user cannot
> expect how the resource usage will change. It will be random.
> 
> In this meaning, I wanted to set "owner" of file-caches. But file-caches are
> used in more explict way than swap and the user can be aware of the usage
> easier than swap cache.(and files are expected to be shared in its nature.)
> 
> The patch itself will require some more work.
> What I feel difficut in cgroup's rmdir() is
> ==
> 	pre_destroy();   => pre_destroy() reduces css's refcnt to be 0.
> 	CGROUP_WAIT_ON_RMDIR is set
> 	if (check css's refcnt again)
> 	{
> 		sleep and retry
> 	}
> ==
> css_tryget() check CSS_IS_REMOVED but CSS_IS_REMOVED is set only when
> css->refcnt goes down to be 0. Hmm.
> 
> I think my patch itself is not so bad. But the scheme is dirty in general.
> 
> Thanks,
> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good except for:

> @@ -374,6 +385,7 @@ struct cgroup_subsys {
>  	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
>  						  struct cgroup *cgrp);
>  	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
> +	int (*rmdir_retry)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	int (*can_attach)(struct cgroup_subsys *ss,
>  			  struct cgroup *cgrp, struct task_struct *tsk);
s/rmdir_retry/retry_rmdir

It has been working well so far, but I will continue to test for more long time.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
