Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A26FE6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 18:51:16 -0500 (EST)
Date: Wed, 11 Nov 2009 08:44:35 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 2/8] memcg: move memcg_tasklist mutex
Message-Id: <20091111084435.4686ba4f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091110191423.GD3314@balbir.in.ibm.com>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091106141149.9c7e94d5.nishimura@mxp.nes.nec.co.jp>
	<20091110191423.GD3314@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009 00:44:23 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-06 14:11:49]:
> 
> > memcg_tasklist was introduced to serialize mem_cgroup_out_of_memory() and
> > mem_cgroup_move_task() to ensure tasks cannot be moved to another cgroup
> > during select_bad_process().
> > 
> > task_in_mem_cgroup(), which can be called by select_bad_process(), will check
> > whether a task is in the mem_cgroup or not by dereferencing task->cgroups
> > ->subsys[]. So, it would be desirable to change task->cgroups
> > (rcu_assign_pointer() in cgroup_attach_task() does it) with memcg_tasklist held.
> > 
> > Now that we can define cancel_attach(), we can safely release memcg_tasklist
> > on fail path even if we hold memcg_tasklist in can_attach(). So let's move
> > mutex_lock/unlock() of memcg_tasklist.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |   22 ++++++++++++++++++++--
> >  1 files changed, 20 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 4bd3451..d3b2ac0 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3395,18 +3395,34 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
> >  	return ret;
> >  }
> > 
> > +static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> > +				struct cgroup *cgroup,
> > +				struct task_struct *p,
> > +				bool threadgroup)
> > +{
> > +	mutex_lock(&memcg_tasklist);
> > +	return 0;
> > +}
> > +
> > +static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> > +				struct cgroup *cgroup,
> > +				struct task_struct *p,
> > +				bool threadgroup)
> > +{
> > +	mutex_unlock(&memcg_tasklist);
> > +}
> > +
> >  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
> >  				struct cgroup *cont,
> >  				struct cgroup *old_cont,
> >  				struct task_struct *p,
> >  				bool threadgroup)
> >  {
> > -	mutex_lock(&memcg_tasklist);
> > +	mutex_unlock(&memcg_tasklist);
> 
> What does this mean for nesting? I think the API's are called with
> cgroup_mutex held, so memcg_tasklist nests under cgroup_mutex right?
Yes.

> Could you please document that at the mutex declaration point.
I'm going to remove this mutex completely. It's no use as I said
in another mail(http://marc.info/?l=linux-mm&m=125749423314702&w=2).

> Shouldn't you be removing the FIXME as well?
> 
I remove this FIXME comment in [5/8] :)
This patch itself has nothing to do with this recharge feature.


Thanks,
Daisuke Nishimura.

> >  	/*
> >  	 * FIXME: It's better to move charges of this process from old
> >  	 * memcg to new memcg. But it's just on TODO-List now.
> >  	 */
> > -	mutex_unlock(&memcg_tasklist);
> >  }
> > 
> >  struct cgroup_subsys mem_cgroup_subsys = {
> > @@ -3416,6 +3432,8 @@ struct cgroup_subsys mem_cgroup_subsys = {
> >  	.pre_destroy = mem_cgroup_pre_destroy,
> >  	.destroy = mem_cgroup_destroy,
> >  	.populate = mem_cgroup_populate,
> > +	.can_attach = mem_cgroup_can_attach,
> > +	.cancel_attach = mem_cgroup_cancel_attach,
> >  	.attach = mem_cgroup_move_task,
> >  	.early_init = 0,
> >  	.use_id = 1,
> > -- 
> > 1.5.6.1
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> 	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
