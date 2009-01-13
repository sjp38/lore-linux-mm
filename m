Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B0D6E6B005C
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 04:26:47 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0D9QjRK022266
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Jan 2009 18:26:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4176945DE50
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:26:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 23E2145DE4F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:26:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 104D71DB8038
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:26:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C2DB91DB803C
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:26:44 +0900 (JST)
Date: Tue, 13 Jan 2009 18:25:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/4] memcg: fix OOM KILL under hierarchy
Message-Id: <20090113182542.004556aa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <496C51C8.5040900@cn.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108183207.26d88794.kamezawa.hiroyu@jp.fujitsu.com>
	<496C51C8.5040900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jan 2009 16:33:12 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > -int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
> > +static int
> > +mm_match_cgroup_hierarchy(struct mm_struct *mm, struct mem_cgroup *mem)
> > +{
> > +	struct mem_cgroup *curr;
> > +	int ret;
> > +
> > +	if (!mm)
> > +		return 0;
> > +	rcu_read_lock();
> > +	curr = mem_cgroup_from_task(mm->owner);
> 
> curr can be NULL ?
> 
Good Catch! You're right.

> > +	if (mem->use_hierarchy)
> > +		ret = css_is_ancestor(&curr->css, &mem->css);
> > +	else
> > +		ret = (curr == mem);
> > +	rcu_read_unlock();
> > +	return ret;
> > +}
> > +
> 
> ...
> 
> > +void mem_cgroup_update_oom_jiffies(struct mem_cgroup *mem)
> > +{
> > +	struct mem_cgroup *cur;
> > +	struct cgroup_subsys_state *css;
> > +	int id, found;
> > +
> > +	if (!mem->use_hierarchy) {
> > +		mem->last_oom_jiffies = jiffies;
> > +		return;
> > +	}
> > +
> > +	id = 0;
> > +	rcu_read_lock();
> > +	while (1) {
> > +		css = css_get_next(&mem_cgroup_subsys, id, &mem->css, &found);
> > +		if (!css)
> > +			break;
> > +		if (css_tryget(css)) {
> > +			cur = container_of(css, struct mem_cgroup, css);
> > +			cur->last_oom_jiffies = jiffies;
> > +			css_put(css);
> > +		}
> > +		id = found + 1;
> > +	}
> > +	rcu_read_unlock();
> > +	return;
> 
> redundant "return"
> 
ok, will remove it.

Thank you.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
