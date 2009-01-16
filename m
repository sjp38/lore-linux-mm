Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1E1DC6B0055
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 20:59:37 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G1xYcH029192
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 10:59:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A21445DE5C
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 10:59:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 429C445DE53
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 10:59:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ED4C1E08004
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 10:59:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D5C81DB803C
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 10:59:32 +0900 (JST)
Date: Fri, 16 Jan 2009 10:58:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] memcg: hierarchical reclaim by CSS ID
Message-Id: <20090116105828.392044ce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <496FE791.9030208@cn.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115192943.7c1df53a.kamezawa.hiroyu@jp.fujitsu.com>
	<496FE30C.1090300@cn.fujitsu.com>
	<20090116103810.5ef55cc3.kamezawa.hiroyu@jp.fujitsu.com>
	<496FE791.9030208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 09:49:05 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Fri, 16 Jan 2009 09:29:48 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> >>>  /*
> >>> - * Dance down the hierarchy if needed to reclaim memory. We remember the
> >>> - * last child we reclaimed from, so that we don't end up penalizing
> >>> - * one child extensively based on its position in the children list.
> >>> + * Visit the first child (need not be the first child as per the ordering
> >>> + * of the cgroup list, since we track last_scanned_child) of @mem and use
> >>> + * that to reclaim free pages from.
> >>> + */
> >>> +static struct mem_cgroup *
> >>> +mem_cgroup_select_victim(struct mem_cgroup *root_mem)
> >>> +{
> >>> +	struct mem_cgroup *ret = NULL;
> >>> +	struct cgroup_subsys_state *css;
> >>> +	int nextid, found;
> >>> +
> >>> +	if (!root_mem->use_hierarchy) {
> >>> +		spin_lock(&root_mem->reclaim_param_lock);
> >>> +		root_mem->scan_age++;
> >>> +		spin_unlock(&root_mem->reclaim_param_lock);
> >>> +		css_get(&root_mem->css);
> >>> +		ret = root_mem;
> >>> +	}
> >>> +
> >>> +	while (!ret) {
> >>> +		rcu_read_lock();
> >>> +		nextid = root_mem->last_scanned_child + 1;
> >>> +		css = css_get_next(&mem_cgroup_subsys, nextid, &root_mem->css,
> >>> +				   &found);
> >>> +		if (css && css_is_populated(css) && css_tryget(css))
> >> I don't see why you need to check css_is_populated(css) ?
> >>
> > 
> > Main reason is for sanity. I don't like to hold css->refcnt of not populated css.
> 
> I think this is a rare case. It's just a very short period when a cgroup is
> being created but not yet fully created.
> 
I don't think so. When the cgroup is mounted with several subsystems, it can call
create() and populate() several times. So, memory allocation occurs between
create() and populate(), it can call try_to_free_page() (of global LRU). More than
that, if CONFIG_PREEMPT=y, any "short" race doesn't mean safe.



Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
