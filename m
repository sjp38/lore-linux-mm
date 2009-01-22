Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 903C76B0093
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 22:00:19 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0M30Ewt026741
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jan 2009 12:00:14 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 86E4C45DE52
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 12:00:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C53D45DE4F
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 12:00:14 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 15194E38004
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 12:00:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 511E3E38008
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 12:00:13 +0900 (JST)
Date: Thu, 22 Jan 2009 11:59:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] cgroup: add CSS ID
Message-Id: <20090122115908.262f2440.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090122113729.878e96cf.nishimura@mxp.nes.nec.co.jp>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192522.0130e550.kamezawa.hiroyu@jp.fujitsu.com>
	<20090122113729.878e96cf.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jan 2009 11:37:29 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> Sorry for very late reply.
> 
> It looks good in general.
> Just a few comments.
> 
> > +/**
> > + * css_lookup - lookup css by id
> > + * @ss: cgroup subsys to be looked into.
> > + * @id: the id
> > + *
> > + * Returns pointer to cgroup_subsys_state if there is valid one with id.
> > + * NULL if not. Should be called under rcu_read_lock()
> > + */
> > +struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
> > +{
> > +	struct css_id *cssid = NULL;
> > +
> > +	BUG_ON(!ss->use_id);
> > +	cssid = idr_find(&ss->idr, id);
> > +
> > +	if (unlikely(!cssid))
> > +		return NULL;
> > +
> > +	return rcu_dereference(cssid->css);
> > +}
> > +
> Just for clarification, is there any user of this function ?
> (I agree it's natulal to define 'lookup' function, though.)
> 
A user in my plan is swap_cgroup.



> > +/**
> > + * css_get_next - lookup next cgroup under specified hierarchy.
> > + * @ss: pointer to subsystem
> > + * @id: current position of iteration.
> > + * @root: pointer to css. search tree under this.
> > + * @foundid: position of found object.
> > + *
> > + * Search next css under the specified hierarchy of rootid. Calling under
> > + * rcu_read_lock() is necessary. Returns NULL if it reaches the end.
> > + */
> > +struct cgroup_subsys_state *
> > +css_get_next(struct cgroup_subsys *ss, int id,
> > +	     struct cgroup_subsys_state *root, int *foundid)
> > +{
> > +	struct cgroup_subsys_state *ret = NULL;
> > +	struct css_id *tmp;
> > +	int tmpid;
> > +	int rootid = css_id(root);
> > +	int depth = css_depth(root);
> > +
> I think it's safe here, but isn't it better to call css_id/css_depth
> under rcu_read_lock(they call rcu_dereference) ?
> 
As commented, this css_get_next() call should be called under rcu_read_lock().


> > +	if (!rootid)
> > +		return NULL;
> > +
> > +	BUG_ON(!ss->use_id);
> > +	rcu_read_lock();
> > +	/* fill start point for scan */
> > +	tmpid = id;
> > +	while (1) {
> > +		/*
> > +		 * scan next entry from bitmap(tree), tmpid is updated after
> > +		 * idr_get_next().
> > +		 */
> > +		spin_lock(&ss->id_lock);
> > +		tmp = idr_get_next(&ss->idr, &tmpid);
> > +		spin_unlock(&ss->id_lock);
> > +
> > +		if (!tmp)
> > +			break;
> > +		if (tmp->depth >= depth && tmp->stack[depth] == rootid) {
> Can't be css_is_ancestor used here ?
> I think it would be more easy to understand.
> 
Hmm, it requires 

	css_is_ancestor(tmp->css, root);

and adds memory barriers to acsess tmp->css and tmp->css->id, root->id
(compiler will not optimize these accesses because of memory barrier.)

So, I think bare code is better here.

Thank you for review.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
