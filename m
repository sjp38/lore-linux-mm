Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EC54E6B0082
	for <linux-mm@kvack.org>; Wed, 21 Jan 2009 21:42:09 -0500 (EST)
Date: Thu, 22 Jan 2009 11:37:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 1/4] cgroup: add CSS ID
Message-Id: <20090122113729.878e96cf.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090115192522.0130e550.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192522.0130e550.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi.

Sorry for very late reply.

It looks good in general.
Just a few comments.

> +/**
> + * css_lookup - lookup css by id
> + * @ss: cgroup subsys to be looked into.
> + * @id: the id
> + *
> + * Returns pointer to cgroup_subsys_state if there is valid one with id.
> + * NULL if not. Should be called under rcu_read_lock()
> + */
> +struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
> +{
> +	struct css_id *cssid = NULL;
> +
> +	BUG_ON(!ss->use_id);
> +	cssid = idr_find(&ss->idr, id);
> +
> +	if (unlikely(!cssid))
> +		return NULL;
> +
> +	return rcu_dereference(cssid->css);
> +}
> +
Just for clarification, is there any user of this function ?
(I agree it's natulal to define 'lookup' function, though.)

> +/**
> + * css_get_next - lookup next cgroup under specified hierarchy.
> + * @ss: pointer to subsystem
> + * @id: current position of iteration.
> + * @root: pointer to css. search tree under this.
> + * @foundid: position of found object.
> + *
> + * Search next css under the specified hierarchy of rootid. Calling under
> + * rcu_read_lock() is necessary. Returns NULL if it reaches the end.
> + */
> +struct cgroup_subsys_state *
> +css_get_next(struct cgroup_subsys *ss, int id,
> +	     struct cgroup_subsys_state *root, int *foundid)
> +{
> +	struct cgroup_subsys_state *ret = NULL;
> +	struct css_id *tmp;
> +	int tmpid;
> +	int rootid = css_id(root);
> +	int depth = css_depth(root);
> +
I think it's safe here, but isn't it better to call css_id/css_depth
under rcu_read_lock(they call rcu_dereference) ?

> +	if (!rootid)
> +		return NULL;
> +
> +	BUG_ON(!ss->use_id);
> +	rcu_read_lock();
> +	/* fill start point for scan */
> +	tmpid = id;
> +	while (1) {
> +		/*
> +		 * scan next entry from bitmap(tree), tmpid is updated after
> +		 * idr_get_next().
> +		 */
> +		spin_lock(&ss->id_lock);
> +		tmp = idr_get_next(&ss->idr, &tmpid);
> +		spin_unlock(&ss->id_lock);
> +
> +		if (!tmp)
> +			break;
> +		if (tmp->depth >= depth && tmp->stack[depth] == rootid) {
Can't be css_is_ancestor used here ?
I think it would be more easy to understand.

> +			ret = rcu_dereference(tmp->css);
> +			if (ret) {
> +				*foundid = tmpid;
> +				break;
> +			}
> +		}
> +		/* continue to scan from next id */
> +		tmpid = tmpid + 1;
> +	}
> +
> +	rcu_read_unlock();
> +	return ret;
> +}
> +


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
