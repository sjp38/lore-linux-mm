Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 402316B01B6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 20:47:11 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o520l7Uj026003
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 2 Jun 2010 09:47:08 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8656245DE70
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:47:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CE8145DE4D
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:47:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 176991DB803E
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:47:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C71BD1DB803A
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:47:06 +0900 (JST)
Date: Wed, 2 Jun 2010 09:42:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][1/3] memcg clean up try charge
Message-Id: <20100602094253.1ca5f3f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100601113658.GF2804@balbir.in.ibm.com>
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
	<20100601113658.GF2804@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010 17:06:58 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-01 18:24:06]:
> >    why we retry or quit by return code.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |  244 +++++++++++++++++++++++++++++++++-----------------------
> >  1 file changed, 145 insertions(+), 99 deletions(-)
> > 
> > Index: mmotm-2.6.34-May21/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.34-May21.orig/mm/memcontrol.c
> > +++ mmotm-2.6.34-May21/mm/memcontrol.c
> > @@ -1072,6 +1072,49 @@ static unsigned int get_swappiness(struc
> >  	return swappiness;
> >  }
> > 
> > +/* A routine for testing mem is not under move_account */
> > +
> > +static bool mem_cgroup_under_move(struct mem_cgroup *mem)
> > +{
> > +	struct mem_cgroup *from = mc.from;
> > +	struct mem_cgroup *to = mc.to;
> > +	bool ret = false;
> > +
> > +	if (from == mem || to == mem)
> > +		return true;
> > +
> > +	if (!from || !to || !mem->use_hierarchy)
> > +		return false;
> > +
> > +	rcu_read_lock();
> > +	if (css_tryget(&from->css)) {
> > +		ret = css_is_ancestor(&from->css, &mem->css);
> > +		css_put(&from->css);
> > +	}
> > +	if (!ret && css_tryget(&to->css)) {
> > +		ret = css_is_ancestor(&to->css,	&mem->css);
> > +		css_put(&to->css);
> > +	}
> > +	rcu_read_unlock();
> > +	return ret;
> > +}
> > +
> > +static bool mem_cgroup_wait_acct_move(struct mem_cgroup *mem)
> > +{
> > +	if (mc.moving_task && current != mc.moving_task) {
> > +		if (mem_cgroup_under_move(mem)) {
> > +			DEFINE_WAIT(wait);
> > +			prepare_to_wait(&mc.waitq, &wait, TASK_INTERRUPTIBLE);
> > +			/* moving charge context might have finished. */
> > +			if (mc.moving_task)
> > +				schedule();
> 
> If we sleep with TASK_INTERRUPTIBLE, we should also check for
> signal_pending() at the end of the schedule and handle it
> appropriately to cancel the operation. 
> 
Hmm. yes. and if signal is a fatal one, we can use "bypass" root.

> Looks good to me otherwise.

Thank you.

Regards,
-Kame
> 

> 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
