Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAD4Ikne030783
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 13:18:47 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 78DC145DD80
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 13:18:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4323445DD7C
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 13:18:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 266D31DB803E
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 13:18:46 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A59D31DB8037
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 13:18:45 +0900 (JST)
Date: Thu, 13 Nov 2008 13:18:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v3)
Message-Id: <20081113131807.b2f22261.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112112141.GA25386@balbir.in.ibm.com>
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop>
	<20081111123417.6566.52629.sendpatchset@balbir-laptop>
	<20081112140236.46448b47.kamezawa.hiroyu@jp.fujitsu.com>
	<491A6E71.5010307@linux.vnet.ibm.com>
	<20081112150126.46ac6042.kamezawa.hiroyu@jp.fujitsu.com>
	<491A7345.4090500@linux.vnet.ibm.com>
	<20081112151233.0ec8dc44.kamezawa.hiroyu@jp.fujitsu.com>
	<491A7637.3050402@linux.vnet.ibm.com>
	<20081112153314.a7162192.kamezawa.hiroyu@jp.fujitsu.com>
	<20081112112141.GA25386@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 16:51:41 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:


> Here is the iterative version of this patch. I tested it in my
> test environment. NOTE: The cgroup_locked check is still present, I'll
> remove that shortly after your patch is accepted.
> 
> This patch introduces hierarchical reclaim. When an ancestor goes over its
> limit, the charging routine points to the parent that is above its limit.
> The reclaim process then starts from the last scanned child of the ancestor
> and reclaims until the ancestor goes below its limit.
> 

complicated as you said but it seems it's from style.

I expected following kind of one.
==

struct mem_cgroup *memcg_select_next_token(struct mem_cgroup *itr,
					struct mem_cgroup *cur,
					struct mem_cgroup *root)
{
	struct cgroup *pos, *tmp, *parent, *rootpos;

	cgroup_lock();
	if (!itr || itr->obsolete)
		itr = cur;

	rootpos = root->css.cgroup;
	pos = itr->css.cgroup;
	parent = pos->parent;
	/* start from children */
	if (!list_empty(&pos->children)) {
		pos = list_entry(pos->children.next, struct cgroup, sibling);
		mem_cgroup_put(itr);
		itr = mem_cgroup_from_cont(pos);
		mem_cgroup_get(itr);
		goto unlock;
	}
next_parent:
	if (pos == rootpos) {
		/* I'm root and no available children */
		mem_cgroup_put(itr);
		itr = mem_cgroup_from_cont(pos);
		mem_cgroup_get(itr);
		goto unlock;
	}
	/* Do I have next siblings ? */
	if (pos->sibling.next != &parent->children) {
		pos = list_entry(pos->sibling.next, struct cgroup, sibling);
		mem_cgroup_put(itr);
		itr = mem_cgroup_from_cont(pos);
		mem_cgroup_get(itr);
		goto unlock;
	}
	/* Ok, go back to parent */
	pos = pos->parent;
	goto next_parent;
	
unlock:
	root->reclaim_token = token;
	cgroup_unlock();
	return itr;
}

struct mem_cgroup *memcg_select_start_token(struct mem_cgroup *cur,
					    struct mem_cgroup *root)
{
	struct mem_cgroup *token;

	if (cur == root)
		return cur;

	cgroup_lock();

	token = root->reclaim_token;
	if (token->obsolete) {
		mem_cgroup_put(token);  /* decrease refcnt */
		root->reclaim_token = cur;
		token = cur;
		mem_cgroup_get(cur);	/* increase refcnt */
		cgroup_unlock();
		return token;
	}
	cgroup_unlock();
	
	return memcg_select_next_token(token, cur, root);
}


int mem_cgroup_do_reclaim(struct mem_cgroup *mem,
			  struct mem_cgroup *root_mem,
			  gfp_t mask)
{
	struct cgroup *cgroup;
	struct mem_cgroup *tmp, *token, *start;
	/*
	 * We do memory reclaim under "root_mem".
	 * We have to be careful not to reclaim memory only from
	 * unlucky one. For avoiding that, we use "token".
	 */

	token = memcg_select_start_token(mem, root_mem);

	start = NULL;

	while (start != token) {
		if (!token->obsolete) {
			ret = try_to_free_mem_cgroup_pages(token,
						GFP_HIGHUSER_MOVABLE);
			if (!res_counter_check_under_limit(&root_mem->res))
				return 0;
			if (ret == 0)
				retry--;
			start = token;
			token = memcg_select_next_token(token, mem, root_mem);
		} else {
			/* This mem_cgroup is destroyed. */
			mem_cgroup_put(token);
			token = memcg_select_next_token(NULL, mem, root_mem);
		}
	}
	
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
