Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 635E66B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 21:52:18 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id to1so7802345ieb.37
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 18:52:18 -0700 (PDT)
Received: by mail-qc0-f174.google.com with SMTP id n9so2664672qcw.5
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 18:52:14 -0700 (PDT)
Date: Mon, 23 Sep 2013 21:52:11 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v6 0/5] memcg, cgroup: kill css id
Message-ID: <20130924015211.GD3482@htj.dyndns.org>
References: <524001F8.6070205@huawei.com>
 <20130923130816.GH30946@htj.dyndns.org>
 <20130923131215.GI30946@htj.dyndns.org>
 <5240DD83.1070509@huawei.com>
 <20130923175247.ea5156de.akpm@linux-foundation.org>
 <20130924013058.GB3482@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924013058.GB3482@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

(cc'ing Stephen, hi!)

On Mon, Sep 23, 2013 at 09:30:58PM -0400, Tejun Heo wrote:
> Hello, Andrew.
> 
> On Mon, Sep 23, 2013 at 05:52:47PM -0700, Andrew Morton wrote:
> > > I would love to see this patchset go through cgroup tree. The changes to
> > > memcg is quite small,
> > 
> > It seems logical to put this in the cgroup tree as that's where most of
> > the impact occurs.
> 
> Cool, applying the changes to cgroup/for-3.13.

Stephen, Andrew, cgroup/for-3.13 will cause a minor conflict in
mm/memcontrol.c with the patch which reverts Michal's reclaim changes.

  static void __mem_cgroup_free(struct mem_cgroup *memcg)
  {
	  int node;
	  size_t size = memcg_size();

  <<<<<<< HEAD
  =======
	  mem_cgroup_remove_from_trees(memcg);
	  free_css_id(&mem_cgroup_subsys, &memcg->css);

  >>>>>>> 1fa8f71dfa6e28c89afad7ac71dcb19b8c8da8b7
	  for_each_node(node)
		  free_mem_cgroup_per_zone_info(memcg, node);

It's a context conflict and just removing free_css_id() call resolves
it.

  static void __mem_cgroup_free(struct mem_cgroup *memcg)
  {
	  int node;
	  size_t size = memcg_size();

	  mem_cgroup_remove_from_trees(memcg);

	  for_each_node(node)
		  free_mem_cgroup_per_zone_info(memcg, node);

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
