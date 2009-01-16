Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 046066B0055
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 20:39:19 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G1dH5J015921
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 10:39:17 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CE2F62AEA81
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 10:39:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E4F51EF084
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 10:39:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 168761DB805A
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 10:39:15 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 860B01DB803F
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 10:39:14 +0900 (JST)
Date: Fri, 16 Jan 2009 10:38:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] memcg: hierarchical reclaim by CSS ID
Message-Id: <20090116103810.5ef55cc3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <496FE30C.1090300@cn.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192943.7c1df53a.kamezawa.hiroyu@jp.fujitsu.com>
	<496FE30C.1090300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 09:29:48 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> >  /*
> > - * Dance down the hierarchy if needed to reclaim memory. We remember the
> > - * last child we reclaimed from, so that we don't end up penalizing
> > - * one child extensively based on its position in the children list.
> > + * Visit the first child (need not be the first child as per the ordering
> > + * of the cgroup list, since we track last_scanned_child) of @mem and use
> > + * that to reclaim free pages from.
> > + */
> > +static struct mem_cgroup *
> > +mem_cgroup_select_victim(struct mem_cgroup *root_mem)
> > +{
> > +	struct mem_cgroup *ret = NULL;
> > +	struct cgroup_subsys_state *css;
> > +	int nextid, found;
> > +
> > +	if (!root_mem->use_hierarchy) {
> > +		spin_lock(&root_mem->reclaim_param_lock);
> > +		root_mem->scan_age++;
> > +		spin_unlock(&root_mem->reclaim_param_lock);
> > +		css_get(&root_mem->css);
> > +		ret = root_mem;
> > +	}
> > +
> > +	while (!ret) {
> > +		rcu_read_lock();
> > +		nextid = root_mem->last_scanned_child + 1;
> > +		css = css_get_next(&mem_cgroup_subsys, nextid, &root_mem->css,
> > +				   &found);
> > +		if (css && css_is_populated(css) && css_tryget(css))
> 
> I don't see why you need to check css_is_populated(css) ?
> 

Main reason is for sanity. I don't like to hold css->refcnt of not populated css.
Second reason is for avoinding unnecessary calls to try_to_free_pages(),
it's heavy. I should also add mem->res.usage == 0 case for skipping but not yet.

THanks,
-Kame

> > +			ret = container_of(css, struct mem_cgroup, css);
> > +
> > +		rcu_read_unlock();
> > +		/* Updates scanning parameter */
> > +		spin_lock(&root_mem->reclaim_param_lock);
> > +		if (!css) {
> > +			/* this means start scan from ID:1 */
> > +			root_mem->last_scanned_child = 0;
> > +			root_mem->scan_age++;
> > +		} else
> > +			root_mem->last_scanned_child = found;
> > +		spin_unlock(&root_mem->reclaim_param_lock);
> > +	}
> > +
> > +	return ret;
> > +}
> > +
> 
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
